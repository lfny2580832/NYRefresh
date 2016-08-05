//
//  ViewController.m
//  NYRefresh
//
//  Created by 牛严 on 16/8/5.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "ViewController.h"
#import "TestVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 50, 100, 100)];
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)test
{
    TestVC *vc = [[TestVC alloc]init];
        UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navVC animated:NO completion:nil];
}
@end
