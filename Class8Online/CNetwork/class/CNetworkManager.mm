//
//  CNetworkManager.m
//  IOLIBDome
//
//  Created by chuliangliang on 15/4/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CNetworkManager.h"
#include <vector.h>
#import "KeepOnLineUtils.h"
#import "ClassRoomEventModel.h"  //在线课堂相关模型 文件
#import "CoreTextUtil.h"


#define  pPictureBegin   0xE000 
#define  pPictureEnd   0xE3FF
#define  nEscLen		1 
#define cFontHead      0x01
#define SendMsgLen 800

#define SESSIONTYPE @"sessionType"
#define SESSION_TIME_OUT 30
#define CONNECTServer_sid -200

@interface CNetworkManager ()<CNetworkCallBackDelegate>
{
    dispatch_queue_t queue;
    NSTimer *sessionTimer;
}
@property (weak, nonatomic) id <CNetworkManagerDelegate>delegate;

@property (strong, nonatomic) NSMutableDictionary *delegateConfigDic; //存储所有代理对象
@property (strong, nonatomic) NSMutableDictionary *sessionDic; //存储所有已发出但未收到回应网络会话 key 会话id value 已发出时间(单位s) key: 会话id_type value: 代理对象key
@end

static CNetworkManager *manager = nil;
@implementation CNetworkManager
@synthesize isConnected;

//=================================
//TODO: 会话超时管理
//=================================
- (void)upDateSessionTime{
    [self sessionTimeUpdate];
}

//更新会话发出时间
- (void)sessionTimeUpdate {
    NSArray *keys = [self.sessionDic allKeys];
    for (NSString *sessionIdNum in keys) {
        
        if ([sessionIdNum rangeOfString:SESSIONTYPE].location != NSNotFound) {
            continue;
        }
        id sessionTime = [self.sessionDic objectForKey:sessionIdNum];
        if (sessionTime) {
           CGFloat sTime = [sessionTime floatValue];
            sTime += 1;
            if (sTime > SESSION_TIME_OUT) {
                [self sessionTimeOut:[sessionIdNum intValue]];
            }else {
                sessionTime = [NSNumber numberWithFloat:sTime];
                [self.sessionDic setObject:sessionTime forKey:sessionIdNum];
            }
        }
    }
}
//请求超时回调
- (void)sessionTimeOut:(int)sid {
    int pType = [self.sessionDic intForKey:[NSString stringWithFormat:@"%@%d",SESSIONTYPE,sid]];
    id callBackDelegate = [self getDelegateWithRecProtocolType:pType];
    [self removeDelegateWithType:(CNetworkRecProtocol)pType];
    if (pType == CNW_ConnectServer) {
        //连接服务器超时
        CSLog(@"TCP/IP ==> 服务器连接超时(IP:%s, port:%d)",LoginClient::GetInstance().getTcpIp(),LoginClient::GetInstance().getTcpPort());
        if ([SVProgressHUD isVisible]) {
            //服务器连接失败
            [SVProgressHUD showErrorWithStatus:CSLocalizedString(@"cnetwork_net_bad")];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOtificationConnectTimeOut object:nil];
        [self disConnect];
    }else{
        if ([callBackDelegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
            [callBackDelegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_net_timeOut") cNetworkRecType:pType];
        }
        CSLog(@"TCP/IP连接超时==> %d",pType);
    }
    [self removeSessionDicSess:sid];
}
/**
 * 移除超时管理会话
 **/
- (void)removeSessionDicSess:(int)sid {
    NSString *key = [NSString stringWithFormat:@"%d",sid];
    id sidNum = [self.sessionDic objectForKey:key];
    if (sidNum) {
        [self.sessionDic removeObjectForKey:key];
        [self.sessionDic removeObjectForKey:[NSString stringWithFormat:@"%@%@",SESSIONTYPE,key]];
    }
}

/**
 * 添加超时管理会话
 **/
- (void)addSessionDicSess:(int)sid proType:(CNetworkRecProtocol )ptype
{
    NSString *sidkey = [NSString stringWithFormat:@"%d",sid];
    NSNumber *sidTime = [NSNumber numberWithFloat:1];
    
    NSString *sidPtypeKey = [NSString stringWithFormat:@"%@%d",SESSIONTYPE,sid];
    NSNumber *sidPtype = [NSNumber numberWithInt:ptype];
    
    [self.sessionDic setObject:sidTime forKey:sidkey];
    [self.sessionDic setObject:sidPtype forKey:sidPtypeKey];
}

+ (CNetworkManager *)defaultManager
{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CNetworkManager alloc] init];
    });
    return manager;
}

- (void)dealloc {
    self.delegateConfigDic = nil;
    self.delegate = nil;
    if (queue) {
        queue = nil;
    }
    self.sessionDic = nil;
}
- (id)init {
    self = [super init];
    if (self) {
        self.delegate = nil;
        isConnected = NO;
        self.hasNotNetWork = YES;
        self.delegateConfigDic = [[NSMutableDictionary alloc] init];
        self.isLoginServer = YES;
        [self initWork];
        [self _initDispatchQueue];
        [self _initTimer];
    }
    return self;
}
- (void)_initDispatchQueue {
   queue = dispatch_queue_create("cnetwork.queue", NULL);
}

/**
 * 初始化网络
 **/
- (void)initWork {
    
    LoginClient::GetInstance().Attach(cNetworkCallback);
    GetCnetworkCallbackInst().delegate = self;
    LoginClient::GetInstance().setKeelOnline(NO);
    using namespace GNET;
    NetSys::Socket_open();
    AString strFile;
    GNET::Conf::GetInstance(strFile);
    GNET::PollIO::Init();
}
/**
 *定时器更新会话时间
 **/
- (void) _initTimer{
    self.sessionDic = [[NSMutableDictionary alloc] init];
    
    sessionTimer = [NSTimer scheduledTimerWithTimeInterval:0.99999 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:sessionTimer forMode:NSRunLoopCommonModes];
}
/**
 * 定时器更新时间
 **/
- (void)update {
    [self upDateSessionTime];
}
/**
 * 连接服务器
 **/
- (void)connectToServer {
    
    if ([Utils IsEnableNetWork]) {

        NSString *ipString = Piano_TCP_API_IP;
        int port = Piano_TCP_PORT;
        
        if (!self.isLoginServer) {
            //非登录
            NSString *ip_port_string = [UserAccount shareInstance].link;
            NSArray *ip_Port_arr = [ip_port_string componentsSeparatedByString:@":"];
            ipString = [ip_Port_arr firstObject];
            port = [[ip_Port_arr lastObject] intValue];
        }
        CSLog(@"TCP/IP (ip:%@, port: %d)",ipString,port);
        LoginClient::GetInstance().setTcpIPAndPort([ipString UTF8String], port);
        LoginClient::GetInstance().ConnectToServer();
        
        [self addSessionDicSess:CONNECTServer_sid proType:CNW_ConnectServer];
    }else {
        //网络不可用
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    }
    self.hasNotNetWork = NO;
}

/**
 * 断开连接
 **/
- (void)disConnect {
    [self.sessionDic removeAllObjects];
    self.isLoginServer = YES;
    isConnected = NO;
    LoginClient::GetInstance().setKeelOnline(NO);
    
    LoginClient::GetInstance().Disconnect();
}

/**
 * 添加代理对象
 **/
- (void)addDelegate:(id)aDelegate withRecProtocolType:(CNetworkRecProtocol)type
{
    if (!aDelegate) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%d",type];
    [self.delegateConfigDic setObject:aDelegate forKey:key];
}

/**
 * 删除代理对象
 **/
- (void)removeDelegateWithType:(CNetworkRecProtocol)type
{
    NSString *key = [NSString stringWithFormat:@"%d",type];
    id obj = [self.delegateConfigDic objectForKey:key];
    if (!obj) {
        return;
    }
    [self.delegateConfigDic removeObjectForKey:key];
}

/**
 * 获取代理对象
 **/
- (id)getDelegateWithRecProtocolType:(int)type
{
    NSString *key = [NSString stringWithFormat:@"%d",type];
    id obj = [self.delegateConfigDic objectForKey:key];
    return obj;
}

//=======================================================
//TODO: Octets/NSString/unichar
//=======================================================
/**
 * Octets ==> NSString
 **/
- (NSString *)stringFromOctets:(GNET::Octets)oct
{
    int len = oct.size();
    char cChar[1024] = {0};
    
    memcpy(cChar, oct.begin(), len);
    cChar[len] = '\0';
    NSString *objc_string = [NSString stringWithUTF8String:cChar];
    return objc_string;
}


/**
 * Octets ==> unichar ==> NSString
 **/

- (NSString *)stringFromOctetsWithUnichar:(GNET::Octets)oct
{
    
    int len = oct.size();
    unichar* uChar = new unichar(len);
    memcpy(uChar, oct.begin(), len);
    uChar[len/sizeof(unichar)] = 0;
    NSString *objc_string = [[NSString alloc] initWithCharactersNoCopy:uChar length:len/sizeof(unichar) freeWhenDone:NO];
    return objc_string;
}

/**
 * 新
 * Octets ==> unichar ==> NSString
 **/

- (NSString *)stringFromOctets:(GNET::Octets)oct atUnichar:(unichar)uChar
{
    
    unichar info[1024] = {0};
    int len = oct.size();
    memcpy(info, oct.begin(), len);
    info[len/sizeof(unichar)] = 0;
    NSString* objc_string = [[NSString alloc]initWithCharacters: info length:len/sizeof(unichar)];
    return objc_string;
}

/**
 * NSString ==> Octets
 **/
- (GNET::Octets)octetsFromString:(NSString *)string_objc
{
    const char *string_char = [string_objc UTF8String];
    GNET::Octets octets (string_char, (int)string_objc.length);
    return octets;
}

/**
 * NSString ==> unichar ==> Octets
 **/
- (GNET::Octets)octetsFromUnichar:(unichar *)uChar atString:(NSString *)string {

    
    [string  getCharacters: uChar];
    uChar[string.length *2] = 0;
    uChar[string.length *sizeof(unichar)] = 0;

    AString aString((char*)uChar,(int)string.length *sizeof(unichar));
    GNET::Octets octets (aString, (int)string.length *sizeof(unichar));
    return octets;

}


//发送表情
- (GNET::Octets)octetsFromUnicharHasGifImg:(unichar *)uChar atString:(NSString *)string isGif:(BOOL)gif{

    /*
    const unichar startuc[1] = {0xE000};
    const unichar enduc[1] = {0xE3FF};
    
    NSString *startString = [NSString stringWithCharacters:startuc length:1];
    NSString *endString = [NSString stringWithCharacters:enduc length:1];
    string = [NSString stringWithFormat:@"%@%@%@",startString,string,endString];
    
    [string  getCharacters: uChar];
    uChar[string.length *2] = 0;
    uChar[string.length *sizeof(unichar)] = 0;
    
    
    AString aString((char*)uChar, (int)string.length*sizeof(unichar));
    GNET::Octets octets (aString, (int)string.length *sizeof(unichar));
    return octets;
    */

    NSString *txt = @"";
    if (gif) {
        txt = [NSString stringWithFormat:@"<body style=\" font-family:'Microsoft YaHei'; font-size:14px; font-weight:400; font-style:normal;\"><p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><img src=\":/face/res/face/account/%@\"></p></body",string];
    }else {
        txt = [NSString stringWithFormat:@"<body style=\" font-family:'Microsoft YaHei'; font-size:14px; font-weight:400; font-style:normal;\"><p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">%@</p></body",string];
    }
    [txt  getCharacters: uChar];
    uChar[txt.length *2] = 0;
    uChar[txt.length *sizeof(unichar)] = 0;
    
    
    AString aString((char*)uChar, (int)txt.length*sizeof(unichar));
    GNET::Octets octets (aString, (int)txt.length *sizeof(unichar));
    return octets;
}

//===================================
//TODO: 过滤接收聊天消息
//===================================
- (unichar)getMsgUchar:(unichar)uChar
{
    if (uChar == pPictureBegin) {
        return '[';
    }else if (uChar == pPictureEnd)
    {
        return ']';
    }
    return uChar;
}

- (BOOL)hasFontInfo:(unichar)uchar
{
    if (uchar>>8 == cFontHead) {
        return YES;
    }
    return NO;
}


//============================
//TODO:  CNetworkCallBackDelegate 回调处理
//============================
#pragma mark -
#pragma mark - CNetworkCallBackDelegate
-(void) cNetWorkCallback:(unsigned int) sessionId  Event:(GNET::EVENT_VALUE) event Data:(GNET::Protocol*) pData
{
 
    [self removeSessionDicSess:sessionId]; //移除超时会话管理
    if (pData) {
       unsigned int pType = pData->GetType();
        CSLog(@"TCP/IP协议类型: %d",pType);
    }
    
    if (EVENT_ADDSESSION == event) {
        //添加会话
        CSLog(@"TCP/IP 已经连接");
        isConnected = YES;
        [self removeSessionDicSess:CONNECTServer_sid];//移除对连接服务器超时管理
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOtificationReConnect object:nil];
        
    }else if (EVENT_DELSESSION == event) {
        //删除会话
        CSLog(@"删除会话");
    }else if (EVENT_DISCONNECT == event) {
        //断开连接
        [self removeSessionDicSess:CONNECTServer_sid];//移除对连接服务器超时管理
        LoginClient::GetInstance().setKeelOnline(NO);
        self.isLoginServer = YES; //只要断开就从 登录开始
        isConnected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOtificationDidDisconnect object:nil];
        CSLog(@"TCP/IP 断开连接");
    }else if (EVENT_LOAD_SUCCESS == event) {
        //请求成功
        [self cNetWorkFinish:sessionId Data:pData];
    }else if (EVENT_LOAD_FAILD == event) {
       //请求失败
        [self cNetWorkFaild:sessionId Data:pData];
    }
}

//成功
- (void)cNetWorkFinish:(unsigned int) sessionId Data:(GNET::Protocol*) pData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        int pType = pData->GetType();
        self.delegate = [self getDelegateWithRecProtocolType:pType];

        if (pData->GetType() == LoginRet::PROTOCOL_TYPE) {
//===========================
//TODO: 登录返回结果
//===========================
            //登录返回结果
            LoginRet* pLogin = (LoginRet*)pData;
            if(pLogin->retcode == pLogin->OK)
            {
                [UserAccount shareInstance].uid = pLogin->userid;
                [UserAccount shareInstance].link = [self stringFromOctets:pLogin->link];
                [UserAccount shareInstance].token = [self stringFromOctets:pLogin->token atUnichar:NULL];
                [UserAccount shareInstance].netisp = pLogin->netisp;
                
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFinish:nil cNetworkRecType:pType];
                }
            }
            else if (pLogin->retcode == GNET::LoginRet::INVALID_USERNAME || pLogin->retcode == GNET::LoginRet::INVALID_PASSWORD)
            {
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    //用户名/密码 错误
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_login_error_nameAndPwd") cNetworkRecType:pType];
                }
            }else if (pLogin->retcode == LoginRet::USER_FROZEN) {
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    //账号冻结
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_login_error_userFrozen") cNetworkRecType:pType];
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    //其他原因登录失败
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_login_error") cNetworkRecType:pType];
                }
            }
            pLogin->Destroy();
            
        }else if (pData->GetType() == TokenValidateResp::PROTOCOL_TYPE) {
//=============================
//TODO: token 验证返回
//=============================
            LoginClient::GetInstance().setKeelOnline(YES);
            TokenValidateResp *tokenRet = (TokenValidateResp *)pData;
            if (tokenRet->retcode == 0) {
                //成功
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                    //验证成功
                    [self.delegate cNetWorkCallBackFinish:CSLocalizedString(@"cnetwork_token_validate") cNetworkRecType:pType];
                }
                
            }else {
                //失败
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_token_validate_faild") cNetworkRecType:pType];
                }
            }
        }else if (pData->GetType() == ReturnUser::PROTOCOL_TYPE) {
//=============================
//TODO: token 登录用户信息
//=============================
            ReturnUser *loginUser = (ReturnUser *)pData;
            if (loginUser->retcode == 0) {
                //成功
                UserInfo info_user = loginUser->userinfo;
                // C++ PRO ===> obc Model
                User *u = [[User alloc] init];
                u.uid = info_user.userid;
                u.authority = info_user.authority;
                u.gender = info_user.gender;
                u.bantype = info_user.bantype;
                u.state = info_user.state;
                u.useDevice = info_user.device;
                
                u.nickName = [self stringFromOctets:info_user.nickname atUnichar:NULL];
                u.realname = [self stringFromOctets:info_user.realname atUnichar:NULL];
                u.avatar = [self stringFromOctets:info_user.pic atUnichar:NULL];
                u.mobile = [self stringFromOctets:info_user.mobile atUnichar:NULL];
                u.email = [self stringFromOctets:info_user.email atUnichar:NULL];
                u.signature = [self stringFromOctets:info_user.signature atUnichar:NULL];
                u.pulladdr = [self stringFromOctets:info_user.pulladdr atUnichar:NULL];
                u.pushaddr = [self stringFromOctets:info_user.pushaddr atUnichar:NULL];
                
                
                if ([UserAccount shareInstance].uid == u.uid) {
                    [UserAccount shareInstance].loginUser = u;
                    
                }
                
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFinish:u cNetworkRecType:pType];
                }
                
                if (![KeepOnLineUtils shareKeepOnline].keepOnline) {
                    [KeepOnLineUtils shareKeepOnline].keepOnline = YES;
                }
                
            }else {
                //获取用户信息错误
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_request_faild") cNetworkRecType:pType];
                }
            }
            loginUser->Destroy();
            
        }else if (pData->GetType() == KickOut::PROTOCOL_TYPE) {
//=============================
//TODO: token 用户在别处登录
//=============================
            KickOut *kick = (KickOut *)pData;
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:[NSNumber numberWithLongLong:kick->userid] cNetworkRecType:pType];
            }
            
            
        }else if (pData->GetType() == UserEnter::PROTOCOL_TYPE) {
            //自己/他人进入课堂
            UserEnter *userEnt = (UserEnter *)pData;
            UserInfo info_user = userEnt->userinfo;
            
            UserEnterModel *obj_userEnt = [[UserEnterModel alloc] init];
            obj_userEnt.courseId = userEnt->cid;
            obj_userEnt.device = userEnt -> device;
            obj_userEnt.netisp = userEnt -> netisp;
            
            User *u = [[User alloc] init];
            u.uid = info_user.userid;
            u.authority = info_user.authority;
            u.gender = info_user.gender;
            u.bantype = info_user.bantype;
            u.state = info_user.state;
            u.useDevice = info_user.device;
            
            u.nickName = [self stringFromOctets:info_user.nickname atUnichar:NULL];
            u.realname = [self stringFromOctets:info_user.realname atUnichar:NULL];
            u.avatar = [self stringFromOctets:info_user.pic atUnichar:NULL];
            u.mobile = [self stringFromOctets:info_user.mobile atUnichar:NULL];
            u.email = [self stringFromOctets:info_user.email atUnichar:NULL];
            u.signature = [self stringFromOctets:info_user.signature atUnichar:NULL];
        
            
            char cChar_pullAddr[800] = {0};
            int len = info_user.pulladdr.size();
            memcpy(cChar_pullAddr, info_user.pulladdr.begin(), len);
            cChar_pullAddr[len] = '\0';
            NSString *objc_string = [NSString stringWithUTF8String:cChar_pullAddr];
            u.pulladdr = objc_string;
            
            char cChar_pushvideo[500] = {0};
            int len_Pushvideo = info_user.pushaddr.size();
            memcpy(cChar_pushvideo, info_user.pushaddr.begin(), len_Pushvideo);
            cChar_pushvideo[len_Pushvideo] = '\0';
            NSString *pushVideo = [NSString stringWithUTF8String:cChar_pushvideo];
            u.pushaddr = pushVideo;
            if (info_user.userid == [UserAccount shareInstance].uid) {
                //保存自己的音视频上传地址
                [UserAccount shareInstance].loginUser.pushaddr = pushVideo;

                CSLog(@"---UserEnter--登录用户音视频推流地址: %@",pushVideo);
            }

            
            obj_userEnt.user = u;
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_userEnt cNetworkRecType:pType];
            }
            
            userEnt->Destroy();
        } else if (pData->GetType() == UserWelcome::PROTOCOL_TYPE) {
//=========================
//TODO:  进入课堂回调
//=========================
#pragma mark - 
#pragma mark - 进入课堂回调
            //TODO: 进入课堂
            UserWelcome *userWc = (UserWelcome *)pData;
            //-- 0成功 1未到进入课堂时间,2课已结束,3权限不够,4黑名单禁止入课堂,5课堂加锁--
            if (userWc->ret == UserWelcome::SUCCESS || userWc->ret == UserWelcome::CLASS_END || userWc->ret == UserWelcome::ENTERTIME_NOT_COME) {
                //成功
                CSLog(@"CNetworkManager ==>> 进入课堂回执(UserWelcome) CID: %lld CLASSID: %lld",userWc->cid,userWc->classid);

                UserWelecomeModel *obj_wel = [[UserWelecomeModel alloc] init];
                obj_wel.cid = userWc->cid;
                obj_wel.retCode = (WelCode)userWc->ret;
                obj_wel.classid = userWc->classid;
                obj_wel.cname = [self stringFromOctets:userWc->cname atUnichar:NULL];
                obj_wel.feedback = userWc->feedback;
                obj_wel.mainshow = userWc->mainshow;
                obj_wel.userheadurl = [self stringFromOctets:userWc->userheadurl atUnichar:NULL];
                obj_wel.code_text = [self stringFromOctets:userWc->code atUnichar:NULL];
                obj_wel.timebeforeclass = userWc->timebeforeclass;
                //白板事件
                NSMutableArray *whiteBoardActionList = [[NSMutableArray alloc] init];
                for (int i = 0; i < userWc->whiteboard.size(); i ++) {
                    WhiteBoardAction wdActon = (WhiteBoardAction )userWc->whiteboard[i];
                    
                    WhiteBoardActionModel *obj_whAc =[[WhiteBoardActionModel alloc] init];
                    obj_whAc.uid = wdActon.userid;
                    obj_whAc.cid = wdActon.cid;
                    obj_whAc.owerid = wdActon.oweruid;
                    obj_whAc.paintId = wdActon.paintId;
                    
                    WhiteBoardActionModelType obj_wbType;
                    char obj_wb_char = wdActon.paintype;
                    if (obj_wb_char == 1) {
                        obj_wbType = WhiteBoardEventModelType_PEN;
                    }else if (obj_wb_char== 2) {
                        obj_wbType = WhiteBoardEventModelType_ERASOR;
                    }else if (obj_wb_char == 3) {
                        obj_wbType = WhiteBoardEventModelType_TXT;
                    }else if ( obj_wb_char == 4) {
                        obj_wbType = WhiteBoardEventModelType_LASER_POINT;
                    }else if (obj_wb_char == 103) {
                        obj_wbType = WhiteBoardEventModelType_UNDO;
                    }else if (obj_wb_char == 104) {
                        obj_wbType = WhiteBoardEventModelType_Clearn;
                    }
                    obj_whAc.paintype = obj_wbType;
                    
                    char cChar[100000] = {0};
                    int len =wdActon.arguments.size();
                    memcpy(cChar, wdActon.arguments.begin(), len);
                    cChar[len] = '\0';
                    NSData *data = [NSData dataWithBytes:cChar length:len];
                    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    NSString *objc_string = [[NSString alloc] initWithData:data encoding:enc];

                    obj_whAc.jsonString = objc_string;
                    
                    obj_whAc.pageId = wdActon.pageId;

                    [whiteBoardActionList addObject:obj_whAc];
                }
                obj_wel.whiteBoardActions = whiteBoardActionList;
                
                //当前主窗口
                CurrentShowModel *obj_currentShow = [[CurrentShowModel alloc] init];
                obj_currentShow.page = userWc->currentshow.page;
                
                char cChar[1000] = {0};
                int len =userWc->currentshow.name.size();
                memcpy(cChar, userWc->currentshow.name.begin(), len);
                cChar[len] = '\0';
                NSString *objc_string = [NSString stringWithUTF8String:cChar];
                obj_currentShow.name = objc_string;
                
                
                
                char obj_showType_char = userWc->currentshow.showtype;
                CSLog(@"初始化进入房间当前显示type: %d",obj_showType_char);
                
                CurrentShowModelType obj_showType = CurrentShowModelType_BLANK;
                if (obj_showType_char == userWc->currentshow.BLANK) {
                    obj_showType = CurrentShowModelType_BLANK;
                }else if (obj_showType_char == CurrentShowModelType_COURSEWARE) {
                    obj_showType = CurrentShowModelType_COURSEWARE;
                }else if (obj_showType_char == CurrentShowModelType_WHITEBOARD) {
                    obj_showType = CurrentShowModelType_WHITEBOARD;
                }
                obj_currentShow.showType = obj_showType;
                obj_wel.current = obj_currentShow;

                
                //课件列表
                NSMutableArray *courseWareList = [[NSMutableArray alloc] init];
                for (int i = 0; i < userWc->cousewarelist.size(); i ++) {
                    NSString *courseWareName = [self stringFromOctets:userWc->cousewarelist[i] atUnichar:NULL];
                    [courseWareList addObject:courseWareName];
                    
                }
                obj_wel.cousewarelist = courseWareList;
                
                //上下课状态
                char obj_classState_char = userWc -> classstate;
                CSLog(@"进入课堂==> 上下课状态: %d",obj_classState_char);
                WelClassStateModelType obj_classStateType;
                if ((obj_classState_char & userWc -> CLASS_ON_AND_BEGIN) == userWc -> CLASS_ON_AND_BEGIN) {
                    //上课中
                    obj_classStateType = WelClassStateModelType_CLASS_ON_AND_BEGIN;
                }else if ((obj_classState_char & userWc -> CLASS_ON_NOT_BEGIN) == userWc -> CLASS_ON_NOT_BEGIN) {
                    //正在进行,但未上课
                    obj_classStateType = WelClassStateModelType_CLASS__ON_NOT_BEGIN;
                }else if ((obj_showType_char & userWc -> CLASS_WAIT_ON) == userWc -> CLASS_WAIT_ON) {
                    //准备中
                    obj_classStateType = WelClassStateModelType_CLASS_WAIT_ON;
                }else if ((obj_showType_char & userWc -> CLASS_NOT_ON) == userWc -> CLASS_NOT_ON){
                    //未开始
                    obj_classStateType = WelClassStateModelType_CLASS_NOT_ON;
                }
                obj_wel.classstate = obj_classStateType;
                
                
                //是否能够举手发言,文字聊天
                int classMode = userWc -> classmode;
                obj_wel.classmode = classMode;
                ClassRoomLog(@"初始进入课堂权限数值: %d",classMode);
                
                obj_wel.durationtime = userWc -> durationtime;
                
                //解析老师视频地址
                NSMutableDictionary *userVideoList = [[NSMutableDictionary alloc] init];
                obj_wel.teachervedio = userWc->teachervedio;
                long long currentAskStuUid = -1; //被提问者UID 为-1 时代表 无正在被提问的人
                for (int i = 0; i < userWc-> userlist.size(); i ++) {
                    UserInfo uInfo = userWc->userlist[i];
                    
                    char cChar_video[500] = {0};
                    int len_video = uInfo.pulladdr.size();
                    memcpy(cChar_video, uInfo.pulladdr.begin(), len_video);
                    cChar_video[len_video] = '\0';
                    NSString *obj_Tvideo = [NSString stringWithUTF8String:cChar_video];
                    
        
                    if (uInfo.authority == UserInfo::TEACHER) {
                        obj_wel.teacherVideoDic = [Utils getTeacherMainVideo:obj_Tvideo];
                        obj_wel.teaVideoSrcUrl = obj_Tvideo;
                        obj_wel.teaUid = uInfo.userid;
                    }
                    
                    if (uInfo.userid == [UserAccount shareInstance].uid) {
                        //保存自己的音视频上传地址
                        char cChar_pushvideo[500] = {0};
                        int len_Pushvideo = uInfo.pushaddr.size();
                        memcpy(cChar_pushvideo, uInfo.pushaddr.begin(), len_Pushvideo);
                        cChar_pushvideo[len_Pushvideo] = '\0';
                        NSString *pushVideo = [NSString stringWithUTF8String:cChar_pushvideo];
                        [UserAccount shareInstance].loginUser.pushaddr = pushVideo;
                        CSLog(@"---UserWelcome--登录用户音视频推流地址: %@",pushVideo);
                    }
                    

                    if ((uInfo.state & UserInfo::SPEAK)== UserInfo::SPEAK) {
                        currentAskStuUid = uInfo.userid;
                        CSLog(@"---UserWelcome--正在提问学生uid== %lld  useratate:%d",uInfo.userid,uInfo.state);
                    }
                    
                    if ([Utils objectIsNotNull:obj_Tvideo]) {
                        [userVideoList setObject:obj_Tvideo forKey:[NSString stringWithFormat:@"%lld",uInfo.userid]];
                    }
                }
                obj_wel.userListWithVideoUrlDic = userVideoList;
                obj_wel.askStuUID = currentAskStuUid;
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFinish:obj_wel cNetworkRecType:pType];
                }
            }else if (userWc->ret == UserWelcome::AUTHORITY_ERR) {
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_class_pt") cNetworkRecType:pType];
                }
            }else if (userWc->ret == UserWelcome::BLACKLIST) {
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_user_isKickOut") cNetworkRecType:pType];
                }
            }else if (userWc->ret == UserWelcome::CLASSROOM_LOCKED) {
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_class_didlock") cNetworkRecType:pType];
                }
            }else {
                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_request_faild") cNetworkRecType:pType];
                }
            
            }
            userWc->Destroy();
        }else if (pData->GetType() == QueryUserListResp::PROTOCOL_TYPE) {
#pragma mark -
#pragma mark - 返回课堂已有用户的列表
            
            QueryUserListResp *userList = (QueryUserListResp *)pData;
            NSMutableDictionary *obj_userListDic = [[NSMutableDictionary alloc] init];
            ClassRoomLog(@"课堂已有用户的列表个数: %lu",userList->userlist.size());
            for (int i = 0 ; i < userList->userlist.size(); i ++) {
                
                UserInfo uInfo = userList->userlist[i];
                User *u = [[User alloc] init];
                u.uid = uInfo.userid;
                u.authority = uInfo.authority;
                u.gender = uInfo.gender;
                u.bantype = uInfo.bantype;
                u.state = uInfo.state;
                u.useDevice = uInfo.device;
                
                u.nickName = [self stringFromOctets:uInfo.nickname atUnichar:NULL];
                u.realname = [self stringFromOctets:uInfo.realname atUnichar:NULL];
                u.avatar = [self stringFromOctets:uInfo.pic atUnichar:NULL];
//                u.mobile = [self stringFromOctets:uInfo.mobile atUnichar:NULL];
//                u.email = [self stringFromOctets:uInfo.email atUnichar:NULL];
//                u.signature = [self stringFromOctets:uInfo.signature atUnichar:NULL];
//                u.pushaddr = [self stringFromOctets:uInfo.pushaddr atUnichar:NULL];
                
                char cChar_pullAddr[800] = {0};
                int len = uInfo.pulladdr.size();
                memcpy(cChar_pullAddr, uInfo.pulladdr.begin(), len);
                cChar_pullAddr[len] = '\0';
                NSString *objc_string = [NSString stringWithUTF8String:cChar_pullAddr];
                u.pulladdr = objc_string;
                [obj_userListDic setObject:u forKey:[NSString stringWithFormat:@"%lld",u.uid]];
                
            }
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_userListDic cNetworkRecType:pType];
            }
            
        }else if (pData->GetType() == SendTextMsg::PROTOCOL_TYPE) {
#pragma mark -
#pragma mark - 发送/接收聊天信息 回调
            dispatch_async(queue, ^{
                
                //聊天信息 接收
                
                
                SendTextMsg *sdMsg = (SendTextMsg *)pData;
                SendTextMsgModel *obj_sendMsgModel = [[SendTextMsgModel alloc] init];
                
                NSDate *nowDate = [NSDate date];
                long long msgid = [nowDate timeIntervalSince1970]*1000;
                
                CSLog(@"消息回调时间: %lld",sdMsg->time);
                obj_sendMsgModel.msgId = msgid;
                obj_sendMsgModel.time = sdMsg->time;
                obj_sendMsgModel.courseId = sdMsg->cid;
                obj_sendMsgModel.uid = sdMsg->userid;
                obj_sendMsgModel.recvid = sdMsg->recvid;
                
                char obj_recType_char = sdMsg->recvtype;
                MsgRecvType obj_msgRecType;
                if (obj_recType_char == sdMsg->CLASS) {
                    obj_msgRecType = MsgRecvType_CLASS;
                }else if (obj_recType_char == sdMsg->GROUP) {
                    obj_msgRecType = MsgRecvType_GROUP;
                }else if (obj_recType_char == sdMsg->USER){
                    obj_msgRecType = MsgRecvType_USER;
                }
                obj_sendMsgModel.recvtype = obj_msgRecType;
                obj_sendMsgModel.recvgroupid = sdMsg->recvgroupid;
                obj_sendMsgModel.isMe = [UserAccount shareInstance].loginUser.uid == sdMsg->userid?YES:NO;
                
                long long recTime = sdMsg -> time + 28800;
                NSDate *recDate=[NSDate dateWithTimeIntervalSince1970:recTime];
                obj_sendMsgModel.datetime = recDate;
                
//                unichar nChatText[1024] = {0};
//                int len = sdMsg->message.size();
//                memcpy(nChatText, sdMsg->message.begin(), len);
//                nChatText[len/sizeof(unichar)] = 0;
//                unichar msg_Char[1024] = {0};
//                
//                int startIdx = 0;
//                if ([self hasFontInfo:nChatText[0]]) {
//                    startIdx = 3;
//                }
//                for (int i = startIdx ; i < 1024 - startIdx; i++) {
//                    msg_Char[i-startIdx] = [self getMsgUchar:nChatText[i]];
//                }
//                NSString* obj_Text = [[NSString alloc]initWithCharacters: msg_Char length:len/sizeof(unichar)];
//                obj_sendMsgModel.text = obj_Text;
                
                
                unichar nChatText[800] = {0};
                int len = sdMsg->message.size();
                memcpy(nChatText, sdMsg->message.begin(), len);
                nChatText[len] = '\0';
                NSString* obj_Text = [[NSString alloc]initWithCharacters: nChatText length:len/sizeof(unichar)];
                obj_sendMsgModel.text = [CoreTextUtil filterContentText:obj_Text];

                
                
                
                CSLog(@"聊天消息接收时间%@ 内容: %@",recDate,obj_Text);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                        [self.delegate cNetWorkCallBackFinish:obj_sendMsgModel cNetworkRecType:pType];
                    }
                    sdMsg->Destroy();
                });
                
            });
            
        }else if (pData->GetType() == UserLeave::PROTOCOL_TYPE){
#pragma mark- 
#pragma mark- 离开课堂 回调
            //离开课堂
            
            UserLeave *uLeave = (UserLeave *)pData;
            
            UserLeaveModel *obj_userLeave = [[UserLeaveModel alloc] init];
            obj_userLeave.uid = uLeave->userid;
            obj_userLeave.cid = uLeave->cid;
            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_userLeave cNetworkRecType:pType];
            }

            uLeave -> Destroy();
        }else if (pData->GetType() == SwitchClassShow::PROTOCOL_TYPE) {
#pragma mark - 
#pragma mark - 课堂展示内容控制
            //课堂展示内容 切换
            SwitchClassShow *classShow = (SwitchClassShow *)pData;
            
            
            SwitchClassShowModel *obj_swClassShow = [[SwitchClassShowModel alloc] init];
            obj_swClassShow.uid = classShow->userid;
            obj_swClassShow.courseId = classShow->cid;
            
            CurrentShowModel *obj_currentShow = [[CurrentShowModel alloc] init];
            obj_currentShow.page = classShow->currentshow.page;
            
            char cChar[1000] = {0};
            int len =classShow->currentshow.name.size();
            memcpy(cChar, classShow->currentshow.name.begin(), len);
            cChar[len] = '\0';
            NSString *objc_string = [NSString stringWithUTF8String:cChar];
            obj_currentShow.name = objc_string;
            
            char obj_showType_char = classShow->currentshow.showtype;
            CSLog(@"课堂展示内容控制: %d",obj_showType_char);
            CurrentShowModelType obj_showType = CurrentShowModelType_BLANK;
            if (obj_showType_char == classShow->currentshow.BLANK) {
                obj_showType = CurrentShowModelType_BLANK;
            }else if (obj_showType_char == CurrentShowModelType_COURSEWARE) {
                obj_showType = CurrentShowModelType_COURSEWARE;
            }else if (obj_showType_char == CurrentShowModelType_WHITEBOARD) {
                obj_showType = CurrentShowModelType_WHITEBOARD;
            }
            
            obj_currentShow.showType = obj_showType;
            obj_swClassShow.currentShow = obj_currentShow;
            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_swClassShow cNetworkRecType:pType];
            }
            classShow->Destroy();
            
        }else if (pData->GetType() == SetMainShow::PROTOCOL_TYPE){
#pragma mark -
#pragma mark - 主窗口切换
            SetMainShow *mainShow = (SetMainShow *)pData;
            SetMainShowModel *obj_MainShow = [[SetMainShowModel alloc] init];
            obj_MainShow.teacher = mainShow->teacher;
            obj_MainShow.classid = mainShow->classid;
            obj_MainShow.showtype = (MainShowType)mainShow->showtype;
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_MainShow cNetworkRecType:pType];
            }
            mainShow->Destroy();
            
        }else if (pData->GetType() == CreateWhiteBoard::PROTOCOL_TYPE){
#pragma mark - 
#pragma mark - 创建白板 回调
            //创建白板
            
            CreateWhiteBoard *cwbd = (CreateWhiteBoard *)pData;
            
            CreateWhiteBoardModel *obj_Createwb = [[CreateWhiteBoardModel alloc] init];
            obj_Createwb.uid = cwbd -> userid;
            obj_Createwb.courseId = cwbd -> cid;
            obj_Createwb.wbid = cwbd -> wbid;
            obj_Createwb.wbName = [self stringFromOctets:cwbd -> wbname atUnichar:NULL];
            
            char objcwbType_char = cwbd->actionytype;
            CreateWhiteBoardModelType obj_cwbType;
            
            if ((objcwbType_char & cwbd -> ADD) == cwbd -> ADD) {
                obj_cwbType = CreateWhiteBoardModelType_ADD;
            }else if ((objcwbType_char & cwbd -> DEL) == cwbd -> DEL) {
                obj_cwbType = CreateWhiteBoardModelType_DEL;
            }else if ((objcwbType_char & cwbd -> MODIFY) == cwbd -> MODIFY) {
                obj_cwbType = CreateWhiteBoardModelType_MODIFY;
            }
            obj_Createwb.actionytype = obj_cwbType;
            
            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_Createwb cNetworkRecType:pType];
            }
            cwbd->Destroy();
        }else if (pData->GetType() == AddCourseWare::PROTOCOL_TYPE) {
#pragma mark - 
#pragma mark - 添加课件 回调
            //添加课件
            AddCourseWare * acw = (AddCourseWare *)pData;
            
            AddCourseWareModel *obj_addCW = [[AddCourseWareModel alloc] init];
            obj_addCW.uid = acw->userid;
            obj_addCW.cid = acw->cid;
            obj_addCW.cwtype = [self stringFromOctets:acw->cwtype atUnichar:NULL];
            obj_addCW.cwname = [self stringFromOctets:acw->cwname atUnichar:NULL];
            
            char obj_addCwType_char = acw->actiontype;
            AddCourseWareModelType obj_addcwType;
            if (obj_addCwType_char == acw -> ADD) {
                obj_addcwType = AddCourseWareModelType_ADD;
            }else if (obj_addCwType_char == acw -> DEL) {
                obj_addcwType = AddCourseWareModelType_DEL;
            }else if (obj_addCwType_char == acw -> CLOSE) {
                obj_addcwType = AddCourseWareModelType_CLOSE;
            }
            obj_addCW.actiontype = obj_addcwType;
            
            char obj_sender_char = acw->sender;
            AddCourseWareSenderType obj_addcwSender;
            if (obj_sender_char == acw->CLIENT) {
                obj_addcwSender = AddCourseWareSenderType_CLIENT;
            }else if (obj_sender_char == acw->WEBSERVER) {
                obj_addcwSender = AddCourseWareSenderType_WEBSERVER;
            }
            obj_addCW.senderType = obj_addcwSender;
            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_addCW cNetworkRecType:pType];
            }
            acw->Destroy();
        }else if (pData->GetType() == SetClassState::PROTOCOL_TYPE) {
#pragma mark - 
#pragma mark - 上课/下课 回调
            //上课/下课
            SetClassState *classSatte = (SetClassState *)pData;
            
            SetClassStateModel *obj_classState = [[SetClassStateModel alloc] init];
            obj_classState.ret = classSatte->ret;
            obj_classState.uid = classSatte->userid;
            obj_classState.cid = classSatte->cid;
            obj_classState.classid = classSatte->classid;
            
            CSLog(@"CNetworkManager ==>> 设置课堂(SetClassState) CID: %lld CLASSID: %lld",classSatte->cid,classSatte->classid);
            
            char obj_classState_char = classSatte -> classstate;
            SetClassStateModelType obj_classStateType;
            if ((obj_classState_char & classSatte -> CLASS_BEGIN) == classSatte -> CLASS_BEGIN) {
                obj_classStateType = SetClassStateModelType_CLASS_BEGIN;
            }if ((obj_classState_char & classSatte -> CLASS_END) == classSatte -> CLASS_END) {
                obj_classStateType = SetClassStateModelType_CLASS_END;
            }
            obj_classState.classstate = obj_classStateType;

            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_classState cNetworkRecType:pType];
            }
            
            classSatte->Destroy();
        }else if (pData->GetType() == ClassAction::PROTOCOL_TYPE) {
#pragma mark - 
#pragma mark - 课堂行为 回调
            //课堂事件
            ClassAction *ca = (ClassAction *)pData;
            ClassActionModel *obj_classAction = [[ClassActionModel alloc] init];
            
            obj_classAction.uid = ca->userid;
            obj_classAction.cid = ca->cid;
            obj_classAction.teacherId = ca->teacheruid;
            
            char obj_calssactiontType_char = ca -> actiontype;
            ClassActionModelType obj_classActionType;
            if (obj_calssactiontType_char == ca -> ASK_SPEAK) {
                obj_classActionType = ClassActionModelType_ASK_SPEAK;
            }else if (obj_calssactiontType_char == ca -> CANCEL_SPEAK) {
                obj_classActionType = ClassActionModelType_CANCEL_SPEAK;
            }else if (obj_calssactiontType_char == ca -> ALLOW_SPEAK) {
                obj_classActionType = ClassActionModelType_ALLOW_SPEAK;
            }else if (obj_calssactiontType_char == ca -> CLEAN_SPEAK) {
                obj_classActionType = ClassActionModelType_CLEAN_SPEAK;
            }else if (obj_calssactiontType_char == ca -> KICKOUT) {
                obj_classActionType = ClassActionModelType_KICKOUT;
            }else if (obj_calssactiontType_char == ca -> ADD_STUDENT_VIDEO) {
                obj_classActionType = ClassActionModelType_ADD_STUDENT_VIDEO;
            }else if (obj_calssactiontType_char == ca -> DEL_STUDENT_VIDEO) {
                obj_classActionType = ClassActionModelType_DEL_STUDENT_VIDEO;
            }else if (obj_calssactiontType_char == ca -> OPEN_VOICE) {
                obj_classActionType = ClassActionModelType_OPEN_VOICE;
            }else if (obj_calssactiontType_char == ca -> CLOSE_VOICE) {
                obj_classActionType = ClassActionModelType_CLOSE_VOICE;
            }else if (obj_calssactiontType_char == ca -> OPEN_VIDEO) {
                obj_classActionType = ClassActionModelType_OPEN_VIDEO;
            }else if (obj_calssactiontType_char == ca -> CLOSE_VIDEO) {
                obj_classActionType = ClassActionModelType_CLOSE_VIDEO;
            }else if (obj_calssactiontType_char == ca -> MUTE) {
                obj_classActionType = ClassActionModelType_MUTE;
            }else if (obj_calssactiontType_char == ca -> UNMUTE) {
                obj_classActionType = ClassActionModelType_UNMUTE;
            }else if (obj_calssactiontType_char == ca -> ENTER_GROUP) {
                obj_classActionType = ClassActionModelType_ENTER_GROUP;
            }else if (obj_calssactiontType_char == ca -> LEAVE_GROUP) {
                obj_classActionType = ClassActionModelType_LEAVE_GROUP;
            }else if (obj_calssactiontType_char == ca -> CALL_TEACHER) {
                obj_classActionType = ClassActionModelType_CALL_TEACHER;
            }
            obj_classAction.actiontype = obj_classActionType;

            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_classAction cNetworkRecType:pType];
            }
            ca->Destroy();
            
        }else if (pData -> GetType()  == WhiteBoardEvent::PROTOCOL_TYPE) {
#pragma mark- 
#pragma mark - 白板事件及行为 回调
            //白板
            WhiteBoardEvent *wbE = (WhiteBoardEvent *)pData;
            
            
            
            WhiteBoardEventModel *obj_wbEvent = [[WhiteBoardEventModel alloc] init];
            WhiteBoardActionModel *obj_wbAction = [[WhiteBoardActionModel alloc] init];
            obj_wbAction.uid = wbE->action.userid;
            obj_wbAction.cid = wbE->action.cid;
            obj_wbAction.owerid = wbE->action.oweruid;
            obj_wbAction.paintId = wbE->action.paintId;
            
            char cChar[100000] = {0};
            int len =wbE->action.arguments.size();
            memcpy(cChar, wbE->action.arguments.begin(), len);
            cChar[len] = '\0';
            NSData *data = [NSData dataWithBytes:cChar length:len];
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *objc_string = [[NSString alloc] initWithData:data encoding:enc];
            
            
            
            obj_wbAction.jsonString = objc_string;
            obj_wbAction.pageId = wbE->action.pageId;
            
            WhiteBoardActionModelType obj_wbType;
            char obj_wb_char = wbE->action.paintype;
            
            if (obj_wb_char == wbE-> PEN) {
                obj_wbType = WhiteBoardEventModelType_PEN;
            }else if (obj_wb_char == wbE-> ERASOR) {
                obj_wbType = WhiteBoardEventModelType_ERASOR;
            }else if (obj_wb_char == wbE-> TXT) {
                obj_wbType = WhiteBoardEventModelType_TXT;
            }else if ( obj_wb_char == wbE-> LASER_POINT) {
                obj_wbType = WhiteBoardEventModelType_LASER_POINT;
            }else if (obj_wb_char == wbE-> UNDO) {
                obj_wbType = WhiteBoardEventModelType_UNDO;
            }else if (obj_wb_char == 104) {
                obj_wbType = WhiteBoardEventModelType_Clearn;
            }
            obj_wbAction.paintype = obj_wbType;
            obj_wbEvent.wbActionModel = obj_wbAction;
            
            
            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_wbEvent cNetworkRecType:pType];
            }
            wbE->Destroy();

        }else if (pData->GetType() == SetTeacherVedio::PROTOCOL_TYPE) {
#pragma mark - 
#pragma mark - 老师切换主视频
            SetTeacherVedio *tVideo = (SetTeacherVedio *)pData;
            
            SetTeacherVedioModel *obj_tVideo = [[SetTeacherVedioModel alloc] init];
            obj_tVideo.cid = tVideo -> cid;
            obj_tVideo.uid = tVideo -> userid;
            obj_tVideo.teachervedio = tVideo -> teachervedio;
            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_tVideo cNetworkRecType:pType];
            }
            tVideo->Destroy();
            
        }else if (pData->GetType() == SetClassMode::PROTOCOL_TYPE) {
#pragma mark -
#pragma mark - 课堂权限设置
            SetClassMode *setModel = (SetClassMode *)pData;
            SetClassMode_obj *obj_setModel = [[SetClassMode_obj alloc] init];
            obj_setModel.uid = setModel->userid;
            obj_setModel.cid = setModel->cid;
            
            char obj_setModel_char = setModel->classmode;
            CSLog(@"课堂权限设置:%d",obj_setModel_char);
            obj_setModel.classmode = obj_setModel_char;
            
            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
                [self.delegate cNetWorkCallBackFinish:obj_setModel cNetworkRecType:pType];
            }
            setModel->Destroy();
            
        }/*else if (pData->GetType() == Sign::PROTOCOL_TYPE) {
#pragma mark -
#pragma mark - 签到
        
        }else if (pData->GetType() == SignOut::PROTOCOL_TYPE) {
#pragma mark -
#pragma mark - 签退
            SignOut *signOut = (SignOut *)pData;
            
            CSLog(@"CNetworkManager ==>> 课堂签退成功 协议回执(SetClassState) CID: %lld CLASSID: %lld",signOut->courseid,signOut->classid);
            signOut->Destroy();
        }*/
//        else if (pData->GetType() == MobileConnectClassResp::PROTOCOL_TYPE) {
//            //=============================
//            //TODO: 手机连接课堂
//            //=============================
//            MobileConnectClassResp *mobiConnect = (MobileConnectClassResp*)pData;
//            MobileConnectClassRespModel *mobiConnectModel = [[MobileConnectClassRespModel alloc] init];
//            mobiConnectModel.uid = mobiConnect->userid;
//            mobiConnectModel.tid = mobiConnect->tid;
//            mobiConnectModel.cid = mobiConnect->cid;
//            
//            char cChar_DevName[500] = {0};
//            int len_devName = mobiConnect->devicename.size();
//            memcpy(cChar_DevName, mobiConnect->devicename.begin(), len_devName);
//            cChar_DevName[len_devName] = '\0';
//            NSString *devName = [NSString stringWithUTF8String:cChar_DevName];
//            mobiConnectModel.devName = devName;
//            
//            if (mobiConnect->OK == mobiConnect->ret) {
//                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
//                    [self.delegate cNetWorkCallBackFinish:mobiConnectModel cNetworkRecType:pType];
//                }
//            }else if (mobiConnect->CODE_INVALID == mobiConnect->ret) {
//                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
//                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_camera_code_invalid") cNetworkRecType:pType];
//                }
//            }else if (mobiConnect->TEACHER_NOT_EXIST == mobiConnect->ret) {
//                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
//                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_camera_tea_not_exist") cNetworkRecType:pType];
//                }
//            }else if (mobiConnect->CONNECTION_OUT_OF_RANGE == mobiConnect->ret) {
//                if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
//                    [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_request_faild") cNetworkRecType:pType];
//                }
//            }
//            mobiConnect->Destroy();
//        }else if (pData->GetType() == ChooseMobile::PROTOCOL_TYPE) {
//            //=============================
//            //TODO: PC 控制手机是否传输视频
//            //=============================
//            ChooseMobile *mobi = (ChooseMobile* )pData;
//            
//            ChooseMobileMdoel *objMobi = [[ChooseMobileMdoel alloc] init];
//            objMobi.uid = mobi->userid;
//            objMobi.tid = mobi->tid;
//            ChooseMobiStyle style;
//            if (mobi->actiontype == ChooseMobile::STOP) {
//                style = ChooseMobiStyle_STOP;
//            }else if (mobi->actiontype == ChooseMobile::CHOOSE) {
//                style = ChooseMobiStyle_CHOOSE;
//            }
//            char cChar_video[500] = {0};
//            int len_video = mobi->pushaddr.size();
//            memcpy(cChar_video, mobi->pushaddr.begin(), len_video);
//            cChar_video[len_video] = '\0';
//            NSString *videoPushaddr = [NSString stringWithUTF8String:cChar_video];
//            objMobi.pushaddr = videoPushaddr;
//            
//            objMobi.chooseStyle = style;
//            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
//                [self.delegate cNetWorkCallBackFinish:objMobi cNetworkRecType:pType];
//            }
//            mobi->Destroy();
//        }else if (pData->GetType() == Kick::PROTOCOL_TYPE) {
//            //=============================
//            //TODO: PC 控制手机设备列表操作<删除/下课删除/手机断开>
//            //=============================
//            Kick *k = (Kick *)pData;
//            KickModel *kModel = [[KickModel alloc] init];
//            kModel.uid = k->userid;
//            kModel.tid = k->tid;
//            KickStyle kStyle;
//            if (k->notifytype == k->DELETE_DEVICE) {
//                kStyle = KickStyle_DELETE_DEVICE;
//            }else if (k->notifytype == k->CLASS_END) {
//                kStyle = KickStyle_CLASS_END;
//            }if (k->notifytype == k->MOBILE_OFF) {
//                kStyle = KickStyle_MOBILE_OFF;
//            }
//            kModel.kickStyle = kStyle;
//            if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFinish:cNetworkRecType:)]) {
//                [self.delegate cNetWorkCallBackFinish:kModel cNetworkRecType:pType];
//            }
//            k->Destroy();
//        }

    });
}

//失败
- (void)cNetWorkFaild:(unsigned int) sessionId Data:(GNET::Protocol*) pData
{
    int pType = pData->GetType();
    if ([self.delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
        [self.delegate cNetWorkCallBackFaild:CSLocalizedString(@"cnetwork_request_faild") cNetworkRecType:pType];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////------------TODO: API接口 ------------------------------------------//////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark -  API接口


//========================
//TODO: 登录
//========================
- (void)loginUserName:(NSString *)name userPwd:(NSString *)pwd responseDelegate:(id<CNetworkManagerDelegate>)delegate
{
    
    [self addDelegate:delegate withRecProtocolType:CNW_loginRet];
    
    unichar uniname[100] = {0};
    [name  getCharacters: uniname];
    uniname[name.length *2] = 0;
    AString astrName((char*)uniname,(int)name.length *2);
    
    const char* password = [pwd UTF8String];
    GNET::Octets otpassword(password, (int)pwd.length);
    GNET::Octets key;
    
    MD5Hash md5;
    md5.Update(otpassword);
    md5.Final(key);
    char szTemp[8] = {0};
    string strs;
    unsigned char* pkeymd5 = (unsigned char*)key.begin();
    for (int i = 0; i < 16; i++) {
        snprintf(szTemp, 8, "%02X",  pkeymd5[i]);
        strs += szTemp;
    }
    
    NSString* pstrPwd = [NSString stringWithUTF8String:strs.c_str()];
    [pstrPwd getCharacters:uniname];
    uniname[strs.length()*2] = 0;
    AString astrpwd((char*)uniname,(int)strs.length() *2);
    
    
    NSString *devName = [UIDevice currentDevice].model;
    unichar uChar_devName[100] = {0};
    
    
    Login login_;
    login_.username.replace(astrName, astrName.GetLength());
    login_.passwordmd5.replace(astrpwd, astrpwd.GetLength());
    login_.devicetype = Login::IOS;
    login_.devicename = [self octetsFromUnichar:uChar_devName atString:devName];
    login_.logintype = Login::NAMEPASSWD;
    
    int sid = GNET::LoginClient::GetInstance().GetSessionID();
    [self addSessionDicSess:sid proType:CNW_loginRet];
    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(sid,login_);
    });

}

//========================
//TODO: 验证Token
//========================
- (void)tokenValidateResponseDelegate:(id<CNetworkManagerDelegate>)delegate
{
    [self addDelegate:delegate withRecProtocolType:CNW_TokenValidateRet];
    
    NSString *devName = [UIDevice currentDevice].model;
    unichar uChar_devName[100] = {0};
    unichar uChar_token[300] = {0};
    
    TokenValidate tokenValidate;
    tokenValidate.linksid = 100;
    tokenValidate.userid = [UserAccount shareInstance].uid;
    tokenValidate.devicename = [self octetsFromUnichar:uChar_devName atString:devName];
    tokenValidate.devicetype = TokenValidate::MOBILE;
    tokenValidate.token = [self octetsFromUnichar:uChar_token atString:[UserAccount shareInstance].token];
    
    int sid = GNET::LoginClient::GetInstance().GetSessionID();
    [self addSessionDicSess:sid proType:CNW_TokenValidateRet];

    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(sid,tokenValidate);
    });
}

//======================
//TODO: 获取用户信息
//======================
- (void)queryUserInfo:(long long)uid responseDelegate:(id<CNetworkManagerDelegate>)delegate
{
    [self addDelegate:delegate withRecProtocolType:CNW_UserInfoRet];
    QueryUser queryUser;
    queryUser.userid = uid;
    
    int sid = GNET::LoginClient::GetInstance().GetSessionID();
    [self addSessionDicSess:sid proType:CNW_UserInfoRet];
    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(sid,queryUser);
    });
}

//=====================
//TODO: kickOut 用户被踢
//=====================
- (void)userKickoutAtDelegate:(id<CNetworkManagerDelegate>)delegate
{
    [self addDelegate:delegate withRecProtocolType:CNW_KickOut];
}


//=====================
//TODO: 进入课堂
//====================
- (void)userIntoClassRoom:(long long)cid classID:(long long)classid responseDelegate:(id<CNetworkManagerDelegate>)delegate
{
    
    if (!isConnected) {
        if (delegate && [delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
            [delegate cNetWorkCallBackFaild:@"请检查网络后,请重试" cNetworkRecType:CNW_UserWelecome];
        }
        return;
    }
    [self addDelegate:delegate withRecProtocolType:CNW_UserWelecome];
    CSLog(@"CNetworkManager ==>> 进入课堂CID: %lld CLASSID: %lld",cid,classid);
    
    User *user = [UserAccount shareInstance].loginUser;
    UserEnter uEnter;
    uEnter.cid = cid;
    uEnter.classid = classid;
    uEnter.receiver = 0;
    uEnter.device = Login::IOS;
    uEnter.netisp = [UserAccount shareInstance].netisp;
    UserInfo uInfo;
    uInfo.userid = user.uid;
    uInfo.state = 12; //12
    uEnter.userinfo = uInfo;
    
    int sid = GNET::LoginClient::GetInstance().GetSessionID();
    [self addSessionDicSess:sid proType:CNW_UserWelecome];
    
    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(sid,uEnter);
    });
}


//=====================
//TODO: 设置在线课堂接收代理<学生>
//=====================
- (void)addClassInfoDelegate:(id<CNetworkManagerDelegate>)aDelegate
{
    [self addDelegate:aDelegate withRecProtocolType:CNW_UserEnter];         //进入课堂<登录用户:客户端主动发出, 他人进入 登录者接收>
    [self addDelegate:aDelegate withRecProtocolType:CNW_SwitchClassShow];   //课堂展示信息控制
    [self addDelegate:aDelegate withRecProtocolType:CNW_CreateWhiteBoard];  //创建/删除/修改 白板
    [self addDelegate:aDelegate withRecProtocolType:CNW_AddCourseWare];     //老师添加课件
    [self addDelegate:aDelegate withRecProtocolType:CNW_SetClassState];     //课堂状态 上课/下课
    [self addDelegate:aDelegate withRecProtocolType:CNW_SetClassMode];      //课堂设置 
    [self addDelegate:aDelegate withRecProtocolType:CNW_ClassActions];      //课堂事件 举手提问/踢人等
    [self addDelegate:aDelegate withRecProtocolType:CNW_WhiteBoardEvent];   //课堂白板
    [self addDelegate:aDelegate withRecProtocolType:CNW_SetTeacherVedioRet];//老师切换主视频
    [self addDelegate:aDelegate withRecProtocolType:CNW_UserLeaveRet];      //用户离开课堂
    [self addDelegate:aDelegate withRecProtocolType:CNW_QueryUserListResp]; //已经进入课堂的用户列表
    [self addDelegate:aDelegate withRecProtocolType:CNW_SendMsgRet];        // 发送/接收消息
    [self addDelegate:aDelegate withRecProtocolType:CNW_SetMainShow];       //主窗口变化
}

//=====================
//TODO: 设置在线课堂接收代理<教师>
//=====================
- (void)addClassInfoDelegateForTeacher:(id<CNetworkManagerDelegate>)aDelegate
{
    [self addDelegate:aDelegate withRecProtocolType:CNW_UserEnter];         //进入课堂<登录用户:客户端主动发出, 他人进入 登录者接收>
    [self addDelegate:aDelegate withRecProtocolType:CNW_UserLeaveRet];      //用户离开课堂
    [self addDelegate:aDelegate withRecProtocolType:CNW_QueryUserListResp]; //已经进入课堂的用户列表
    [self addDelegate:aDelegate withRecProtocolType:CNW_SendMsgRet];        // 发送/接收消息
    [self addDelegate:aDelegate withRecProtocolType:CNW_SetClassState];     //课堂状态 上课/下课
}


//=====================
//TODO: 移除在线课堂相关监听代理 <学生>
//=====================
- (void)removeClassInfoDelegate
{
    [self removeDelegateWithType:CNW_SwitchClassShow];      //课堂展示信息控制
    [self removeDelegateWithType:CNW_CreateWhiteBoard];     //课堂白板 创建/删除/修改
    [self removeDelegateWithType:CNW_AddCourseWare];        //老师添加课件
    [self removeDelegateWithType:CNW_SetClassState];        //课堂状态 上课/下课
    [self removeDelegateWithType:CNW_SetClassMode];         //课堂设置
    [self removeDelegateWithType:CNW_ClassActions];         //课堂事件 举手提问/踢人等
    [self removeDelegateWithType:CNW_WhiteBoardEvent];      //课堂白板
    [self removeDelegateWithType:CNW_UserWelecome];         //移除 进入课堂代理
    [self removeDelegateWithType:CNW_UserLeaveRet];         //移除 离开课堂代理
    [self removeDelegateWithType:CNW_UserEnter];            //进入课堂<登录用户:客户端主动发出, 他人进入 登录者接收>
    [self removeDelegateWithType:CNW_SetTeacherVedioRet];   //移除老师切换主视频
    [self removeDelegateWithType:CNW_UserLeaveRet];         //移除用户离开课堂
    [self removeDelegateWithType:CNW_QueryUserListResp];    //移除已经进入课堂的用户列表
    [self removeDelegateWithType:CNW_SendMsgRet];           //移除聊天消息接收-发送代理
    [self removeDelegateWithType:CNW_SetMainShow];          //移除主窗口切换
}

//=====================
//TODO: 移除在线课堂相关监听代理<教师>
//=====================
- (void)removeClassInfoDelegateForTeacher
{
    [self removeDelegateWithType:CNW_UserWelecome];         //移除 进入课堂代理
    [self removeDelegateWithType:CNW_SendMsgRet];           //移除聊天消息接收-发送代理
    [self removeDelegateWithType:CNW_UserLeaveRet];         //移除用户离开课堂
    [self removeDelegateWithType:CNW_QueryUserListResp];    //移除已经进入课堂的用户列表
    [self removeDelegateWithType:CNW_UserEnter];            //进入课堂<登录用户:客户端主动发出, 他人进入 登录者接收>
    [self removeDelegateWithType:CNW_SetClassState];        //课堂状态 上课/下课
}


//=====================
//进入课堂签到
//=====================
- (void)classRoomSign:(long long) cid userId:(long long)uid classid:(long long)classid
{

//    Sign sign;
//    sign.receiver = 0;
//    sign.userid = uid;
//    sign.courseid = cid;
//    sign.classid = classid;
//    sign.time = 0;
//    dispatch_async(queue, ^{
//        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),sign);
//    });
}

//===================
//课堂签退
//===================
- (void)classRoomSignOut:(int)startCount commentText:(NSString *)text userid:(long long) uid courseId:(long long) cid classID:(long long)classid
{
    
//    unichar cm[200] = {0};
//
//    SignOut signOut;
//    signOut.receiver = 0;
//    signOut.userid = uid;
//    signOut.courseid = cid;
//    signOut.star = startCount;
//    signOut.classid = classid;
//    signOut.time = 0;
//    signOut.comment = [self octetsFromUnichar:cm atString:text];
//    
//    dispatch_async(queue, ^{
//        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),signOut);
//    });
}

//=====================
//TODO: 发送信息
//=====================
- (void)sendMessage:(NSString *)text ChatType:(int)cType sendUid:(long long)sUid courseId:(long long)cid isGIF:(BOOL)isGif recUid:(long long)ruid
{
    
    if (!isConnected) {
        id delegate = [self getDelegateWithRecProtocolType:CNW_SendMsgRet];
        if (delegate && [delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
            [delegate cNetWorkCallBackFaild:@"请检查网络后,请重试" cNetworkRecType:CNW_SendMsgRet];
        }
        return;
    }

    
    unichar nMsg[800] = {0};

    SendTextMsg sMsg;
    sMsg.cid = cid;
    sMsg.receiver = 0;
    sMsg.recvgroupid = 0;
    sMsg.userid = sUid;
    if (cType ==0) {
        //群消息
        sMsg.recvtype = SendTextMsg::CLASS;
        sMsg.recvid = 0;
    }else if (cType == 2) {
        //小组聊天
        
    }else if (cType == 3) {
        //私聊消息
        sMsg.recvtype = SendTextMsg::USER;
        sMsg.recvid = ruid;
    }
    sMsg.message = [self octetsFromUnicharHasGifImg:nMsg atString:text isGif:isGif];
    
    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),sMsg);
    });
}


//=====================
//TODO: 离开课堂
//=====================
- (void)userLeaveCourse:(long long) courseid userid:(long long) uid responseDelegate:(id<CNetworkManagerDelegate>)delegate
{
    
    UserLeave uLeave;
    uLeave.receiver = 0;
    uLeave.cid = courseid;
    uLeave.userid = uid;
    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),uLeave);
    });

}


/*------移动摄像头 工具使用的相关协议------*/



//======================
//TODO: 手机连接课堂请求
//======================
//- (void)mobileConnectClass:(long long)uid code:(NSString *)codeString deviceName:(NSString *)devName responseDelegate:(id<CNetworkManagerDelegate>)delegate
//{
//    if (!isConnected) {
//        if (delegate && [delegate respondsToSelector:@selector(cNetWorkCallBackFaild:cNetworkRecType:)]) {
//            [delegate cNetWorkCallBackFaild:@"请检查网络后,请重试" cNetworkRecType:CNW_loginRet];
//        }
//        return;
//    }
//    
//    [self addDelegate:delegate withRecProtocolType:CNW_MobileConnectClass];
//    
//    unichar deviceName[128] = {0};
//    
//    const char *ascii =[codeString  UTF8String];
//    AString aString(ascii,(int)codeString.length);
//    GNET::Octets codeoctets (aString, (int)codeString.length);
//    
//    
//    
//    MobileConnectClassReq mobiConnect;
//    mobiConnect.userid = uid;
//    mobiConnect.devicename = [self octetsFromUnichar:deviceName atString:devName];
//    mobiConnect.code = codeoctets;
//    
//    dispatch_async(queue, ^{
//        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),mobiConnect);
//    });
//    
//}

//======================
//TODO: 设置手机连接课堂成功后接收代理
//======================
//- (void)addMobiDidConnectChooseDelegate:(id<CNetworkManagerDelegate>)delegate
//{
//    [self addDelegate:delegate withRecProtocolType:CNW_ChooseMobile];
//    [self addDelegate:delegate withRecProtocolType:CNW_Kick];
//}
//
//======================
//TODO: 移除手机连接课堂成功后接收代理
//======================
//- (void)delMobiDidConnectChooseDelegate
//{
//    [self removeDelegateWithType:CNW_ChooseMobile];
//    [self removeDelegateWithType:CNW_Kick];
//}

////======================
////TODO: 被选中或者被删除 回复
////======================
//- (void)returnChooseAt:(ChooseMobileMdoel *)chooseModel
//{
//    ChooseMobileResp chooseResp;
//    chooseResp.userid = chooseModel.uid;
//    chooseResp.tid = chooseModel.tid;
//    chooseResp.ret =0;
//    
//    char t;
//    if (chooseModel.chooseStyle == ChooseMobiStyle_CHOOSE) {
//        t = ChooseMobile::CHOOSE;
//    }else if (chooseModel.chooseStyle == ChooseMobile::STOP) {
//        t = ChooseMobile::STOP;
//    }
//    chooseResp.actiontype = t;
//    dispatch_async(queue, ^{
//        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),chooseResp);
//    });
//    
//}
//
////======================
////TODO: 主动停止视频传输
////======================
//- (void)mobileCameraOffWithTeaId:(long long)tid
//{
//    Kick kic;
//    kic.userid = [UserAccount shareInstance].uid;
//    kic.tid = tid;
//    kic.notifytype = Kick::MOBILE_OFF;
//    dispatch_async(queue, ^{
//        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),kic);
//    });
//    
//}
//

//======================
//TODO: 教师主动 上课/下课
//======================
- (void)classBegin:(BOOL)isBegin courseID:(long long)cid classID:(long long)classid userid:(long long)uid
{
    SetClassState classSate;
    classSate.receiver = 0;
    classSate.userid = uid;
    classSate.cid = cid;
    classSate.classid = classid;
    classSate.classstate = isBegin?SetClassState::CLASS_BEGIN:SetClassState::CLASS_END;
    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),classSate);
    });
}

//TODO: 意见反馈
- (void)feedBack:(NSString *)content withUserID:(long long)uid
{
    FeedBack fd;
    fd.userid = uid;
    fd.fbtype = 1;
    fd.title = NULL;
    fd.mobile = NULL;
    unichar nMsg[1024] = {0};
    fd.content = [self octetsFromUnichar:nMsg atString:content];
    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),fd);
    });
}

//=====================
//TODO: 课堂举手
//=====================
- (void)handsup:(long long) courseid userid:(long long) uid isHand:(BOOL)ishand responseDelegate:(id<CNetworkManagerDelegate>)delegate
{
    ClassAction uLeave;
    if (ishand) {
        uLeave.actiontype = GNET::ClassAction::ASK_SPEAK;
    }else{
        uLeave.actiontype = GNET::ClassAction::CANCEL_SPEAK;
    }
    uLeave.receiver = 0;
    uLeave.cid = courseid;
    uLeave.userid = uid;
    dispatch_async(queue, ^{
        GNET::LoginClient::GetInstance().Send(GNET::LoginClient::GetInstance().GetSessionID(),uLeave);
    });
}
@end
