//
//  CLEmojiView.h
//  EmojiView
//
//  Created by chuliangliang on 15/5/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEVICE_SCREENWIDTH  [[UIScreen mainScreen] bounds].size.width
#define Emoji_LINE_COUNT 10                                      //每行表情数
#define Emoji_line 5
#define Emoji_Width  ((DEVICE_SCREENWIDTH - Emoji_line * Emoji_LINE_COUNT)/ Emoji_LINE_COUNT)    //每个表情的宽度
#define Emoji_Height Emoji_Width                                //每个表情的高度
#define Emoji_line_count 4

@class CLEmojiView;
@protocol CLEmojiViewDelegate <NSObject>

@optional
- (void)didTouchEmojiView:(CLEmojiView *)view touchedEmojiName:(NSString *)name emojiIndexPath:(NSString *)idxPathString;

@end

@interface CLEmojiView : UIView
@property (weak, nonatomic) id <CLEmojiViewDelegate> delegate;
- (void)updateEmojis:(NSArray *)arr;
@end
