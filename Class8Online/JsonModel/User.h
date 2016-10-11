//
//  User.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

typedef enum {
    UserAuthorityType_VISITOR = 1,      //试听者,非注册用户
    UserAuthorityType_OBSERVER = 10,    //旁听者,注册用户,非课程学生
    UserAuthorityType_MONITOR = 20,     //管理员,校长,领导
    UserAuthorityType_STUDENT = 30,     //学生
    UserAuthorityType_ASSISTANT = 31,   //助教
    UserAuthorityType_TEACHER = 40,     //老师
    
}UserAuthorityType;                     //认证类型 <用户类型>

typedef enum {
    UserGender_UNKNOW_GENDER = 0, //未知
    UserGender_MALE = 1,          //男
    UserGender_FEMALE = 2,        //女
}UserGender;                      //性别


@interface User : JSONModel
//登录用户获取用户信息解析
- (id)initLoginUserInfoWithJSON:(NSDictionary *)json;

//学校主页教师用户信息初始化
- (id)initUserInfoWithJSON:(NSDictionary *)json;

@property (assign, nonatomic) long long uid,teaUid,
birthday;                                           /*用户生日时间戳*/

@property (assign, nonatomic) float pfCount;       //教师评分数
@property (assign, nonatomic) int authority, //认证类型 <用户类型>
courseCount,    //全部课程总数
stuCount,       //教师用户拥有的所有学生数
gender,         //性别
bantype,        //封禁类型0:正常,1:被封
state,          // ASK_SPEAK举手状态, SPEAK发言状态̬ 1 : ASK_SPEAK 2: SPEAK <iOS 暂时不使用>
useDevice;      //使用设备 pc/手机 (见登录协议)


@property (strong ,nonatomic)NSString *nickName,    /*用户昵称*/
*city,              /*城市*/
*schoolName,        /*学校名*/
*company,           /*工作单位*/
*departments,       /*院系*/
*professional,      /*专业*/
*resiAddress,       /*地区*/
*realname,          /*用户名*/
*signature,         /*签名*/
*description__,     /*简介*/
*avatar,            /*用户头像*/
*headimageUrl,      /*老师头像*/
*mobile,            /*用户手机*/
*email,             /*邮箱*/
*stuNo,             /*学号*/
*grade,             /*年级*/
*pulladdr,          /*视频拉取地址*/
*pushaddr;          /*视频推流地址*/
@property (strong ,nonatomic)NSString *organization;    /*organization*/


@property (assign, nonatomic) BOOL hasUnReadMsg;    /*是否有未读信息<在线课堂在线用户列表使用>*/


@end


@interface UserList : JSONModel
@property (strong ,nonatomic) NSMutableArray *list; //用户列表
@property (assign, nonatomic) BOOL hasMore; //是否有更多 目前 10 个位一页

/**
 * 初始化学校首页教师列表
 **/
- (id)initWithSchoolUserList:(NSDictionary *)json;

/**
 * 初始化全部教师列表
 **/
- (id)initWithSchoolAllTeachersUserList:(NSDictionary *)json;
- (void)addUserList:(UserList *)uList;



@end