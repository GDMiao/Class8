//
//  MediaCollection.h
//  CAP
//
//  Created by chuliangliang on 15/7/3.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CLRecord.h"
#import "VideoRecord.h"

//#define MediaShowRecordlog 1

#ifdef MediaShowRecordlog
#define MediaLog(...){} NSLog(__VA_ARGS__)
#else
#define MediaLog(...){}
#endif


typedef void(^MediaCallBack_audio)(SInt16 * audioBuffer ,UInt32 len);
typedef void(^MediaCallBack_video)(UInt8 * videoBuffer, size_t vWidth, size_t vHeight);

@interface MediaCollection : NSObject

@property (copy, nonatomic) MediaCallBack_audio audioCallBack;
@property (copy, nonatomic) MediaCallBack_video videoCallBack;
@property (strong, nonatomic) CLRecord *audio;
@property (strong, nonatomic) VideoRecord *video;

- (id)initWithVideoFPS:(int)fps audioRate:(int)rate audioChannel:(int)channel;


/**
 *是否可以采集媒体信息 (例如 用户禁用摄像头/麦克风 返回NO)
 **/
- (BOOL)hasStartMediaColllection;

/**
 * 视频预览窗口
 * 如不需要 则不处理
 **/
- (void)videoPreview:(UIView *)view;

/**
 * 开始媒体信息采集
 **/
- (void)startMediaCollection;

    
/**
 * 停止媒体信息采集
 **/
- (void)stopMediaCollection;

@end
