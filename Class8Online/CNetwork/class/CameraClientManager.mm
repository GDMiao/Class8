//
//  CameraClientManager.m
//  Class8Online
//
//  Created by chuliangliang on 16/1/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CameraClientManager.h"
#import "CameraClientCallBack.h"
#include "CameraClient.h"
#include "gnconf.h"
#include "gnpollio.h"
#include <vector.h>
#import <CommonCrypto/CommonDigest.h>
#import "CNETModels.h"
#import "SVProgressHUD.h"

#define CAMERACLIENT_SESSIONTYPE @"cameraClient_sessionTimeOut_key"     //会话超时管理key
#define SESSTION_TIMEOUT 30                                             //会话超时时间
#define CAMERA_CONNECTServer_sid 200                                    //连接服务器会话id

@interface CameraClientUtils : NSObject
/**
 * NSString ==> unichar ==> Octets
 **/
+ (GNET::Octets)octetsFromUnichar:(unichar *)uChar atString:(NSString *)string;

/**
 * Octets ==> NSString
 **/
+ (NSString *)stringFromOctets:(GNET::Octets)oct;

+ (int64_t)MD5UDID;
@end

@implementation CameraClientUtils
/**
 * NSString ==> unichar ==> Octets
 **/
+ (GNET::Octets)octetsFromUnichar:(unichar *)uChar atString:(NSString *)string {
    
    
    [string  getCharacters: uChar];
    uChar[string.length *2] = 0;
    uChar[string.length *sizeof(unichar)] = 0;
    
    AString aString((char*)uChar,(int)string.length *sizeof(unichar));
    GNET::Octets octets (aString, (int)string.length *sizeof(unichar));
    return octets;
}


/**
 * Octets ==> NSString
 **/
+ (NSString *)stringFromOctets:(GNET::Octets)oct
{
    int len = oct.size();
    char cChar[1024] = {0};
    
    memcpy(cChar, oct.begin(), len);
    cChar[len] = '\0';
    NSString *objc_string = [NSString stringWithUTF8String:cChar];
    return objc_string;
}


+ (int64_t)MD5UDID
{
    NSString *dUdid = DeviceUDID;
    const char *str = [dUdid UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
//    NSString *md5 = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//                     r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];


    int64_t INT64_UDID = 0;
    for (int i = 0; i < 16; i ++) {
        NSString *tmpInt = [NSString stringWithFormat:@"%d",r[i]];
        INT64_UDID+= [tmpInt intValue];
    }
    return INT64_UDID;
}

@end


@interface CameraClientManager ()<CameraClientCallBackDelegate>
{
    dispatch_queue_t queue; //网络队列
    BOOL m_isLogin; //当前是否为登录服务器 YES: 登录服务器 NO : 非登录服务器
    BOOL m_didConnect;  //当前是否已经连接 不区分登录服务里和非登录服务器 yes:已连接 no: 未连接
    NSString *m_codeString;
    NSString *m_deviceName;
    int64_t m_deviceUdid;
    NSString *m_linkString;
    NSTimer *sessionTimer;
}
@property (weak, nonatomic) id<CameraClientManagerDelegate>delegate;
@property (strong, nonatomic) NSMutableDictionary *sessionDic; //存储所有已发出但未收到回应网络会话 key 会话id value 已发出时间(单位s) key: 会话id_type
@end

static CameraClientManager *cameraClient = nil;
@implementation CameraClientManager
+ (CameraClientManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cameraClient = [[CameraClientManager alloc] init];
    });
    return cameraClient;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initNetwork];
        [self _initDispatchQueue];
        [self _initOther];
    }
    return self;
}

- (void)dealloc
{
    if (queue) {
        queue = nil;
    }
    self.delegate = nil;
    m_codeString = nil;
    m_deviceName = nil;
    m_linkString = nil;
    [self.sessionDic removeAllObjects];
    self.sessionDic = nil;
    [self sessionTimerStop];
}

/**
 *初始化网络
 **/
- (void)_initNetwork
{
    CameraClient::GetInstance().Attach(cameraClientCallBack);
    GetCameraClientCallBackInst().delegate = self;
    CameraClient::GetInstance().setKeelOnline(NO);
    using namespace GNET;
    NetSys::Socket_open();
    AString strFile;
    GNET::Conf::GetInstance(strFile);
    GNET::PollIO::Init();
}

/**
 * 初始化队列及回调配置
 **/
- (void)_initDispatchQueue {
    queue = dispatch_queue_create("cnetwork_camera.queue", NULL);
    self.delegate = nil;
}

/**
 * 初始化其他参数
 **/
- (void)_initOther
{
    m_isLogin = YES;
    m_didConnect = NO;
    m_codeString = nil;
    m_deviceName = nil;
    m_deviceUdid = [CameraClientUtils MD5UDID];
    self.sessionDic = [[NSMutableDictionary alloc] init];

    CSLog(@"CameraClientManager ==> 设备唯一标识UDID INT64 %lld",m_deviceUdid);

}

/**
 * 获取回调代理对象
 **/
- (id)objDelegate
{
    return self.delegate;
}

/**
 * 会话时间管理定时器启动
 **/
- (void)sessionTimerBegin
{
    if (!sessionTimer) {
        sessionTimer = [NSTimer scheduledTimerWithTimeInterval:0.99999 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:sessionTimer forMode:NSRunLoopCommonModes];
    }
}

/**
 * 会话时间管理定时器关闭
 **/
- (void)sessionTimerStop
{
    if (sessionTimer) {
        [sessionTimer invalidate];
        sessionTimer = nil;
    }

}

//更新会话发出时间
- (void)timerUpdate
{
    NSArray *keys = [self.sessionDic allKeys];
    for (NSString *sessionIdNum in keys) {
        if ([sessionIdNum rangeOfString:CAMERACLIENT_SESSIONTYPE].location != NSNotFound) {
            continue;
        }
        id sessionTime = [self.sessionDic objectForKey:sessionIdNum];
        if (sessionTime) {
            CGFloat sTime = [sessionTime floatValue];
            sTime += 1;
            if (sTime > SESSTION_TIMEOUT) {
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

    int pType = [self.sessionDic intForKey:[NSString stringWithFormat:@"%@%d",CAMERACLIENT_SESSIONTYPE,sid]];
    id callBackDelegate = [self objDelegate];
    if (pType == CCP_ConnectTimeOut) {
        //连接服务器超时
        CSLog(@"CameraClientManager ==> TCP/IP服务器连接超时(IP:%s, port:%d)",CameraClient::GetInstance().getTcpIp(),CameraClient::GetInstance().getTcpPort());
        if ([callBackDelegate respondsToSelector:@selector(cameraClientManagerFaild:cNetworkRecType:)]) {
            [callBackDelegate cameraClientManagerFaild:CSLocalizedString(@"cnetwork_net_timeOut") cNetworkRecType:pType];
        }else if ([SVProgressHUD isVisible]) {
            //服务器连接失败
            [SVProgressHUD showErrorWithStatus:CSLocalizedString(@"cnetwork_net_timeOut")];
        }
        [self disConnectServer];
    }else{
        if ([callBackDelegate respondsToSelector:@selector(cameraClientManagerFaild:cNetworkRecType:)]) {
            [callBackDelegate cameraClientManagerFaild:CSLocalizedString(@"cnetwork_net_timeOut") cNetworkRecType:pType];
        }
        CSLog(@"CameraClientManager ==> TCP/IP连接超时 type:  %d",pType);
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
        [self.sessionDic removeObjectForKey:[NSString stringWithFormat:@"%@%@",CAMERACLIENT_SESSIONTYPE,key]];
    }
}

/**
 * 添加超时管理会话
 **/
- (void)addSessionDicSess:(int)sid proType:(CameraClientRecProtocolType )ptype
{
    NSString *sidkey = [NSString stringWithFormat:@"%d",sid];
    NSNumber *sidTime = [NSNumber numberWithFloat:1];
    
    NSString *sidPtypeKey = [NSString stringWithFormat:@"%@%d",CAMERACLIENT_SESSIONTYPE,sid];
    NSNumber *sidPtype = [NSNumber numberWithInt:ptype];
    
    [self.sessionDic setObject:sidTime forKey:sidkey];
    [self.sessionDic setObject:sidPtype forKey:sidPtypeKey];
}


/**
 *连接服务器
 **/
- (void)connectToServer
{
    if ([Utils IsEnableNetWork]) {
        [self sessionTimerBegin];
//        NSString *ipString = TCP_API_IP;
        NSString *ipString = Piano_TCP_API_IP;
//        int port = TCP_PORT;
        int port = Piano_TCP_PORT;
        if (!m_isLogin) {
            //非登录
            if (!m_linkString) {
                //link 地址为空时 返回错误
                if ([self.delegate respondsToSelector:@selector(cameraClientManagerFaild:cNetworkRecType:)]) {
                    [self.delegate cameraClientManagerFaild:@"服务器连接失败" cNetworkRecType:CCP_MobileConnectClass];
                }
                return;
            }
            NSString *ip_port_string = m_linkString;
            NSArray *ip_Port_arr = [ip_port_string componentsSeparatedByString:@":"];
            ipString = [ip_Port_arr firstObject];
            port = [[ip_Port_arr lastObject] intValue];
        }
        CSLog(@"CameraClientManager ==> TCP/IP (ip:%@, port: %d)",ipString,port);
        CameraClient::GetInstance().setTcpIPAndPort([ipString UTF8String], port);
        CameraClient::GetInstance().ConnectToServer();
        
        [self addSessionDicSess:CAMERA_CONNECTServer_sid proType:CCP_ConnectTimeOut];
    }else {
        //网络不可用
        if ([self.delegate respondsToSelector:@selector(cameraClientManagerFaild:cNetworkRecType:)]) {
            [self.delegate cameraClientManagerFaild:@"网络不可用,请检查网络设置后重试" cNetworkRecType:CCP_NOT_Net];
        }
    }
}

/**
 *断开服务器
 **/
- (void)disConnectServer
{
    [self.sessionDic removeAllObjects];
    [self sessionTimerStop];
    m_linkString = nil;
    m_isLogin = YES;
    m_didConnect = NO;
    CameraClient::GetInstance().setKeelOnline(NO);
    CameraClient::GetInstance().Disconnect();
}

#pragma mark -
#pragma mark - CNetworkCallBackDelegate
-(void) CameraClientCallBack:(unsigned int) sessionId  Event:(GNET::EVENT_VALUE) event Data:(GNET::Protocol*) pData
{
    
    
    [self removeSessionDicSess:sessionId];//移除超时管理
    if (pData) {
        unsigned int pType = pData->GetType();
        CSLog(@"CameraClientManager==>TCP/IP协议类型: %d",pType);
    }
    
    if (EVENT_ADDSESSION == event) {
        [self removeSessionDicSess:CAMERA_CONNECTServer_sid];//移除对连接服务器超时管理
        //添加会话 <已连接>
        m_didConnect = YES;
        [self cameraClientManagerDidconnectToSever];
        
    }else if (EVENT_DELSESSION == event) {
        //删除会话
        CSLog(@"CameraClientManager ==> 删除会话");
        
    }else if (EVENT_DISCONNECT == event) {
        //断开连接
        [self removeSessionDicSess:CAMERA_CONNECTServer_sid];//移除对连接服务器超时管理
        [self sessionDiddisConnectServer:m_isLogin];
        
        m_isLogin = YES; //只要断开就从 登录开始
        m_didConnect = NO;
    }else if (EVENT_LOAD_SUCCESS == event) {
        //请求成功
        [self cNetWorkFinish:sessionId Data:pData];
    }else if (EVENT_LOAD_FAILD == event) {
        //请求失败
        [self cNetWorkFaild:sessionId Data:pData];
    }
}

#pragma mark -
#pragma mark - 服务器已连接
- (void)cameraClientManagerDidconnectToSever
{
    CSLog(@"CameraClientManager==> TCP/IP 已经连接");
    if (!m_isLogin&&m_didConnect) {
        //已经连接非登录服务器时保持心跳
        CSLog(@"CameraClientManager ==> 已经连接非登录服务器时保持心跳");
        CameraClient::GetInstance().setKeelOnline(YES);
        [self mobileConnectClassWithcode:m_codeString deviceName:m_deviceName responseDelegate:self.delegate];
    }else if (m_isLogin&&m_didConnect){
        CSLog(@"CameraClientManager ==> 已经连接登录服务器");
        [self mobileGetLink];
    }
    
    
}
#pragma mark -
#pragma mark - 服务器已断开连接
- (void)sessionDiddisConnectServer:(BOOL)isloginServer
{
    
    if ([[self delegate] respondsToSelector:@selector(cameraClientManagerDiddisConnectServer:)]) {
        [[self delegate] cameraClientManagerDiddisConnectServer:isloginServer];
        [self.sessionDic removeAllObjects];
    }
    CameraClient::GetInstance().setKeelOnline(NO);
    CSLog(@"CameraClientManager ==> TCP/IP 断开连接");
    
}

#pragma mark -
#pragma mark - 数据接收失败
- (void)cNetWorkFaild:(unsigned int) sessionId Data:(GNET::Protocol*) pData
{
    CSLog(@"CameraClientManager ==> 数据接收失败");
    int pType = pData->GetType();
    if ([[self objDelegate] respondsToSelector:@selector(cameraClientManagerFinish:cNetworkRecType:)]) {
        [[self objDelegate] cameraClientManagerFinish:CSLocalizedString(@"cnetwork_request_faild") cNetworkRecType:pType];
    }
}

#pragma mark -
#pragma mark - 数据接收成功
- (void)cNetWorkFinish:(unsigned int) sessionId Data:(GNET::Protocol*) pData
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int pType = pData->GetType();
        if (pData->GetType() == MobileConnectResp::PROTOCOL_TYPE) {
            //通过手机标识获取link地址
            MobileConnectResp *mConnectResp = (MobileConnectResp *)pData;
            if (mConnectResp->ret == 0) {
                [self disConnectServer];    //断开服务器
                m_linkString  = [CameraClientUtils stringFromOctets:mConnectResp->link]; //记录link 地址
                m_isLogin = NO;             //切换至非登录服务器
                [self connectToServer];     //连接link
                
            }else {
                if ([self.delegate respondsToSelector:@selector(cameraClientManagerFaild:cNetworkRecType:)]) {
                    [self.delegate cameraClientManagerFaild:@"服务器连接失败" cNetworkRecType:CCP_MobileConnectClass];
                }
            }
            
            
        }else if (pData->GetType() == MobileConnectClassResp::PROTOCOL_TYPE) {
            //=============================
            //TODO: 手机连接课堂
            //=============================
            MobileConnectClassResp *mobiConnect = (MobileConnectClassResp*)pData;
            MobileConnectClassRespModel *mobiConnectModel = [[MobileConnectClassRespModel alloc] init];
            mobiConnectModel.uid = mobiConnect->userid;
            mobiConnectModel.tid = mobiConnect->tid;
            mobiConnectModel.cid = mobiConnect->cid;
            
            char cChar_DevName[500] = {0};
            int len_devName = mobiConnect->devicename.size();
            memcpy(cChar_DevName, mobiConnect->devicename.begin(), len_devName);
            cChar_DevName[len_devName] = '\0';
            NSString *devName = [NSString stringWithUTF8String:cChar_DevName];
            mobiConnectModel.devName = devName;
            
            if (mobiConnect->OK == mobiConnect->ret) {
                if ([self.delegate respondsToSelector:@selector(cameraClientManagerFinish:cNetworkRecType:)]) {
                    [self.delegate cameraClientManagerFinish:mobiConnectModel cNetworkRecType:pType];
                }
            }else if (mobiConnect->CODE_INVALID == mobiConnect->ret) {
                if ([self.delegate respondsToSelector:@selector(cameraClientManagerFaild:cNetworkRecType:)]) {
                    [self.delegate cameraClientManagerFaild:CSLocalizedString(@"cnetwork_camera_code_invalid") cNetworkRecType:pType];
                }
            }else if (mobiConnect->TEACHER_NOT_EXIST == mobiConnect->ret) {
                if ([self.delegate respondsToSelector:@selector(cameraClientManagerFaild:cNetworkRecType:)]) {
                    [self.delegate cameraClientManagerFaild:CSLocalizedString(@"cnetwork_camera_tea_not_exist") cNetworkRecType:pType];
                }
            }else if (mobiConnect->CONNECTION_OUT_OF_RANGE == mobiConnect->ret) {
                if ([self.delegate respondsToSelector:@selector(cameraClientManagerFaild:cNetworkRecType:)]) {
                    [self.delegate cameraClientManagerFaild:CSLocalizedString(@"cnetwork_request_faild") cNetworkRecType:pType];
                }
            }
            mobiConnect->Destroy();
        }else if (pData->GetType() == ChooseMobile::PROTOCOL_TYPE) {
            //=============================
            //TODO: PC 控制手机是否传输视频
            //=============================
            ChooseMobile *mobi = (ChooseMobile* )pData;
            
            ChooseMobileMdoel *objMobi = [[ChooseMobileMdoel alloc] init];
            objMobi.uid = mobi->userid;
            objMobi.tid = mobi->tid;
            ChooseMobiStyle style;
            if (mobi->actiontype == ChooseMobile::STOP) {
                style = ChooseMobiStyle_STOP;
            }else if (mobi->actiontype == ChooseMobile::CHOOSE) {
                style = ChooseMobiStyle_CHOOSE;
            }
            char cChar_video[500] = {0};
            int len_video = mobi->pushaddr.size();
            memcpy(cChar_video, mobi->pushaddr.begin(), len_video);
            cChar_video[len_video] = '\0';
            NSString *videoPushaddr = [NSString stringWithUTF8String:cChar_video];
            objMobi.pushaddr = videoPushaddr;
            
            objMobi.chooseStyle = style;
            if ([self.delegate respondsToSelector:@selector(cameraClientManagerFinish:cNetworkRecType:)]) {
                [self.delegate cameraClientManagerFinish:objMobi cNetworkRecType:pType];
            }
            mobi->Destroy();
        }else if (pData->GetType() == Kick::PROTOCOL_TYPE) {
            //=============================
            //TODO: PC 控制手机设备列表操作<删除/下课删除/手机断开>
            //=============================
            Kick *k = (Kick *)pData;
            KickModel *kModel = [[KickModel alloc] init];
            kModel.uid = k->userid;
            kModel.tid = k->tid;
            KickStyle kStyle;
            if (k->notifytype == Kick::DELETE_DEVICE) {
                kStyle = KickStyle_DELETE_DEVICE;
            }else if (k->notifytype == Kick::CLASS_END) {
                kStyle = KickStyle_CLASS_END;
            }if (k->notifytype == Kick::MOBILE_OFF) {
                kStyle = KickStyle_MOBILE_OFF;
            }else if (k->notifytype == Kick::TEACHER_LEAVE){
                kStyle = KickStyle_TEACHER_LEAVE;
            }
            kModel.kickStyle = kStyle;
            if ([self.delegate respondsToSelector:@selector(cameraClientManagerFinish:cNetworkRecType:)]) {
                [self.delegate cameraClientManagerFinish:kModel cNetworkRecType:pType];
            }
            k->Destroy();
        }
        
    });
}



#pragma mark -
#pragma mark - 协议发送接口

//======================
//TODO: 手机连接课堂请求
//======================
- (void)mobileConnectClassWithcode:(NSString *)codeString
                        deviceName:(NSString *)devName
                  responseDelegate:(id<CameraClientManagerDelegate>)delegate
{
    self.delegate = delegate;
    
    if (!m_isLogin && m_didConnect) {
        //已经连接link
      CSLog(@"CameraClientManager ==> 已经连接link 直接发送Code连接课堂");
        unichar deviceName[128] = {0};
        const char *ascii =[codeString  UTF8String];
        AString aString(ascii,(int)codeString.length);
        GNET::Octets codeoctets (aString, (int)codeString.length);
        
        
        
        MobileConnectClassReq mobiConnect;
        mobiConnect.userid = m_deviceUdid;
        mobiConnect.devicename = [CameraClientUtils octetsFromUnichar:deviceName atString:devName];
        mobiConnect.code = codeoctets;
        
        int sid = GNET::CameraClient::GetInstance().GetSessionID();
        [self addSessionDicSess:sid proType:CCP_MobileConnectClass];
        dispatch_async(queue, ^{
            GNET::CameraClient::GetInstance().Send(GNET::CameraClient::GetInstance().GetSessionID(),mobiConnect);
        });

        
    }else {
       //未连接link 视为未登录状态
        m_codeString = codeString;
        m_deviceName = devName;
        
        CSLog(@"CameraClientManager ==> 未连接link 视为未登录状态 1)连接登录服务器 2)通过手机唯一标识登录 3)断开登录服务器并连接link 4)发送code连接课堂");
        [self connectToServer];
    }
}

/**
 *连接登录服务器后获取link 地址
 **/
- (void)mobileGetLink
{
    CSLog(@"CameraClientManager ==> 连接登录服务器后通过唯一标识获取link 地址");
    MobileConnectReq mconnect;
    mconnect.userid = m_deviceUdid;
    mconnect.sid = 0;
    dispatch_async(queue, ^{
        GNET::CameraClient::GetInstance().Send(GNET::CameraClient::GetInstance().GetSessionID(),mconnect);
    });
}


//======================
//TODO: 被选中或者被删除 回复
//======================
- (void)returnChooseAt:(ChooseMobileMdoel *)chooseModel
{
    ChooseMobileResp chooseResp;
    chooseResp.userid = chooseModel.uid;
    chooseResp.tid = chooseModel.tid;
    chooseResp.ret =0;
    
    char t;
    if (chooseModel.chooseStyle == ChooseMobiStyle_CHOOSE) {
        t = ChooseMobile::CHOOSE;
    }else if (chooseModel.chooseStyle == ChooseMobile::STOP) {
        t = ChooseMobile::STOP;
    }
    chooseResp.actiontype = t;
    dispatch_async(queue, ^{
        GNET::CameraClient::GetInstance().Send(GNET::CameraClient::GetInstance().GetSessionID(),chooseResp);
    });
    
}

//======================
//TODO: 主动停止视频传输
//======================
- (void)mobileCameraOffWithTeaId:(long long)tid
{
    Kick kic;
    kic.userid = [UserAccount shareInstance].uid;
    kic.tid = tid;
    kic.notifytype = Kick::MOBILE_OFF;
    dispatch_async(queue, ^{
        GNET::CameraClient::GetInstance().Send(GNET::CameraClient::GetInstance().GetSessionID(),kic);
    });
}

//======================
//TODO: 设置手机连接课堂成功后接收代理
//======================
- (void)addMobiDidConnectChooseDelegate:(id<CameraClientManagerDelegate>)delegate
{
    self.delegate = delegate;
}

//======================
//TODO: 移除手机连接课堂成功后接收代理
//======================
- (void)delMobiDidConnectChooseDelegate
{
    self.delegate = nil;
}

@end
