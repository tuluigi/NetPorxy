//
//  ViewController.m
//  NetAgency
//
//  Created by Luigi on 2018/1/2.
//  Copyright © 2018年 Luigi. All rights reserved.
//

#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>
@interface ViewController ()
@property (nonatomic ,strong) NSArray *dataSources;
@property (nonatomic ,strong) UITableView *tableview;
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
