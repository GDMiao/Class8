//
//  NoticesModel.m
//  Class8Online
//
//  Created by chuliangliang on 15/9/2.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "NoticesModel.h"

@implementation NoticesModel

- (void)dealloc {

    self.title = nil;
    self.content = nil;
    self.iconUrl = nil;
    self.subTitle = nil;
    self.dateString = nil;
    self.strPublicName = nil;
    self.readTimeString = nil;
}

- (void)parse:(NSDictionary *)json {
    
    //string
    self.title = [json stringForKey:@"msgName"];
    self.subTitle = [json stringForKey:@"title"];
    self.content = [json stringForKey:@"content"];
    self.iconUrl = [json stringForKey:@"userImg"];
    self.strPublicName = [json stringForKey:@"strPublicName"];
    self.dateString = [json stringForKey:@"createTime"];
    self.readTimeString = [json stringForKey:@"readTimeString"];
    
    //int
    self.noticeType = [json intForKey:@"msgType"];
    self.userType = [json intForKey:@"userType"];
    self.userSex = [json intForKey:@"sex"];
    
    //long long
    self.senderid = [json longForKey:@"senderid"];
    self.msgId = [json longForKey:@"msgId"];
    
    //bool
    self.readFlag = [json boolForKey:@"readFlag"];
    
}
@end


const int noticesWithOnePageCount = 10;
@implementation NoticesList

- (void)dealloc
{
    self.list = nil;
}

- (void)parse:(NSDictionary *)json {

    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    
    NSArray *listArr = [json arrayForKey:@"list"];
    
    for (NSDictionary *tmpDic in listArr) {
        NoticesModel *tmpNoticeModel = [[NoticesModel alloc] initWithJSON:tmpDic];
        [tmpList addObject:tmpNoticeModel];
    }
    self.list = tmpList;

    if (self.list.count < noticesWithOnePageCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
    
}

- (void)addNotices:(NoticesList *)nList
{
    if (nList.list.count > 0) {
        [self.list addObjectsFromArray:nList.list];
    }
    self.hasMore = nList.hasMore;
}
@end