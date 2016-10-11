//
//  TimePickerView.m
//  TimePickerTest
//
//  Created by miaoguodong on 16/3/22.
//  Copyright © 2016年 miaoguodong. All rights reserved.
//

#import "TimePickerView.h"

#define PICKVIEW_H 200
#define kFirstComponent 0
#define kSubComponent 1

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

@interface TimePickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    BOOL isAnimated;
}

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray * arrayMonth;
@property (strong, nonatomic) NSMutableArray * arrayYear;
@property (strong, nonatomic) NSString * selectedDateString;
@property (strong, nonatomic) UIButton *passbt,*cancelbt;
@property (strong, nonatomic) UIView *maskBgview, *pickBgView;


@end

@implementation TimePickerView

- (void)dealloc
{
    self.myPickerblock = nil;
    self.currentDate = nil;
    self.pickBgView = nil;
    self.pickerView = nil;
    self.arrayMonth = nil;
    self.arrayYear =  nil;
    self.selectedDateString = nil;
    self.maskBgview = nil;
    self.passbt = nil;
    self.cancelbt = nil;
}

- (id)initWithFrame:(CGRect)frame withPickBlock:(PickerBlock)block
{
    if (self = [super initWithFrame:frame]) {
        [self _initPickerView];
        self.myPickerblock = block;
        
    }
    return self;
}

- (void)_initPickerView
{
    isAnimated = NO;
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.maskBgview = [[UIView alloc] initWithFrame:self.bounds];
    self.maskBgview.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [self addSubview:self.maskBgview];
    
    
    self.pickBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 25+PICKVIEW_H)];
    self.pickBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.pickBgView];

    UIView *topline = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 1)];
    topline.backgroundColor = MakeColor(0xe3, 0xe4, 0xe5);
    [self.pickBgView addSubview:topline];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger year = [components year];  //当前的年份
    NSInteger month = [components month];  //当前的月份

    _arrayYear =[[NSMutableArray alloc]initWithCapacity:0];
    //   [[arrayYear reverseObjectEnumerator] allObjects];//数组倒序排列
    for (NSInteger k = year - 1970 ; k > 0; k --) {
        [_arrayYear addObject:[NSString stringWithFormat:@"%d年",year-k]];
    }
    for (int i= 0; i < year/2; i++ ) {
        [_arrayYear addObject:[NSString stringWithFormat:@"%d年",year+i]];
    }
    
    _arrayMonth = [[NSArray alloc]initWithObjects:@"1月", @"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月",nil];
    self.pickerView = [[UIPickerView alloc]initWithFrame:self.pickBgView.bounds];
    self.pickerView.delegate =self;
    self.pickerView.dataSource = self;
    [self.pickBgView addSubview:self.pickerView];
    
    [self.pickerView selectRow:[_arrayYear indexOfObject:[NSString stringWithFormat:@"%ld年",(long)year]] inComponent:0 animated:YES];
    [self.pickerView selectRow:[_arrayMonth indexOfObject:[NSString stringWithFormat:@"%ld月",(long)month]] inComponent:1 animated:YES];
    _selectedDateString = [NSString stringWithFormat:@"%d年%d月",year,month];
    
    
    self.passbt = [UIButton buttonWithType:UIButtonTypeSystem];
    self.passbt.frame = CGRectMake(self.width-60, 10, 50, 25);
    self.passbt.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.passbt setTitle:@"确定" forState:UIControlStateNormal];
    [self.passbt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.pickBgView addSubview:self.passbt];
    [self.passbt addTarget:self action:@selector(datechange) forControlEvents:UIControlEventTouchUpInside];

    self.cancelbt = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelbt.frame = CGRectMake(10, 10, 50, 25);
    self.cancelbt.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancelbt setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelbt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.pickBgView addSubview:self.cancelbt];
    [self.cancelbt addTarget:self action:@selector(cancelButton) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)showOrHidden:(BOOL)show
{
    if (show) {
        isAnimated = YES;
        self.hidden = NO;
        [UIView animateWithDuration:0.35 animations:^{
            self.maskBgview.alpha = 0.56;
            self.pickBgView.bottom = self.height;
        } completion:^(BOOL finished) {
            isAnimated = NO;
        }];
        
    }else {
        isAnimated = YES;

        [UIView animateWithDuration:0.35 animations:^{
            self.maskBgview.alpha = 0.0;
            self.pickBgView.top = self.height;
        } completion:^(BOOL finished) {
            isAnimated = NO;
            self.hidden = YES;
        }];
    
    }
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    _currentDate = currentDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self.currentDate];
    NSInteger year = [components year];  //当前的年份
    NSInteger month = [components month];  //当前的月份

    [self.pickerView selectRow:[_arrayYear indexOfObject:[NSString stringWithFormat:@"%ld年",(long)year]] inComponent:0 animated:YES];
    [self.pickerView selectRow:[_arrayMonth indexOfObject:[NSString stringWithFormat:@"%ld月",(long)month]] inComponent:1 animated:YES];

    
}

- (void)datechange
{
    if (self.myPickerblock) {
        self.myPickerblock(_selectedDateString);
    }
   
}

- (void)cancelButton
{
    CSLog(@"取消日期选择");
    isAnimated = YES;
    
    [UIView animateWithDuration:0.35 animations:^{
        self.maskBgview.alpha = 0.0;
        self.pickBgView.top = self.height;
    } completion:^(BOOL finished) {
        isAnimated = NO;
        self.hidden = YES;
    }];
}


//返回几列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

//返回列的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == kFirstComponent) {
        return _arrayYear.count;
    }else{
        return _arrayMonth.count;
    }
}

//显示的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component==kFirstComponent){
        NSString *provinceStr = [_arrayYear objectAtIndex:row];
        return provinceStr;
    }else{
        NSString *provinceStr = [_arrayMonth objectAtIndex:row];
        return provinceStr;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == kFirstComponent) {//刷新
        [pickerView selectRow:kFirstComponent inComponent:kSubComponent animated:YES];
        [pickerView reloadComponent:kSubComponent];
    }
    NSInteger yearComponent = [pickerView selectedRowInComponent:kFirstComponent];
    NSInteger monthComponent = [pickerView selectedRowInComponent:kSubComponent];
    NSString * yearString = [_arrayYear objectAtIndex:yearComponent];
    NSString * monthString = [_arrayMonth objectAtIndex:monthComponent];
    _selectedDateString = [NSString stringWithFormat:@"%@%@",yearString,monthString];
}
// 修改 pickerView 的字体大小
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        pickerLabel.minimumFontSize = 8.;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:UITextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:17]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
