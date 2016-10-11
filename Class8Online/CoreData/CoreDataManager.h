//
//  CoreDataManager.h
//  BTCTrade
//
//  Created by chuliangliang on 14-1-16.
//  Copyright (c) 2014年 banvon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chat.h"
#import "CacheFile.h"


#define DATABASEMANAGER [CoreDataManager defaultManager]
@interface CoreDataManager : NSObject
+ (id)defaultManager;
//保存数据
- (BOOL)save;
//删除数据
- (void)deleteobject:(NSManagedObject *)obj;

- (NSManagedObjectContext *)context;


//===============================================
// 聊天
//===============================================
#pragma mark- ////
#pragma mark- 聊天消息
- (Chat *)createChatById:(NSNumber *)msgId;
- (Chat *)getChatByid:(NSNumber *)msgId;

/**
 *获取最后一条聊天信息时间 加1 之后返回
 **/
- (NSDate *)getLastMsgTime:(long long)cid userid:(long long)uid;
//===============================================
// 缓存文件记录
//===============================================
#pragma mark-
#pragma mark- 缓存文件记录
//创建
- (CacheFile *)createCacheFile:(NSString *)name;
//查找
- (CacheFile *)getCacheFile:(NSString *)fileName;
//获取过期缓存文件名
- (NSArray *)getInvalidateCacheFile;

@end
