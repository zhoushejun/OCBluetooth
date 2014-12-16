//
//  OCBTLECentralManager.m
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-23.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "OCBTLECentralManager.h"

@interface OCBTLECentralManager ()

@property (nonatomic, strong) CBCentralManager *centralManager;

@end

@implementation OCBTLECentralManager
@synthesize centralManager = _centralManager;
@synthesize previousState;
@synthesize strDeviceType = _strDeviceType;
@synthesize strDeviceName = _strDeviceName;
@synthesize dicPeripherals = _dicPeripherals;
@synthesize arrFoundPeripherals = _arrFoundPeripherals;
@synthesize arrConnectedPeripherals = _arrConnectedPeripherals;
@synthesize dicBundlePeripherals = _dicBundlePeripherals;
@synthesize peripheralDelegate;


+ (id)shareCentralManager{
    static OCBTLECentralManager *this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[OCBTLECentralManager alloc] init];
    });
    return this;
}

- (id)init{
    if (self = [super init]) {
        self.previousState = -1;
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        _arrFoundPeripherals = [[NSMutableArray alloc] init];
        _arrConnectedPeripherals = [[NSMutableArray alloc] init];
        _dicBundlePeripherals = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - discovery

- (void)startScanningForUUIDString:(NSString *)strUUID{
    NSLogCurrentFunction;
    NSMutableArray *arrUUID = nil;
    if (strUUID) {
        arrUUID = [NSMutableArray arrayWithObjects:[CBUUID UUIDWithString:strUUID] ,nil];
    }
    NSDictionary *dicOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                           forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self.centralManager scanForPeripheralsWithServices:arrUUID
                                                options:dicOptions];
}

- (void)stopScanning{
    NSLogCurrentFunction;
    [self.centralManager stopScan];
}

#pragma mark - connction/disconnection

- (void)connectPeripheral:(CBPeripheral *)peripheral{
    NSLogCurrentFunction;
    if (peripheral.state != CBPeripheralStateConnected) {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral{
    NSLogCurrentFunction;
    if (peripheral && peripheral.state == CBPeripheralStateConnected) {
        [self.centralManager  cancelPeripheralConnection:peripheral];
    }
}

#pragma mark - CBCentralManagerDelegate

/** 检查手机设备是否支持BLE */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLogCurrentFunction;
    if ([self.peripheralDelegate respondsToSelector:@selector(centralManagerDidUpdateState:)]) {
        [self.peripheralDelegate centralManagerDidUpdateState:[self.centralManager state]];
    }
}

/** 扫描到设备的回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString *strPerName = [NSString stringWithFormat:@"%@", peripheral.name];
    strPerName = [strPerName uppercaseString];
    if (self.strDeviceName && ![self.strDeviceName isEqualToString:@""]) {
        NSString *strDevName = [NSString stringWithFormat:@"%@", self.strDeviceName];
        strDevName = [strDevName uppercaseString];
        if ([strPerName rangeOfString:strDevName].length <= 0) {
            return;
        }
    }
    
    if (![self.arrFoundPeripherals containsObject:peripheral]) {
        [self.arrFoundPeripherals addObject:peripheral];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetTextView" object:self.arrFoundPeripherals];
    }
    if (peripheral && [peripheralDelegate respondsToSelector:@selector(serviceDidDiscoverPeripheral:advertisementData:)]) {
        [peripheralDelegate serviceDidDiscoverPeripheral:peripheral advertisementData:advertisementData];
    }
}

/** 连接上设备的回调 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLogCurrentFunction;
    NSLog(@"连接上设备:%@", peripheral.name);
    OCBTLEPeripheralService *service = [[OCBTLEPeripheralService alloc] initWithPeripheral:peripheral controller:peripheralDelegate];
    [service start];
    service.strDeviceTag = [NSString stringWithFormat:@"%@", self.strDeviceType];
    if (![self.arrConnectedPeripherals containsObject:service]) {
        [self.arrConnectedPeripherals addObject:service];
    }

    if ([self.peripheralDelegate respondsToSelector:@selector(serviceDidConnect:)]) {
        [self.peripheralDelegate serviceDidConnect:service];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetTextView" object:self.arrFoundPeripherals];
}

/** 连接失败的回调 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLogCurrentFunction;
    NSLog(@"连接失败: %@. (%@)", peripheral, [error localizedDescription]);
    if ([self.peripheralDelegate respondsToSelector:@selector(serviceDidFailToConnect:)]) {
        [self.peripheralDelegate serviceDidFailToConnect:peripheral];
    }
}

/**断开连接的回调*/
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLogCurrentFunction;
    NSLog(@"断开连接:%@. (%@)", peripheral, [error localizedDescription]);
    for (OCBTLEPeripheralService *service in self.arrConnectedPeripherals) {
        if ([service peripheral] == peripheral) {
            [self.arrConnectedPeripherals removeObject:service];
            if ([self.peripheralDelegate respondsToSelector:@selector(serviceDidDisconnect:)]) {
                [self.peripheralDelegate serviceDidDisconnect:service];
            }
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetTextView" object:self.arrFoundPeripherals];
}

#pragma mark - CBPeripheralDelegate

#pragma mark -

- (void)cleanup{
    for (OCBTLEPeripheralService *service in self.arrConnectedPeripherals) {
        [service reset];
    }
    [self.arrConnectedPeripherals removeAllObjects];
    [self.arrFoundPeripherals removeAllObjects];
    [self.dicPeripherals removeAllObjects];
}

@end
