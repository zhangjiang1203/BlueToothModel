//
//  ZJBlueToothManager.m
//  BlueToothModel
//
//  Created by zitang on 2018/5/11.
//  Copyright © 2018年 zitang. All rights reserved.
//

#import "ZJBlueToothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ZJBlueToothManager()<CBCentralManagerDelegate>

/**
 蓝牙中心管理者
 */
@property (nonatomic, strong) CBCentralManager *cmgr;

@end

@implementation ZJBlueToothManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cmgr = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];

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

//扫描到设备进入的代理方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"%s,line = %d,per=%@,data=%@,rssi = %@",__FUNCTION__,__LINE__,peripheral,advertisementData,RSSI);
}


@end
