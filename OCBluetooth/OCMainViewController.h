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

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, retain) OCBTLEPeripheralService *service;
@property (nonatomic, retain) NSData *dataWrite;

/** 搜索外设 */
- (void)scanningPeriphral;
//
///** @name 读写数据 */
//// @{
///** 解析收到的数据 */
//- (void)analyzeData:(NSData *)data;
//- (void)readData;
//- (void)writeData;
//// @}end of 读写数据

@end
