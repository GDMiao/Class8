//
//  VideoRecord.h
//  CAP
//
//  Created by chuliangliang on 15/7/2.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//#define ShowRecordlog 1

#ifdef ShowRecordlog
#define CLVideoLog(...){} NSLog(__VA_ARGS__)
#else 
#define CLVideoLog(...){}
#endif
@protocol VideoRecordDelegate <NSObject>


- (void)videoRecordRecVideo:(UInt8 *)videoBuffer videoWidth:(size_t)width videoHeight:(size_t)height;
@end

typedef enum
{
    VideoSize_288_352,
    VideoSize_480_640,
    VideoSize_720_1280,
}VideoSize;
@interface VideoRecord : NSObject 
@property (weak, nonatomic) id <VideoRecordDelegate>delegate;
@property (assign, nonatomic) int producerFps;  //默认 15
@property (strong, nonatomic) UIView *videoPreview;
@property (assign, nonatomic) BOOL capTureFlashOn; //是否开始闪光灯 默认关闭
@property (assign, nonatomic) BOOL swichCaptureBack; //是否切换到后摄像头 yes:后 no: 前
@property (assign, nonatomic) CGFloat cameraAddNearly; //摄像头拉近 每次拉近 0.03
@property (assign, nonatomic) CGFloat cameraPullAway;  //摄像头拉远 每次拉远 0.03
@property (strong, nonatomic) UIPinchGestureRecognizer *pullAwayAndNearlyPinch; //伸缩摄像头手势
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture; //点击聚焦手势

@property (assign, nonatomic) BOOL hasCameraPullAwayAndNearly, //是否开启摄像头伸缩 默认yes
hasFocusCursorWithTap; // 是否使用点击屏幕聚焦 默认yes

/**
 *开始视频采集
 ***/
- (void)startVideoCapture;

/**
 *停止视频采集
 **/
- (void)stopVideoCapture;

/**
 * 外部调用 用来更新摄像头方向信息
 **/
- (void)refreshCameraDevicePortait;

/**
 *调整视频尺寸
 **/
- (void)changeSessionPreset:(VideoSize)sessionPreset;

/**
 * 更新视频预览窗口的尺寸
 **/
- (void)updatevideoPreviewFrame:(CGRect )rect;
@end
