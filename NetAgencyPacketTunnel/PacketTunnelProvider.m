//
//  PacketTunnelProvider.m
//  NetAgencyPacketTunnel
//
//  Created by netease on 2018/1/3.
//  Copyright © 2018年 Luigi. All rights reserved.
//

#import "PacketTunnelProvider.h"

 NSString *kNAPacketTunnelRemoteAddress = @"kNAPacketTunnelRemoteAddress";
 NSString *kNAPacketTunnelMatchDomains = @"kNAPacketTunnelMatchDomains";


@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
	// Add code here to start the process of connecting the tunnel.
    
    NSString *remoteAddress = [options objectForKey:kNAPacketTunnelRemoteAddress];
    if (remoteAddress.length<1) {
        if (completionHandler) {
            completionHandler([NSError errorWithDomain:NSURLErrorKey code:100 userInfo:@{@"reason":@"invalid options"}]);
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
    
    id matchDomains = [options objectForKey:kNAPacketTunnelMatchDomains];
    if ([matchDomains isKindOfClass:[NSArray class]]) {
      proxySettings.matchDomains = matchDomains;
    }else{
        NSLog(@"invalid MatchDomains");
    }
    
    
    settings.proxySettings = proxySettings;
    
    [self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            NSLog(@"start Tunnel Success");
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

@end
