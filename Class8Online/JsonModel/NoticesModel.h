//
//  NoticesModel.h
//  Class8Online
//
//  Created by chuliangliang on 15/9/2.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

typedef enum
{   NoticesType_Person = 0,     /*个人私信*/
    NoticesType_Tea = 50,       /*公开信-课程消息*/
    NoticesType_School = 60,    /*公开信-教务消息*/
    NoticesType_System = 100,   /*公开信-全站系统消息*/
}NoticesType;              //通知中心消息类型

@interface NoticesModel : JSONModel

@property (nonatomic, strong) NSString *title, /*一级标题*/
*content,   /*通知内容*/
*iconUrl,   /*封面url <用户头像等/系统icon/学校logo>*/
*subTitle,  /*二级标题*/
*dateString,/*时间*/
*readTimeString,/*消息阅读时间*/
*strPublicName; /*发起者名*/

@property (nonatomic, assign) int noticeType,       /*消息类型*/
userType, /*用户角色类型 暂时不使用*/
userSex;  /*用户性别*/
@property (nonatomic, assign) long long senderid,   /*发起者id*/
msgId;  /*消息id*/

@property (nonatomic, assign) BOOL readFlag;    /*消息是否阅读*/
@end


@interface NoticesList : JSONModel
@property (nonatomic ,strong) NSMutableArray *list;
@property (nonatomic, assign) BOOL hasMore;
- (void)addNotices:(NoticesList *)nList;
@end