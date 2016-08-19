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

const CGFloat NYRefreshHeaderHeight = 50.0;
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

///RefreshType
@property (nonatomic, assign) NYRefreshHeadType refreshType;

///Target
@property (weak, nonatomic) id refreshingTarget;

///Action
@property (assign, nonatomic) SEL refreshingAction;

@end

@implementation NYRefreshHeader
{
    NSMutableArray *_refreshImages;
}

#pragma mark 初始化方法
- (instancetype)initWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    self = [self initWithFrame:CGRectMake(0, - NYRefreshHeaderHeight, NYRefreshHeaderWidth, NYRefreshHeaderHeight)];
    if (self) {
        self.refreshingTarget = target;
        self.refreshingAction = action;
    }
    return self;
}

- (instancetype)initWithHeadRefreshingBlock:(NYHeadRefreshingBlock)block
{
    self = [self initWithFrame:CGRectMake(0, - NYRefreshHeaderHeight, NYRefreshHeaderWidth, NYRefreshHeaderHeight)];
    if (self) {
        self.refreshingBlock = block;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isRefresh = NO;
        self.refreshType = NYRefreshPullDown;
        
        self.titleLoading = @"加载中";
        self.titleRelease = @"释放以刷新";
        self.titlePullDown = @"下拉以刷新";
        
//        [self addSubview:self.statusLabel];
        [self addSubview:self.imageView];
        
        [self loadRefreshImages];

    }
    return self;
}

- (void)loadRefreshImages
{
    _refreshImages = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i = 50; i < 120; i ++) {
        [_refreshImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"headrefresh%03d",i]]];
    }
    self.imageView.animationImages = _refreshImages;
    self.imageView.animationDuration = 1.4;
    self.imageView.animationRepeatCount = 0;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.centerX = self.window.centerX;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        self.offsetY = - self.scrollView.contentOffset.y;
    }
}

#pragma mark 设置刷新状态
- (void)setRefreshType:(NYRefreshHeadType)refreshType
{
    _refreshType = refreshType;
    if (refreshType == NYRefreshRelease)
    {
        self.statusLabel.text = self.titleRelease;
    }
    else if (refreshType == NYRefreshLoading)
    {
        self.statusLabel.text = self.titleLoading;
    }
    else if (refreshType == NYRefreshPullDown)
    {
        self.statusLabel.text = self.titlePullDown;
    }
}

#pragma mark SetOffsetY
- (void)setOffsetY:(CGFloat)offsetY
{
    _offsetY = offsetY;
    
    //---------------设置下拉时的图片动画---------------
    [self setPullDownImage];
    
    //判断是否在拖动scrollview
    if (self.scrollView.dragging)
    {
        //判断是否在刷新状态
        if (!self.isRefresh) {
            if (offsetY < NYRefreshHeaderHeight * 1.5)
            {
                self.refreshType = NYRefreshPullDown;
            }
            else{
                // 判断滑动方向 以让“松开以刷新”变回“下拉可刷新”状态
                if (offsetY - _lastPosition > 5) {
                    self.lastPosition = offsetY;
                    self.lastPosition = 0;
                    
                    self.refreshType = NYRefreshRelease;
                }
            }
        }
    }
    else
    {
        //进入刷新状态
        if (self.refreshType == NYRefreshRelease) {
            [self beginRefreshing];
        }
    }
}

- (void)setPullDownImage
{
    //手在屏幕上下拉动时
    if (self.scrollView.dragging)
    {
        if (self.offsetY > 25 && self.offsetY < 75)
        {
            int imageIndex = (int)(self.offsetY- 25);
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"headpull%02d",imageIndex]];
            self.imageView.image = image;
        }
        else if (self.offsetY >= 75)
        {
            UIImage *image = [UIImage imageNamed:@"headpull49"];
            self.imageView.image = image;
        }
    }
}

#pragma mark 开启 关闭刷新
- (void)beginRefreshing
{
    if (!self.isRefresh) {
        self.isRefresh = YES;
        self.refreshType = NYRefreshLoading;
        
        //执行刷新动画
        [self.imageView startAnimating];
        
        // 设置刷新状态_scrollView的位置
        [UIView animateWithDuration:0.3 animations:^
        {
            self.scrollView.contentInset = UIEdgeInsetsMake(75, 0, 0, 0);
            self.lastPosition = 0;
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
//                _scrollView.contentOffset=CGPointMake(0, point.y + NYRefreshHeaderHeight * 1.5);
                _scrollView.contentOffset=CGPointMake(0, point.y + 75);

            }
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            self.refreshType = NYRefreshPullDown;
            [self.imageView stopAnimating];
            self.imageView.image = [UIImage imageNamed:@"headpull01"];
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
        _statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 25, 100, 25)];
        _statusLabel.text = _titlePullDown;
        
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _statusLabel;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.width - 80)/2, 0, 80, 50)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = [UIImage imageNamed:@"headpull01"];
    }
    return _imageView;
}


@end
