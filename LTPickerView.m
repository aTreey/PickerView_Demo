//
//  LTPickerView.m
//  LTPickerView
//
//  Created by LaoTao on 15/9/7.
//  Copyright (c) 2015年 LaoTao. All rights reserved.
//

#import "LTPickerView.h"

#define LTToolbarHeight 40
#define LTPickerHeight 216
#define LTPickerArray @""


typedef NS_ENUM(NSInteger, LTArrayElementClass) {
    LTArrayElementClassArray = 0,
    LTArrayElementClassString,
    LTArrayElementClassDictionary,
};


@interface LTPickerView ()

@property (copy, nonatomic) void (^cancalClicked)(LTPickerView *pickerView);
@property (copy, nonatomic) void (^doneClicked)(LTPickerView *pickerView, NSString *resultString);

@property (strong, nonatomic) UIToolbar *toolBar;           //toolBar
@property (strong, nonatomic) UIPickerView *pickerView;     //选择器
@property (strong, nonatomic) UIDatePicker *datePicker;     //日期选择器
@property (strong, nonatomic) NSDate *defaultDate;          //默认显示的日期
@property (copy, nonatomic) NSString *resultString;
@property (strong, nonatomic) UILabel *toolCenterLabel;     //toolBar中间的Title Label

//@property (assign, nonatomic) NSInteger pickerViewHeight;   //pickerView的高度

@property (nonatomic, strong) UIView * bgView;

@property (assign, nonatomic) LTArrayElementClass elementClass; //数组元素的类型
@property (strong, nonatomic) NSArray *plistArray;
@property (strong, nonatomic) NSMutableArray *dicKeyArray;  //保存字典数组中所有key的数组

@end

@implementation LTPickerView
{
    BOOL _tapBOOL;
    CGFloat _width;
    CGFloat _height;
    NSMutableArray *_resultArray;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setDoneClickBlock:(void (^)(LTPickerView *pickerView, NSString *resultString))doneBlock {
    _doneClicked = [doneBlock copy];
}

- (void)setDoneClickBlock:(void (^)(LTPickerView *pickerView, NSString *resultString))doneBlock
              cancelBlock:(void (^)(LTPickerView *pickerView))cancelBlock {
    _doneClicked = [doneBlock copy];
    _cancalClicked = [cancelBlock copy];
}

- (NSArray *)plistArray {
    if (_plistArray == nil) {
        _plistArray = [NSArray array];
    }
    return _plistArray;
}

- (instancetype)init {
    if (self = [super init]) {
        
        _height = [UIScreen mainScreen].bounds.size.height;
        _width = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(0, 0, _width, _height);
        
        _resultString = @"";
        [self customUI];
        [self setToolBar];
    }
    return self;
}

- (void)customUI {
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _width, _height)];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _width, _height)];
    [_bgView addSubview:backgroundView];
    
    [self addSubview:_bgView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewTapGesture)];
    
    _tapBOOL = YES;
    [self addGestureRecognizer:tap];
}

/**
 *  判断数组元素的类型
 */
- (void)setArrayClass:(NSArray *)array {
    _dicKeyArray = [NSMutableArray array];
    
    for (id obj in array) {
        if ([obj isKindOfClass:[NSArray class]]) {
            _elementClass = LTArrayElementClassArray;
            _resultArray = [NSMutableArray array];
            for (int i = 0; i < array.count; i++) {
                NSArray *arr = array[i];
                if (arr.count > 0) {
                    [_resultArray addObject:[NSString stringWithFormat:@"%@", arr[0]]];
                }else {
                    [_resultArray addObject:@""];
                }
            }
            
            _resultString = [_resultArray componentsJoinedByString:LTPickerArray];
            break;
        }else if ([obj isKindOfClass:[NSString class]]) {
            _resultString = array.count ? array[0] : @"";
            _elementClass = LTArrayElementClassString;
            break;
        }else if ([obj isKindOfClass:[NSDictionary class]]) {
            _elementClass = LTArrayElementClassDictionary;
            [_dicKeyArray addObject:[obj allKeys]];
            break;
        }
    }
}

#pragma mark - 初始化 UIPickerView
- (instancetype)initPickerViewWithArray:(NSArray *)array title:(NSString *)title {
    self = [self init];
    if (self) {
        self.plistArray = array;
        [self setArrayClass:array];
        [self setPickerView];
        [self setToolBarCenterTitle:title];
    }
    return self;
}

#pragma mark - 初始化 UIDatePickerView
- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate datePickerMode:(UIDatePickerMode)datePickerMode title:(NSString *)title {
    if (self = [self init]) {
        
        _defaultDate = defaultDate;
        [self setDatePickerWithDatePickerMode:datePickerMode];
        [self setToolBarCenterTitle:title];
    }
    return self;
}

/**
 *  pickerView
 */
#pragma mark - 创建pickerView
- (void)setPickerView {
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, _height - LTPickerHeight, [UIScreen mainScreen].bounds.size.width, LTPickerHeight)];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [self.bgView addSubview:pickerView];
    
//    NSLog(@"pickerView:%@", NSStringFromCGRect(pickerView.frame));
//    NSLog(@"%@", NSStringFromCGRect(self.bgView.frame));
    _pickerView = pickerView;
}

#pragma mark - 创建datePicker
- (void)setDatePickerWithDatePickerMode:(UIDatePickerMode)datePickerMode {
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, _height - LTPickerHeight, [UIScreen mainScreen].bounds.size.width, LTPickerHeight)];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];

    //如果是显示小时的样式，不设置最大时间限制 add By Tao 2016-01-21 11:37
    if (datePickerMode != UIDatePickerModeTime) {
        datePicker.maximumDate = [NSDate date];
    }
    
    //设置最小时间值。目前为 1901-1-1 00:00:00
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:-2177481600];
    
    datePicker.datePickerMode = datePickerMode;
    datePicker.backgroundColor = [UIColor whiteColor];
    
    if (_defaultDate) {
        [datePicker setDate:_defaultDate];
    }
    
    [self.bgView addSubview:datePicker];
    
    _datePicker = datePicker;
}

/**
 *  设置ToolBar
 */
- (void)setToolBar {
    _toolBar = [self setToolBarStyle];
    _toolBar.frame = CGRectMake(0, _height - LTPickerHeight - LTToolbarHeight, [UIScreen mainScreen].bounds.size.width, LTToolbarHeight);
    [self.bgView addSubview:_toolBar];
}

- (UIToolbar *)setToolBarStyle {
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.backgroundColor = [UIColor colorWithRed:((((0xadadad)>>16)&0xFF))/255. green:((((0xadadad)>>8)&0xFF))/255.  blue:((((0xadadad)>>0)&0xFF))/255. alpha:1];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定  " style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked)];
    
    //追加间距对象UIBarButtonSystemItemFlexibleSpace
    UIBarButtonItem *centerSpate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    _toolCenterLabel = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) / 2, 10, 200, 20)];
    _toolCenterLabel.textAlignment = NSTextAlignmentCenter;
    _toolCenterLabel.font = [UIFont systemFontOfSize:14];
    centerSpate.customView = _toolCenterLabel;
    
    toolBar.items = @[leftItem, centerSpate, rightItem];
    
    return toolBar;
}

/**
 *  设置PickerView的颜色
 */
- (void)setPickerViewColor:(UIColor *)color {
    _pickerView.backgroundColor = color;
}

/**
 *  设置toolBar的文字颜色
 */
- (void)setTintColor:(UIColor *)tintColor {
    _toolBar.tintColor = tintColor;
}

/**
 *  设置toolBar的背景颜色
 */
- (void)setToolBarTintColor:(UIColor *)color {
    _toolBar.barTintColor = color;
}

/**
 *  设置toolBar中间title标题
 */
- (void)setToolBarCenterTitle:(NSString *)title {
    _toolCenterLabel.text = title;
}

/**
 *  设置选中行
 */
- (void)setSeletedRow:(NSInteger)row {
    
    if (row >= _plistArray.count) {
        _resultString = _plistArray[0];
        [_pickerView selectRow:0 inComponent:0 animated:YES];
        return;
    }
    switch (_elementClass) {
        case LTArrayElementClassString:
            _resultString = [NSString stringWithFormat:@"%@", _plistArray[row]];
            break;
        case LTArrayElementClassArray:
            //数组部分，需要后续维护，修改。 add By LaoTao 2015-09-09 10:02
            for (int i = 0; i < _plistArray.count; i++) {
                _resultString = [NSString stringWithFormat:@"%@", _plistArray[i][row]];
            }
            break;
        case LTArrayElementClassDictionary:
            //字典和数组内容需要再优化 add By LaoTao 22:17
            
        default:
            break;
    }
    
    [_pickerView selectRow:row inComponent:0 animated:YES];
}

- (void)setSelectedRows:(NSArray *)rows {
    
    for (int i = 0; i < rows.count; i++) {
        NSInteger index = [rows[i] integerValue];
        [_pickerView selectRow:index inComponent:i animated:YES];
        //设置默认选中的内容
        _resultString = [NSString stringWithFormat:@"%@%@", _resultString, _plistArray[i][index]];
    }
}

- (void)setDatePickerMaxTime:(NSDate *)date {
    _datePicker.maximumDate = date;
}

#pragma mark - pickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    NSInteger component = 0;
    switch (_elementClass) {
        case LTArrayElementClassArray:      //二维数组
            component = _plistArray.count;
            break;
        case LTArrayElementClassString:
            component = 1;
            break;
        case LTArrayElementClassDictionary:
            //字典类型，需要再优化算法内容。 待定 add By LaoTao 2015-9-7 22:03
//            component = _dicKeyArray.count;
            component = 2;
            break;
        default:
            break;
    }
    
    return component;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *rowArray;
    switch (_elementClass) {
        case LTArrayElementClassArray:
            rowArray = _plistArray[component];  //二维数组
            break;
        case LTArrayElementClassString:
            rowArray = _plistArray;
            break;
        case LTArrayElementClassDictionary:
            //字典类型，需要再优化算法内容。 待定 add By LaoTao 2015-9-7 22:03
            /*
            NSInteger pIndex = [pickerView selectedRowInComponent:0];
            NSDictionary *dic=_plistArray[pIndex];
            for (id dicValue in [dic allValues]) {
                if ([dicValue isKindOfClass:[NSArray class]]) {
                    if (component%2==1) {
                        rowArray=dicValue;
                    }else{
                        rowArray=_plistArray;
                    }
                }
            }
             */
            rowArray = [NSArray array];
            
            break;
        default:
            break;
    }
    
    return rowArray.count;
}

#pragma mark - UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *rowTitle = @"";
    
    switch (_elementClass) {
        case LTArrayElementClassArray:
            rowTitle = _plistArray[component][row];
            break;
        case LTArrayElementClassString:
            rowTitle = _plistArray[row];
            break;
        case LTArrayElementClassDictionary:
            //字典类型，需要再优化算法内容。 待定 add By LaoTao 2015-9-7 22:03
            /*
            NSInteger pIndex = [pickerView selectedRowInComponent:0];
            NSDictionary *dic=_plistArray[pIndex];
            if(component%2==0)
            {
                rowTitle=_dicKeyArray[row][component];
            }
            for (id aa in [dic allValues]) {
                if ([aa isKindOfClass:[NSArray class]]&&component%2==1){
                    NSArray *bb=aa;
                    if (bb.count>row) {
                        rowTitle=aa[row];
                    }
                }
            }
             */
            
            
            break;
        default:
            break;
    }

    return rowTitle;
}

//iPhone 4, iPhone 5服药 单位显示不全的问题
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    if (_elementClass == LTArrayElementClassArray) {
//        
//        if (_plistArray.count == 5) {
//            if (component == 3) {
//                return pickerView.frame.size.width / 20;
//            }else if (component == 4) {
//                return pickerView.frame.size.width / 20 * 7;
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


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (_elementClass) {
        case LTArrayElementClassArray:
//            NSLog(@"%@", _plistArray);
            _resultArray[component] = [NSString stringWithFormat:@"%@", _plistArray[component][row]];
            _resultString = [_resultArray componentsJoinedByString:LTPickerArray];
            
            break;
        case LTArrayElementClassString:
            _resultString = _plistArray[row];
            break;
        case LTArrayElementClassDictionary:
            //字典类型，需要再优化算法内容。 待定 add By LaoTao 2015-9-7 22:03
        {
            
        }
            
            break;
        default:
            break;
    }
}

#pragma mark - 显示pickerView
- (void)show {
    UIView * view = [UIApplication sharedApplication].keyWindow;
    [view addSubview:self];
//    NSLog(@"frame:%@,%@", NSStringFromCGRect(view.frame), NSStringFromCGRect(_pickerView.frame));
}

#pragma mark - 移除pickerView
- (void)remove {
    if (_cancalClicked != nil) {
        self.cancalClicked(self);
    }
    
    [self removeFromSuperview];
//    NSLog(@"remove");
}

- (void)bgViewTapGesture {
    if (_tapBOOL == YES) {
        [_bgView removeFromSuperview];
        [self removeFromSuperview];
        _tapBOOL = NO;
    }
}

- (void)dealloc {
    NSLog(@"pickerView释放");
}

#pragma mark - 点击『完成』
- (void)doneButtonClicked {
    if (_pickerView) {
        if (!_resultString) {
            _resultString = @"";
            switch (_elementClass) {
                case LTArrayElementClassString:
                    _resultString = [NSString stringWithFormat:@"%@", _plistArray[0]];
                    break;
                case LTArrayElementClassArray:
                    for (int i = 0; i < _plistArray.count; i++) {
                        _resultString = [NSString stringWithFormat:@"%@", _plistArray[i][0]];
                    }
                    break;
                case LTArrayElementClassDictionary:
                    //字典和数组内容需要再优化 add By LaoTao 22:17
                    
                default:
                    break;
            }
        }
    }else if (_datePicker) {
        
        NSDateFormatter  *formatter = [[NSDateFormatter alloc ]init];
        
        /*
         UIDatePickerModeTime,           // Displays hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. 6 | 53 | PM)
         UIDatePickerModeDate,           // Displays month, day, and year depending on the locale setting (e.g. November | 15 | 2007)
         UIDatePickerModeDateAndTime,    // Displays date, hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. Wed Nov 15 | 6 | 53 | PM)
         UIDatePickerModeCountDownTimer,
         */
        switch (_datePicker.datePickerMode) {
            case UIDatePickerModeTime:
            {
                [formatter setDateFormat:@"HH:mm"];
                NSString *dateStr = [formatter stringFromDate:_datePicker.date];
                _resultString = dateStr;
            }
                break;
            case UIDatePickerModeDate:
                [formatter setDateFormat:@"yyyy-MM-dd"];
                _resultString = [formatter stringFromDate:_datePicker.date];
                break;
            case UIDatePickerModeDateAndTime:
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                _resultString = [formatter stringFromDate:_datePicker.date];
                break;
            case UIDatePickerModeCountDownTimer:
                //[formatter setDateFormat:@"yyyy-MM-dd"];
                [formatter setDateFormat:@"HH:mm"];
                _resultString = [formatter stringFromDate:_datePicker.date];
                break;
            default:
                break;
        }
        
        NSLog(@"pickerView:%@", _resultString);
    }
    
    if (_doneClicked != nil) {
        self.doneClicked(self, _resultString);
    }
    
    
    if ([self.delegate respondsToSelector:@selector(toolBarDoneButtonHaveClicked:resultString:)]) {
        [self.delegate toolBarDoneButtonHaveClicked:self resultString:_resultString];
    }
    
    [self remove];
}


@end
