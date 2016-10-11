//
//  Class8OnlineDefine.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#ifndef Class8Online_Class8OnlineDefine_h
#define Class8Online_Class8OnlineDefine_h

#endif

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

//国际化
#define CSLocalizedString(__str__) NSLocalizedString(__str__,__str__)
//当前设备的屏幕宽度
#define SCREENWIDTH  [[UIScreen mainScreen] bounds].size.width
//当前设备的屏幕高度
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define IS_IOS5 ( [[[UIDevice currentDevice] systemVersion] compare:@"5.0"] != NSOrderedAscending )
#define IS_IOS6 ( [[[UIDevice currentDevice] systemVersion] compare:@"6.0"] != NSOrderedAscending )
#define IS_IOS7 ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define IS_IOS8 ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )

typedef unsigned  short __uShort;
//颜色
#define MakeColor(r,g,b) ([UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1])

#define LOBYTE(w) ((Byte)(((NSUInteger)(w)) & 0xff))
#define GetRValue(rgb)      (LOBYTE(rgb))
#define GetGValue(rgb)      (LOBYTE(((__uShort)(rgb)) >> 8))
#define GetBValue(rgb)      (LOBYTE((rgb)>>16))

//获取唯一标识 <摄像头>
#define DeviceUDID  [[UIDevice currentDevice].identifierForVendor UUIDString];


#ifndef __OPTIMIZE__
#define CSLog(...) NSLog(__VA_ARGS__)
#else
#define CSLog(...) {}
#endif

//PC 发来原始的HTML 头开始
#define HTML_BODY1_FOR_CHAT_PC @"<body>\n"



//是否输出多媒体
//#define ShowMediaLog 1

#ifdef ShowMediaLog
#define ShowLog(...) NSLog(__VA_ARGS__)                 //输出音视频log
#else
#define ShowLog(...) {}                                 //禁止输出音视频log
#endif



//是否输出在线课堂log
#define ShowClassRoomLog 1

#ifdef ShowClassRoomLog
#define ClassRoomLog(...) NSLog(__VA_ARGS__)            //输出课堂内所有log
#else
#define ClassRoomLog(...) {}                            //关闭输出课堂内所有log
#endif


#define StopAVAudioPlayer @"stopPlayVoice"

#define AudioPlayerAndRecoderToStop @"audioPlayerOrRecorderToStopNotification"

//过度图片消失后 刷新课堂列表的通知
#define CovertImageDidHiddenAndRefreshMainViewListNotification @"refrech_MainViewList"


//消除 variable %0 may be uninitialized when %select{used here|captured by block}1 警告提示
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconditional-uninitialized"
//
#pragma clang diagnostic ignored "-Wdeprecated"
//消除 implicit conversion from enumeration type %0 to different enumeration type %1 警告提示
#pragma clang diagnostic ignored "-Wenum-conversion"
//消除 class method %objcclass0 not found (return type defaults to 'id') 警告提示
#pragma clang diagnostic ignored "-Wobjc-method-access"
//消除 conflicting parameter types in implementation of %0: %1 vs %2 警告提示
#pragma clang diagnostic ignored "-Wmethod-signatures"
//消除 conflicting parameter types in implementation of %0%diff{: $ vs $|}1,2 警告提示
#pragma clang diagnostic ignored "-Wmismatched-parameter-types"
//消除 will never be executed 警告提示
#pragma clang diagnostic ignored "-Wunreachable-code"

//app 评分地址
#define AppevaluationUrl @"https://itunes.apple.com/us/app/ke-ba-class8/id1103570333?mt=8"


//是否正式服务器
#define AppleRelease 1
