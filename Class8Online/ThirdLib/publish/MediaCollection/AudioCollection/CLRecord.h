//
//  CLRecord.h
//  SpeekDome
//
//  Created by chuliangliang on 15/7/2.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define ShowVideoRecordlog 1

#ifdef ShowVideoRecordlog
#define CLRECORDLog(...){} NSLog(__VA_ARGS__)
#else
#define CLRECORDLog(...){}
#endif


#define CLAudiomSampleRate 16000
#define CLAudioChannelsPerFrame 1

@protocol CLRecordDelegate <NSObject>

- (void)clRecordAudio:(SInt16 *)audioBuffer audioDataByteSize:(UInt32)audioSize;


@end

@interface CLRecord : NSObject
@property (weak, nonatomic) id<CLRecordDelegate> delegate;
@property (assign, nonatomic) int audioRate; //采样率
@property (assign, nonatomic) int audioChannel; //通道
@property (assign, nonatomic) BOOL isMicruning; //是否正在录音

/**
 *开始录音
 **/
- (void)startRecord;
/**
 * 停止录音
 **/
- (void)stopRecord;

@end
