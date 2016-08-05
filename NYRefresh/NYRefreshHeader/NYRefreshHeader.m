//
//  NYRefreshHeader.m
//  NYRefresh
//
//  Created by 牛严 on 16/8/5.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "NYRefreshHeader.h"
#import "UIView+NYRefresh.h"

const CGFloat NYRefreshHeaderHeight = 35.0;
const CGFloat NYRefreshHeaderWidth = 200;


@interface NYRefreshHeader ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat offsetY;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, assign) CGFloat lastPosition;

@end

@implementation NYRefreshHeader

+ (instancetype)headerWithRefreshing
{
    NYRefreshHeader *cmp = [[self alloc] init];
    return cmp;
}


- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, NYRefreshHeaderWidth, NYRefreshHeaderHeight)];
    if (self) {
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
    //判断是否在拖动scrollview
    if (self.scrollView.dragging) {
        //判断是否在刷新状态
        if (!self.isRefresh) {
            if (offsetY < 50) {
                self.statusLabel.text = @"释放";
            }else{
                // 判断滑动方向 以让“松开以刷新”变回“下拉可刷新”状态
                if (offsetY - _lastPosition > 5) {
                    _lastPosition = offsetY;
                    self.statusLabel.text = @"下拉";
                }
            }
        }
    }else{
        //进入刷新状态
        if ([self.statusLabel.text isEqualToString:@"释放"]) {
            [self beginRefreshing];
        }
    }
}

#pragma mark Private
- (void)beginRefreshing
{
    self.isRefresh = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint point = self.scrollView.contentOffset;
        if (point.y != 0) {
            self.scrollView.contentOffset = CGPointMake(0, point.y + 50);
        }
        self.statusLabel.text = @"下拉";
        self.scrollView.contentInset = UIEdgeInsetsZero;
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
