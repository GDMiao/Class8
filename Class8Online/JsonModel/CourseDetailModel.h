//
//  CourseDetailModel.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"
#import "LessonsModel.h"

@interface CourseDetailModel : JSONModel
@property (assign, nonatomic) long long courseID,                       /*课程ID*/
teaUid,                                                                 /*教师ID*/
currentClassID;                                                         /*当前进入课堂的classid*/
@property (assign, nonatomic) float coursePrice;                        // 课程价钱

@property (strong, nonatomic) NSString *courseName,                     /*课程名*/
*courseCoverURL,                                                        /*课程封面*/
*courseBeginTime,                                                       /*课程开始时间*/
*courseEndTime,                                                         /*课程结束时间*/
*schoolName,                                                            /*所属学校名*/
*teaName,                                                               /*教师名字*/
*teaAvatar,                                                             /*教师头像*/
*courseDescription;                                                     /*课程描述*/


@property (assign, nonatomic) int lessonTotal,                          /*课节总数*/
studentTotal;                                                           /*学生总数*/
@property (assign, nonatomic) float avgScore;                           /*课程综合评分*/
@property (assign, nonatomic) BOOL canEnterClass;                       /*是否可以进入课程直播页*/
@property (assign, nonatomic) long long canEnterClassID;                     /*是否可以进入课程直播页*/
@property (assign, nonatomic) int signupStatus;                       /*报名状态 0未报名 1已报名*/
@property (assign, nonatomic) int classHadFinished;                   /*课程结束状态 0 未结束 1 结束了*/

- (id)initCourseDetailJosn:(NSDictionary *)json;

@end
