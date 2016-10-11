//
//  SchoolNoticeModel.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/18.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "SchoolNoticeModel.h"

@implementation SchoolNoticeModel

- (void)dealloc
{
    self.contentTxt = nil;
    self.title = nil;
    self.createTime = nil;
    self.linkUrl = nil;

}

- (void)parse:(NSDictionary *)json
{
    
    self.title = [json stringForKey:@"title"];
    self.contentTxt = [json stringForKey:@"content"];
    self.linkUrl = [json stringForKey:@"linkUrl"];
    self.createTime = [json stringForKey:@"createTime"];
}

@end

const int courseListOnePageCount = 5;
@implementation SchoolNoticeList

- (void)dealloc {
    self.list = nil;
}

- (void)parse:(NSDictionary *)json
{
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    json = [json objectForKey:@"result"];
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSArray *listArr = [json arrayForKey:@"list"];
        for (NSDictionary *dic  in listArr) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            SchoolNoticeModel *tmpNotice = [[SchoolNoticeModel alloc] initWithJSON:dic];
            [tmpList addObject:tmpNotice];
        }
    }
    self.list = tmpList;
    if (self.list.count < courseListOnePageCount) {
        self.hasMore = NO;
    }else
    {
        self.hasMore = YES;
    }
}

- (void)addNoticeList:(SchoolNoticeList *)list
{
    if (list.list.count > 0) {
        [self.list addObjectsFromArray:list.list];
        
    }
    self.hasMore = list.hasMore;
}
@end