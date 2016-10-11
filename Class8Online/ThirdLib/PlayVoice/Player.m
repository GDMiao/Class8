//
//  Player.m
//  mobileikaola
//
//  Created by 初亮亮 on 14-11-6.
//  Copyright (c) 2013年 ikaola. All rights reserved.
//

#import "Player.h"
//#import "iToast.h"

@implementation Player
+(Player *)sharePlayer
{
    static Player *sharedPlayerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedPlayerInstance = [[self alloc] init];
    });
    return sharedPlayerInstance;
}
-(id)init
{
    self = [super init];
    if (self) {
        self.cacheDic = [NSMutableDictionary dictionaryWithCapacity:1];
        cacheDelegates = [[NSMutableArray alloc] init];
        cacheURLs = [[NSMutableArray alloc] init];
        cacheVoiceDelegates = [[NSMutableDictionary alloc] init];
        [self resetTimerCount];
        //添加监听
        //停止播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStopPlayNotification:) name:StopAVAudioPlayer object:nil];
        //听筒距离
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}
-(void)stopTimerCountRun
{
    if (countDownTimer_) {
        [countDownTimer_ invalidate];
        countDownTimer_ = nil;
    }
}
-(void)resetTimerCount
{
    [self stopTimerCountRun];
    countDownTimer_ = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCountDown) userInfo:nil repeats:YES];
}
- (void)timeCountDown
{
    if (self.player.isPlaying) {
        //当前时间
        NSURL *playingURL = self.player.url;
        id delegate = [cacheVoiceDelegates objectForKey:playingURL];
        if ([delegate respondsToSelector:@selector(playDuration:currentTime:)]) {
            [delegate playDuration:self.player.duration currentTime:self.player.currentTime];
        }
    }
}
-(void)removeObjectIndex:(NSUInteger)index
{
    if (index != NSNotFound) {
        if (cacheURLs.count > index) {
            [cacheURLs removeObjectAtIndex:index];
        }
        if (cacheDelegates.count > index) {
            [cacheDelegates removeObjectAtIndex:index];
        }
        
    }
}
-(void)removeVoiceFile:(NSString *)file
{
    NSURL *fileURL = [NSURL URLWithString:[file stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
    
    [cacheVoiceDelegates removeObjectForKey:fileURL];
}
-(void)removeVoiceDelegate:(id)aDelegate
{
    if (aDelegate) {
        [cacheVoiceDelegates removeObjectsForKeys:[cacheVoiceDelegates allKeysForObject:aDelegate]];
    }
    
}
-(void)addVoiceFile:(NSString *)file delegate:(id)aDelegate
{
    NSURL *fileURL = [NSURL URLWithString:[file stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
    if (fileURL) {
        [cacheVoiceDelegates removeObjectForKey:fileURL];
        [cacheVoiceDelegates setObject:aDelegate forKey:fileURL];
    }
}
-(void)playFilePathVoice:(NSString *)file currentTime:(NSTimeInterval)currentTime delegate:(id)aDelegate
{
    [self addVoiceFile:file delegate:aDelegate];
    [self playFilePathVoice:file currentTime:currentTime];
}
-(void)playFilePathVoice:(NSString *)file currentTime:(NSTimeInterval)currentTime
{
    NSURL *fileURL = [NSURL URLWithString:[file stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];

    CSLog(@"fileUrl---%@",file);
    if (self.player && [self.lastVoiceFile isEqual:file]) {
        //如果正在播放当前音频，跳至播放时间
        [self resetPlayer];
        [self.player setCurrentTime:currentTime];
        [self.player prepareToPlay];
        
        [self play];
    }else{
        //
        if (self.player && self.player.isPlaying) {
            //正在播放 就停止播放
            
            [self stopPlayer];
        }
        
        AVAudioPlayer *newPlayer =
        [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                               error: nil];
        self.player = newPlayer;
        self.player.numberOfLoops = 0;
        [self.player setCurrentTime:currentTime];
        self.player.meteringEnabled = YES;
        [self.player setVolume:1.0];
        [self.player setDelegate: self];
        [self.player prepareToPlay];
        self.lastVoiceFile = file;
        
        [self play];
    }
    CSLog(@"lastVoiceFile--%@",self.lastVoiceFile);
    CSLog(@"playerUrl--%@",self.player.url);
}
-(void)play
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    if ([self.player play]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];//保持屏幕长亮
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
        NSURL *playingURL = self.player.url;
        id delegate = [cacheVoiceDelegates objectForKey:playingURL];
        if (delegate) {
            [delegate playStart];
        }
    }else{
        //语音播放失败
        
    }
}
-(NSTimeInterval)playCurrentTime:(NSString *)file
{
//    NSURL *fileURL = [NSURL URLWithString:[file stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
    if (self.player && [self.lastVoiceFile isEqual:file]) {
        return self.player.currentTime;
    }
    return 0;
}
-(void)saveCurrentTime
{
    if (self.player) {
        [self.cacheDic setValue:[NSNumber numberWithDouble:self.player.currentTime] forKey:self.player.url.absoluteString];
    }
    
}
-(NSTimeInterval)playDuration:(NSString *)file
{
//    NSURL *fileURL = [NSURL URLWithString:[file stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
    if (self.player && [self.lastVoiceFile isEqual:file]) {
        return self.player.duration;
    }
    return 1;
}
-(BOOL)isPlaying:(NSString *)file
{
//    NSURL *fileURL = [NSURL URLWithString:[file stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
    if (self.player && [self.lastVoiceFile isEqual:file]) {
        return self.player.isPlaying;
    }
    return NO;
}
-(BOOL)isPauseing:(NSString *)file
{
//    NSURL *fileURL = [NSURL URLWithString:[file stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
    if (self.player && [self.lastVoiceFile isEqual:file]) {
        if (self.player.currentTime > 0) {
            return YES;
        }
        return NO;
    }
    return NO;
}
-(BOOL)isPlayerUrl:(NSString *)file
{
//    NSURL *fileURL = [NSURL URLWithString:[file stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
    return [self.lastVoiceFile isEqual:file];
}
-(void)resetPlayer
{
    if (self.player) {
        
        [self.player stop];
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];//自动锁屏
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
        self.player.currentTime = 0;
    }
    if (self.cacheDic) {
        [self.cacheDic removeAllObjects];
    }
}
-(void)stopPlayer
{
    NSURL *playingURL = self.player.url;
    if (playingURL) {
        id delegate = [cacheVoiceDelegates objectForKey:playingURL];
        if ([delegate respondsToSelector:@selector(playStop)]) {
            [delegate playStop];
            [[NSNotificationCenter defaultCenter]postNotificationName:AudioPlayerAndRecoderToStop object:nil];
        }
        [self resetPlayer];
    }
    
}
-(void)pausePlayer
{
    if (self.player) {
        NSURL *playingURL = self.player.url;
        id delegate = [cacheVoiceDelegates objectForKey:playingURL];
        if ([delegate respondsToSelector:@selector(playerPause)]) {
            [delegate playerPause];
        }
        [self.player stop];
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];//自动锁屏
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
    }
}
-(float)getPeakPower
{
    if (!self.player.isPlaying) {
        return 0.3;
    }
    [self.player updateMeters];
    //发送updateMeters消息来刷新平均和峰值功率。此计数是以对数刻度计量的，-160表示完全安静，0表示最大输入值
    
    float power = 0.0f;
    for (int i = 0; i < [self.player numberOfChannels]; i++) {
        power += [self.player peakPowerForChannel:i];
    }
    power /= [self.player numberOfChannels];
    float peakPowerForChannel = (power + 160)/160;
    CSLog(@"peakPowerForChannel===%f",peakPowerForChannel);
    return peakPowerForChannel;
}
#pragma mark -
#pragma mark AVAudioPlayerDelegate Methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
    }
    NSURL *playingURL = self.player.url;
    id delegate = [cacheVoiceDelegates objectForKey:playingURL];
    if ([delegate respondsToSelector:@selector(playStop)]) {
        [delegate playStop];
    }
    CSLog(@"audioPlayerDidFinishPlaying");
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];//自动锁屏
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    [session setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:AudioPlayerAndRecoderToStop object:nil];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSURL *playingURL = self.player.url;
    id delegate = [cacheVoiceDelegates objectForKey:playingURL];
    if ([delegate respondsToSelector:@selector(playStop)]) {
        [delegate playStop];
    }
//    [[[iToast makeText:[error localizedFailureReason]]
//      setGravity:iToastGravityCenter] show];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];//自动锁屏
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    [session setCategory:AVAudioSessionCategoryAmbient error:nil];
    CSLog(@"audioPlayerDecodeErrorDidOccur");
}
-(void)receiveStopPlayNotification:(NSNotification *)notification
{
    if (notification.object) {
        NSNumber *number = notification.object;
        if ([number boolValue]) {
            NSURL *playingURL = self.player.url;
            if (playingURL) {
                [cacheVoiceDelegates removeObjectForKey:playingURL];
            }
            
        }
    }
    
    [self stopPlayer];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        CSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        CSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

-(void)dealloc
{
    self.player = nil;
    self.cacheDic = nil;
    self.lastVoiceFile = nil;
    [self resetTimerCount];
    if (cacheDelegates) {
        cacheDelegates = nil;
    }
    if (cacheURLs) {
        cacheURLs = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)clearMemory
{
    if (cacheDelegates) {
        [cacheDelegates removeAllObjects];
    }
    if (cacheURLs) {
        [cacheURLs removeAllObjects];
    }
    
}
@end
