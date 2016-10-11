//
//  ChatImageDownUtils.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/31.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "ChatImageDownUtils.h"
#define  CHATIMGMAXDOWNCOUNT 3
@interface ChatImageDownUtils ()
@property (strong, nonatomic) NSMutableDictionary *chatImgDic;
@end

static ChatImageDownUtils *chatImgDown = nil;
@implementation ChatImageDownUtils
+ (ChatImageDownUtils *)shareChatImag
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatImgDown = [[ChatImageDownUtils alloc] init];
    });
    return chatImgDown;
}
- (id)init {
    self = [super init];
    if (self) {
        self.chatImgDic = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (BOOL)existImgName:(NSString *)imgName {
    if ([self.chatImgDic objectForKey:imgName]) {
        return YES;
    }
    return NO;
}

- (BOOL)hasReLoadImagWithUrl:(NSURL *)url
{
    NSString *imgName = [[[url absoluteString] lastPathComponent] copy];
    int downCount = [self.chatImgDic intForKey:imgName];
    BOOL hasDown = NO;

    if (CHATIMGMAXDOWNCOUNT > downCount) {
        hasDown  = YES;
    }
    downCount ++;
    [self.chatImgDic setObject:[NSNumber numberWithInt:downCount] forKey:imgName];
    CSLog(@"聊天图片下载失败%d次, 地址:%@",downCount,url);
    return hasDown;
}
@end
