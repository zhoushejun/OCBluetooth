//
//  OCBTLEPeripheralService.h
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-23.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

/*!
 @file      OCBTLEPeripheralService.h
 @brief     设备服务管理者
 @author    shejun.zhou
 @version   1.0.0
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
extern NSString *kBLEPeripheralUUIDString;
extern NSString *kBLEPeripheralServicesUUIDString;
extern NSString *kBLEPeripheralReadCharacteristicUUIDString;
extern NSString *kBLEPeripheralWriteCharacteristicUUIDString;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class OCBTLEPeripheralService;


@protocol OCPeripheralDelegate<NSObject>

@optional

- (void)centralManagerDidUpdateState:(CBCentralManagerState)state;
- (void)serviceDidDiscoverPeripheral:(CBPeripheral *)peripheral
                    advertisementData:(NSDictionary *)advertisementData;
- (void)serviceDidConnect:(OCBTLEPeripheralService*)service;
- (void)serviceDidFailToConnect:(CBPeripheral *)peripheral;
- (void)serviceDidDisconnect:(OCBTLEPeripheralService*)service;
- (void)peripheralDidReadValue:(OCBTLEPeripheralService *)service
                          value:(NSData *)data;
- (void)writeValue;
@end

/****************************************************************************/
/*					   	OCBTLEPeripheralService                             */
/****************************************************************************/
@interface OCBTLEPeripheralService : NSObject{
    NSString *_strDevice;
}

@property (readonly) CBPeripheral *peripheral;
@property (nonatomic, retain) NSString *strDeviceTag;

- (id)initWithPeripheral:(CBPeripheral *)peripheral controller:(id<OCPeripheralDelegate>)controller;
- (void)reset;
- (void)start;

- (void)enteredBackground;
- (void)enteredForeground;

- (NSData *)readValue;

/*!
 @brief     从蓝牙设备读取数据
 @param     data 向蓝牙设备发送的指令
 */
- (void)readValue:(NSData *)data;

/*!
 @brief     向蓝牙设备写数据（如固件升级）
 @param     data 向蓝牙设备发送的指令
 */
- (void)writeValue:(NSData *)data;

@end
