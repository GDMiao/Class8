//
//  MyCourseList.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/24.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "MyCourseList.h"

const int MyCourseList_onePageCount = 10;
@implementation MyCourseList
- (void)dealloc
{
    self.list = nil;
}
-(void)parse:(NSDictionary *)json
{
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    NSArray *courseList = [json arrayForKey:@"list"];
    for (NSDictionary *dic in courseList) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        CourseModel *tmpCourseModel = [[CourseModel alloc] initWithJSON:dic];
        [tmpList addObject:tmpCourseModel];
    }
    self.list = tmpList;
    if (self.list.count < MyCourseList_onePageCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
}
//添加数据
- (void)addCourseList:(MyCourseList *)cList {
    if (cList.list.count > 0) {
        [self.list addObjectsFromArray:cList.list];
    }
    self.hasMore = cList.hasMore;
}

@end
