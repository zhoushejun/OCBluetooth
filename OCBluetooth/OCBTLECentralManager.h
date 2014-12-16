//
//  OCBTLECentralManager.h
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-23.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

/*!
 @file      OCBTLECentralManager.h
 @author    shejun.zhou
 @version   1.0 
 @brief     蓝牙管理中心
 @detail
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OCBTLEPeripheralService.h"

@interface OCBTLECentralManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSString *strDeviceType;              ///< 硬件设备类型
@property (nonatomic, strong) NSString *strDeviceName;              ///< 硬件设备名称：4字符ID
@property (nonatomic, strong) NSMutableDictionary *dicPeripherals;  ///<

/****************************************************************************/
/*							Access to the devices							*/
/****************************************************************************/
@property (nonatomic, strong) NSMutableArray *arrFoundPeripherals;          ///< 搜索到的外围设备
@property (nonatomic, strong) NSMutableArray *arrConnectedPeripherals;      ///< 已连接的外围设备
@property (nonatomic, strong) NSMutableDictionary *dicBundlePeripherals;    ///< 绑定的外围设备

@property (nonatomic, assign) CBCentralManagerState previousState;          ///< 中心管理者之前的状态
@property (nonatomic, assign) id<OCPeripheralDelegate> peripheralDelegate;

+ (id)shareCentralManager;

/****************************************************************************/
/*								Actions										*/
/****************************************************************************/
- (void)startScanningForUUIDString:(NSString *)strUUID;
- (void)stopScanning;

- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;
- (void)cleanup;

@end
