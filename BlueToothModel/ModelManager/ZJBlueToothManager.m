//
//  ZJBlueToothManager.m
//  BlueToothModel
//
//  Created by zitang on 2018/5/11.
//  Copyright © 2018年 zitang. All rights reserved.
//

#import "ZJBlueToothManager.h"

@interface ZJBlueToothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

/**
 蓝牙中心管理者
 */
@property (nonatomic, strong) CBCentralManager *cmgr;

/**
 蓝牙数组
 */
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *blueArr;

/**
 外围设备
 */
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation ZJBlueToothManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cmgr = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
        self.blueArr = [NSMutableArray array];
    }
    return self;
}

#pragma mark -CBCenterManager的代理方法
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    //blue的状态显示
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"未知状态");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"打开状态");
            //开始扫描设备
            //第一个参数为nil 表示扫描所有的外设
            //[CBUUID UUIDWithString:@"指定的设备"]
            [self.cmgr scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBManagerStateResetting:
            NSLog(@"重置状态");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"关闭状态");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"不支持");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"未授权");
            break;
            
    }
}

#pragma mark -第一步开始扫描外设
//扫描到设备进入的代理方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    /*
     一个主设备最多能连7个外设，每个外设最多只能给一个主设备连接，连接成功 失败 断开会进入各自的代理方法中
     - (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;//连接外设成功
     - (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//外设连接失败
     - (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//断开外设

     */
    if (peripheral.name){
//        NSLog(@"%s,line = %d,per=%@,data=%@,rssi = %@",__FUNCTION__,__LINE__,peripheral,advertisementData,RSSI);
        if (![self.blueArr containsObject:peripheral]){
            if (self.BlueResultBlock) {
                [self.blueArr addObject:peripheral];
                self.BlueResultBlock(self.blueArr);
            }
        }
    }
}

-(void)connectPeripheral:(CBPeripheral *)peripheral{
    self.peripheral = peripheral;
    [self.cmgr connectPeripheral:peripheral options:nil];
}

#pragma mark -第二部连接外设
//外设连接成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接外设==%@==成功",peripheral.name);
    if (self.conResult) {
        self.conResult(YES, nil);
    }
    //设置peripheral代理文件
    [peripheral setDelegate:self];
    //扫描外设service 成功后会进入方法-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [peripheral discoverServices:nil];
}
//连接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接失败==%@==",peripheral.name);
    if (self.conResult) {
        self.conResult(NO, error?error.description:@"");
    }
}

//断开外设连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接失败==%@==",peripheral.name);
    if (self.conResult) {
        self.conResult(error?NO:YES, error?error.description:@"");
        return;
    }
}

#pragma mark -第三步扫描外设中的服务和特征 CBPeripheralDelegate
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //发现外设
    if (error) {
        NSLog(@"discovered services for %@ with error:%@",peripheral.name,[error localizedDescription]);
    }
    for (CBService *service in peripheral.services){
        NSLog(@"service.UUID=%@",service.UUID);
        //扫描每个servicecharacteristics 扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//发现外设的service的特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"discovered services for %@ with error:%@",peripheral.name,[error localizedDescription]);
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        //获取characteristic的值，读到数据会进入-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral readValueForCharacteristic:characteristic];
        //搜索characterstic的Description，读到数据会进入-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

#pragma mark -第五步获取characteristic的值和description的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    //打印出characteristic的UUID的值
    //value的类型是NSDATA
    NSLog(@"%s, line = %d, characteristic.UUID:%@  value:%@", __FUNCTION__, __LINE__, characteristic.UUID, characteristic.value);
}

// 发现特征Characteristics的描述Descriptor
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        NSLog(@"descriptor.UUID:%@",descriptor.UUID);
    }
}

//#pragma mark -写数据到特征中
//-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//
//}


@end
