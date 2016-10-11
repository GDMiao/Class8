//
//  UserAccess.m
//  Class8Camera
//
//  Created by chuliangliang on 15/7/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "UserAccount.h"
#import "KeepOnLineUtils.h"


#define LoginUserConfigDic @"login_userConfigDic_Key"
#define LoginUserConfig_loginName @"login_name"
#define LoginUserConfig_loginPwd @"login_pwd"
#define LoginUserConfig_mindPwd @"mind_pwd"
#define LoginUserConfig_autoLogin @"auto_login"
#define LoginUserConfig_UID @"login_uid"
#define LoginUserConfig_Token @"login_token"

//--miao
#define LoginUserConfig_Device @"login_deviceNameKey_"
#define LoginUserConfig_CodeKey @"login_codeStringKey_"

static UserAccount *userAccount = nil;
@implementation UserAccount

+ (UserAccount *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userAccount = [[UserAccount alloc] init];
    });
    return userAccount;
}
- (void)dealloc {
    self.loginName = nil;
    self.loginPwd = nil;
    self.token = nil;
    self.link = nil;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self readData];
    }
    return self;
}

- (void)readData {
    _mindPwd = YES;

    self.loginUser = nil;
    NSUserDefaults *userInfo= [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [userInfo objectForKey:LoginUserConfigDic];
    if (userDic && [userDic isKindOfClass:[NSDictionary class]]) {
        _loginName = [userDic stringForKey:LoginUserConfig_loginName];
        _autoLogin = [userDic boolForKey:LoginUserConfig_autoLogin];
//        _mindPwd = [userDic boolForKey:LoginUserConfig_mindPwd];
        _loginPwd = self.mindPwd?[userDic stringForKey:LoginUserConfig_loginPwd]:@"";
        _token = [userDic stringForKey:LoginUserConfig_Token];
        _uid = [userDic longForKey:LoginUserConfig_UID];
        _deviceName = [self getDeviceNameFromLocation:userDic];
        _codeString = [userDic stringForKey:[NSString stringWithFormat:@"%@%lld",LoginUserConfig_CodeKey,self.uid]];

    }else {
        _uid = 0;
        _loginName = @"";
        _loginPwd = @"";
        _token = @"";
        _autoLogin = NO;
        _mindPwd = NO;
        _deviceName = @"";
        _codeString = @"";

    }
}

- (NSString *)getDeviceNameFromLocation:(NSDictionary *)userDic
{
    
    NSString *sub_key = DeviceUDID;
    NSString *devString = [userDic stringForKey:[NSString stringWithFormat:@"%@%@",LoginUserConfig_Device,sub_key]];
    if ([Utils objectIsNull:devString]) {
        UIDevice *dev = [UIDevice currentDevice];        
        devString = [NSString stringWithFormat:@"\"%@\"的%@",dev.name,[Utils deviceString]];
    }
    return devString;
}

//更新用户配置信息
- (void)updateUserConfig:(id)value forKey:(NSString *)key
{
    if ([Utils objectIsNull:value]) {
        return;
    }
    
    NSUserDefaults *userInfo= [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [userInfo objectForKey:LoginUserConfigDic];
    if (userDic && [userDic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithDictionary:userDic];
        [muDic setObject:value forKey:key];
        
        NSUserDefaults *userInfo= [NSUserDefaults standardUserDefaults];
        [userInfo setValue:muDic forKey: LoginUserConfigDic];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else {
        NSMutableDictionary *muDic = [[NSMutableDictionary alloc] init];
        [muDic setObject:value forKey:key];
        
        NSUserDefaults *userInfo= [NSUserDefaults standardUserDefaults];
        [userInfo setValue:muDic forKey: LoginUserConfigDic];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


//==========================================
//TODO : 设置用户名
//==========================================
- (void)setLoginName:(NSString *)loginName {
    _loginName = loginName;
    [self updateUserConfig:loginName forKey:LoginUserConfig_loginName];
}

//==========================================
//TODO : 设置密码
//==========================================
- (void)setLoginPwd:(NSString *)loginPwd {
    _loginPwd = loginPwd;
    [self updateUserConfig:loginPwd forKey:LoginUserConfig_loginPwd];
}

//==========================================
//TODO : 设置是否自动登录
//==========================================
- (void)setAutoLogin:(BOOL)autoLogin {
    _autoLogin = autoLogin;
    [self updateUserConfig:[NSNumber numberWithBool:autoLogin] forKey:LoginUserConfig_autoLogin];
}

//==========================================
//TODO : 设置是否记住密码
//==========================================
- (void)setMindPwd:(BOOL)mindPwd {
    _mindPwd = mindPwd;
    [self updateUserConfig:[NSNumber numberWithBool:mindPwd] forKey:LoginUserConfig_mindPwd];
}

//==========================================
//TODO : 设置UID
//==========================================
- (void)setUid:(long long)uid {
    _uid = uid;
    [self updateUserConfig:[NSNumber numberWithLongLong:uid] forKey:LoginUserConfig_UID];
    [self readData]; //切换登录用户之后更新数据
}

//==========================================
//TODO : 设置Token
//==========================================
- (void)setToken:(NSString *)token {
    _token = token;
    [self updateUserConfig:token forKey:LoginUserConfig_Token];
}

//用户注销
- (void)userLogout
{
    self.autoLogin = NO;
    self.loginUser = nil;
    self.uid = 0;
    [KeepOnLineUtils shareKeepOnline].keepOnline = NO;

}


#pragma mark--miao
//==========================================
//TODO : 设置设备昵称
//==========================================
- (void)setDeviceName:(NSString *)deviceName {
    _deviceName = deviceName;
    NSString *sub_key = DeviceUDID;
    [self updateUserConfig:deviceName forKey:[NSString stringWithFormat:@"%@%@",LoginUserConfig_Device,sub_key]];
}

//==========================================
//TODO : 设置当前使用的Code
//==========================================
- (void)setCodeString:(NSString *)codeString
{
    _codeString = codeString;
    [self updateUserConfig:codeString forKey:[NSString stringWithFormat:@"%@%lld",LoginUserConfig_CodeKey,self.uid]];
}



@end
