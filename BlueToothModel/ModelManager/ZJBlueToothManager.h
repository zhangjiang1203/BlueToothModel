//
//  ZJBlueToothManager.h
//  BlueToothModel
//
//  Created by zitang on 2018/5/11.
//  Copyright © 2018年 zitang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^ConnectResult)(BOOL isSucc,NSString *error);

@interface ZJBlueToothManager : NSObject

/**
 返回的蓝牙搜索的结果
 */
@property (nonatomic, copy) void (^BlueResultBlock)(NSArray *dataArr);

/**
 蓝牙的连接结果
 */
@property (nonatomic, copy) ConnectResult conResult;

/**
 开始连接外设

 @param peripheral 外围设备
 */
-(void)connectPeripheral:(CBPeripheral*)peripheral;

@end
