//
//  LessonsModel.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

typedef enum
{
    LessonsStatus_NotBegin = 15,        /*未开始*/
    LessonsStatus_Ongoing = 16,         /*正在进行中*/
    LessonsStatus_Done = 17,            /*已经完成*/
    LessonsStatus_TimeOut = 20,         /*课节已经取消，主动或者被动。被动指今天之前的课程，不让再上了 按已完成处理*/
}LessonsStatus;

@interface LessonsModel : JSONModel

@property (assign, nonatomic) long long lessonsID,          /*课节ID*/
coureID;                                                    /*课程ID*/
@property (assign, nonatomic) int lessonsNumber,            /*课节数*/
lessonsStatus;                                              /*课节状态 详情见 枚举: LessonsStatus */
@property (strong, nonatomic) NSString *lessonsName,        /*课节名*/
*lessonsBeginTime,                                          /*课节开始时间*/
*lessonsEndTime,                                            /*课节结束时间*/
*lessonsBeginTimeAcual,                                     /*课程计划开始时间*/
*lessonsEndTimeAcual,                                       /*课程计划技术时间*/
*lessonsCreateTime;                                         /*课程创建时间*/

@end

@interface LessonsList : JSONModel
@property (nonatomic,strong) NSMutableArray *list;
@end