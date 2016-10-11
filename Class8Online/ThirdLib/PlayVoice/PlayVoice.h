//
//  PlayVoice.h
//  mobileikaola
//
//  Created by 初亮亮 on 14-11-6.
//  Copyright (c) 2014年 ikaola. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Downloader.h"

typedef NS_ENUM(NSInteger, PlayStatus) {
    PlayStatus_Default,/*无按钮默认*/
    PlayStatus_Loading,/*正在下载*/
    PlayStatus_Playing,/*正在播放*/
    PlayStatus_Pause,/*暂停*/
    PlayStatus_Stop,/*停止*/
};
typedef NS_ENUM(NSInteger, StopType) {
    StopType_Manual,/*手动停止*/
    StopType_Nature,/*自然结束*/
};

@class PlayVoice;
@protocol PlayVoiceDelegate <NSObject>
@optional
-(void)noDownload:(PlayVoice *)aPlayVoice;//本地没有下载的文件
-(void)startDownload:(PlayVoice *)aPlayVoice;//开始下载
-(void)stopDownload:(PlayVoice *)aPlayVoice;//停止下载语音
-(void)playDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime;//播放文件时长
-(void)startPlayVoice:(PlayVoice *)aPlayVoice;//开始播放
-(void)pausePlayVoice:(PlayVoice *)aPlayVoice;//暂停播放
-(void)stopPlayVoice:(PlayVoice *)aPlayVoice;//停止播放
-(void)downloadSuccess:(BOOL)success;//下载文件成功
- (void)downloadFail;//文件下载失败 add for 1.6;
-(void)stopPlayVoice:(PlayVoice *)aPlayVoice stopType:(StopType)stopType;//停止播放
@end

//<DownloaderDelegate>
@interface PlayVoice : NSObject

@property(strong, nonatomic) NSString *voiceUrl,*filePath;//语音链接，语音本地地址
@property(assign,nonatomic,readonly) PlayStatus status;
@property(assign,nonatomic) BOOL onlyDowndFile;//是否只下载文件
@property(assign,nonatomic) id delegate;
-(id)initWithDelegate:(id)aDelegate;
-(void)setVoiceUrl:(NSString *)voiceUrl delegate:(id)aDelegate;
-(void)setFlyVoiceUrl:(NSString *)voiceUrl delegate:(id)aDelegate;//飞行轨迹地图播放语音
-(void)setFlyVoiceFile:(NSString *)voiceFile delegate:(id)aDelegate;//传话筒只传本地地址
-(void)setVoiceFile:(NSString *)filePath delegate:(id)aDelegate;
-(void)stopPlay;
//播放点击
-(void)startPlay;
-(void)startPlay:(float)progress;
/*传话筒 试听 停止*/
- (void)airFoneStopPaly;
@end
