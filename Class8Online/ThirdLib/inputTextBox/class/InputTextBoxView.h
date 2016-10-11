//
//  InputTextBoxView.h
//  InPutBoxView
//
//  Created by chuliangliang on 15-1-5.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
//由于时间紧迫 有可能不是非常完美 欢迎大家指正
//
//QQ: 949977202
//Email: chuliangliang300@sina.com

#import <UIKit/UIKit.h>
#import "EmojiInputView.h"
#import "RecordInputView.h"
#import "InputMoreView.h"
#import "CLEmojiKeyBorad.h"
#import "CLEmojiInpuView.h"

@class InputTextBoxView;
@protocol InputTextBoxViewDelegate <NSObject>
@optional
/**
 * 输入源是否包含语音 默认 没有
 **/
- (UIView *)InputTextBoxViewWithVoiceView:(InputTextBoxView *)inputTextBox;

/**
 * 输入源是否包含表情 默认 没有
 **/
- (UIView *)InputTextBoxViewWithFaceView:(InputTextBoxView *)inputTextBox;

/**
 * 输入源为表情单组表情 <小表情>
 **/
- (UIView *)InputTextBoxViewWithSmallFaceView:(InputTextBoxView *)inputTextBox;

/**
 * 输入源是否包含更多(更多输入页可以有 相册/相机/圈人 等) 默认 没有
 **/
- (UIView *)InputTextBoxViewWithMoreView:(InputTextBoxView *)inputTextBox;;


/**
 * 输入框高度变化、输入源切换导致高度变化 回调
 **/
- (void)InputTextBoxViewChangedHeight:(float)height animateTime:(CGFloat)time;


/**
 * 是否可以发送文字
 * 目的: 可以通过此方法 根据文字长度 做出限制 列入不能发送 空字符 默认不限制
 **/
- (BOOL)hasSendText:(NSString *)text;

/**
 * 发送文字回调
 **/
- (void)sendContext:(NSString *)text;

/**
 * 发送表情 imgName : 图片名 idxpath: 图片id : 唯一标示
 **/
- (void)sendGifFace:(NSString *)imgName indxPath:(NSString *)idxpath;

/**
 * 发送语音回调
 **/
- (void)sendVoice:(NSString *)path VoiceLength:(int)length;

/**
 * 更多输入源 点击的索引
 **/
- (void)inputTextBoxDidselectMoreButtonAtIndex:(NSInteger )index;
@end

@interface InputTextBoxView : UIView
- (id)initWithDelegate:(id)aDelegate showAtController:(UIViewController *)controller;
- (id)initWithDelegate:(id)aDelegate showAtView:(UIView *)aView;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) UIFont *textFont;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) BOOL hasShowKeyBorad; //是否监听键盘弹出  默认yes

@property (nonatomic) BOOL isAutoChangeFrame; //输入框是否自定更新坐标 默认yes
/**
 * 隐藏键盘/语音/表情键盘/更多输入视图
 **/
- (void)hiddenAll;

//是否处于编辑中
- (BOOL)isEditing;
@end
