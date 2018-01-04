//
//  PacketTunnelProvider.m
//  NetAgencyPacketTunnel
//
//  Created by netease on 2018/1/3.
//  Copyright © 2018年 Luigi. All rights reserved.
//

#import "PacketTunnelProvider.h"


@interface PacketTunnelProvider ()
@property (nonatomic ,strong) NWTCPConnection *tcpConnection;
@end


@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
	// Add code here to start the process of connecting the tunnel.
    
    NSString *remoteAddress = @"104.20.82.194";
    NSString *remotePort = @"0";
    NSArray *matchDomains   = @[@"apkpure.com",@"a.apkpure.com",@"download.apkpure.com",@"m.apkpure.com",@"static.apkpure.com"];
    
    if (remoteAddress.length<1) {
        if (completionHandler) {
            completionHandler([self p_errorWithReason:@"configuration is missing sever address"]);
        }
        return;
    }
    
   
    NEIPv4Settings *ipv4Settings = [[NEIPv4Settings alloc]  initWithAddresses:@[remoteAddress] subnetMasks:@[@"255.255.255.0"]];
    ipv4Settings.includedRoutes =@[[NEIPv4Route defaultRoute]];
    
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc]  initWithTunnelRemoteAddress:remoteAddress];
    settings.IPv4Settings = ipv4Settings;
    settings.MTU = @(1600);
    
    NEProxySettings *proxySettings = [[NEProxySettings alloc]  init];
    NSString *proxyServerName = @"localhost";
    NSInteger proxyServerPort = 9000;
    proxySettings.HTTPEnabled = YES;
    proxySettings.HTTPServer = [[NEProxyServer alloc]  initWithAddress:proxyServerName port:proxyServerPort];
    
    proxySettings.HTTPSEnabled = YES;
    proxySettings.HTTPSServer =[[NEProxyServer alloc]  initWithAddress:proxyServerName port:proxyServerPort];
    proxySettings.excludeSimpleHostnames = YES;
    proxySettings.matchDomains = matchDomains;

    settings.proxySettings = proxySettings;

    //todo add end host name
    NWHostEndpoint *endpoint = [NWHostEndpoint endpointWithHostname:remoteAddress port:remotePort];
    self.tcpConnection =[self createTCPConnectionThroughTunnelToEndpoint:endpoint enableTLS:NO TLSParameters:nil delegate:self];
    if (nil==self.tcpConnection) {
        if (completionHandler) {
          NSError *error =[self p_errorWithReason:@"create tcp failed"];
          completionHandler(error);
        }
        return;
    }
    
    [self.tcpConnection addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
   
    __weak PacketTunnelProvider *weakSelf = self;
    [self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            NSLog(@"start Tunnel Success");
            //开始读取tun0数据，转发给tunnelSever
            [weakSelf p_readIpPackets];
        }
        if (completionHandler) {
            completionHandler(error);
        }
    }];
    
                                   
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
	// Add code here to start the process of stopping the tunnel.
	completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
	// Add code here to handle the message.
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
	// Add code here to get ready to sleep.
	completionHandler();
}

- (void)wake {
	// Add code here to wake up.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![keyPath isEqualToString:@"status"]) {
        return;
    }
    switch (self.tcpConnection.state) {
        case NWTCPConnectionStateConnected:{
            [self p_handlePackets];
        }
            break;
        case NWTCPConnectionStateDisconnected:{
            //handle disconnected
            
        }break;
        case NWTCPConnectionStateCancelled:{
            //handle cancel
        }break;
        default:
            break;
    }
}
#pragma mrak - Private

/**
 读取tun0 中数据，进行自定义封装，发送给tunnelSever
 */
- (void)p_readIpPackets{
    [self.packetFlow readPacketObjectsWithCompletionHandler:^(NSArray<NEPacket *> * _Nonnull packets) {
        NSMutableData *tunnelData =[[NSMutableData alloc] init];
        /****可以对数据封装，自定义数据格式等等****/
        for (NEPacket *ipPacket in packets) {
           // NSData *data =[];
            [tunnelData appendData:ipPacket.data];
        }
        /*********/
        [self.tcpConnection write:tunnelData completionHandler:^(NSError * _Nullable error) {
            [self p_readIpPackets];
        }];
    }];
}

/**
 读取tunnelSever数据，按照自定义格式解析，发送给tun0
 */
- (void)p_handlePackets{
    
    [self.tcpConnection readMinimumLength:32 maximumLength:(128 * 1024) completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            //error， 处理错误情况
            return ;
        }
        NSMutableData *mData = nil;
        /****对tunnelSever的数据进行校验解析，异常处理等等****/
        //do something
        mData = data;
        /********/
        //将server数据数据写入tun0 中
        NSArray *protocals = @[];
        BOOL isSucceed = [self.packetFlow writePackets:@[mData] withProtocols:protocals];
        NSLog(@"write tun0 succeed = %bool",isSucceed);
        
        //循环继续读取tunnelSever数据处理
        [self p_handlePackets];
        
    }];
}
- (NSError *)p_errorWithReason:(NSString *)reaseon{
    if (reaseon == nil) {
        return nil;
    }
    return [NSError errorWithDomain:NSURLErrorDomain code:100 userInfo:@{@"message":reaseon}];
}
@end
