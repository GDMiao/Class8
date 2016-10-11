//
//  InputMoreView.h
//  InPutBoxView
//
//  Created by chuliangliang on 15-1-6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
//由于时间紧迫 有可能不是非常完美 欢迎大家指正
//
//QQ: 949977202
//Email: chuliangliang300@sina.com

#import <UIKit/UIKit.h>

typedef struct
{
    uint32_t  tag;
    char      *imageName;
    char      *hilightImgName;
    char      *title;
} buttonCongfig;

@class InputMoreView;
@protocol InputMoreViewDelegate <NSObject>
@optional
- (void) inputMoreView:(InputMoreView *)view didSelectInde:(NSInteger)index;

@end

@interface InputMoreView : UIView
- (id)initWithFrame:(CGRect)frame items:(NSArray *)aItems delegate:(id/*<InputMoreViewDelegate>*/)aDelegate;

@end
