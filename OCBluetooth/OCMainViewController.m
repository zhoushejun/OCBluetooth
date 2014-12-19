//
//  OCMainViewController.m
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-21.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "OCMainViewController.h"
#import "OCBTLECentralManager.h"
#import "OCHandBandDataModel.h"

/** @name const */
// @{
#define UNSUPORTBLUETOOTH_4_0 @"您的设备不支持蓝牙4.0"
/** 搜索的设备名称 */
#define DEFAULT_DEVICE_NAME @"F239"
/** 向手环发送的命令 */
#define SEND_COMMAND @"0x24"
// @}end of const

@interface OCMainViewController ()

@property (nonatomic, strong) NSMutableData *mutableData;   ///< 存储手环返回来的数据
@property (nonatomic, strong) NSMutableArray *arrayData;    ///< 存储搜索到的蓝牙设备
@property (nonatomic, strong) UIButton *btnScanning;        ///< 搜索蓝牙设备/停止搜索蓝牙设备
@property (nonatomic, strong) UIButton *btnConnect;         ///< 连接蓝牙/断开蓝牙 btn

@end

@implementation OCMainViewController
@synthesize mutableData = _mutableData;
@synthesize arrayData = _arrayData;
@synthesize btnScanning = _btnScanning;
@synthesize btnConnect = _btnConnect;
@synthesize tableView = _tableView;
@synthesize textFieldDemand = _textFieldDemand;
@synthesize textFieldDevice = _textFieldDevice;
@synthesize service = _service;
@synthesize dataWrite = _dataWrite;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mutableData = [NSMutableData dataWithCapacity:40];
    
    int x0 = 20;
    int space = 40;
    int w = (SCREEN_WIDTH - 2*x0 - space)/2;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, w, 44);
    btn.backgroundColor = [UIColor grayColor];
    btn.tag = 1001;     ///< 1001:搜索蓝牙   1002:停止搜索蓝牙
    [btn setTitle:@"搜索蓝牙" forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor orangeColor];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn addTarget:self action:@selector(btnScanningPress:) forControlEvents:UIControlEventTouchUpInside];
    self.btnScanning = btn;
    [self.view addSubview:btn];
    
    UIButton *btnCnt = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCnt.frame = CGRectMake(x0 + w + space, 60, w, 44);
    btnCnt.backgroundColor = [UIColor grayColor];
    btnCnt.tag = 1001;  ///< 2001:连接蓝牙  2001:断开蓝牙
    [btnCnt setTitle:@"连接蓝牙" forState:UIControlStateNormal];
    btnCnt.titleLabel.textColor = [UIColor orangeColor];
    btnCnt.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnCnt addTarget:self action:@selector(btnConnect:) forControlEvents:UIControlEventTouchUpInside];
    self.btnConnect = btnCnt;
    [self.view addSubview:btnCnt];
    
    UIButton *btnCleanUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCleanUp.frame = CGRectMake(20, 110, w, 44);
    [btnCleanUp setTitle:@"清空" forState:UIControlStateNormal];
    btnCleanUp.backgroundColor = [UIColor grayColor];
    [btnCleanUp addTarget:self action:@selector(btnCleanUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCleanUp];
    
    UIButton *btnUpdateFirmware = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUpdateFirmware.frame = CGRectMake(20, 160, w, 44);
    [btnUpdateFirmware setTitle:@"发送指令" forState:UIControlStateNormal];
    btnUpdateFirmware.backgroundColor = [UIColor grayColor];
    [btnUpdateFirmware addTarget:self action:@selector(btnUpdateFirmware:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnUpdateFirmware];
    
    UITextField *textFieldDevice = [[UITextField alloc] initWithFrame:CGRectMake(x0 + w + space, 110, w, 44)];
    textFieldDevice.backgroundColor = [UIColor grayColor];
    textFieldDevice.textColor = [UIColor  whiteColor];
    textFieldDevice.textAlignment = NSTextAlignmentCenter;
    //    textField.delegate = self;
    textFieldDevice.keyboardType = UIKeyboardTypeDefault;
    textFieldDevice.text = DEFAULT_DEVICE_NAME;
    self.textFieldDevice = textFieldDevice;
    [self.view addSubview:self.textFieldDevice];
    
    UITextField *textFieldDemand = [[UITextField alloc] initWithFrame:CGRectMake(x0 + w + space, 160, w, 44)];
    textFieldDemand.backgroundColor = [UIColor grayColor];
    textFieldDemand.textColor = [UIColor  whiteColor];
    textFieldDemand.textAlignment = NSTextAlignmentCenter;
//    textField.delegate = self;
    textFieldDemand.keyboardType = UIKeyboardTypeDefault;
    textFieldDemand.text = SEND_COMMAND;
    self.textFieldDemand = textFieldDemand;
    [self.view addSubview:self.textFieldDemand];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 300, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 300-10)];
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
        case CBCentralManagerStateUnknown:{
            strState = @"手机蓝牙处于未知(即初始)状态";
        break;
        }
            
        case CBCentralManagerStateResetting:{
            strState = @"手机蓝牙处于正在重围状态";
        break;
        }
            
        case CBCentralManagerStateUnsupported:{
            strState = @"手机蓝牙处于不支持状态";
        break;
        }
            
        case CBCentralManagerStateUnauthorized:{
            strState = @"手机蓝牙处于未授权状态";
        break;
        }
            
        case CBCentralManagerStatePoweredOff:{
            strState = @"手机蓝牙处于关闭状态";
        
        break;
        }
            
        case CBCentralManagerStatePoweredOn:{
            strState = @"手机蓝牙处于开启(可用)状态";
        [self scanningPeriphral];
        break;
        }
            
        default:{
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示"
                                                             message:UNSUPORTBLUETOOTH_4_0
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"确定", nil];
            [alertV show];
            break;
        }
    }
    NSLog(@"%@", strState);
}

- (void)serviceDidDiscoverPeripheral:(CBPeripheral *)peripheral
                    advertisementData:(NSDictionary *)advertisementData{
    NSString *adDataStr = [[advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey] description];
    NSLog(@"设备名:%@  广播数据:%@", peripheral.name, adDataStr);
    if (![[[OCBTLECentralManager shareCentralManager] arrFoundPeripherals] containsObject:peripheral]){
        [[[OCBTLECentralManager shareCentralManager] arrFoundPeripherals] addObject:peripheral];
    }
    [self.tableView reloadData];
}

- (void)serviceDidConnect:(OCBTLEPeripheralService*)service{
    NSLogCurrentFunction
    self.service = service;
    [self.service start];
    self.btnConnect.tag = 2002;
    [self.btnConnect setTitle:@"断开蓝牙" forState:UIControlStateNormal];
}

- (void)serviceDidFailToConnect:(CBPeripheral *)peripheral{
    
}

- (void)serviceDidDisconnect:(OCBTLEPeripheralService*)service{
    NSLogCurrentFunction
    [self cleanUpPeriphral];
    self.btnConnect.tag = 2001;
    [self.btnConnect setTitle:@"连接蓝牙" forState:UIControlStateNormal];
}

- (void)peripheralDidReadValue:(OCBTLEPeripheralService *)service
                          value:(NSData *)data{
    if (service != self.service) {
        return;
    }
    NSLog(@"读到的数据=%@",[data description]);
    [OCTool addALaryerOnWindow:[data description]];
    /** 返回的数据data至少包括1字节id(代表指令)、1字节No(代表第N个数据包)、1字节length(代表本包(第N个数据包)的长度) */
    if (!data || data.length < 3) {
        return;
    }
    [self.mutableData appendData:data];
    /** data 的第 2 字节最高位如果为 1 则表示本条指令请求结束，否则后面还有数据 */
    NSString *strFinal = [data.description substringWithRange:NSMakeRange(3, 1)];
    int n = [strFinal intValue];
    n = n >> 3;
    /** n 为1则说明是最后一条数据 */
    if (n == 1) {
        /** 在进行下一条数据请求前需要解析本条指令请求完的数据，然后将其清空 */
        [[OCHandBandDataModel sharedInstance] analyzeHBData:self.mutableData];
        [self clearDataBytes];
        [self shouldWriteValue:data];
    }
}

/** 清空用于存储从手环返回来的数据的对象的内容，以便请求下一指令时存储从手环返回来的数据 */
- (void)clearDataBytes{
    [self.mutableData resetBytesInRange:NSMakeRange(0, self.mutableData.length)];
    self.mutableData.length = 0;
}

/** 处理是否向手环请求下一条数据 */
- (void)shouldWriteValue:(NSData *)data{
    UInt8 xval[1] = {0};
    [data getBytes:&xval range:NSMakeRange(0, 1)];
    NSLog(@"当前指令请求完成:%#04x", xval[0]);
    xval[0] = xval[0] - 1;
    NSString *strDate = [OCTool historyDateStringFrom:xval[0]];
    while (![[OCHandBandDataModel sharedInstance] shouldRequestDataForDate:strDate]) {
        xval[0] = xval[0] - 1;
    }
    if (xval[0] >= 0x10) {
        [self writeValue:xval[0]];
    }else{
        NSLog(@"7天历史记录请求结束！");
    }
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
    if (self.btnScanning.tag == 1001) {
        self.btnScanning.tag = 1002;
        [self.btnScanning setTitle:@"停止搜索蓝牙" forState:UIControlStateNormal];
        NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
        NSLog(@"搜索蓝牙");
        [self textFieldResignFirstResponder];
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanningPeriphral) object:sender];
        [self performSelector:@selector(scanningPeriphral) withObject:sender afterDelay:0.2f];
        NSLog(@"%lf", 1000*([NSDate timeIntervalSinceReferenceDate] - time));
    }else {
        self.btnScanning.tag = 1001;
        [self.btnScanning setTitle:@"搜索蓝牙" forState:UIControlStateNormal];
        [self stopScanningPeriphral];
    }
}

- (void)btnCleanUp:(id)sender{
    [self textFieldResignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cleanUpPeriphral) object:sender];
    [self performSelector:@selector(cleanUpPeriphral) withObject:sender afterDelay:0.2f];
}

- (void)btnConnect:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 2001) {
        [self textFieldResignFirstResponder];
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectPerphral) object:sender];
        [self performSelector:@selector(connectPerphral) withObject:sender afterDelay:0.2f];
    }else {
        [self btnDisconnect:sender];
    }
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
    [self cleanUpPeriphral];
    
    OCBTLECentralManager *CentralManager = [OCBTLECentralManager shareCentralManager];
    CentralManager.strDeviceName = str;
    if (!CentralManager.peripheralDelegate) {
        CentralManager.peripheralDelegate = self;
    }
    [CentralManager startScanningForUUIDString:nil];
}

- (void)stopScanningPeriphral{
    OCBTLECentralManager *ble = [OCBTLECentralManager shareCentralManager];
    [ble stopScanning];
}

- (void)cleanUpPeriphral{
    [self disconnectPerphral];
    OCBTLECentralManager *ble = [OCBTLECentralManager shareCentralManager];
    [ble cleanup];
    [self.arrayData removeAllObjects];
    [self.tableView reloadData];
}

- (void)connectPerphral{
    [self connectPerphral:0];
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
    NSLog(@"发送的指令:%#04x", val_p);
    if (!self.service) {
        NSLog(@"service is nil");
        return;
    }
    UInt8 val =val_p;
    NSData *fd = [[NSData alloc] initWithBytes:&val length:1];
    if (val_p == 0x01 ||val_p == 0x02 || (val_p >= 0x07 && val_p <= 0x24)) {
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
