//
//  OCMainViewController.h
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-21.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

/*!
 @file      OCMainViewController.h
 @brief     主界面，目前所有的操作均放在主界面上进行，包括蓝牙搜索、连接、向蓝牙设备发送数据等，主界面可指定搜索的蓝牙设备名称及发送的指令码
 @author    shejun.zhou
 @version   1.0.0
 */

#import <UIKit/UIKit.h>
#import "OCBTLEPeripheralService.h"

@interface OCMainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, OCPeripheralDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *textFieldDemand;
@property (nonatomic, strong) UITextField *textFieldDevice;
@property (nonatomic, retain) OCBTLEPeripheralService *service;
@property (nonatomic, retain) NSData *dataWrite;

/** 搜索外设 */
- (void)scanningPeriphral;
/** 停止搜索外设 */
- (void)stopScanningPeriphral;

@end
