//
//  ZJCustomViewController.m
//  BlueToothModel
//
//  Created by zitang on 2018/5/11.
//  Copyright © 2018年 zitang. All rights reserved.
//

#import "ZJCustomViewController.h"
#import "ZJBlueToothManager.h"

@interface ZJCustomViewController ()

/**
 蓝牙模块
 */
@property (nonatomic, strong) ZJBlueToothManager *blueMang;

@end

@implementation ZJCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blueMang = [[ZJBlueToothManager alloc]init];
    
}


@end
