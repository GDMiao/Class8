//
//  ChatManager.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/22.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChatDBObject;
@interface ChatManager : NSObject

/**
 *发送群消息
 **/
- (void)sendRoomMsg:(NSString *)msg isGif:(BOOL)gif classID:(long long)classid;


/**
 *发送私聊消息
 **/
- (void)sendUserMsg:(NSString *)msg isGif:(BOOL)gif classID:(long long)classid recUid:(long long)ruid;
@end
