//
//  CameraClientManager.h
//  Class8Online
//
//  Created by chuliangliang on 16/1/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CAMERACLIENTMANAGER [CameraClientManager defaultManager]


typedef enum {
    CCP_NOT_Net = -100,                 //没有网络连接
    CCP_ConnectTimeOut = -99,           //服务器连接超时
    CCP_disConnect = -98,               //服务器中断连接
    
    CCP_MobileConnectClass = 1035,      //手机助手连课堂
    CCP_ChooseMobile = 1038,            //选择手机助手开始/停止上传音视频
    CCP_Kick = 1040,                    //用于消息通知，包括主动删除手机设备、下课
    CCP_MobileConnectResp = 1056,       //用于手机code码登录地址回应
    CCP_MobileOff = 1057,               //用于手机掉线通知,服务器间通信

}CameraClientRecProtocolType;

@protocol CameraClientManagerDelegate <NSObject>

- (void) cameraClientManagerFinish:(id)value cNetworkRecType:(int) pType;  //成功后的回调
- (void) cameraClientManagerFaild:(id)value cNetworkRecType:(int) pType;   //失败后的回调

@optional
- (void) cameraClientManagerDiddisConnectServer:(BOOL)isLoginServer;        //与服务器断开

@end

@class ChooseMobileMdoel;
@interface CameraClientManager : NSObject
+ (CameraClientManager *)defaultManager;

/**
 *连接服务器
 **/
- (void)connectToServer;

//======================
//TODO: 手机连接课堂请求
//======================
- (void)mobileConnectClassWithcode:(NSString *)codeString
                deviceName:(NSString *)devName
          responseDelegate:(id<CameraClientManagerDelegate>)delegate;

//======================
//TODO: 被选中或者被删除 回复
//======================
- (void)returnChooseAt:(ChooseMobileMdoel *)chooseModel;

//======================
//TODO: 主动停止视频传输
//======================
- (void)mobileCameraOffWithTeaId:(long long)tid;


//======================
//TODO: 设置手机连接课堂成功后接收代理
//======================
- (void)addMobiDidConnectChooseDelegate:(id<CameraClientManagerDelegate>)delegate;

//======================
//TODO: 移除手机连接课堂成功后接收代理
//======================
- (void)delMobiDidConnectChooseDelegate;

@end

