//
//  ClassModel.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
// 暂时只有 我的日历页 使用

#import "JSONModel.h"

typedef enum {
    ClassModelType_Online = 1,  /*在线*/
    ClassModelType_NotOnlie,    /*非在线*/

    
} ClassModelType; //课程类型 <在线/非在线>

@interface ClassModel : JSONModel

@property (strong, nonatomic) NSString *name,   /*课程名称*/
*startTime, /*开始时间*/
*teaNick,   /*教师昵称*/
*tearealName,  /*教师名字*/
*couresPrice,   /*课程价格*/
*couresrecordUrl, /*直播录播地址*/
*courseAdress,  /*上课地址*/
*courseIcon,     /*课程Img url*/
*finishedclass, /*已完成的课程数*/
*totalclass;    /*课程总数*/



@property (assign, nonatomic) int tyoe;         /*是否在线课程*/
@property (assign, nonatomic) BOOL invalidate;  /*是否失效*/
@property (assign, nonatomic) long long cid,    /*课程ID*/
classid,    /*课节id*/
teacherId; /*教师id*/
@end

@interface ClassModelList : JSONModel
@property (strong , nonatomic) NSMutableArray *list; /*课程数组*/
@property (nonatomic, assign) BOOL hasMore;
- (void)addClassModelList:(ClassModelList *)list;
/**
 * 仅仅全部课程使用
 **/
- (id)initWithAllCouresJson:(NSDictionary *)json;

@end