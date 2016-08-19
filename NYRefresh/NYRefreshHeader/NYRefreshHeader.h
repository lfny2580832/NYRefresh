//
//  NYRefreshHeader.h
//  NYRefresh
//
//  Created by 牛严 on 16/8/5.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+NYRefresh.h"

typedef void (^NYHeadRefreshingBlock)();

typedef NS_ENUM(NSInteger, NYRefreshHeadType)
{
    NYRefreshPullDown,
    NYRefreshLoading,
    NYRefreshRelease
};

@interface NYRefreshHeader : UIView

//当控件较多时会选用set枚举的方式统一设置
@property (nonatomic, copy) NSString *titlePullDown;
@property (nonatomic, copy) NSString *titleLoading;
@property (nonatomic, copy) NSString *titleRelease;

@property (nonatomic, copy) NYHeadRefreshingBlock refreshingBlock;


- (instancetype)initWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

- (instancetype)initWithHeadRefreshingBlock:(NYHeadRefreshingBlock)block;

- (void)endRefreshing;


@end
