//
//  UIScrollView+NYRefresh.h
//  NYRefresh
//
//  Created by 牛严 on 16/8/5.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NYRefreshHeader;

@interface UIScrollView (NYRefresh)

///headerView视图层级，需在headerView之前设置
@property (nonatomic, assign) NSInteger headerViewIndex;

@property (nonatomic, strong) NYRefreshHeader *ny_header;


@end
