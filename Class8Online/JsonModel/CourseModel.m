//
//  CourseModel.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/16.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CourseModel.h"

@implementation CourseModel
- (void)dealloc
{
    self.courseName = nil;
    self.teaName = nil;
    self.courseIcon = nil;
    self.priceTotal = nil;
    self.price_total = nil;
}

- (void)parse:(NSDictionary *)json
{
    self.courseID = [json longForKey:@"courseid"];
    self.classingId = [json longForKey:@"classingid"];
    self.className = [json stringForKey:@"className"];
    self.coverUrl = [json stringForKey:@"coverUrl"];
    self.courseIcon = [json stringForKey:@"coverUrl"];
    self.courseName = [json stringForKey:@"courseName"];
    self.teaName = [json stringForKey:@"teacherName"];
    self.recordUrl = [json stringForKey:@"recordUrl"];
    self.stuCount = [json intForKey:@"totalStudent"];
    self.didDoneCount = [json intForKey:@"finishedclass"];
    self.tatolCount = [json intForKey:@"totalclass"];
    self.priceTotal = [json stringForKey:@"priceTotal"];
    self.price_total = [json stringForKey:@"price_total"];
    self.startTime = [json stringForKey:@"createTime"];
    self.teaHomeStartTime = [json stringForKey:@"latelyStartTimePlan"];
    self.latelyStartTimePlan = [json stringForKey:@"latelyStartTimePlan"];
    self.classid = [json longForKey:@"classid"];
 

    
    self.courseOver = self.didDoneCount == self.tatolCount;
}
@end


const int courseListOnePageCount = 5;
@implementation CourseList

- (void)dealloc
{
    self.list = nil;
}
- (void)parse:(NSDictionary *)json
{
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    //学生主页课程列表 <正在学习/已经完成学下>

    NSArray *courseList = [json arrayForKey:@"result"];
    for (NSDictionary *dic in courseList) {
        CourseModel *tmpCourse = [[CourseModel alloc] initWithJSON:dic];
        [tmpList addObject:tmpCourse];
    }
    self.list = tmpList;
    if (self.list.count<courseListOnePageCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
}

- (void)addCourseList:(CourseList *)list
{
    if (list.list.count > 0) {
        [self.list addObjectsFromArray:list.list];
    }
    self.hasMore = list.hasMore;
}

/**
 *仅仅教师主页初始化最新课程+热门课程使用
 **/
-(id)initWithTeacherHomeCourseJSON:(NSDictionary *)json
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
        
        [self parseTeacherHomeCourseJson:json];
    }
    
    return self;

}

- (void)parseTeacherHomeCourseJson:(NSDictionary *)json
{
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    NSMutableArray *tmpList_last_model = [[NSMutableArray alloc] init];
//    NSMutableArray *tmpList_hot_model = [[NSMutableArray alloc] init];
    //教师主页 最新课程
    NSArray *courseList_last = [json arrayForKey:@"lastest"];
    for (NSDictionary *dic in courseList_last) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        CourseModel *tmpCourse = [[CourseModel alloc] initWithJSON:dic];
        [tmpList_last_model addObject:tmpCourse];
    }
//    self.teaLastCourseCoun = tmpList_last_model.count;
    
    //教师主页 最新课程
//    NSArray *courseList_hot = [json arrayForKey:@"hot"];
//    for (NSDictionary *dic in courseList_hot) {
//        if (![dic isKindOfClass:[NSDictionary class]]) {
//            continue;
//        }
//        CourseModel *tmpCourse = [[CourseModel alloc] initWithJSON:dic];
//        [tmpList_hot_model addObject:tmpCourse];
//    }
//    self.teaHotCourseCount = tmpList_hot_model.count;
    if (courseList_last.count>0) {
        [tmpList addObjectsFromArray:tmpList_last_model];
    }
//    if (courseList_hot.count > 0) {
//        [tmpList addObjectsFromArray:tmpList_hot_model];
//    }
//    self.list = tmpList;
//    self.hasMore = NO;
    self.list = tmpList;
    if (self.list.count<courseListOnePageCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
}

/**
 *仅仅教师主页初始化全部课程使用
 **/
-(id)initWithTeacherHomeALLCourseJSON:(NSDictionary *)json
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
        
        [self parseTeacherHomeAllCourseJson:json];
    }
    
    return self;
}

//教师首页教师全部课程赋值
- (void)parseTeacherHomeAllCourseJson:(NSDictionary *)json
{
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    //学生主页课程列表 <正在学习/已经完成学下>

    NSDictionary *dic_josn = [json objectForKey:@"result"];
    
    NSArray *courseList = nil;
    if ([dic_josn isKindOfClass:[NSDictionary class]]) {
        courseList = [dic_josn arrayForKey:@"list"];
    }
    
    for (NSDictionary *dic in courseList) {
        CourseModel *tmpCourse = [[CourseModel alloc] initWithJSON:dic];
        [tmpList addObject:tmpCourse];
    }
    self.list = tmpList;
    if (self.list.count<courseListOnePageCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
}

/**
 *仅仅学校首页课程模型解析
 **/
-(id)initWithSchoolHomeCourseJSON:(NSDictionary *)json
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
        
        [self parseSchoolHomeCourseJson:json];
    }
    
    return self;

}
/**
 * 仅仅学校首页课程模型解析
 **/
- (void)parseSchoolHomeCourseJson:(NSDictionary *)json
{
    
    NSDictionary *json_dic = [json objectForKey:@"result"];
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    
    if ([json_dic isKindOfClass:[NSDictionary class]]) {
        NSArray *courseList = [json_dic arrayForKey:@"list"];
        for (NSDictionary *dic in courseList) {
            CourseModel *tmpCourse = [[CourseModel alloc] initWithJSON:dic];
            [tmpList addObject:tmpCourse];
        }
    }
//    self.orderCourseCount = tmpList.count;
    self.list = tmpList;
    if (self.list.count<courseListOnePageCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }

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
            CourseModel *tmpCourse = [[CourseModel alloc] initWithJSON:dic];
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
@end
