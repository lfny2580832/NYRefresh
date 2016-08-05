//
//  TestVC.m
//  NYRefresh
//
//  Created by 牛严 on 16/8/5.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "TestVC.h"
#import "NYRefreshHeader/NYRefreshHeader.h"

@interface TestVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation TestVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"测试VC";
        self.view.backgroundColor = [UIColor grayColor];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 375, self.view.bounds.size.height) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.ny_header = [NYRefreshHeader headerWithRefreshing];
        [self.view addSubview:self.tableView];

    }
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:0.0277 green:0.7235 blue:0.5135 alpha:1.0];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
