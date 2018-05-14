//
//  ZJCustomViewController.m
//  BlueToothModel
//
//  Created by zitang on 2018/5/11.
//  Copyright © 2018年 zitang. All rights reserved.
//

#import "ZJCustomViewController.h"
#import "ZJBlueToothManager.h"

@interface ZJCustomViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

/**
 蓝牙模块
 */
@property (nonatomic, strong) ZJBlueToothManager *blueMang;

/**
 显示的数据
 */
@property (nonatomic, strong) NSMutableArray<CBPeripheral*> *showDataArr;

@end

@implementation ZJCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showDataArr = [NSMutableArray array];
    self.blueMang = [[ZJBlueToothManager alloc]init];
    __weak typeof(self) weakSelf = self;
    self.blueMang.BlueResultBlock = ^(NSArray *dataArr) {
      //返回的蓝牙扫描结果
        weakSelf.showDataArr = [NSMutableArray arrayWithArray:dataArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.myTableView reloadData];
        });
    };
    self.blueMang.conResult = ^(BOOL isSucc, NSString *error) {
        NSLog(@"连接的结果==%ld==%@",isSucc,error);
    };
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.showDataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"systemCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"systemCell"];
    }
    cell.textLabel.text = self.showDataArr[indexPath.row].name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.blueMang connectPeripheral:self.showDataArr[indexPath.row]];
}

@end
