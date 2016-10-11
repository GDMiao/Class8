//
//  UserAccess.h
//  Class8Camera
//
//  Created by chuliangliang on 15/7/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserAccount : NSObject

+ (UserAccount *)shareInstance;
@property (strong, nonatomic) NSString *loginName, *loginPwd,*token,*link,*deviceName,*codeString;
@property (strong, nonatomic) User *loginUser;
@property (nonatomic) char netisp;              //网络提供商
@property (nonatomic, assign) int usertype;     //暂时不使用

@property (assign, nonatomic) BOOL autoLogin,   //是否自动登录
mindPwd;                                        //是否记住密码
@property (assign, nonatomic) BOOL audioYESOrNo;  // 是否开启声音
@property (assign, nonatomic) long long uid;    //登录用户id

//用户注销
- (void)userLogout;
@end
