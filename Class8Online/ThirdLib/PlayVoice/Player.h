//
//  Player.h
//  mobileikaola
//
//  Created by 初亮亮 on 14-11-6.
//  Copyright (c) 2013年 ikaola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol playerDelegate <NSObject>
@optional
-(void)playDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime;
-(void)playStop;
-(void)playerPause;
-(void)playStart;
@end

@interface Player : NSObject<AVAudioPlayerDelegate>
{
    NSMutableArray *cacheDelegates;
    NSMutableArray *cacheURLs;
    NSMutableDictionary *cacheVoiceDelegates;
    NSTimer     *countDownTimer_;//定时器，每秒调用一次
}
@property(strong,nonatomic) AVAudioPlayer *player;

@property(strong,nonatomic) NSMutableDictionary *cacheDic;
+(Player *)sharePlayer;
-(void)removeVoiceFile:(NSString *)file;
-(void)removeVoiceDelegate:(id)aDelegate;//删除对应的代理
-(void)addVoiceFile:(NSString *)file delegate:(id)aDelegate;
-(void)playFilePathVoice:(NSString *)file currentTime:(NSTimeInterval)currentTime delegate:(id)aDelegate;
-(void)playFilePathVoice:(NSString *)file currentTime:(NSTimeInterval)currentTime;//从定义时间开始播放
-(NSTimeInterval)playCurrentTime:(NSString *)file;//语音当前播放的时间
-(NSTimeInterval)playDuration:(NSString *)file;//语音播放的总时长
-(BOOL)isPlaying:(NSString *)file;//语音是否正在播放
-(void)stopPlayer;//停止播放
-(float)getPeakPower;//波峰
-(void)pausePlayer;//暂停
-(BOOL)isPlayerUrl:(NSString *)file;
-(BOOL)isPauseing:(NSString *)file;//是否暂停

@property (strong,nonatomic) NSString *lastVoiceFile;

@property (strong,nonatomic) NSString *downloadUrl;//下载的地址
@end
