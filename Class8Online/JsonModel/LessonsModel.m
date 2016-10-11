//
//  LessonsModel.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "LessonsModel.h"

@implementation LessonsModel
- (void)dealloc
{
    self.lessonsBeginTime = nil;
    self.lessonsEndTime = nil;
    self.lessonsBeginTimeAcual = nil;
    self.lessonsEndTimeAcual = nil;
    self.lessonsCreateTime = nil;

    self.lessonsName = nil;
    
    
}
- (void)parse:(NSDictionary *)json
{
 
    self.lessonsID = [json longForKey:@"classid"];
    self.coureID = [json longForKey:@"courseid"];
    
    self.lessonsStatus = [json intForKey:@"classState"];
    self.lessonsNumber = [json intForKey:@"seqNum"];
    
    self.lessonsName = [json stringForKey:@"className"];
    self.lessonsCreateTime = [json stringForKey:@"createTime"];
    self.lessonsEndTimeAcual = [json stringForKey:@"endTimeActual"];
    self.lessonsEndTime = [json stringForKey:@"endTimePlan"];
    self.lessonsBeginTimeAcual = [json stringForKey:@"startTimeActual"];
    self.lessonsBeginTime = [json stringForKey:@"startTimePlan"];
    
}

@end

@implementation LessonsList
- (void)dealloc
{
    
}

- (void)parse:(NSDictionary *)json
{
    //课节列表
    NSMutableArray *tmpLessonsList = [[NSMutableArray alloc] init];
    NSArray *resultArr = [json arrayForKey:@"result"];
    for (NSDictionary *dic in resultArr) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        LessonsModel *tmpLesson =[[LessonsModel alloc] initWithJSON:dic];
        [tmpLessonsList addObject:tmpLesson];
    }
    self.list = tmpLessonsList;

}
@end