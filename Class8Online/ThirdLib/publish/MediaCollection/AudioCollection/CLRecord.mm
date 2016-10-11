//
//  CLRecord.m
//  SpeekDome
//
//  Created by chuliangliang on 15/7/2.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CLRecord.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CAStreamBasicDescription.h"
#define kBufferDurationSeconds .5
#define kNumberRecordBuffers	3


@interface CLRecord ()
{
    AudioQueueRef				mQueue;
    AudioQueueBufferRef			mBuffers[kNumberRecordBuffers];
    SInt64						mRecordPacket; // current packet number in record file
    CAStreamBasicDescription	mRecordFormat;
    Boolean						mIsRunning;

//    NSMutableData *totalAudioData;
//    int totalAllCount;
}
@end
@implementation CLRecord

void audioRouteChangeListenerCallback (void *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueS,
                                       const void                *inPropertyValue)
{
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    CFStringRef state = nil;
    //获取音频路线
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute ,&propertySize,&state);//kAudioSessionProperty_AudioRoute：音频路线
    CLRECORDLog(@"获取音频路线 %@",(__bridge NSString *)state);//Headphone 耳机  Speaker 喇叭.
}

static void MyInputBufferHandler (	void *								inUserData,
                                  AudioQueueRef						inAQ,
                                  AudioQueueBufferRef					inBuffer,
                                  const AudioTimeStamp *				inStartTime,
                                  UInt32								inNumPackets,
                                  const AudioStreamPacketDescription*	inPacketDesc)

{
    CLRecord *aqr = (__bridge CLRecord *)inUserData;
    try {
        if (inNumPackets > 0) {
            [aqr processAudioBuffer:inBuffer withQueue:inAQ];
            
        }
        
        if (aqr->mIsRunning)
            if(AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL)){
                CLRECORDLog(@"AudioQueueEnqueueBuffer failed");
            }
        
    } catch (NSException *e) {
        CLRECORDLog(@"Error: 录音buffer 解析失败");
    }
}

- (id)init {
    self = [super init];
    if (self) {
        [self _initObjs];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}
- (void)_initObjs {
    self.isMicruning = NO;
//    totalAudioData = [[NSMutableData alloc] init];
//    totalAllCount = 0;
    
    OSStatus error = AudioSessionInitialize(NULL, NULL, NULL, NULL);
    if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", error);
    else
    {
//        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
//        OSStatus setSessionStatus = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
//        
//        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);

//        if (!IS_IOS7) {
//            UInt32 allowBluetoothInput = 1;
//            error = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,sizeof (allowBluetoothInput),&allowBluetoothInput);
//            if (error) CLRECORDLog(@"设置蓝牙输出失败");
//        }
//        UInt32 mode = kAudioSessionMode_VoiceChat;
//         error = AudioSessionSetProperty(kAudioSessionProperty_Mode, sizeof(mode), &mode);
        
        
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        if (error) CLRECORDLog(@"couldn't set audio category!");
        
        error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, (__bridge void *)(self));
        if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", error);
        UInt32 inputAvailable = 0;
        UInt32 size = sizeof(inputAvailable);
        
        // we do not want to allow recording if input is not available
        error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
        if (error) CLRECORDLog(@"ERROR GETTING INPUT AVAILABILITY! %d\n", error);
        
        
        // we also need to listen to see if input availability changes
        error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, audioRouteChangeListenerCallback, (__bridge void *)(self));
        if (error) CLRECORDLog(@"ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", error);
        
        error = AudioSessionSetActive(true);
        if (error) CLRECORDLog(@"AudioSessionSetActive (true) failed");
    }

    
    
}

- (void)setupAudioFormat:(UInt32) inFormatID {
    memset(&mRecordFormat, 0, sizeof(mRecordFormat));
    UInt32 size = sizeof(mRecordFormat.mSampleRate);
    if (AudioSessionGetProperty( kAudioSessionProperty_CurrentHardwareSampleRate,&size,&mRecordFormat.mSampleRate) != kAudioSessionNoError) {
        CLRECORDLog(@"采样率未找到\n");
    }
    size = sizeof(mRecordFormat.mChannelsPerFrame);
    if (AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels,&size,&mRecordFormat.mChannelsPerFrame) != kAudioSessionNoError) {
        CLRECORDLog(@"无法输入通道数\n");
    }
    mRecordFormat.mFormatID = inFormatID;
    if (inFormatID == kAudioFormatLinearPCM)
    {
        // if we want pcm, default to signed 16-bit little-endian
        mRecordFormat.mSampleRate = self.audioRate;;
        mRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        mRecordFormat.mBitsPerChannel = 16;
        mRecordFormat.mBytesPerPacket = mRecordFormat.mBytesPerFrame = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
        mRecordFormat.mFramesPerPacket = 1;
        mRecordFormat.mChannelsPerFrame = self.audioChannel;
    }
}


- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue {
    
    UInt32 audioDataByteSize = buffer->mAudioDataByteSize;
    SInt16 * audioData = (SInt16 *) buffer->mAudioData;
    
    

//    if (totalAllCount == 50) {
//        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *docsDir = [dirPaths objectAtIndex:0];
//        NSString *savedPath = [docsDir stringByAppendingPathComponent:@"new-录音3"];
//        if ([totalAudioData writeToFile:savedPath atomically:YES]) {
//            CSLog(@"文件写入成功*********************************************************");
//        }
//    }else if (totalAllCount < 50) {
//        NSData *data = [NSData dataWithBytes:audioData length:audioDataByteSize];
//        [totalAudioData appendData:data];
//    }
//    totalAllCount ++;
    CLRECORDLog(@"实时音频Size:%d \n",audioDataByteSize);
    
    if ([self.delegate respondsToSelector:@selector(clRecordAudio:audioDataByteSize:)]) {
        [self.delegate clRecordAudio:audioData audioDataByteSize:audioDataByteSize];
    }
}


- (int)ComputeRecordBufferSize:(const AudioStreamBasicDescription *)format seconds:(float)seconds{
    int packets, frames, bytes = 0;
    try {
        frames = (int)ceil(seconds * format->mSampleRate);
        
        if (format->mBytesPerFrame > 0)
            bytes = frames * format->mBytesPerFrame;
        else {
            UInt32 maxPacketSize;
            if (format->mBytesPerPacket > 0)
                maxPacketSize = format->mBytesPerPacket;	// constant packet size
            else {
                UInt32 propertySize = sizeof(maxPacketSize);
                if (AudioQueueGetProperty(mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,&propertySize)) {
                    CLRECORDLog(@"无法输出数据包队列的最大大小\n");
                }
            }
            if (format->mFramesPerPacket > 0)
                packets = frames / format->mFramesPerPacket;
            else
                packets = frames;	// worst-case scenario: 1 frame in a packet
            if (packets == 0)		// sanity check
                packets = 1;
            bytes = packets * maxPacketSize;
        }
    } catch (NSException *e) {
//        		char buf[256];
//        		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
        CLRECORDLog(@"error: %@",e);
        return 0;
    }	
    return bytes;

}

/**
 *开始录音
 **/
- (void)startRecord {
    int i, bufferByteSize;
    UInt32 size;

    
    try {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;  //设置成话筒模式
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride),&audioRouteOverride);
        
        UInt32 audioRouteOverride1 = kAudioSessionMode_VoiceChat;  //设置成语音通话模式
        AudioSessionSetProperty (kAudioSessionProperty_Mode,
                                 sizeof (audioRouteOverride1),
                                 &audioRouteOverride1);

        
        [self setupAudioFormat:kAudioFormatLinearPCM];
        AudioQueueNewInput( &mRecordFormat, MyInputBufferHandler,
                           (__bridge void*)(self) /* userData */
                           ,NULL /* run loop */
                           , NULL /* run loop mode */
                           ,0 /* flags */
                           , &mQueue);
        mRecordPacket = 0;
        
        size = sizeof(mRecordFormat);
            if(AudioQueueGetProperty(mQueue, kAudioQueueProperty_StreamDescription,
                              &mRecordFormat, &size) != kAudioSessionNoError){
                CLRECORDLog(@"couldn't get queue's format");
            }
        
        bufferByteSize = [self ComputeRecordBufferSize:&mRecordFormat seconds:kBufferDurationSeconds];
        for (i = 0; i < kNumberRecordBuffers; ++i) {
            if (AudioQueueAllocateBuffer(mQueue, bufferByteSize, &mBuffers[i]) != kAudioSessionNoError) {
                printf("AudioQueueAllocateBuffer 失败\n");
            }
            
            if (AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL) != kAudioSessionNoError) {
                printf("AudioQueueEnqueueBuffer 失败\n");
            }
        }
        // start the queue
        mIsRunning = true;
        self.isMicruning = YES;
        if (AudioQueueStart(mQueue, NULL) != kAudioSessionNoError ) {
            printf("音频队列开始 失败\n");
            self.isMicruning = NO;
        }
    }
    catch (NSException *e) {
        CLRECORDLog(@"异常错误: %@",e);
    }
    catch (...) {
//        fprintf(stderr, "An unknown error occurred\n");
        CLRECORDLog(@"An unknown error occurred\n");
    }	

}

/**
 * 停止录音
 **/
- (void)stopRecord {
    mIsRunning = false;
    self.isMicruning = NO;
    if (AudioQueueStop(mQueue, true) != kAudioSessionNoError) {
        printf("AudioQueueStop failed");
    }
    AudioQueueDispose(mQueue, true);

//    
//    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docsDir = [dirPaths objectAtIndex:0];
//    NSString *savedPath = [docsDir stringByAppendingPathComponent:@"new-录音"];
//    [totalAudioData writeToFile:savedPath atomically:YES];

}



@end
