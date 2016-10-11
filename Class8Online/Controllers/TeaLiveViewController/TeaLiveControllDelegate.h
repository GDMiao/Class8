//
//  Header.h
//  Class8Online
//
//  Created by chuliangliang on 15/11/24.
//  Copyright © 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    TeaLiveRoomShow_Default =  10, /*默认*/
    TeaLiveRoomShow_CourseWare,    /*课件*/
}TeaLiveRoomShow; //主窗口显示内容



typedef  enum
{
    TeaLiveRoomSatus_NOT_ON = 0 ,       /*未开始*/
    TeaLiveRoomSatus_WAIT_ON = 1,       /*准备中*/
    TeaLiveRoomSatus_ON_NOT_BEGIN = 2,   /*正在进行,但未上课*/
    TeaLiveRoomSatus_ON_AND_BEGIN = 4,  /*上课中*/
 
}TeaLiveRoomSatus; //课堂状态


typedef enum
{
    CurrentClassModel_UNSPEAKABLE = 0,              //禁止举手
    CurrentClassModel_SPEAKABLE = 1,                //可举手
    CurrentClassModel_TEXTABLE = 2,                 //可聊天
    CurrentClassModel_UTEXTABLE = 3,                //禁止聊天
    CurrentClassModel_ASIDEABLE = 4,                //可旁听
    CurrentClassModel_UNASIDEABLE = 5,              //不可旁听
    CurrentClassModel_Imageable = 8,                //允许发图片
    CurrentClassModel_Imagedisable = 9,             //禁止发图片
    CurrentClassModel_Lock = 16,                    //锁定
    CurrentClassModel_UnLock = 17,                  //解锁

}CurrentClassModel; //课堂权限


@protocol TeaLiveControllDelegate <NSObject>

@optional

/**
 * isSuccess 进入课堂 失败/成功
 **/
- (void)liveControllIntoLiveRoom:(BOOL)isSuccess;


/**
 * 用户在其他地方登陆
 **/
- (void)liveControllUserLoginWithOtherLocation;

/**
 * 程序退到后台
 **/
- (void)liveControllApplicationWillResignActive;

/**
 * 程序进入前台
 **/
- (void)liveControllApplicationWillBecame;


/**
 * 更新课堂状态
 **/
- (void)liveControllUpdateClsssState:(TeaLiveRoomSatus)status;

@end