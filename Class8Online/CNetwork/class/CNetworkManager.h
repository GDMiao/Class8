//
//  CNetworkManager.h
//  IOLIBDome
//
//  Created by chuliangliang on 15/4/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
/**
 *此类用来维护除小助手外的所有TCP 连接使用 for 2016/01/26 之后的版本
 **/

#import <Foundation/Foundation.h>
#import "CNetworkCallBack.h"
#include "loginclient.h"
#include "gnconf.h"
#include "gnpollio.h"
#import "SVProgressHUD.h"
#import "CNETModels.h"

#define CNETWORKMANAGER [CNetworkManager defaultManager]
#define KNOtificationDidDisconnect @"didDisConnect"     //断开连接的通知
#define KNOtificationReConnect @"reconnect"             //重新连接/已经连接 通知
#define KNOtificationConnectTimeOut @"connectTimeOut"   //服务器连接超时

typedef  enum {
    CNW_ConnectServer = -200,           //连接服务器<自定义使用>
    
    CNW_loginRet = 202,                 //登录返回 数据
    CNW_TokenValidateRet = 206,         //Token验证返回
    CNW_UserInfoRet = 2002,
    
    CNW_UserEnter = 1001,               //进入课堂<登录用户:客户端主动发出, 他人进入 登录者接收>
    CNW_UserWelecome = 1002,            //进入课堂回执
    CNW_SendMsgRet = 1010,              //发送消息
    CNW_UserLeaveRet = 1003,            //离开课堂
    CNW_SwitchClassShow = 1004,         //改变课堂显示 进入课堂需设置此代理
    CNW_CreateWhiteBoard = 1005,        //创建/删除/修改 白板 进入课堂需设置此代理
    CNW_AddCourseWare = 1006,           //老师添加课件 进入课堂需设置此代理
    CNW_SetClassState = 1008,           //上下课 进入课堂需设置此代理
    CNW_SetClassMode = 1009,            //课堂权限设置  进入课堂需设置此代理
    CNW_ClassActions = 1011,            //课堂事件 举手提问/踢人等 进入课堂需设置此代理
    CNW_WhiteBoardEvent = 1012,         //白板事件 进入课堂需设置此代理
    CNW_KickOut = 1016,                 //用户被踢出 <在其他设备登陆>
    CNW_MediaServerResp = 1018,         //请求媒体服务器
    CNW_SetTeacherVedioRet = 1027,      //老师切换主视频
    CNW_QueryUserListResp = 1026,       //已进入课堂的用户列表
    CNW_keepAlive = 1029,               //保持心跳 连接link后保持在线
    CNW_Sign = 1030,                    //课堂签到
    /*-移动摄像头 工具 使用的 网络协议-*/
//    CNW_MobileConnectClass = 1035,      //手机助手连课堂
//    CNW_ChooseMobile = 1038,            //选择手机助手开始/停止上传音视频
//    CNW_Kick = 1040,                    //用于消息通知，包括主动删除手机设备、下课
    CNW_SetMainShow = 1052,             //主窗口显示控制
    
}CNetworkRecProtocol;                   //收到的请求结果的协议类型


@protocol CNetworkManagerDelegate <NSObject>

@optional
- (void) cNetWorkCallBackFinish:(id)value cNetworkRecType:(int) pType;  //成功后的回调
- (void) cNetWorkCallBackFaild:(id)value cNetworkRecType:(int) pType;   //失败后的回调

@end

@interface CNetworkManager : NSObject
+ (CNetworkManager *)defaultManager;

/**
 * 是否使用登录服务器地址 第一次启动 默认 yes
 **/
@property (nonatomic, assign) BOOL isLoginServer;

/**
 * 是否可以显示无网提示 第一次启动为 yes
 **/
@property (nonatomic, assign) BOOL hasNotNetWork;

/**
 *是否已经连接
 **/
@property (nonatomic, assign) BOOL isConnected;

/**
 * 删除代理对象
 **/
- (void)removeDelegateWithType:(CNetworkRecProtocol)type;


/**
* Octets ==> unichar ==> NSString
**/
- (NSString *)stringFromOctetsWithUnichar:(GNET::Octets)oct;


/**
 * 断开连接
 **/
- (void)disConnect;

/**
 * 连接服务器
 **/
- (void)connectToServer;


//========================
//TODO: 登录
//========================
- (void)loginUserName:(NSString *)name userPwd:(NSString *)pwd responseDelegate:(id<CNetworkManagerDelegate>)delegate;

//========================
//TODO: 验证Token
//========================
- (void)tokenValidateResponseDelegate:(id<CNetworkManagerDelegate>)delegate;


//======================
//TODO: 获取用户信息
//======================
- (void)queryUserInfo:(long long)uid responseDelegate:(id<CNetworkManagerDelegate>)delegate;

//=====================
//TODO: kickOut 用户被踢
//=====================
- (void)userKickoutAtDelegate:(id<CNetworkManagerDelegate>)delegate;

//=====================
//TODO: 进入课堂
//====================
- (void)userIntoClassRoom:(long long)cid classID:(long long)classid responseDelegate:(id<CNetworkManagerDelegate>)delegate;

//=====================
//TODO: 设置在线课堂接收代理<学生>
//=====================
- (void)addClassInfoDelegate:(id<CNetworkManagerDelegate>)aDelegate;

//=====================
//TODO: 设置在线课堂接收代理<教师>
//=====================
- (void)addClassInfoDelegateForTeacher:(id<CNetworkManagerDelegate>)aDelegate;

//=====================
//TODO: 移除在线课堂相关监听代理<学生>
//=====================
- (void)removeClassInfoDelegate;

//=====================
//TODO: 移除在线课堂相关监听代理<教师>
//=====================
- (void)removeClassInfoDelegateForTeacher;


//=====================
//进入课堂签到
//=====================
- (void)classRoomSign:(long long) cid userId:(long long)uid classid:(long long)classid;

//===================
//课堂签退
//===================
- (void)classRoomSignOut:(int)startCount commentText:(NSString *)text userid:(long long) uid courseId:(long long) cid classID:(long long)classid;

//=====================
//TODO: 发送信息 1 : 课堂 2: 小组 3:用户个人
//=====================
- (void)sendMessage:(NSString *)text ChatType:(int)cType sendUid:(long long)sUid courseId:(long long)cid isGIF:(BOOL)isGif recUid:(long long)ruid;

//=====================
//TODO: 离开课堂
//=====================
- (void)userLeaveCourse:(long long) courseid userid:(long long) uid responseDelegate:(id<CNetworkManagerDelegate>)delegate;

/*------移动摄像头 工具使用的相关协议------*/

//======================
//TODO: 手机连接课堂请求
//======================
//- (void)mobileConnectClass:(long long)uid code:(NSString *)codeString deviceName:(NSString *)devName responseDelegate:(id<CNetworkManagerDelegate>)delegate;


//======================
////TODO: 设置手机连接课堂成功后接收代理
////======================
//- (void)addMobiDidConnectChooseDelegate:(id<CNetworkManagerDelegate>)delegate;
//
////======================
////TODO: 移除手机连接课堂成功后接收代理
////======================
//- (void)delMobiDidConnectChooseDelegate;

////======================
////TODO: 被选中或者被删除 回复
////======================
//- (void)returnChooseAt:(ChooseMobileMdoel *)chooseModel;
//
////======================
////TODO: 主动停止视频传输
////======================
//- (void)mobileCameraOffWithTeaId:(long long)tid;


//======================
//TODO: 教师主动 上课/下课
//======================
- (void)classBegin:(BOOL)isBegin courseID:(long long)cid classID:(long long)classid userid:(long long)uid;

//TODO: 意见反馈
- (void)feedBack:(NSString *)content withUserID:(long long)uid;

//=====================
//TODO: 课堂举手
//=====================
- (void)handsup:(long long) courseid userid:(long long) uid isHand:(BOOL)ishand responseDelegate:(id<CNetworkManagerDelegate>)delegate;
@end

