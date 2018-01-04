//
//  ViewController.m
//  NetAgency
//
//  Created by Luigi on 2018/1/2.
//  Copyright © 2018年 Luigi. All rights reserved.
//

#import "ViewController.h"
#import "PacketTunnelProvider.h"

@interface ViewController ()
@property (nonatomic ,strong) NSArray *dataSources;
@property (nonatomic ,strong) UITableView *tableview;
@property (nonatomic ,strong) PacketTunnelProvider *tunnelProvider;

@property (nonatomic ,strong) NETunnelProviderManager *manager;

@property (nonatomic ,strong) UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createVpn];
    
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Start" forState:UIControlStateNormal];
//    [button setTitle:@"Close" forState:UIControlStateSelected];
    
    CGFloat width =100.0f;
    button.frame = CGRectMake(0, 0, width, width);
    button.layer.cornerRadius = width/2.0;
    button.layer.masksToBounds = YES;
    button.backgroundColor = [UIColor greenColor];
    button.center= self.view.center;
    [button addTarget:self action:@selector(onVpnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.button = button;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createVpn{
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        NETunnelProviderManager *manager = nil;
        if (managers.count==0) {
            //create manager
            manager = (NETunnelProviderManager *)[NETunnelProviderManager sharedManager];
            NEVPNProtocolIKEv2 *p = [[NEVPNProtocolIKEv2 alloc] init];
            p.username = @"";
            p.serverAddress = @"";
            p.passwordReference = nil;
            p.localIdentifier = @"";
            p.remoteIdentifier = @"";
            manager.protocolConfiguration = p;
        }else{
            manager = managers.firstObject;
        }
        
        manager.enabled = YES;
        manager.onDemandEnabled = YES;
        manager.localizedDescription= @"MyVpn";
        
        // manager.protocolConfiguration =[nevpo];
        [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            if (nil == error) {
               
            }
        }];
        self.manager = manager;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVpnStateChange:) name:NEVPNStatusDidChangeNotification object:nil];
}

- (void)onVpnAction:(UIButton *)sender{
    switch (self.manager.connection.status) {
        case NEVPNStatusConnected:
            [self stopVPN];
            break;
        case NEVPNStatusDisconnected:{
            [self startVpn];
        }break;
        case NEVPNStatusInvalid:{
            NSLog(@"配置失败");
        }break;
        default:
            break;
    }
}
- (void)onVpnStateChange:(NSNotification *)Notification{
    NEVPNStatus state = self.manager.connection.status;
    switch (state) {
        case NEVPNStatusInvalid:
             [self.button setTitle:@"Start" forState:UIControlStateNormal];
            NSLog(@"无效连接");
            break;
        case NEVPNStatusDisconnected:
            [self.button setTitle:@"Start" forState:UIControlStateNormal];
            NSLog(@"未连接");
            break;
        case NEVPNStatusConnecting:
            [self.button setTitle:@"Connecting" forState:UIControlStateNormal];
            NSLog(@"正在连接");
            break;
        case NEVPNStatusConnected:
            [self.button setTitle:@"Stop" forState:UIControlStateNormal];
            NSLog(@"已连接");
            break;
        case NEVPNStatusDisconnecting:
             [self.button setTitle:@"Disconnecting" forState:UIControlStateNormal];
            NSLog(@"断开连接");
            break;
        default:
            break;
    }
}

- (void)startVpn{
    [self.manager.connection startVPNTunnelWithOptions:nil andReturnError:nil];
}
- (void)stopVPN{
    [self.manager.connection stopVPNTunnel];
}
#pragma mark - Getter
- (NSArray *)dataSources{
    if (_dataSources) {
        return _dataSources;
    }
    _dataSources = @[@"apkpure.com",@"a.apkpure.com",@"download.apkpure.com",@"m.apkpure.com",@"static.apkpure.com"];
    return _dataSources;
}


@end
