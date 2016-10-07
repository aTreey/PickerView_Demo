//
//  LTDrugPickerView.m
//  HealthGuard
//
//  Created by LaoTao on 16/6/8.
//  Copyright © 2016年 LaoTao. All rights reserved.
//

#import "LTDrugPickerView.h"

@implementation LTDrugPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (void)setPickerView {
//    [super setPickerView];
//    self.pickerView.delegate = self;
//    self.pickerView.dataSource = self;
//}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (pickerView.numberOfComponents == 5) {
        if (component == 3) {   //小数点
            return pickerView.frame.size.width / 20;
        }else if (component == 4) {
            return pickerView.frame.size.width / 20 * 7;
        }else {
            return pickerView.frame.size.width / 5;
        }
    }
    
    return pickerView.frame.size.width;
}

//iPhone 4, iPhone 5服药 单位显示不全的问题
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    if (_elementClass == LTArrayElementClassArray) {
//
//        if (_plistArray.count == 5) {
//            if (component == 3) {
//                return pickerView.frame.size.width / 10;
//            }else if (component == 4) {
//                return pickerView.frame.size.width / 10 * 3;
//            }else {
//                return pickerView.frame.size.width / 5;
//            }
//        }
//
//        return pickerView.frame.size.width / _plistArray.count;
//    }
//
//    return pickerView.frame.size.width;
//}



@end
