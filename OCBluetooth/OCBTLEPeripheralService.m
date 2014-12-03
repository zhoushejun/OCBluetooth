//
//  OCBTLEPeripheralService.m
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-23.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "OCBTLEPeripheralService.h"

/** kBLEPeripheralUUIDString为nil,则会扫瞄所有的可连接设备; 可以指定一个CBUUID对象 从而只扫瞄注册用指定服务的设备 */
//NSString *kBLEPeripheralUUIDString = @"4EEFFDDF-ABFB-8275-B3D3-0FC84D3E879C";
NSString *kBLEPeripheralUUIDString = nil;
NSString *kBLEPeripheralServicesUUIDString = @"6e400001-b5a3-f393-e0a9-e50e24dcca9e";
NSString *kBLEPeripheralWriteCharacteristicUUIDString = @"6e400002-b5a3-f393-e0a9-e50e24dcca9e";
NSString *kBLEPeripheralReadCharacteristicUUIDString = @"6e400003-b5a3-f393-e0a9-e50e24dcca9e";
/*
NSString *kBLEPeripheralUUIDString = @"4EEFFDDF-ABFB-8275-B3D3-0FC84D3E879C";
NSString *kBLEPeripheralServicesUUIDString = @"00001530-1212-EFDE-1523-785FEABCD123";//空中升级：长按21秒
NSString *kBLEPeripheralWriteCharacteristicUUIDString = @"00001532-1212-EFDE-1523-785FEABCD123";
NSString *kBLEPeripheralReadCharacteristicUUIDString = @"00001531-1212-EFDE-1523-785FEABCD123";
*/
@interface OCBTLEPeripheralService ()<CBPeripheralDelegate>{
@private
    CBPeripheral		*servicePeripheral;
    CBService			*BLEPeripheralService;
    
    CBCharacteristic	*readCharacteristic;
    CBCharacteristic    *writeCharacteristic;
    
    CBUUID              *peripheralUUID;
    CBUUID              *peripheralServiceUUID;
    CBUUID              *readCharacteristicUUID;
    CBUUID              *writeCharacteristicUUID;
    
    id<OCPeripheralDelegate>	peripheralDelegate;
}

@property (nonatomic, retain) CBCharacteristic    *writeCharacteristic;

@end

@implementation OCBTLEPeripheralService
@synthesize writeCharacteristic;
@synthesize peripheral = servicePeripheral;
@synthesize strDeviceTag = _strDeviceTag;

#pragma mark - init

- (id)initWithPeripheral:(CBPeripheral *)peripheral controller:(id<OCPeripheralDelegate>)controller{
    if (self = [super init]) {
        servicePeripheral = peripheral;
        servicePeripheral.delegate = self;
        peripheralDelegate = controller;
        if (kBLEPeripheralUUIDString) {
            peripheralUUID	= [CBUUID UUIDWithString:kBLEPeripheralUUIDString];
        }
        
        peripheralServiceUUID = [CBUUID UUIDWithString:kBLEPeripheralServicesUUIDString];
        readCharacteristicUUID = [CBUUID UUIDWithString:kBLEPeripheralReadCharacteristicUUIDString];
        writeCharacteristicUUID	= [CBUUID UUIDWithString:kBLEPeripheralWriteCharacteristicUUIDString];
    }
    return self;
}

- (void)reset{
    if (servicePeripheral) {
        servicePeripheral = nil;
    }
}

#pragma mark - service interaction

- (void)start{
    NSArray	*serviceArray	= [NSArray arrayWithObjects:peripheralServiceUUID, nil];
    
    [servicePeripheral discoverServices:serviceArray];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    NSLogCurrentFunction
}

/** 查询到蓝牙设备服务回调函数 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLogCurrentFunction;
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    if (peripheral != servicePeripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    NSArray	*services = [peripheral services];
    if (!services || ![services count]) {
        return ;
    }
    
    BLEPeripheralService = nil;
    for (CBService *service in services) {
        if ([[service UUID] isEqual:peripheralServiceUUID]) {
            BLEPeripheralService = service;
            break;
        }
    }
    
    if (BLEPeripheralService) {
        NSArray	*uuids	= [NSArray arrayWithObjects:readCharacteristicUUID, writeCharacteristicUUID, nil];
        [peripheral discoverCharacteristics:uuids forService:BLEPeripheralService];
    }
}

/** 查询蓝牙设备所带的特征值回调函数 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    NSLogCurrentFunction;
    if (peripheral != servicePeripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (service != BLEPeripheralService) {
        NSLog(@"Wrong Service.\n");
        return ;
    }
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    NSArray *characteristics = [service characteristics];
    for (CBCharacteristic *characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        NSLog(@"readCharacteristicUUID:%@\nwriteCharacteristicUUID:%@", readCharacteristicUUID, writeCharacteristicUUID);
        if ([[characteristic UUID] isEqual:readCharacteristicUUID]) { // 读的通道
            NSLog(@"Discovered readCharacteristic");
            readCharacteristic = characteristic;
            NSLog(@"readCharacteristic:%@", readCharacteristic);
            [peripheral setNotifyValue:YES forCharacteristic:readCharacteristic];
        }else if ([[characteristic UUID] isEqual:writeCharacteristicUUID]){// 写的通道
            NSLog(@"Discovered writeCharacteristic");
            writeCharacteristic = characteristic;
            NSLog(@"writeCharacteristic:%@", writeCharacteristic);
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

/** 处理蓝牙设备发过来的数据 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    NSLogCurrentFunction;
    if (peripheral != servicePeripheral) {
        NSLog(@"Wrong peripheral\n");
        return ;
    }
    
    if ([error code] != 0) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    /* Temperature change */
    if ([[characteristic UUID] isEqual:readCharacteristicUUID]) {
        if ([peripheralDelegate respondsToSelector:@selector(peripheralDidReadValue:value:)]) {
            [peripheralDelegate peripheralDidReadValue:self value:[readCharacteristic value]];
        }
        return;
    }
    if ([characteristic.UUID isEqual:writeCharacteristicUUID]) {
        if ([peripheralDelegate respondsToSelector:@selector(peripheralDidReadValue:value:)]) {
            [peripheralDelegate peripheralDidReadValue:self value:[writeCharacteristic value]];
        }
        return;
    }
}

/** 给蓝牙设备发数据 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    NSLogCurrentFunction;
    if (error) {
        NSLog(@"write error = %@",[error description]);
    }
    [peripheral readValueForCharacteristic:characteristic];
}

#pragma mark -

- (void)resetNotifyValueForCharacteristic:(BOOL)b {
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:peripheralServiceUUID]) {
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:readCharacteristicUUID] ) {
                    [servicePeripheral setNotifyValue:b forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (void)enteredBackground{
    // And STOP getting notifications from it
    [self resetNotifyValueForCharacteristic:NO];
}

- (void)enteredForeground{
    // And START getting notifications from it
    [self resetNotifyValueForCharacteristic:YES];
}

- (NSData *)readValue{
    if (readCharacteristic) {
        return [readCharacteristic value];
    }
    return nil;
}

- (void)readValue:(NSData *)data{
    if (!data) {
        NSLog(@"data == nil");
        return ;
    }
    
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
        return ;
    }
    
     if (!readCharacteristic) {
     NSLog(@"%@ No valid read characteristic", readCharacteristic);
     return;
     }
     [servicePeripheral writeValue:data forCharacteristic:readCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)writeValue:(NSData *)data{
    if (!data) {
        NSLog(@"data == nil");
        return ;
    }
    
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
        return ;
    }
   
    if (!writeCharacteristic) {
        NSLog(@"%@ No valid write characteristic", writeCharacteristic);
        return;
    }
    [servicePeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

@end
