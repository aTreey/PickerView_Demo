//
//  LTWindowContentView.h
//  LTPickerView
//
//  Created by LaoTao on 15/9/7.
//  Copyright (c) 2015年 LaoTao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTWindowContentView : UIView
{
    
}


@property (weak, nonatomic) UIView *customView;

- (void)showInView:(UIView *)superView animated:(BOOL)animated;
- (void)show;

- (void)dissMiss;

@end
