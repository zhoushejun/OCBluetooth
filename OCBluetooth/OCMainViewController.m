//
//  OCMainViewController.m
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-21.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "OCMainViewController.h"
#import "OCBTLECentralManager.h"

/** @name const */
// @{
#define UNSUPORTBLUETOOTH_4_0 @"您的设备不支持蓝牙4.0"
// @}end of const

/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
/** kBLEPeripheralUUIDString为nil,则会扫瞄所有的可连接设备; 可以指定一个CBUUID对象 从而只扫瞄注册用指定服务的设备 */
//NSString *kBLEPeripheralUUIDString = @"00001530-1212-EFDE-1523-785FEABCD123";//按21秒后进入空中升级模式的设备UUID
//NSString *kBLEPeripheralUUIDString = nil;
/**  */
//NSString *kBLEPeripheralServicesUUIDString;
/**  */
//NSString *kBLEPeripheralReadCharacteristicUUIDString;
/**  */
//NSString *kBLEPeripheralWriteCharacteristicUUIDString;

@interface OCMainViewController ()

@property (nonatomic, strong) NSMutableArray *arrayData;
@end

@implementation OCMainViewController
@synthesize arrayData = _arrayData;
@synthesize tableView = _tableView;
@synthesize textFieldDemand = _textFieldDemand;
@synthesize textFieldDevice = _textFieldDevice;
@synthesize service = _service;
@synthesize dataWrite = _dataWrite;

@synthesize dataFirware = _dataFirware;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, 120, 44);
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitle:@"搜索蓝牙" forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor orangeColor];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn addTarget:self action:@selector(btnScanningPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btnConnect = [UIButton buttonWithType:UIButtonTypeCustom];
    btnConnect.frame = CGRectMake(180, 60, 120, 44);
    btnConnect.backgroundColor = [UIColor grayColor];
    [btnConnect setTitle:@"连接蓝牙" forState:UIControlStateNormal];
    btnConnect.titleLabel.textColor = [UIColor orangeColor];
    btnConnect.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnConnect addTarget:self action:@selector(btnConnect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnConnect];
    
    UIButton *btnDisconnect = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDisconnect.frame = CGRectMake(180, 110, 120, 44);
    btnDisconnect.backgroundColor = [UIColor grayColor];
    [btnDisconnect setTitle:@"断开蓝牙" forState:UIControlStateNormal];
    btnDisconnect.titleLabel.textColor = [UIColor orangeColor];
    btnDisconnect.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnDisconnect addTarget:self action:@selector(btnDisconnect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDisconnect];
    
    UIButton *btnCleanUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCleanUp.frame = CGRectMake(20, 110, 120, 44);
    [btnCleanUp setTitle:@"清空" forState:UIControlStateNormal];
    btnCleanUp.backgroundColor = [UIColor grayColor];
    [btnCleanUp addTarget:self action:@selector(btnCleanUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCleanUp];
    
    UIButton *btnUpdateFirmware = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUpdateFirmware.frame = CGRectMake(20, 160, 120, 44);
    [btnUpdateFirmware setTitle:@"空中升级" forState:UIControlStateNormal];
    btnUpdateFirmware.backgroundColor = [UIColor grayColor];
    [btnUpdateFirmware addTarget:self action:@selector(btnUpdateFirmware:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnUpdateFirmware];
    
    UITextField *textFieldDemand = [[UITextField alloc] initWithFrame:CGRectMake(180, 160, 120, 44)];
    textFieldDemand.backgroundColor = [UIColor grayColor];
    textFieldDemand.textColor = [UIColor  whiteColor];
    textFieldDemand.textAlignment = NSTextAlignmentCenter;
//    textField.delegate = self;
    textFieldDemand.keyboardType = UIKeyboardTypeDefault;
    textFieldDemand.text = @"0x07";
    self.textFieldDemand = textFieldDemand;
    [self.view addSubview:self.textFieldDemand];
    
    UITextField *textFieldDevice = [[UITextField alloc] initWithFrame:CGRectMake(180, 210, 120, 44)];
    textFieldDevice.backgroundColor = [UIColor grayColor];
    textFieldDevice.textColor = [UIColor  whiteColor];
    textFieldDevice.textAlignment = NSTextAlignmentCenter;
//    textField.delegate = self;
    textFieldDevice.keyboardType = UIKeyboardTypeDefault;
    textFieldDevice.text = @"C31A";
    self.textFieldDevice = textFieldDevice;
    [self.view addSubview:self.textFieldDevice];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 300, 300, SCREEN_HEIGHT - 300-10)];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTextView:) name:@"resetTextView" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self textFieldResignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *strCellId = @"strCellId";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:strCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.arrayData objectAtIndex:indexPath.row]];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:12.f];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self textFieldResignFirstResponder];
    [self connectPerphral:indexPath.row];
}

#pragma mark - UITextFieldDelegate


#pragma mark - OCPeripheralDelegate

- (void)centralManagerDidUpdateState:(CBCentralManagerState)state{
    NSString *strState = nil;
    switch (state) {
        case CBCentralManagerStateUnknown:
        {
        strState = @"手机蓝牙处于未知(即初始)状态";
        break;
        }
            
        case CBCentralManagerStateResetting:
        {
        strState = @"手机蓝牙处于正在重围状态";
        break;
        }
            
        case CBCentralManagerStateUnsupported:
        {
        strState = @"手机蓝牙处于不支持状态";
        break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
        strState = @"手机蓝牙处于未授权状态";
        break;
        }
            
        case CBCentralManagerStatePoweredOff:
        {
        strState = @"手机蓝牙处于关闭状态";
        
        break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
        strState = @"手机蓝牙处于开启(可用)状态";
        [self scanningPeriphral];
        break;
        }
            
        default:
        {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:UNSUPORTBLUETOOTH_4_0 delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertV show];
            break;
        }
    }
    NSLog(@"%@", strState);
}

- (void)serviceDidDiscoverPeripheral:(CBPeripheral *)peripheral
                    advertisementData:(NSDictionary *)advertisementData{
    NSString *adDataStr = [[advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey] description];
    /*if (!adDataStr) {
        NSLog(@"广播数据为空");
        return;
    }*/
    NSLog(@"广播数据adDataStr:%@", adDataStr);
    
    if (![[[OCBTLECentralManager shareCentralManager] arrFoundPeripherals] containsObject:peripheral]){
        [[[OCBTLECentralManager shareCentralManager] arrFoundPeripherals] addObject:peripheral];
    }
    [self.tableView reloadData];
}

- (void)serviceDidConnect:(OCBTLEPeripheralService*)service{
    NSLogCurrentFunction
    self.service = service;
    [self.service start];
    [self.service.peripheral readRSSI];
}

- (void)serviceDidFailToConnect:(CBPeripheral *)peripheral{
}

- (void)serviceDidDisconnect:(OCBTLEPeripheralService*)service{
    NSLogCurrentFunction
    [self cleanUpPeriphral];
}

- (void)peripheralDidReadValue:(OCBTLEPeripheralService *)service
                          value:(NSData *)data{
    NSLog(@"读到的数据=%@",[data description]);
    [OCTool addALaryerOnWindow:[data description]];
    if (!data) {
        return;
    }
    self.service = service;
}

- (void)writeValue{
    //////////
    char buffer[16] = {};
    
    for (int n = 0; n<16; n++) {
        buffer[n] = 0x00;
    }
    buffer[1] = 0x01;
    buffer[2] = 0x02;
    self.dataWrite = [NSData dataWithBytes:buffer length:16];
    
    //////////
    if (!self.dataWrite) {
        return;
    }
    if (!self.service) {
        NSLog(@"service is nil");
        return;
    }
    [self.service writeValue:self.dataWrite];
}

#pragma mark - interactions

- (void)textFieldResignFirstResponder {
    [self.textFieldDemand resignFirstResponder];
    [self.textFieldDevice resignFirstResponder];
}

- (void)btnScanningPress:(id)sender{
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"搜索蓝牙");
    [self textFieldResignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanningPeriphral) object:sender];
    [self performSelector:@selector(scanningPeriphral) withObject:sender afterDelay:0.2f];
    NSLog(@"%lf", 1000*([NSDate timeIntervalSinceReferenceDate] - time));
}

- (void)btnCleanUp:(id)sender{
    [self textFieldResignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cleanUpPeriphral) object:sender];
    [self performSelector:@selector(cleanUpPeriphral) withObject:sender afterDelay:0.2f];
}

- (void)btnConnect:(id)sender{
    [self textFieldResignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectPerphral) object:sender];
    [self performSelector:@selector(connectPerphral) withObject:sender afterDelay:0.2f];
    
}

- (void)btnDisconnect:(id)sender{
    NSLogCurrentFunction;
    [self textFieldResignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(disconnectPerphral) object:sender];
    [self performSelector:@selector(disconnectPerphral) withObject:sender afterDelay:0.2f];
}

- (void)btnUpdateFirmware:(id)sender{
    NSLogCurrentFunction;
    [self textFieldResignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(disconnectPerphral) object:sender];
    [self performSelector:@selector(updatePerphral) withObject:sender afterDelay:0.2f];
}

- (void)resetTextView:(NSNotification *)notify{
    NSLog(@"%@", notify.object);
    if (!self.arrayData) {
        NSMutableArray *arr = [NSMutableArray array];
        self.arrayData = arr;
    }
    self.arrayData = nil;
    self.arrayData = [NSMutableArray arrayWithArray:notify.object];
    [self.tableView reloadData];
}

#pragma mark - 

- (void)scanningPeriphral{
    NSString *str = self.textFieldDevice.text;
    /*if (str == nil || [str isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"请输入设备 4 字符ID", @"请输入设备ID")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", @"确定")
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }*/
    [self cleanUpPeriphral];
    OCBTLECentralManager *CentralManager = [OCBTLECentralManager shareCentralManager];
    if (!(str == nil || [str isEqualToString:@""])) {
        CentralManager.strDeviceName = str;
    }
    if (!CentralManager.peripheralDelegate) {
        CentralManager.peripheralDelegate = self;
    }
    [CentralManager startScanningForUUIDString:nil];
}

- (void)cleanUpPeriphral{
    [self disconnectPerphral];
    OCBTLECentralManager *ble = [OCBTLECentralManager shareCentralManager];
    [ble cleanup];
    [self.arrayData removeAllObjects];
    [self.tableView reloadData];
}

- (void)connectPerphral:(NSInteger)index{
    OCBTLECentralManager *ble = [OCBTLECentralManager shareCentralManager];
    if ([ble.arrFoundPeripherals count] > 0) {
        [ble connectPeripheral:ble.arrFoundPeripherals[index]];
    }
}

- (void)disconnectPerphral{
    OCBTLECentralManager *ble = [OCBTLECentralManager shareCentralManager];
    if ([ble.arrConnectedPeripherals count] > 0) {
        OCBTLEPeripheralService *Peripheral = [ble.arrConnectedPeripherals lastObject];
        [ble disconnectPeripheral:Peripheral.peripheral];
    }
}

- (void)updatePerphral{
    OCBTLECentralManager *ble = [OCBTLECentralManager shareCentralManager];
    if ([ble.arrConnectedPeripherals count] > 0) {
        OCBTLEPeripheralService *Peripheral = [ble.arrConnectedPeripherals lastObject];
        if (Peripheral.peripheral.state != CBPeripheralStateConnected) {
            [OCTool addALaryerOnWindow:@"蓝牙未连接"];
            return;
        }
    }else {
        [OCTool addALaryerOnWindow:@"蓝牙未连接"];
        return;
    }
   
    NSString *str = self.textFieldDemand.text;
    if (str != nil && ![str isEqualToString:@""]) {
        UInt8 n = strtoll([str UTF8String], nil, 16);
        [self writeValue:n];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"请输入指令", @"请输入指令")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", @"确定")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)writeValue:(UInt8)val_p
{
    NSLog(@"%#04x", val_p);
    if (!self.service) {
        NSLog(@"service is nil");
        return;
    }
    UInt8 val =val_p;
    NSData *fd = [[NSData alloc] initWithBytes:&val length:1];
    if (val_p == 0x07) {
        [self.service writeValue:fd];
    }else {
        [self.service readValue:fd];
    }
    
}

//请求睡眠数据。
-(void)requestSleepdata
{
    UInt8 val =0x09;
    [self writeValue:val];
}

@end
