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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)startVpn{
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if (managers.count==0) {
            //create manager
        }
        
    }];
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
