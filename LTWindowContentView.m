//
//  LTWindowContentView.m
//  LTPickerView
//
//  Created by LaoTao on 15/9/7.
//  Copyright (c) 2015年 LaoTao. All rights reserved.
//

#import "LTWindowContentView.h"

@implementation LTWindowContentView
{
    UIView *_backgroundView;
//    UIImageView *_backgroundView;
}

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, MainScreenWidth, MainScreenHeight);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight)];
    
    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self addSubview:_backgroundView];
    [self bringSubviewToFront:_backgroundView];
}

- (void)setCustomView:(UIView *)customView {
    
    _customView = customView;
    
    [self addSubview:customView];
    [self bringSubviewToFront:customView];
}


- (void)show {
    
    self.frame = CGRectMake(0, 0, MainScreenWidth, MainScreenHeight);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
}
- (void)showInView:(UIView *)superView animated:(BOOL)animated {
    
    // 动画不需要添加， 后面可以去掉，使用系统自身的就可以
    self.frame = superView.bounds;
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
//    CGRect originFrame = _customView.frame;
    
    /*
    if (superView) {
        _backgroundView.frame = superView.bounds;
        [superView addSubview:self];
        
        if (animated) {
            CGRect new = CGRectMake(originFrame.origin.x, originFrame.origin.y + superView.frame.size.height, originFrame.size.width, originFrame.size.height);
            _customView.frame = new;
            
            _backgroundView.alpha = 0.02;
            
            [UIView animateWithDuration:0.2 animations:^{
                _backgroundView.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    _customView.frame = originFrame;
                } completion:^(BOOL finished) { //往回抖动
                    [UIView animateWithDuration:0.1 animations:^{
                        CGRect newFrame = CGRectMake(originFrame.origin.x, originFrame.origin.y * 1.2, originFrame.size.width, originFrame.size.height);
                        _customView.frame = newFrame;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.08 animations:^{
                            _customView.frame = originFrame;
                        }];
                    }];
                }];
            }];
        }
    }
    */
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dissMiss];
}

- (void)dissMiss {
    if (self.customView) {
        [self.customView removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (void)dealloc {
    NSLog(@"释放掉了dealloc:window");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
