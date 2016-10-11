//
//  CustomMethod.h
//  MessageList
//
//  Created by 刘超 on 13-11-13.
//  Copyright (c) 2013年 刘超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"
#import "OHAttributedLabel.h"
#import "SCGIFImageView.h"

@interface CustomMethod : NSObject
@property (retain,nonatomic) NSDictionary *emojiDic;
@property (retain,nonatomic) NSArray *emojiKeys;
+(CustomMethod *)shareCustomMethod;
+ (NSString *)escapedString:(NSString *)oldString;
+ (void)drawImage:(OHAttributedLabel *)label isGifAnimate:(BOOL)aimate;
+ (NSMutableArray *)addAtUserArr:(NSString *)text atUsers:(NSArray *)atUsers toUser:(NSString *)toUser;
//+ (NSMutableArray *)clubAddAtUserArr:(NSString *)text atUsers:(NSArray *)atUsers toUser:(NSString *)toUser;
+ (NSMutableArray *)addAtUserArr:(NSString *)text;
+ (NSMutableArray *)addHttpArr:(NSString *)text;
+ (NSMutableArray *)addPhoneNumArr:(NSString *)text;
+ (NSMutableArray *)addEmailArr:(NSString *)text;
+ (NSString *)transformString:(NSString *)originalStr  emojiDic:(NSDictionary *)_emojiDic;//匹配表情默认16*16
+ (NSString *)transformString:(NSString *)originalStr emojiDic:(NSDictionary *)_emojiDic imageSize:(float)width;//匹配表情
+ (NSString *)transformString:(NSString *)originalStr emojiDic:(NSDictionary *)_emojiDic imageSize:(float)width ignoreTexts:(NSArray *)ignoreTexts;
+ (NSString *)transformString:(NSString *)originalStr;
+ (NSString *)transformString:(NSString *)originalStr ignoreTexts:(NSArray *)ignoreTexts;
+ (NSString *)transformString:(NSString *)originalStr imageSize:(float)imageSize ignoreTexts:(NSArray *)ignoreTexts;
+(BOOL)containEmoji:(NSRange)emojiRange origStr:(NSString *)origStr ignoreTexts:(NSArray *)ignoreTexts;//表情位置是否在忽略表情转换的字符串中
+ (NSString *)subQuestionCellStr:(NSString *)originalStr;//截取问题字符串

/*
 * 拓展 club 标题匹配表情 和 置顶/加精 图片
 */
+ (NSString *)transformStringWithClubPostsTitle:(NSString *)originalStr imageSize:(float)imageSize isTop:(BOOL)top isEssential:(BOOL)essential;

/*
 * 拓展 club 标题匹配表情 和 置顶/加精 图片 和 是否新帖 add for 2.3
 */
+ (NSString *)transformStringWithClubPostsTitle:(NSString *)originalStr imageSize:(float)imageSize isTop:(BOOL)top isEssential:(BOOL)essential isNewPost:(BOOL)isNew;


//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//在线课堂..
+ (NSString *)class_8transformString:(NSString *)originalStr  imageSize:(float)width ignoreTexts:(NSArray *)ignoreTexts;
//TODO: 在线课堂..匹配表情
+ (NSString *)class_8transformString:(NSString *)originalStr;
@end
