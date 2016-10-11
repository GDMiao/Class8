//
//  ChatManager.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/22.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "ChatManager.h"
#import "CNetworkManager.h"

@implementation ChatManager

/**
 *发送群消息
 **/
- (void)sendRoomMsg:(NSString *)msg isGif:(BOOL)gif classID:(long long)classid
{
    [CNETWORKMANAGER sendMessage:msg ChatType:0 sendUid:[UserAccount shareInstance].loginUser.uid courseId:classid isGIF:gif recUid:0];
}

/**
 *发送私聊消息
 **/
- (void)sendUserMsg:(NSString *)msg isGif:(BOOL)gif classID:(long long)classid recUid:(long long)ruid
{
    [CNETWORKMANAGER sendMessage:msg ChatType:3 sendUid:[UserAccount shareInstance].loginUser.uid courseId:classid isGIF:gif recUid:ruid];
}
@end
