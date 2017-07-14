//
//  ViewController.m
//  JJCommonCollectionViewLayoutDemo
//
//  Created by 房俊杰 on 2017/7/14.
//  Copyright © 2017年 房俊杰. All rights reserved.
//

#import "ViewController.h"

#import "FlowViewController.h"
#import "SquareViewController.h"
#import "ComplexViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 数据源 */
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dataArray = @[@"瀑布流",@"九宫格",@"复杂样式",@"样式自定义，只需遵守代理即可"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}
#pragma mark - 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *base = [[NSClassFromString(@[@"FlowViewController",@"SquareViewController",@"ComplexViewController"][indexPath.row]) alloc] init];
    base.title = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:base animated:YES];
}

@end














































