//
//  ChatDBObject.h
//  FMDBDome
//
//  Created by chuliangliang on 15/7/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseAdditions.h"

//long long
#define CHAT_courseID @"courseID"
#define CHAT_ownerUid @"ownerUid"
#define CHAT_sendUid @"sendUid"
#define CHAT_reciveUid @"reciveUid"
#define CHAT_groupId @"groupId"
#define CHAT_msgId @"msgId"
#define CHAT_time @"time"
#define CHAT_classId @"classId"

//BOOL
#define CHAT_isMe @"isMe"
#define CHAT_isSystemMsg @"isSystemMsg"

//int
#define CHAT_msgStyle @"msgStyle"

//NSString
#define CHAT_contentText @"contentText"
#define CHAT_sendUserNick @"sendUserNick"

typedef enum {
    MsgType_Room = 10,                                  /*房间聊天*/
    MsgType_Group,                                      /*分组聊天*/
    MsgType_One,                                        /*单人聊天*/
}MsgType;

@interface ChatDBObject : NSObject

@property (nonatomic, assign) long long
courseID,                                               /*课程ID*/
ownerUid,                                               /*所有者ID*/
sendUid,                                                /*发送者ID*/
reciveUid,                                              /*接收者ID*/
groupId,                                                /*小组ID*/
msgId,                                                  /*消息ID*/
classId;                                                /*课节id*/


@property (nonatomic, assign) BOOL
isMe,                                                   /*是否是自己发出的消息*/
isSystemMsg;                                            /*是否系统消息*/


@property (nonatomic, assign) MsgType msgStyle;         /*对话类型 <MsgType>*/

@property (nonatomic, strong) NSString
*contentText,                                           /*消息内容*/
*sendUserNick;                                          /*发送者昵称*/


@property (nonatomic, assign) long long time;           /*时间*/


+(BOOL)checkTableCreatedInDb:(FMDatabase *)db;
//=============================================
//TODO: 方法
//=============================================
/**
 * 更新信息
 */
- (BOOL)updateMsg;

/**
 * 从表中删除
 */
- (BOOL)removeFromDb;

/**
 * 取出群聊数据
 **/
+(NSMutableArray *)getRoomMsgListStarid:(long long)startid listCount:(int)len courseId:(long long)cid classID:(long long)classid myUserid:(long long)myUid;


/**
 * 取出私聊数据
 **/
+(NSMutableArray *)getUserChatMsgListStarid:(long long)startid listCount:(int)len courseId:(long long)cid myUserid:(long long)myUid otherUserID:(long long)otherUid;

@end
