//
//  CoreDataManager.m
//  BTCTrade
//
//  Created by chuliangliang on 14-1-16.
//  Copyright (c) 2014年 banvon. All rights reserved.
//

#import "CoreDataManager.h"

#define DBFILE @"ChatDb.sqlite"
@interface CoreDataManager()
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *datamodel;
    NSPersistentStoreCoordinator *coordinator;
}
@end

@implementation CoreDataManager
static CoreDataManager *datamanager = nil;
+ (id)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        datamanager = [[CoreDataManager alloc] init];
    });
    return datamanager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]
                      URLByAppendingPathComponent:DBFILE];
		NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
		coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        __autoreleasing NSError *err = nil;
        
		NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&err];
		if (!store)
		{
			CSLog(@"addPersistentStoreWithType error:%@, userInfo:%@", err, [err userInfo]);
            abort();
		}
		context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:coordinator];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(save)
													 name:UIApplicationWillTerminateNotification
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(save)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}
//保存数据
- (BOOL)save
{
    __autoreleasing NSError *err = nil;
    if([context hasChanges] && ![context save:&err]){
        CSLog(@"save:&err-%@",[err userInfo]);
        abort();
        return NO;
    }
    return YES;
}
- (NSManagedObjectContext *)context
{
    return context;
}
//删除数据
- (void)deleteobject:(NSManagedObject *)obj
{
    [context deletedObjects];
    [context deleteObject:obj];
}
/*查询数据
 limit :返回查询结果中得数据行数
 entityName :需要查询的表的名称
 key : 根据表中的哪个字段进行排序 如果需要用多个字段组合之后进行排序 则 传进来的参数(key)用逗号隔开
 ascending: 排序方式 YES-->升序排序  NO-->降序排序
 
 */
- (NSArray *)executeResultBypredicate:(NSPredicate *)predicate limit:(int)limit entityName:(NSString *)name decriptorkey:(NSString *)key ascending:(BOOL)ascending
{
    NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:name inManagedObjectContext:context];
    [fetchrequest setEntity:entityDesc];
    if (predicate) {
        [fetchrequest setPredicate:predicate];
    }
    if (limit>0) {
        [fetchrequest setFetchLimit:limit];
    }
    if (key !=nil) {
        NSArray *keys = [key componentsSeparatedByString:@","];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[keys count]];
        for (int i = 0; i<keys.count; i++) {
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:[keys objectAtIndex:i] ascending:ascending];
            [array addObject:descriptor];
        }
        [fetchrequest setSortDescriptors:array];
    }
    __autoreleasing NSError *error = nil;
    NSArray *request = [context executeFetchRequest:fetchrequest error: &error];
    return request;
}

//===============================================
// 聊天
//===============================================

#pragma mark- ////
#pragma mark- 聊天消息
//创建
- (Chat *)createChatById:(NSNumber *)msgId {
    Chat *chat = [self getChatByid:msgId];
    if (chat) {
        return chat;
    }
    chat = [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:context];
    chat.msgId = msgId;
    return chat;

}
//查找
- (Chat *)getChatByid:(NSNumber *)msgId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgId == %lld",[msgId longLongValue]];
    NSArray *result = [self executeResultBypredicate:predicate limit:1 entityName:@"Chat" decriptorkey:nil ascending:NO];
    if ([result count] == 1) {
        return [result objectAtIndex:0];
    }
    return nil;
}
/**
 *获取最后一条聊天信息时间 加1 之后返回
 **/
- (NSDate *)getLastMsgTime:(long long)cid userid:(long long)uid
{
    Chat *chat = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.loginUid = %lld and self.courseID = %lld",uid,cid];
    NSArray *result = [self executeResultBypredicate:predicate limit:1 entityName:@"Chat" decriptorkey:@"time" ascending:NO];
    if ([result count] == 1) {
        chat = [result firstObject];
    }
    if (!chat) {
        return [NSDate date];
    }
    NSDate *date_ = chat.time;
    long long time_ = [date_ timeIntervalSince1970] + 1;
    NSDate *returnDate = [NSDate dateWithTimeIntervalSince1970:time_];
    return returnDate;
}

//===============================================
// 缓存文件记录
//===============================================

//创建
- (CacheFile *)createCacheFile:(NSString *)name {
    CacheFile *cfile = [self getCacheFile:name];
    if (cfile) {
        return cfile;
    }
    cfile = [NSEntityDescription insertNewObjectForEntityForName:@"CacheFile" inManagedObjectContext:context];
    cfile.fileName = name;
    return cfile;
}
//查找
- (CacheFile *)getCacheFile:(NSString *)fileName {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName == %@",fileName];
    NSArray *result = [self executeResultBypredicate:predicate limit:1 entityName:@"CacheFile" decriptorkey:nil ascending:NO];
    if ([result count] == 1) {
        return [result objectAtIndex:0];
    }
    return nil;
}
//获取过期缓存文件名
- (NSArray *)getInvalidateCacheFile {
    NSDate *invalidate = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*30];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastOpenTime < %@",invalidate];
    NSArray *result = [self executeResultBypredicate:predicate limit:0 entityName:@"CacheFile" decriptorkey:@"lastOpenTime" ascending:NO];
    return result;
}
@end
