//
//  OCMainViewController.m
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-21.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "OCMainViewController.h"

@interface OCMainViewController ()

@end

@implementation OCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(60, 60, 200, 44);
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitle:@"搜索蓝牙" forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor orangeColor];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)btnPress:(id)sender{
    NSLog(@"搜索蓝牙");
    
}

@end
