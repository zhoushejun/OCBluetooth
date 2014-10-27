//
//  OCBTLECentralManager.h
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-23.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OCBTLEPeripheralService.h"

@interface OCBTLECentralManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, assign) CBCentralManagerState previousState;  ///< 中心管理者之前的状态
@property (nonatomic, strong) NSString *strDeviceType;              ///< 硬件设备类型
@property (nonatomic, strong) NSMutableDictionary *dicPeripherals;  ///<

/****************************************************************************/
/*							Access to the devices							*/
/****************************************************************************/
@property (retain, nonatomic) NSMutableArray *arrFoundPeripherals;         ///< 搜索到的外围设备
@property (retain, nonatomic) NSMutableArray *arrConnectedPeripherals;     ///< 已连接的外围设备
@property (retain, nonatomic) NSMutableDictionary *dicBundlePeripherals;   ///< 绑定的外围设备

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
