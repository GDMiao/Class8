//
//  KeepOnLineUtils.m
//  Class8Online
//
//  Created by chuliangliang on 15/5/25.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "KeepOnLineUtils.h"
#import "CNetworkManager.h"
#import "NewReachability.h"
#import "JPUSHService.h"
#import "NetTran.h"

@interface KeepOnLineUtils () <CNetworkManagerDelegate>
{
    NSString *userPwd; //用户首次登录/切换登录是使用的密码
    BOOL loginByUser; //用户首次登录/切换用户登录手动操作 默认NO
    NewReachability* reach;
    BOOL appDidActive; //app 处于活跃状态
}
@property (copy, nonatomic) LoginVCCallBack loginVCblock; //登录VC 成功登录回调
@end


static KeepOnLineUtils *keepOnlineutils = nil;
const int kickOutAlertTag = 2001;
@implementation KeepOnLineUtils
+ (KeepOnLineUtils *)shareKeepOnline {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keepOnlineutils = [[KeepOnLineUtils alloc] init];
    });
    return keepOnlineutils;
}

- (id)init {
    self = [super init];
    if (self) {
        self.keepOnline = YES;
        loginByUser = NO;
        //重新连接/已经连接 通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tcpReconnect) name:KNOtificationReConnect object:nil];
        
        //重新连接/已经断开连接 通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tcpDisconnect) name:KNOtificationDidDisconnect object:nil];
        
        //监听网络状态改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkDidChange:) name:kReachabilityChangedNotification object:nil];
        
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        
        zeroAddress.sin_family = AF_INET;
        zeroAddress.sin_port = htons(Piano_TCP_PORT);
        zeroAddress.sin_addr.s_addr = inet_addr([Piano_TCP_API_IP UTF8String]);
        
//        zeroAddress.sin_port = TCP_PORT;
//        zeroAddress.sin_addr.s_addr = inet_addr([TCP_API_IP UTF8String]);
        
/*
        char szIpAddr[128] = { 0 };
        bool isIp6 = ::getNetAddr([Piano_TCP_API_IP UTF8String], Piano_TCP_PORT,szIpAddr);
        if(isIp6)
        {
            zeroAddress.sin_family = AF_INET6;
        }
        else
        {
            zeroAddress.sin_family = AF_INET;
        }
        
        unsigned int nIP = 0;
        inet_pton(AF_INET, szIpAddr, (void *)&nIP);
        
        zeroAddress.sin_addr.s_addr = nIP;
        zeroAddress.sin_port = htons(Piano_TCP_PORT);
*/
        reach = [NewReachability reachabilityWithAddress:&zeroAddress];
        [reach startNotifier];
        
        //监听程序退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keepOnlineApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
        //监听程序回到前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keepOnlineApplicationWillBecame:) name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        appDidActive = YES;
    }
    return self;
}

//TODO: 程序退到后台
- (void) keepOnlineApplicationWillResignActive: (NSNotification *)notification
{
    appDidActive = NO;
}

//TODO: 程序进入前台
- (void) keepOnlineApplicationWillBecame: (NSNotification *)notification {
    appDidActive = YES;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 * 检查登录信息是否合法
 **/
- (BOOL)checkLoginInfo:(NSString *)name pwd:(NSString *)p {
    if (name.length <= 0) {
        [Utils showHUDEorror:CSLocalizedString(@"keep_utils_loginName_not")];
        return NO;
    }
    if (p.length <= 0) {
        [Utils showHUDEorror:CSLocalizedString(@"keep_utils_loginPassWord_not")];
        return NO;
    }
    return YES;
}

/**
 * 首次登录/退出切换账号登录接口
 **/
- (void)login:(NSString *)name passWord:(NSString *)pwd result:(LoginVCCallBack)block
{
    NSString *newName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *newPwd = [pwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];


    if (![self checkLoginInfo:newName pwd:newPwd]) {
        return;
    }
    
    self.loginVCblock = block;
    [Utils showHUD:CSLocalizedString(@"keep_utils_login_loading")];
    loginByUser = YES;
    
    //记录登录名及密码
    userPwd = newPwd;
    [UserAccount shareInstance].loginName = newName;
    
    
    if (!CNETWORKMANAGER.isConnected || CNETWORKMANAGER.isLoginServer) {
        CSLog(@"KeepOnLineUtil手动登录==> 未经连接到登录服务器执行步骤: 1)连接登录服务器 2)登录用户 3)返回结果");
        [self changToLoginServer]; //连接登录服务器
        
    }else {
        CSLog(@"KeepOnLineUtil手动登录==> 已经连接到登录服务器执行步骤: 1)登录用户 2)返回结果");
        [self tcpReconnect];  //直接走登录等流程
    }
    
}

/**
 * 网络状态改变 例如网络断开/连接
 **/
- (void)netWorkDidChange:(NSNotification *)notification
{
    NewReachability *reachability = (NewReachability *)[notification object];
    if (![reachability isReachable]) {
        [self disConnect];
        CSLog(@"KeepOnLineUtils自动登录==> 网络状态改变 断开网络");
    }else if ([reachability isReachable]) {
        CSLog(@"KeepOnLineUtils自动登录==> 网络状态改变 连接网络");
        if ([reach currentReachabilityStatus] != NotReachable && appDidActive && [UserAccount shareInstance].autoLogin) {
            [self connectToServer];
        }
    }
}

/**
 *连接TCP服务器
 **/
- (void)connectToServer
{
    if (!CNETWORKMANAGER.isConnected) {
        if (![Utils IsEnableNetWork]) {
            if ([SVProgressHUD isVisible]) {
                [SVProgressHUD dismiss];
            }
            [Utils showAlert:CSLocalizedString(@"keep_utils_netWork_bad")];
            return;
        }
        [CNETWORKMANAGER connectToServer];
    }
}

/**
 *断开服务器
 **/
- (void)disConnect
{
    if (CNETWORKMANAGER.isConnected) {
        [CNETWORKMANAGER disConnect];
    }
}
/**
 * 切换服务器到 登录服务器
 **/
- (void)changToLoginServer
{
    [self disConnect];
    [self connectToServer];
}

/**
 * 是否可以登录(自动/手动)
 **/
- (BOOL)hasAuotoLogin {
    if (loginByUser) {
        return YES;
    }
    return [UserAccount shareInstance].autoLogin && [UserAccount shareInstance].loginName.length > 0 && [UserAccount shareInstance].loginPwd.length > 0;
}


#pragma mark-
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kickOutAlertTag:
        {
            [self changToLoginServer];
            [[UserAccount shareInstance] userLogout];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidKickOut object:nil];
            CSLog(@"KeepOnLineUtils自动登录==> 用户在其他地方登录切换登录服务器并发送本地通知");
        }
            break;
            
        default:
            break;
    }
}



#pragma mark-
#pragma mark - 监听TCP 已经连接成功
- (void)tcpReconnect {
    if (CNETWORKMANAGER.isLoginServer && CNETWORKMANAGER.isConnected) {
        if (![self hasAuotoLogin]) {
            CSLog(@"KeepOnLineUtils自动登录==> 用户名为空/密码为空/非自动登录 返回");
            return;
        }
        CSLog(@"KeepOnLineUtils自动登录==> 开始登录");
        [CNETWORKMANAGER loginUserName:[UserAccount shareInstance].loginName userPwd:loginByUser?userPwd:[UserAccount shareInstance].loginPwd responseDelegate:self];
    }else if (CNETWORKMANAGER.isConnected) {
        // 已经连接到 非登录服务器 需要验证token
        CSLog(@"KeepOnLineUtils自动登录==> 切换服务器成功开始验证token");
        [CNETWORKMANAGER tokenValidateResponseDelegate:self];
    }
}

#pragma mark-
#pragma mark - 监听TCP 断开连接
- (void)tcpDisconnect {
    [self tcpReconnect];  //直接走登录等流程
    CSLog(@"KeepOnLineUtils自动登录==> TCP/IP 断开连接 连接类型:%@ ",CNETWORKMANAGER.isLoginServer?@"登录服务器":@"Link");
    
}



#pragma mark -
#pragma mark- CNetworkManagerDelegate 网络回调
//成功后的回调
- (void) cNetWorkCallBackFinish:(id)value cNetworkRecType:(int)pType
{
    [CNETWORKMANAGER removeDelegateWithType:(CNetworkRecProtocol)pType];
    if (CNW_loginRet == pType) {
        if (loginByUser) {
            [UserAccount shareInstance].loginPwd = userPwd;
            [UserAccount shareInstance].autoLogin = YES;
        }

        CSLog(@"KeepOnLineUtils自动登录==> 切换服务器");
        [self disConnect];
        [CNETWORKMANAGER setIsLoginServer:NO];
        [self connectToServer];
    }else if (CNW_TokenValidateRet == pType) {
        CSLog(@"KeepOnLineUtils自动登录==> 获取用户信息UID: %lld",[UserAccount shareInstance].uid);
        [CNETWORKMANAGER queryUserInfo:[UserAccount shareInstance].uid responseDelegate:self];
    }else if (CNW_UserInfoRet == pType) {
        CSLog(@"KeepOnLineUtils自动登录==> 获取用户信息成功");
        if (loginByUser) {
            [Utils showHUDSuccess:CSLocalizedString(@"keep_utils_login_success")];
            loginByUser = NO;
        }
        
        [CNETWORKMANAGER userKickoutAtDelegate:self];
        
        if (self.loginVCblock) {
            self.loginVCblock();
        }
        NSString *alias_UID = @"0";
        alias_UID = [NSString stringWithFormat:@"%lld",[UserAccount shareInstance].loginUser.uid];
        __autoreleasing NSString *alias = alias_UID;
        
        [JPUSHService setTags:nil alias:alias fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
            CSLog(@"set alias Code: %d",iResCode);
        }];

        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidLoginSuccess object:nil];
        
    }else if (CNW_KickOut == pType) {
        long long userid = [value longLongValue];
        if (userid == [UserAccount shareInstance].uid) {
            UIAlertView *kickOutAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                   message:CSLocalizedString(@"keep_utils_user_kickOut")
                                                                  delegate:self
                                                         cancelButtonTitle:CSLocalizedString(@"keep_utils_ok")
                                                         otherButtonTitles:nil, nil];
            kickOutAlert.tag = kickOutAlertTag;
            [kickOutAlert show];
        }
    }
}
- (void) cNetWorkCallBackFaild:(id)value cNetworkRecType:(int)pType
{
    if (CNW_loginRet == pType) {
        [UserAccount shareInstance].loginPwd = @"";
        [UserAccount shareInstance].autoLogin = NO;
        if (loginByUser) {
            [Utils showHUDEorror:value];
            loginByUser = NO;
        }else {
            [Utils hiddenHUD];
            NSString *errorString = (NSString *)value;
            UIAlertView *kickOutAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                   message:errorString
                                                                  delegate:self
                                                         cancelButtonTitle:CSLocalizedString(@"keep_utils_ok") otherButtonTitles:nil, nil];
            kickOutAlert.tag = kickOutAlertTag;
            [kickOutAlert show];
        }
    }else {
    }
    [CNETWORKMANAGER removeDelegateWithType:(CNetworkRecProtocol)pType];
}

@end
