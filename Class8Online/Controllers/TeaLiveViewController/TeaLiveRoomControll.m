//
//  TeaLiveRoomControll.m
//  Class8Online
//
//  Created by chuliangliang on 15/11/24.
//  Copyright © 2015年 chuliangliang. All rights reserved.
//

#import "TeaLiveRoomControll.h"
#import "CNetworkManager.h"
#import "ClassRoomEventModel.h"
#import "KeepOnLineUtils.h"



@interface TeaLiveRoomControll ()<CNetworkManagerDelegate>

@end

const NSInteger classStartTime = 201511; //上课开始

@implementation TeaLiveRoomControll


- (id)initWithCourseID:(long long) courseid classID:(long long)classid {
    self = [super init];
    if (self) {
        
        self.courseID = courseid;
        self.classID = classid;
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoginWithOtherLocation)
                                                    name:KNotificationDidKickOut object:nil];
        //监听网络是否重新连接并且登录成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectNotification)
                                                     name:KNotificationDidLoginSuccess object:nil];
        //监听程序退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:[UIApplication sharedApplication]];
        //监听程序回到前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillBecame:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];

    }
    return self;
}


/**
 * show Alert View
 **/
- (void)showAlert:(NSString *)text alertTag:(int)tag hasDelegate:(BOOL)hasDelegate cancelTitle:(NSString *)cancenlText otherTitle:(NSString *)otherText
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:text delegate:hasDelegate?self:nil cancelButtonTitle:cancenlText otherButtonTitles:otherText, nil];
    alert.tag = tag;
    [alert show];
}

#pragma mark- 
#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.cancelButtonIndex == buttonIndex) {
        return;
    }
    
    NSInteger alertTag = alertView.tag;
    switch (alertTag) {
        case classStartTime:
        {
            //上课时间到开始上课
            [self classBegin:YES];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    self.delegate = nil;
    ClassRoomLog(@"TeaLiveRoomControll ==> dealoc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 * @param isReconnect 是否重新连接
 * 进入课堂
 **/
- (void)intoClassRoom:(BOOL)isReconnect;

{
    ClassRoomLog(@" TeaLiveRoomControll ==> 教师开始进入课堂ID: %lld 课节ID: %lld",self.courseID,self.classID);
    if (!isReconnect) {
        [Utils showHUD:nil];
    }
    [CNETWORKMANAGER userIntoClassRoom:self.courseID classID:self.classID responseDelegate:self];
    [CNETWORKMANAGER addClassInfoDelegateForTeacher:self]; //课堂相关信息监听
}
/**
 * 离开课堂
 **/
- (void)leaveClassRoom
{
    [CNETWORKMANAGER userLeaveCourse:self.courseID userid:[UserAccount shareInstance].loginUser.uid responseDelegate:self];
    [CNETWORKMANAGER removeClassInfoDelegateForTeacher]; //移除课堂相关信息监听
}


/**
 * 课堂状态-> 上课/下课
 **/
- (void)classBeginOrEnd
{
    [self classBegin:self.roomStatus == TeaLiveRoomSatus_ON_AND_BEGIN ? NO : YES];
}


/**
 * 上课/下课
 **/
- (void)classBegin:(BOOL)isBegin
{
    ClassRoomLog(@"TeaLiveRoomControll ==> 设置课程状态: %@",isBegin?@"上课":@"下课");
    [CNETWORKMANAGER classBegin:isBegin courseID:self.courseID classID:self.classID userid:[UserAccount shareInstance].uid];
}

#pragma mark-
#pragma mark - notices 通知响应方法
//=================================================================
//TODO: notices 通知响应方法
//=================================================================

/**
 * 网络重新连接通知并登录成功
 **/
- (void)didConnectNotification {
    ClassRoomLog(@"TeaLiveRoomControll ==> 在线课堂断线重新连接并且成功登录");
    [self intoClassRoom:YES];
}

/**
 * 用户在其他地方被登录
 **/
- (void)userLoginWithOtherLocation {
    
    [CNETWORKMANAGER removeClassInfoDelegateForTeacher]; //移除课堂相关信息监听
    if ([self.delegate respondsToSelector:@selector(liveControllUserLoginWithOtherLocation)]) {
        [self.delegate liveControllUserLoginWithOtherLocation];
    }    
}
/**
 * 程序退到后台
 **/
- (void) applicationWillResignActive: (NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(liveControllApplicationWillResignActive)]) {
        [self.delegate liveControllApplicationWillResignActive];
    }
}

//TODO: 程序进入前台
- (void) applicationWillBecame: (NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(liveControllApplicationWillBecame)]) {
        [self.delegate liveControllApplicationWillBecame];
    }
}



//=================================================================
//TODO: 网络数据处理
//=================================================================

/**
 * UserEnterModel
 **/
- (void)userEnter:(UserEnterModel *)userEnter
{
    ClassRoomLog(@"TeaLiveRoomControll ==> 教师开始进入课堂 UserEnterModel UID:%lld",userEnter.user.uid);
    if (userEnter.user.uid == [UserAccount shareInstance].uid) {
        //自己进入
        
    }else {
        //他人进入
    }
}

/**
 * userWelecome
 **/
- (void)userWelecome:(UserWelecomeModel *)uWmodel
{
    ClassRoomLog(@"TeaLiveRoomControll ==> 教师开始进入课堂 UserWelecomeModel");

    //读取课堂状态
    self.roomStatus = [self getNowRoomStatus:uWmodel.classstate];
    if ([self.delegate respondsToSelector:@selector(liveControllIntoLiveRoom:)]) {
        [self.delegate liveControllIntoLiveRoom:YES];
    }

    
}

/**
 * 读取课堂状态
 **/
- (TeaLiveRoomSatus)getNowRoomStatus:(WelClassStateModelType)type
{
    TeaLiveRoomSatus status;
    switch (type) {
        case WelClassStateModelType_CLASS_NOT_ON:
        {
            /*未开始*/
            status = TeaLiveRoomSatus_NOT_ON;
        }
            break;
        case WelClassStateModelType_CLASS_WAIT_ON:
        {
            //准备中
            status = TeaLiveRoomSatus_WAIT_ON;            
        
        }
            break;
        case WelClassStateModelType_CLASS__ON_NOT_BEGIN:
        {
            //正在进行,但未上课
            status = TeaLiveRoomSatus_ON_NOT_BEGIN;
            
            [self showAlert:@"上课时间到,是否开始上课?" alertTag:classStartTime hasDelegate:YES cancelTitle:@"否" otherTitle:@"是"];
            
        }
            break;

        case WelClassStateModelType_CLASS_ON_AND_BEGIN:
        {
            //上课中
            status = TeaLiveRoomSatus_ON_AND_BEGIN;
            
        }
            break;

        default:
        {
            //默认 未开始
            status = TeaLiveRoomSatus_NOT_ON;
        }
            break;
    }
    return status;
}


/**
 *上课/下课
 **/
- (void)classState:(SetClassStateModel *)stateModel
{
    
    ClassRoomLog(@"TeaLiveRoomControll ==> 设置课堂状态返回 %@",stateModel.ret == 0? @"成功":@"失败");
    if (stateModel.ret == 0) {
        //成功
        self.roomStatus = self.roomStatus == TeaLiveRoomSatus_ON_AND_BEGIN ? TeaLiveRoomSatus_NOT_ON : TeaLiveRoomSatus_ON_AND_BEGIN;
    }else {
        //失败 课堂状态不处理
    }
    if ([self.delegate respondsToSelector:@selector(liveControllUpdateClsssState:)]) {
        [self.delegate liveControllUpdateClsssState:self.roomStatus];
    }
}


#pragma mark-
#pragma mark - CNetworkManagerDelegate
//=================================================================
//TODO: 网络数据回调
//=================================================================
/**
 * 成功后的回调
 **/
- (void) cNetWorkCallBackFinish:(id)value cNetworkRecType:(int) pType
{
    switch (pType) {
            
        case CNW_UserEnter:
        {
            [self userEnter:(UserEnterModel *)value];
        }
            break;
        case CNW_UserWelecome:
        {
            [Utils hiddenHUD];
            [self userWelecome:(UserWelecomeModel *)value];
        }
            break;
        case CNW_SetClassState:
        {
            //上课/下课
            [self classState:(SetClassStateModel *)value];
        }
            break;
        default:
            break;
    }
    
}

/**
 * 失败后的回调
 **/
- (void) cNetWorkCallBackFaild:(id)value cNetworkRecType:(int) pType
{
    [Utils showHUDEorror:value];
    [CNETWORKMANAGER removeDelegateWithType:(CNetworkRecProtocol)pType];
    if (pType == CNW_UserWelecome) {
        //移除所有 教师上课先关协议代理
        [CNETWORKMANAGER removeClassInfoDelegateForTeacher];
        if ([self.delegate respondsToSelector:@selector(liveControllIntoLiveRoom:)]) {
            [self.delegate liveControllIntoLiveRoom:NO];
        }
    }
    
}



@end
