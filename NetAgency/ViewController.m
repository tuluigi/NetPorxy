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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Start" forState:UIControlStateNormal];
    [button setTitle:@"Close" forState:UIControlStateSelected];
    
    CGFloat width =100.0f;
    button.frame = CGRectMake(0, 0, width, width);
    button.layer.cornerRadius = width/2.0;
    button.layer.masksToBounds = YES;
    button.backgroundColor = [UIColor greenColor];
    button.center= self.view.center;
    [button addTarget:self action:@selector(onVpnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)onVpnAction:(UIButton *)sender{
    if (sender.selected) {
        [self stopVPN];
    }else{
        [self startVpn];
    }
    sender.selected = !sender.selected;
}

- (void)startVpn{
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        NETunnelProviderManager *manager = nil;
        if (managers.count==0) {
            //create manager
            manager = (NETunnelProviderManager *)[NETunnelProviderManager sharedManager];
            NETunnelProviderProtocol *protocal = [[NETunnelProviderProtocol alloc]  init];
            protocal.serverAddress = @"104.20.82.194";
//            protocal.username = @"";
            manager.protocolConfiguration = protocal;
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
        /*
       NSError *aError;
       BOOL isSucceed = [manager.connection startVPNTunnelWithOptions:nil andReturnError:&aError];
        if (isSucceed&&nil==aError) {
            
        }else{
            
        }
         */
    }];
}
- (void)stopVPN{
    
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
