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


@interface NYRefreshHeader : UIView

@property (nonatomic, copy) NSString *titlePullDown;
@property (nonatomic, copy) NSString *titleLoading;
@property (nonatomic, copy) NSString *titleRelease;

@property (nonatomic, copy) NYHeadRefreshingBlock refreshingBlock;




- (instancetype)initWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

- (instancetype)initWithHeadRefreshingBlock:(NYHeadRefreshingBlock)block;

- (void)endRefreshing;


@end
