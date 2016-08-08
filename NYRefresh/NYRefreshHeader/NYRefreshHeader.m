//
//  NYRefreshHeader.m
//  NYRefresh
//
//  Created by 牛严 on 16/8/5.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "NYRefreshHeader.h"
#import "UIView+NYRefresh.h"

#import <objc/message.h>

const CGFloat NYRefreshHeaderHeight = 35.0;
const CGFloat NYRefreshHeaderWidth = 200;

#define NYRefreshMsgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define NYRefreshMsgTarget(target) (__bridge void *)(target)

@interface NYRefreshHeader ()

@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, assign) CGFloat lastPosition;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *statusLabel;

///Target
@property (weak, nonatomic) id refreshingTarget;

///Action
@property (assign, nonatomic) SEL refreshingAction;

@end

@implementation NYRefreshHeader

#pragma mark 初始化方法
- (instancetype)initWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    self = [super initWithFrame:CGRectMake(0, -NYRefreshHeaderHeight, NYRefreshHeaderWidth, NYRefreshHeaderHeight)];
    if (self) {
        self.refreshingTarget = target;
        self.refreshingAction = action;
    }
    return self;
}

- (instancetype)initWithHeadRefreshingBlock:(NYHeadRefreshingBlock)block
{
    self = [super init];
    if (self) {
        self.refreshingBlock = block;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isRefresh = NO;
        
        self.titleLoading = @"加载中";
        self.titleRelease = @"释放以刷新";
        self.titlePullDown = @"下拉以刷新";
        
        [self addSubview:self.statusLabel];
    }
    return self;
}
#pragma mark Override
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        self.scrollView = (UIScrollView *)newSuperview;
        self.center = CGPointMake(self.scrollView.centerX, self.centerY);
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }else{
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        self.offsetY = - self.scrollView.contentOffset.y;
    }
}

#pragma mark SetOffsetY
- (void)setOffsetY:(CGFloat)offsetY
{
    _offsetY = offsetY;
    NSLog(@"offset %f",offsetY);
    //判断是否在拖动scrollview
    if (self.scrollView.dragging) {
        //判断是否在刷新状态
        if (!self.isRefresh) {
            if (offsetY < NYRefreshHeaderHeight * 1.5) {
                self.statusLabel.text = self.titlePullDown;
            }else{
                // 判断滑动方向 以让“松开以刷新”变回“下拉可刷新”状态
                if (offsetY - _lastPosition > 5) {
                    _lastPosition = offsetY;
                    self.statusLabel.text = self.titleRelease;
                }
            }
        }
    }else{
        //进入刷新状态
        if ([self.statusLabel.text isEqualToString:self.titleRelease]) {
            [self beginRefreshing];
        }
    }
}

#pragma mark 开启 关闭刷新
- (void)beginRefreshing
{
    if (!self.isRefresh) {
        self.isRefresh = YES;
        self.statusLabel.text = self.titleLoading;
        
        // 设置刷新状态_scrollView的位置
        [UIView animateWithDuration:0.3 animations:^
        {
            //修改有时候refresh contentOffset 还在0，0的情况 20150723
            CGPoint point = self.scrollView.contentOffset;
            if (point.y > - NYRefreshHeaderHeight * 1.5)
            {
                self.scrollView.contentOffset=CGPointMake(0, point.y - NYRefreshHeaderHeight * 1.5);
            }
            self.scrollView.contentInset=UIEdgeInsetsMake(50, 0, 0, 0);
        }];
    }
    
    [self executeRefreshingCallback];
}

- (void)endRefreshing
{
    self.isRefresh = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            CGPoint point= _scrollView.contentOffset;
            if (point.y!=0) {
                _scrollView.contentOffset=CGPointMake(0, point.y + NYRefreshHeaderHeight * 1.5);
            }
            self.statusLabel.text = self.titlePullDown;
            self.scrollView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
        }];
    });
}

#pragma mark - 执行刷新过程中的操作
- (void)executeRefreshingCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.refreshingBlock) {
            self.refreshingBlock();
        }
        if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
            NYRefreshMsgSend(NYRefreshMsgTarget(self.refreshingTarget), self.refreshingAction, self);
        }
    });
}

#pragma mark Get
- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, NYRefreshHeaderHeight)];
        _statusLabel.text = @"下拉";
    }
    return _statusLabel;
}

@end
