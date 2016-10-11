//
//  BirthdayPickView.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/25.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BirthdayPickView.h"

@interface BirthdayPickView ()
{
    BOOL animating;
}
@property (strong, nonatomic) UIView *bgView,*pickBgView;
@property (strong, nonatomic) UIDatePicker *datePickerView;

@end
@implementation BirthdayPickView

- (void)showOrHidden:(BOOL)show
{
    if (animating) {
        return;
    }

    if (show) {
        animating = YES;
        self.hidden = NO;
        [UIView animateWithDuration:0.35 animations:^{
            self.bgView.alpha = 0.6;
            self.pickBgView.bottom = self.height;
        } completion:^(BOOL finished) {
            animating = NO;
        }];
    }else {
        animating = YES;
        [UIView animateWithDuration:0.35 animations:^{
            self.bgView.alpha = 0.0;
            self.pickBgView.top = self.height;
        } completion:^(BOOL finished) {
            animating = NO;
            self.hidden = YES;
        }];

    }
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubView];
    }
    return self;
}

- (void)dealloc
{
    self.pickBgView = nil;
    self.datePickerView = nil;
    self.bgView = nil;
    self.block = nil;
}
- (void)_initSubView
{
    animating = NO;
    self.backgroundColor = [UIColor clearColor];
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.alpha = 0.0;
    [self addSubview:self.bgView];
    
    
    self.pickBgView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pickBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.pickBgView];
    
    CGFloat dateHeight = 200;
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, self.width, dateHeight)];
    self.datePickerView.datePickerMode = UIDatePickerModeDate;
    self.datePickerView.maximumDate = [NSDate date];
    [self.pickBgView addSubview:self.datePickerView];
    
    self.pickBgView.frame = CGRectMake(0, self.height, self.width, self.datePickerView.height+30);
    
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(self.width-40-5,0 , 40, 30);
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [doneBtn setTitleColor:MakeColor(0x4f, 0xb8, 0x33) forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickBgView addSubview:doneBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(5,0 , 40, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [cancelBtn setTitleColor:MakeColor(0x4f, 0xb8, 0x33) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickBgView addSubview:cancelBtn];
    

}

- (void)doneAction:(UIButton *)button
{
    NSDate *birDate = [self.datePickerView date];
    if (self.block) {
        self.block(NO,birDate);
    }
}

- (void)cancelAction:(UIButton *)button
{
    if (self.block) {
        self.block(YES,nil);
    }
}
@end
