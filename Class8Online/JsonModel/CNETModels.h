//
//  CNETModels.h
//  Class8Camera
//
//  Created by chuliangliang on 15/7/28.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

typedef enum {
    KickStyle_DELETE_DEVICE = 0,    //设备列表删除接入的手机
    KickStyle_CLASS_END = 1,        //下课通知接入的手机
    KickStyle_MOBILE_OFF = 2,       //接入的手机掉线
    KickStyle_TEACHER_LEAVE = 3,    //正在上课时老师离开课堂
}KickStyle;//PC 对手机助手列表的操作

@interface MobileConnectClassRespModel : JSONModel
@property (assign, nonatomic) long long uid,tid,cid;
@property (strong, nonatomic) NSString *devName;


@end

@interface KickModel : JSONModel
@property (assign, nonatomic) long long uid,tid;
@property (assign, nonatomic) KickStyle kickStyle;
@end


typedef enum {
    ChooseMobiStyle_STOP = 0,       //停止传输
    ChooseMobiStyle_CHOOSE = 1,     //开始传输
}ChooseMobiStyle; // 操作类型

@interface ChooseMobileMdoel : JSONModel
@property (assign, nonatomic) long long uid,tid;
@property (strong, nonatomic) NSString *pushaddr;//音视频发送地址
@property (assign, nonatomic) ChooseMobiStyle chooseStyle;
@end


@interface CNETModels : JSONModel

@end
