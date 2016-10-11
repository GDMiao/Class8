//
//  MediaCollection.m
//  CAP
//
//  Created by chuliangliang on 15/7/3.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MediaCollection.h"

@interface MediaCollection ()<CLRecordDelegate, VideoRecordDelegate>
{
    
    int videoFps;
    int audiorate;
    int audioChannel;    
}
@end

@implementation MediaCollection
@synthesize video;
@synthesize audio;

- (id)initWithVideoFPS:(int)fps audioRate:(int)rate  audioChannel:(int)channel
{
    self = [super init];
    if (self) {
        videoFps = fps;
        audiorate = rate;
        audioChannel = channel;
        [self _initOBJ];
    }
    return self;
}

- (void)_initOBJ {
    audio = [[CLRecord alloc] init];
    audio.delegate =self;
    audio.audioRate = audiorate;
    audio.audioChannel = audioChannel;
    
    video = [[VideoRecord alloc] init];
    video.delegate = self;
    if (videoFps > 0) {
        video.producerFps = videoFps;
    }
}

- (void)dealloc {
    if (audio) {
        audio = nil;
    }
    if (video) {
        video = nil;
    }
    self.videoCallBack = nil;
    self.audioCallBack = nil;
}

#pragma mark -
#pragma mark - CLRecordDelegate
- (void)clRecordAudio:(SInt16 *)audioBuffer audioDataByteSize:(UInt32)audi0Size
{
    if (self.audioCallBack) {
        self.audioCallBack (audioBuffer,audi0Size);
    }
}


#pragma mark -
#pragma mark - VideoRecordDelegate
- (void)videoRecordRecVideo:(UInt8 *)videoBuffer videoWidth:(size_t)width videoHeight:(size_t)height
{
    if (self.videoCallBack) {
        self.videoCallBack (videoBuffer,width,height);
    }
    MediaLog(@"视频: w = %zu, h = %zu",width,height);
}


/**
 *是否可以采集媒体信息 (例如 用户禁用摄像头/麦克风 返回NO)
 **/
- (BOOL)hasStartMediaColllection {
    return YES;
}


/**
 * 视频预览窗口
 * 如不需要 则不处理
 **/
- (void)videoPreview:(UIView *)view
{
    video.videoPreview = view;
}

/**
 * 开始媒体信息采集
 **/
- (void)startMediaCollection {
    [audio startRecord];
    [video startVideoCapture];
}

/**
 * 停止媒体信息采集
 **/
- (void)stopMediaCollection {
    [audio stopRecord];
    [video stopVideoCapture];
}
@end
