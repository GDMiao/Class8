//
//  ClassModel.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "ClassModel.h"

@implementation ClassModel

- (void)parse:(NSDictionary *)json {
    
    self.startTime = [json stringForKey:@"createTime"];
    self.name = [json stringForKey:@"courseName"];
    self.tyoe = [json intForKey:@"onlineType"];
    self.teaNick = [json stringForKey:@"nickName"];
    self.tearealName = [json stringForKey:@"teacherName"];
    self.cid = [json longForKey:@"courseid"];
    self.classid = [json longForKey:@"classid"];
    self.teacherId = [json longForKey:@"teacherUid"];
    self.couresrecordUrl = [json stringForKey:@"recordUrl"];
    self.finishedclass = [json stringForKey:@"finishedclass"];
    self.totalclass = [json stringForKey:@"classTotal"];
    self.courseIcon = [json stringForKey:@"coverUrl"];
    self.courseAdress = [json stringForKey:@"defaultOfflineClassroomAddress"];
    self.couresPrice = [json stringForKey:@"price_total"];
}

- (void)dealloc {
    self.name = nil;
    self.startTime = nil;
    self.teaNick = nil;
    self.tearealName = nil;
    self.finishedclass = nil;
    self.totalclass = nil;
    self.courseIcon = nil;
    self.couresrecordUrl = nil;
    self.courseAdress = nil;
    
}
@end


//============================================
//
// ClassModelList
//
//============================================
const int courseListOnePageCount = 5;
@implementation ClassModelList

- (void)parse:(NSDictionary *)json {
    NSArray *listArr = [json arrayForKey:@"courselist"];
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (NSDictionary *tmpDic in listArr) {
        ClassModel *tmpClassModel = [[ClassModel alloc] initWithJSON:tmpDic];
        [tmpArray addObject:tmpClassModel];
    }
    self.list = tmpArray;
}

- (void)dealloc {
    self.list = nil;
}


/**
 * 仅仅全部课程使用
 **/
- (id)initWithAllCouresJson:(NSDictionary *)json
{
    self.code_ = 500;
    self = [self init];
    if(self && json && [json isKindOfClass:[NSDictionary class]])
    {
        self.json_ =json;
        //代码
        id code = [self.json_ objectForKeyIgnoreNull:@"status"];
        if(code)
        {
            @try {
                self.code_= [[code description] intValue];
            }
            @catch (NSException *exception) {
            }
        }
        //消息
        id message = [self.json_ objectForKeyIgnoreNull:@"message"];
        if (message) {
            @try {
                self.message_= [message description];
            }
            @catch (NSException *exception) {
            }
        }else {
            self.message_ = CSLocalizedString(@"json_error_unknown");
        }
        self.SysCurMills = [self.json_ doubleForKey:@"SysCurMills"];
        //数据内容
        
        [self AllCourseJson:json];
    }
    
    return self;
    
    
}
/**
 * 仅仅全部课程模型解析
 **/

- (void)AllCourseJson:(NSDictionary *)json
{
    
    NSDictionary *json_dic = [json objectForKey:@"courses"];
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    
    if ([json_dic isKindOfClass:[NSDictionary class]]) {
        NSArray *courseList = [json_dic arrayForKey:@"list"];
        for (NSDictionary *dic in courseList) {
            ClassModel *tmpCourse = [[ClassModel alloc] initWithJSON:dic];
            [tmpList addObject:tmpCourse];
        }
    }
    
    self.list = tmpList;
    if (self.list.count<courseListOnePageCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
    
}

- (void)addClassModelList:(ClassModelList *)list{
    if (list.list.count > 0) {
        [self.list addObjectsFromArray:list.list];
        
    }
    self.hasMore = list.hasMore;
}
@end