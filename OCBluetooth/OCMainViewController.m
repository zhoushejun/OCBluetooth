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
@synthesize textView = _textView;
@synthesize tableView = _tableView;
@synthesize textField = _textField;
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
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(180, 160, 120, 44)];
    textField.backgroundColor = [UIColor grayColor];
    textField.textColor = [UIColor  whiteColor];
    textField.textAlignment = NSTextAlignmentCenter;
//    textField.delegate = self;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.text = @"0x07";
    self.textField = textField;
    [self.view addSubview:self.textField];
    
    /*
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 200, 300, SCREEN_HEIGHT - 200-10)];
    textView.backgroundColor = [UIColor orangeColor];
    textView.textColor = [UIColor grayColor];
    textView.userInteractionEnabled = NO;
    textView.text = @"test";
    self.textView = textView;
    [self.view addSubview:self.textView];*/
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 200, 300, SCREEN_HEIGHT - 200-10)];
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
    [self.textField resignFirstResponder];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.textField resignFirstResponder];
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
}

- (void)serviceDidConnect:(OCBTLEPeripheralService*)service{
    self.service = service;
    [self.service start];
}

- (void)serviceDidFailToConnect:(CBPeripheral *)peripheral{
}

- (void)serviceDidDisconnect:(OCBTLEPeripheralService*)service{
    
}

- (void)peripheralDidReadValue:(OCBTLEPeripheralService *)service
                          value:(NSData *)data{
    NSLog(@"读到的数据=%@",[data description]);
    [OCTool addALaryerOnWindow:[data description]];
    if (!data) {
        return;
    }
    self.service = service;
    [self readFileData];
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

- (void)btnScanningPress:(id)sender{
    NSLog(@"搜索蓝牙");
    [self.textField resignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanningPeriphral) object:sender];
    [self performSelector:@selector(scanningPeriphral) withObject:sender afterDelay:0.2f];
}

- (void)btnCleanUp:(id)sender{
    [self.textField resignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cleanUpPeriphral) object:sender];
    [self performSelector:@selector(cleanUpPeriphral) withObject:sender afterDelay:0.2f];
}

- (void)btnConnect:(id)sender{
    [self.textField resignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectPerphral) object:sender];
    [self performSelector:@selector(connectPerphral) withObject:sender afterDelay:0.2f];
    
}

- (void)btnDisconnect:(id)sender{
    NSLogCurrentFunction;
    [self.textField resignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(disconnectPerphral) object:sender];
    [self performSelector:@selector(disconnectPerphral) withObject:sender afterDelay:0.2f];
}

- (void)btnUpdateFirmware:(id)sender{
    NSLogCurrentFunction;
    [self.textField resignFirstResponder];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(disconnectPerphral) object:sender];
    [self performSelector:@selector(updatePerphral) withObject:sender afterDelay:0.2f];
}

- (void)resetTextView:(NSNotification *)notify{
    NSLog(@"%@", notify.object);
    self.textView.text = [NSString stringWithFormat:@"%@", notify.object];
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
    OCBTLECentralManager *CentralManager = [OCBTLECentralManager shareCentralManager];
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

- (void)connectPerphral{
    OCBTLECentralManager *ble = [OCBTLECentralManager shareCentralManager];
    if ([ble.arrFoundPeripherals count] > 0) {
        [ble connectPeripheral:[ble.arrFoundPeripherals lastObject]];
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
   
    NSString *str = self.textField.text;
    if (str != nil && ![str isEqualToString:@""]) {
        UInt8 n = strtoll([str UTF8String], nil, 16);
        [self writeValue:n];
    }else{
        [self writeValue:0x0b];
    }
    
}

-(void)writeValue:(UInt8)val_p
{
    NSLog(@"%hhu", val_p);
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

#pragma mark - 读取文件数据

- (void)readFileData{
    NSError *error;
    NSData *jsonData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"binary_list"
                                                                             withExtension:@"json"]];
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:kNilOptions
                                                        error:&error];
    if (!error) {
        NSArray *arrBinaries = [d objectForKey:@"binaries"];
        NSDictionary *dicBinary = [arrBinaries firstObject];
        NSURL *urlFirware = [[NSBundle mainBundle] URLForResource:[dicBinary objectForKey:@"filename"]
                                                    withExtension:[dicBinary objectForKey:@"extension"]];
        self.dataFirware = [NSData dataWithContentsOfURL:urlFirware];
        
    }else{
        NSLog(@"error:%@", error);
    }
   
    
}

@end
