//
//  CourseModel.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/16.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"
@interface CourseModel : JSONModel
@property (nonatomic, assign) long long courseID,       /*课程ID*/
classid,                                                /*课节id*/
classingId;                                             /*正在进行的课节id*/
@property (nonatomic, assign) int stuCount,
didDoneCount,
tatolCount,
teaSex;
@property (nonatomic, strong) NSString *courseName,
*className,
*teaName,
*coverUrl,
*courseIcon,
*recordUrl,
*priceTotal,
*price_total;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *teaHomeStartTime;
@property (nonatomic, strong) NSString *latelyStartTimePlan;
@property (nonatomic, assign) BOOL courseOver;
@end

@interface CourseList : JSONModel
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, assign) NSUInteger teaLastCourseCoun, /*教师个人主页 最新课程数量*/
teaHotCourseCount,                                   /*教师主页 最热课程数量*/
orderCourseCount,
creatCourseCount;
@property (nonatomic, assign) BOOL hasMore;

/**
 *仅仅教师主页初始化最新课程+热门课程使用
 **/
-(id)initWithTeacherHomeCourseJSON:(NSDictionary *)json;

/**
 *仅仅教师主页初始化全部课程使用
 **/
-(id)initWithTeacherHomeALLCourseJSON:(NSDictionary *)json;


/**
 *仅仅学校首页课程模型解析
 **/
-(id)initWithSchoolHomeCourseJSON:(NSDictionary *)json;

/**
 * 仅仅全部课程使用
 **/
- (id)initWithAllCouresJson:(NSDictionary *)json;


- (void)addCourseList:(CourseList *)list;
@end
