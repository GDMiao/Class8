//
//  KeepOnLineUtils.h
//  Class8Online
//
//  Created by chuliangliang on 15/5/25.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

/**
 * tcp 重新连接登录服务器后 进行登录.断开登录服务器 链接link  验证token
 **/

#import <Foundation/Foundation.h>

#define KNotificationDidLoginSuccess @"loginSuccess"    //登录成功/自动登录成功/重新连接登录成功
#define KNotificationDidKickOut @"loginUserKickOut"     //登录用户被踢<在其他地方登录>
#define KEEPONELINEUTILS [KeepOnLineUtils shareKeepOnline]

typedef void (^LoginVCCallBack)(void);                  //登录VC 成功回调
@interface KeepOnLineUtils : NSObject
+ (KeepOnLineUtils *)shareKeepOnline;
@property (assign, nonatomic) BOOL keepOnline;          //是否启动 断线自动登录->切换服务器->验证Token 模式 默认启动 为YES

/**
 * 首次登录/退出切换账号登录接口
 **/
- (void)login:(NSString *)name passWord:(NSString *)pwd result:(LoginVCCallBack)block;

/**
 *连接TCP服务器
 **/
- (void)connectToServer;

/**
 *断开服务器
 **/
- (void)disConnect;

/**
 * 切换服务器到 登录服务器
 **/
- (void)changToLoginServer;
@end
