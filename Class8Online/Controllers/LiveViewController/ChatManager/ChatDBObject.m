//
//  ChatDBObject.m
//  FMDBDome
//
//  Created by chuliangliang on 15/7/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "ChatDBObject.h"
#import "DBConfig.h"

#define CurrentVersion 1 //当前数据表版本 如果增加了新字段就+1
@implementation ChatDBObject

+(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    
    NSString *createStr=@"CREATE  TABLE  IF NOT EXISTS 'ChatDBObject' ('courseID' long long,'classId' long long ,'ownerUid' long long, 'sendUid' long long ,'reciveUid' long long,'groupId' long long, 'msgId' long long,'isMe' bool, 'isSystemMsg' bool,'msgStyle' int ,'contentText' text,'sendUserNick' text, 'time' long long)";
    
    BOOL worked = [db executeUpdate:createStr];
    FMDBQuickCheck(worked);
    if (worked) {
        //创建数据库版本管理
        NSString *createVersionTableStr=@"CREATE  TABLE  IF NOT EXISTS 'DB_Version' ('DBVersion_tableName' TEXT,'versionCode' INT)";
        [db executeUpdate:createVersionTableStr];
        FMResultSet *rs=[db executeQuery:@"select * from DB_Version where DBVersion_tableName=?",@"ChatDBObject"];
        int tableVersion = 0;
        int currentVersion = CurrentVersion;//如果增加了新字段就+1
        while ([rs next]) {
            tableVersion = [rs intForColumn:@"versionCode"];
        }
        [rs close];
        if (currentVersion != tableVersion) {
            switch (tableVersion) {
                case 1:
                    //判断不存在的几个字段
                    if (![db columnExists:@"alias" inTableWithName:@"ChatDBObject"]) {
                        //添加新字段
                        [db executeUpdate:@"alter table ChatDBObject add column alias text"];
                    }
                    if (![db columnExists:@"_description_" inTableWithName:@"ChatDBObject"]) {
                        //添加新字段
                        [db executeUpdate:@"alter table ChatDBObject add column _description_ text"];
                    }
                default:
                    if ([ChatDBObject existVersion:db]) {
                        //存在这个版本
                        [db executeUpdate:@"update DB_Version set versionCode=? where DBVersion_tableName=?",[NSNumber numberWithInt:currentVersion],@"ChatDBObject"];
                    }else{
                        [db executeUpdate:@"INSERT INTO 'DB_Version' ('versionCode','DBVersion_tableName') VALUES (?,?)",[NSNumber numberWithInt:currentVersion],@"ChatDBObject"];
                    }
                    break;
            }
        }
    }
    return worked;
    
}
+(BOOL)existVersion:(FMDatabase *)db
{
    FMResultSet *rs=[db executeQuery:@"select count(*) from DB_Version where DBVersion_tableName=?",@"ChatDBObject"];
    while ([rs next]) {
        int count= [rs intForColumnIndex:0];
        
        if (count!=0){
            [rs close];
            return YES;
        }else
        {
            [rs close];
            return NO;
        }
    };
    [rs close];
    return YES;
}


/**
 * 是否存在
 **/
-(BOOL)existMsg
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        CSLog(@"数据库打开失败");
        return YES;
    };
    [ChatDBObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select count(*) from ChatDBObject where msgId=? and ownerUid=?",[NSNumber numberWithLongLong:self.msgId],[NSNumber numberWithLongLong:self.ownerUid]];
    while ([rs next]) {
        int count= [rs intForColumnIndex:0];
        
        if (count!=0){
            [rs close];
            [db close];
            return YES;
        }else
        {
            [rs close];
            [db close];
            return NO;
        }
        
    };
    [rs close];
    [db close];
    return YES;
}


/**
 *更新
 **/
-(BOOL)updateMsg
{
    
    if ([self existMsg]) {
        //存在,更新
        FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
        if (![db open]) {
            CSLog(@"数据库打开失败");
            return NO;
        };
        [ChatDBObject checkTableCreatedInDb:db];
        BOOL worked=[db executeUpdate:@"update ChatDBObject set courseID=?,classId=?,ownerUid=?,sendUid=?,reciveUid=?,groupId=?,isMe=?,isSystemMsg=?,msgStyle=?,contentText=?, sendUserNick=?,time=? where msgId=?",[NSNumber numberWithLongLong:self.courseID],[NSNumber numberWithLongLong:self.classId],[NSNumber numberWithLongLong:self.ownerUid],[NSNumber numberWithLongLong:self.sendUid],[NSNumber numberWithLongLong:self.reciveUid],[NSNumber numberWithLongLong:self.groupId],[NSNumber numberWithBool:self.isMe],[NSNumber numberWithBool:self.isSystemMsg],[NSNumber numberWithInt:self.msgStyle],self.contentText,self.sendUserNick,[NSNumber numberWithLongLong:self.time],[NSNumber numberWithLongLong:self.msgId]];
        [db close];
        return worked;
    }else{
        //不存在，插入一条
        FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
        if (![db open]) {
            CSLog(@"数据库打开失败");
            return NO;
        };
        [ChatDBObject checkTableCreatedInDb:db];
        NSString *insertStr=@"INSERT INTO 'ChatDBObject' ('courseID','classId','ownerUid','sendUid','reciveUid','groupId','msgId','isMe','isSystemMsg','msgStyle','contentText','sendUserNick','time') VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
        BOOL worked = [db executeUpdate:insertStr,[NSNumber numberWithLongLong:self.courseID],[NSNumber numberWithLongLong:self.classId],[NSNumber numberWithLongLong:self.ownerUid],[NSNumber numberWithLongLong:self.sendUid],[NSNumber numberWithLongLong:self.reciveUid],[NSNumber numberWithLongLong:self.groupId],[NSNumber numberWithLongLong:self.msgId],[NSNumber numberWithBool:self.isMe],[NSNumber numberWithBool:self.isSystemMsg],[NSNumber numberWithInt:self.msgStyle],self.contentText,self.sendUserNick,[NSNumber numberWithLongLong:self.time]];
        [db close];
        return worked;
    }
}

/**
 * 删除数据
 **/
- (BOOL)removeFromDb
{
    
    BOOL worked = NO;
    if ([self existMsg]) {
        //存在,删除
        FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
        if (![db open]) {
            CSLog(@"数据库打开失败");
            return NO;
        };
        [ChatDBObject checkTableCreatedInDb:db];
        worked=[db executeUpdate:@"delete from ChatDBObject where ownerUid=? and msgId=?",[NSNumber numberWithLongLong:self.ownerUid],[NSNumber numberWithLongLong:self.msgId]];
        [db close];
    }
    return worked;
}



/**
 * 数据库查询后 属性赋值
 **/
+ (ChatDBObject *)setPropertyContent:(FMResultSet *)rs
{
    ChatDBObject *chat=[[ChatDBObject alloc]init];
    
    //long long
    chat.courseID = [rs longLongIntForColumn:CHAT_courseID];        /*课程ID*/
    chat.ownerUid = [rs longLongIntForColumn:CHAT_ownerUid];        /*所有者ID*/
    chat.sendUid = [rs longLongIntForColumn:CHAT_sendUid];          /*发送者ID*/
    chat.reciveUid = [rs longLongIntForColumn:CHAT_reciveUid];      /*接收者ID*/
    chat.groupId = [rs longLongIntForColumn:CHAT_groupId];          /*小组ID*/
    chat.msgId = [rs longLongIntForColumn:CHAT_msgId];              /*消息ID*/
    chat.time = [rs longLongIntForColumn:CHAT_time];                /*时间*/
    chat.classId = [rs longLongIntForColumn:CHAT_classId];          /*课节id*/
    
    //BOOL
    chat.isMe = [rs boolForColumn:CHAT_isMe];                       /*是否是自己发出的消息*/
    chat.isSystemMsg = [rs boolForColumn:CHAT_isSystemMsg];         /*是否系统消息*/
    
    //MsgType (int)
    chat.msgStyle = [rs intForColumn:CHAT_msgStyle];                /*对话类型 <MsgType>*/
    
    //NSString
    chat.contentText = [rs stringForColumn:CHAT_contentText];       /*消息内容*/
    chat.sendUserNick = [rs stringForColumn:CHAT_sendUserNick];     /*发送者昵称*/
    return chat;
}


/**
 * 取出数据
 **/
+(NSMutableArray *)getRoomMsgListStarid:(long long)startid listCount:(int)len courseId:(long long)cid classID:(long long)classid myUserid:(long long)myUid
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        CSLog(@"数据库打开失败");
        return resultArr;
    };
    
    [ChatDBObject checkTableCreatedInDb:db];
    
    int msgTotalCount =0;
    FMResultSet *rs= nil;
    if (startid <=0 ) {
        msgTotalCount = [db intForQuery:@"SELECT COUNT(*) FROM ChatDBObject where ownerUid=? and courseID=? and classId=? and msgStyle=?",[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:cid],[NSNumber numberWithLongLong:classid],[NSNumber numberWithLongLong:MsgType_Room]];
        int startIndex = MAX(0, msgTotalCount - len);
        /**
         * 第一次取最新len条
         **/
        rs = [db executeQuery:@"select * from ChatDBObject where ownerUid=? and courseID=? and classId=? and msgStyle=? order by time asc limit ?,?",[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:cid],[NSNumber numberWithLongLong:classid],[NSNumber numberWithInt:MsgType_Room],[NSNumber numberWithInt:startIndex],[NSNumber numberWithInt:len]];
    }else {
        msgTotalCount = [db intForQuery:@"SELECT COUNT(*) FROM ChatDBObject where ownerUid=? and courseID=? and classId=? and msgStyle=? and msgId<=?",[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:cid],[NSNumber numberWithLongLong:classid],[NSNumber numberWithLongLong:MsgType_Room],[NSNumber numberWithLongLong:startid]];
        int startIndex = MAX(0, msgTotalCount - len-1);
        /**
         * 取历史len条数
         **/
       rs = [db executeQuery:@"select * from ChatDBObject where ownerUid=? and courseID=? and classId=? and msgStyle=?  and msgId<? order by time asc limit ?,?",[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:cid],[NSNumber numberWithLongLong:classid],[NSNumber numberWithInt:MsgType_Room],[NSNumber numberWithLongLong:startid],[NSNumber numberWithInt:startIndex],[NSNumber numberWithInt:len]];
    }
    while ([rs next]) {
        ChatDBObject *chat = [ChatDBObject setPropertyContent:rs];
        [resultArr addObject:chat];
    }
    [rs close];
    [db close];
    return resultArr;
}


/**
 * 取出私聊数据
 **/
+(NSMutableArray *)getUserChatMsgListStarid:(long long)startid listCount:(int)len courseId:(long long)cid myUserid:(long long)myUid otherUserID:(long long)otherUid
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        CSLog(@"数据库打开失败");
        return resultArr;
    };
    
    [ChatDBObject checkTableCreatedInDb:db];
    
    int msgTotalCount =0;
    FMResultSet *rs= nil;
    if (startid <=0 ) {
        msgTotalCount = [db intForQuery:@"SELECT COUNT(*) FROM ChatDBObject where courseID=? and msgStyle=? and ((sendUid=? and reciveUid=?)or (sendUid=? and reciveUid=?))",[NSNumber numberWithLongLong:cid],[NSNumber numberWithLongLong:MsgType_One],[NSNumber numberWithLongLong:otherUid],[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:otherUid]];
        int startIndex = MAX(0, msgTotalCount - len);
        /**
         * 第一次取最新len条
         **/
        rs = [db executeQuery:@"select * from ChatDBObject where courseID=? and msgStyle=? and ((sendUid=? and reciveUid=?)or (sendUid=? and reciveUid=?)) order by time asc limit ?,?",[NSNumber numberWithLongLong:cid],[NSNumber numberWithInt:MsgType_One],[NSNumber numberWithLongLong:otherUid],[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:otherUid],[NSNumber numberWithInt:startIndex],[NSNumber numberWithInt:len]];
    }else {
        msgTotalCount = [db intForQuery:@"SELECT COUNT(*) FROM ChatDBObject where courseID=? and msgStyle=? and msgId<=? and ((sendUid=? and reciveUid=?)or (sendUid=? and reciveUid=?))",[NSNumber numberWithLongLong:cid],[NSNumber numberWithLongLong:MsgType_One],[NSNumber numberWithLongLong:startid],[NSNumber numberWithLongLong:otherUid],[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:otherUid]];
        int startIndex = MAX(0, msgTotalCount - len-1);
        /**
         * 取历史len条数
         **/
        rs = [db executeQuery:@"select * from ChatDBObject where courseID=? and msgStyle=? and msgId<? and ((sendUid=? and reciveUid=?)or (sendUid=? and reciveUid=?)) order by time asc limit ?,?",[NSNumber numberWithLongLong:cid],[NSNumber numberWithInt:MsgType_One],[NSNumber numberWithLongLong:startid],[NSNumber numberWithLongLong:otherUid],[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:myUid],[NSNumber numberWithLongLong:otherUid],[NSNumber numberWithInt:startIndex],[NSNumber numberWithInt:len]];
    }
    while ([rs next]) {
        ChatDBObject *chat = [ChatDBObject setPropertyContent:rs];
        [resultArr addObject:chat];
    }
    [rs close];
    [db close];
    return resultArr;

}

@end
