//
//  EmojiInputView.h
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
#import "HPGrowingTextView.h"

#warning  注意: 由于版权问题 表情图片 请自行替换

@interface EmojiUtils : NSObject
@property (nonatomic, strong) NSDictionary *emojiDic;
@property (nonatomic, strong) NSArray *emojiKeys;

@end


@protocol EmojiInputViewDelegate <NSObject>
@optional
-(void)didTouchedEmoji:(NSString *)string;//选中的emoji
-(void)didTouchedDelete;//点击删除
-(void)didTouchedSend;//点击发送
@end


@interface EmojiInputView : UIView
- (id)initWithFrame:(CGRect)frame delegate:(id/*<EmojiInputViewDelegate>*/)aDelegate hasSendButton:(BOOL)aHasSendButton;
@property (weak,nonatomic) id<EmojiInputViewDelegate> delegate;

-(BOOL)hasSuffixEmoji:(NSString *)inputString;//以表情结尾
-(NSString *)setBackPressCustomTextViewWithText:(NSString *)text; //删除最后的表情 或文字 返回最新的文字

-(void)setBackPressTextView:(HPGrowingTextView *)atextView; //删除表情

-(void)setEmojiTextView:(HPGrowingTextView *)atextView emoji:(NSString *)emoji; //输入表情

@end
