//
//  TitleView.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TitleView;
@protocol TitleViewDelegate <NSObject>

@optional
-(void)leftClicked:(TitleView *)view;//左侧点击
-(void)rightClicked:(TitleView *)view;//右侧点击
@end



typedef enum {
    CTitleStyle_FirstLogin = 10,    //透明导航并且没有左右按钮
    CTitleStyle_Home,               //蓝色导航 只有标题没有左右按钮
    CTitleStyle_OnlyBack,           //只有返回 蓝色导航 白色字体
    CTitleStyle_OnlyRight,          //只有右侧按钮
    CTitleStyle_LeftAndRight,       //有左侧和右侧按钮  白色背景/黑色文字
    CTitleStyle_Setting,            //  设置  有左按钮 透明背景
    CTitleStyle_AlphaNoStatus,      //只有返回按钮 白色字体 黑色半透明导航
    CTitleStyle_Camera,             //摄像头数据传输页面 导航透明 没有按钮 显示录制时间及上传标志
} CTitleStyle;

@interface TitleView : UIView
@property (weak, nonatomic)id<TitleViewDelegate>delegate;
- (void)setTitleText:(NSString *)title withTitleStyle:(CTitleStyle)style;
- (void)setTitleText:(NSString *)title;
- (void)setleftButtonText:(NSString *)text;
- (void)setRightButonText:(NSString *)text;
- (void)setleftButtonImg:(UIImage *)img;
- (void)setRightButonImg:(UIImage *)img;
-  (UIButton *)titleLeftButton;
- (UIButton *)titleRightButton;

@end
