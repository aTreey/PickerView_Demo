//
//  LTPickerView.h
//  LTPickerView
//
//  Created by LaoTao on 15/9/7.
//  Copyright (c) 2015年 LaoTao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LTPickerView;

@protocol LTPickerViewDelegate <NSObject>

@optional
- (void)toolBarDoneButtonHaveClicked:(LTPickerView *)pickerView resultString:(NSString *)resultString;

@end

@interface LTPickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<LTPickerViewDelegate> delegate;

- (void)setDoneClickBlock:(void (^)(LTPickerView *pickerView, NSString *resultString))doneBlock;
- (void)setDoneClickBlock:(void (^)(LTPickerView *pickerView, NSString *resultString))doneBlock
              cancelBlock:(void (^)(LTPickerView *pickerView))cancelBlock;

- (instancetype)initPickerViewWithArray:(NSArray *)array title:(NSString *)title;

/**
 *  通过时间创建一个DatePicker
 *  
 *  @param date 默认选中时间
 *  @param isHaveNavController 是否在NavController之内
 *
 *  @return 带有toolBar的datePicker
 */
- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate datePickerMode:(UIDatePickerMode)datePickerMode title:(NSString *)title;

/**
 *  移除本控件
 */
- (void)remove;

/**
 *  显示本控件
 */
- (void)show;

/**
 *  设置PickerView的颜色
 */
- (void)setPickerViewColor:(UIColor *)color;

/**
 *  设置toolBar的文字颜色
 */
- (void)setTintColor:(UIColor *)tintColor;

/**
 *  设置toolBar的背景颜色
 */
- (void)setToolBarTintColor:(UIColor *)color;

/**
 *  设置toolBar中间title标题
 */

/**
 *  设置选中行
 */
- (void)setSeletedRow:(NSInteger)row;
- (void)setSelectedRows:(NSArray *)rows;
- (void)setDatePickerMaxTime:(NSDate *)date;

@end
