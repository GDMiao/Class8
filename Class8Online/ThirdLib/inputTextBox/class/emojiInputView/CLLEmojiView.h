//
//  CLLEmojiView.h
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

@class CLLEmojiView;
@protocol CLLEmojiViewDelegate<NSObject>
@optional
- (void)didTouchEmojiView:(CLLEmojiView *)emojiView touchedEmoji:(NSString*)string;
- (void)didTouchDeleteEmojiView:(CLLEmojiView *)emojiView;
- (void)didTouchSendEmojiView:(CLLEmojiView *)emojiView;
@end;


@interface CLLEmojiView : UIView
{
    BOOL hasSendButton;
}
@property (assign, nonatomic) id<CLLEmojiViewDelegate> delegate;
/**
 * symbolArray  文字
 * emojiArray 表情图片
 */
-(id)initWithFrame:(CGRect)frame symbolArray:(NSArray *)aSymbolArray emojiArray:(NSArray *)aEmojiArray hasSendButton:(BOOL)aHasSendButton;

@end

