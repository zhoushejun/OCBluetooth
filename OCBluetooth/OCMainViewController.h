//
//  OCMainViewController.h
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-21.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCBTLEPeripheralService.h"

@interface OCMainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, OCPeripheralDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *textFieldDemand;
@property (nonatomic, strong) UITextField *textFieldDevice;
@property (nonatomic, retain) OCBTLEPeripheralService *service;
@property (nonatomic, retain) NSData *dataWrite;
@property (nonatomic, retain) NSData *dataFirware;

/** 搜索外设 */
- (void)scanningPeriphral;


@end
