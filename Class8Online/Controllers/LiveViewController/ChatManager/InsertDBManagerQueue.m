//
//  KL_InsertDBObj.m
//  mobileikaola
//
//  Created by chuliangliang on 15-3-2.
//  Copyright (c) 2015年 ikaola. All rights reserved.
//

#import "InsertDBManagerQueue.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "DBConfig.h"
#import "ChatDBObject.h"

@interface InsertDBManagerQueue ()
{
    int page;
}
@property (strong, nonatomic) FMDatabaseQueue *dbQueue;
@end

static InsertDBManagerQueue *insertDbObj = nil;
@implementation InsertDBManagerQueue
@synthesize dbQueue;
+ (InsertDBManagerQueue *)shareInsertDbObj {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        insertDbObj = [[InsertDBManagerQueue alloc] init];
    });
    return insertDbObj;
}

- (id)init {
    self = [super init];
    if (self) {
        page = 0;
        dbQueue = [FMDatabaseQueue databaseQueueWithPath:DATABASE_PATH];
    }
    return self;
}

/**
 * 创建对话信息对象
 **/
- (ChatDBObject *)createChatObj:(NSDictionary *)dic {
    ChatDBObject *chat=[[ChatDBObject alloc]init];
    
    //long long
    chat.courseID = [[dic objectForKey:CHAT_courseID] longLongValue];       /*课程ID*/
    chat.ownerUid = [[dic objectForKey:CHAT_ownerUid] longLongValue];       /*所有者ID*/
    chat.sendUid = [[dic objectForKey:CHAT_sendUid] longLongValue];         /*发送者ID*/
    chat.reciveUid = [[dic objectForKey:CHAT_reciveUid] longLongValue];     /*接收者ID*/
    chat.groupId = [[dic objectForKey:CHAT_groupId] longLongValue];         /*小组ID*/
    chat.msgId = [[dic objectForKey:CHAT_msgId] longLongValue];             /*消息ID*/
    chat.time = [[dic objectForKey:CHAT_time] longLongValue];               /*时间*/
    chat.classId = [[dic objectForKey:CHAT_classId] longLongValue];         /*课节id*/
    
    //BOOL
    chat.isMe = [[dic objectForKey:CHAT_isMe] boolValue];                   /*是否是自己发出的消息*/
    chat.isSystemMsg = [[dic objectForKey:CHAT_isSystemMsg] boolValue];       /*是否系统消息*/
    
    //MsgType (int)
    chat.msgStyle = [[dic objectForKey:CHAT_msgStyle] intValue];            /*对话类型 <MsgType>*/
    
    //NSString
    chat.contentText = [dic objectForKey:CHAT_contentText];                 /*消息内容*/
    chat.sendUserNick = [dic objectForKey:CHAT_sendUserNick];               /*发送者昵称*/
    return chat;

}

- (void)addData:(NSDictionary *)itemDic callBack:(void (^)(ChatDBObject *chat))block
{
    page ++;
    CSLog(@"队列: %d",page);
    const char *queueChar = [[NSString stringWithFormat:@"queue%d",page] UTF8String];
    dispatch_queue_t q1 = dispatch_queue_create(queueChar, NULL);
    dispatch_async(q1, ^{
        ChatDBObject *chat =  [self createChatObj:itemDic];
        [dbQueue inDatabase:^(FMDatabase *db2) {
            //数据解析
            //判断是否存在
            BOOL hasData = NO;
            [ChatDBObject checkTableCreatedInDb:db2];            
            if (chat.msgStyle == MsgType_Room && chat.isSystemMsg) {
                //群聊系统消息 更新时间
                FMResultSet *rs = [db2 executeQuery:@"select * from ChatDBObject where ownerUid=? and courseID=? and msgStyle=? order by time desc limit 1",[NSNumber numberWithLongLong:chat.ownerUid],[NSNumber numberWithLongLong:chat.courseID],[NSNumber numberWithInt:MsgType_Room]];
                while ([rs next]) {
                    long long chat_Time = [rs longLongIntForColumn:CHAT_time]; /*时间*/
                    chat.time = chat_Time>0?chat_Time+1:(long long)[[NSDate date]timeIntervalSince1970];
                }
            }

            
            int count=[db2 intForQuery:@"select count(*) from ChatDBObject where msgId=? and ownerUid=?",[NSNumber numberWithLongLong:chat.msgId],[NSNumber numberWithLongLong:chat.ownerUid]];
            if (count!=0){
                hasData = YES;
            }else
            {
                hasData = NO;
            }
            
            /**
             * 如果数据存在,则更新数据 否则插入数据
             **/
            if (hasData) {
                //更新
                [ChatDBObject checkTableCreatedInDb:db2];
                [db2 executeUpdate:@"update ChatDBObject set courseID=?,classId=?,ownerUid=?,sendUid=?,reciveUid=?,groupId=?,isMe=?,isSystemMsg=?,msgStyle=?,contentText=?, sendUserNick=?,time=? where msgId=?",[NSNumber numberWithLongLong:chat.courseID],[NSNumber numberWithLongLong:chat.classId],[NSNumber numberWithLongLong:chat.ownerUid],[NSNumber numberWithLongLong:chat.sendUid],[NSNumber numberWithLongLong:chat.reciveUid],[NSNumber numberWithLongLong:chat.groupId],[NSNumber numberWithBool:chat.isMe],[NSNumber numberWithBool:chat.isSystemMsg],[NSNumber numberWithInt:chat.msgStyle],chat.contentText,chat.sendUserNick,[NSNumber numberWithLongLong:chat.time],[NSNumber numberWithLongLong:chat.msgId]];
                
            }else {
                //插入
                [ChatDBObject checkTableCreatedInDb:db2];
                NSString *insertStr=@"INSERT INTO 'ChatDBObject' ('courseID','classId','ownerUid','sendUid','reciveUid','groupId','msgId','isMe','isSystemMsg','msgStyle','contentText','sendUserNick','time') VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
                [db2 executeUpdate:insertStr,[NSNumber numberWithLongLong:chat.courseID],[NSNumber numberWithLongLong:chat.classId],[NSNumber numberWithLongLong:chat.ownerUid],[NSNumber numberWithLongLong:chat.sendUid],[NSNumber numberWithLongLong:chat.reciveUid],[NSNumber numberWithLongLong:chat.groupId],[NSNumber numberWithLongLong:chat.msgId],[NSNumber numberWithBool:chat.isMe],[NSNumber numberWithBool:chat.isSystemMsg],[NSNumber numberWithInt:chat.msgStyle],chat.contentText,chat.sendUserNick,[NSNumber numberWithLongLong:chat.time]];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                 block(chat);
             }
         });
    });
}

@end
