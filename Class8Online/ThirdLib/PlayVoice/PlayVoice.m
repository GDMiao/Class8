//
//  PlayVoice.m
//  mobileikaola
//
//  Created by 初亮亮 on 14-11-6.
//  Copyright (c) 2014年 ikaola. All rights reserved.
//

#import "PlayVoice.h"
#import "Player.h"
//#import "VoiceConverter.h"
//#import "KL_Util.h"

@interface PlayVoice ()<playerDelegate>
//@property(retain,nonatomic) Downloader *downloader;
@end
@implementation PlayVoice
@synthesize status;
-(id)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self) {
        self.delegate =aDelegate;
    }
    return self;
}
-(void)setVoiceUrl:(NSString *)voiceUrl delegate:(id)aDelegate
{
//    if (self.downloader) {
//        self.downloader = nil;
//    }
    self.delegate = aDelegate;
    status = PlayStatus_Default;
    self.voiceUrl = voiceUrl;
    [[Player sharePlayer] removeVoiceDelegate:self];
//    NSString *tmpFile = [Downloader isExitDownloadVoiceFile:voiceUrl];
    if (voiceUrl) {
        self.filePath = voiceUrl;
        if ([[Player sharePlayer] isPlayerUrl:self.filePath]) {
            if (![[Player sharePlayer] isPlaying:self.filePath]) {
                if ([[Player sharePlayer] isPauseing:self.filePath]) {
                    status = PlayStatus_Pause;
                    if ([self.delegate respondsToSelector:@selector(playDuration:currentTime:)]) {
                        NSTimeInterval playCurrentTime = [[Player sharePlayer] playCurrentTime:self.filePath];
                        NSTimeInterval playDuration = [[Player sharePlayer] playDuration:self.filePath];
                        [self.delegate playDuration:playDuration currentTime:playCurrentTime];
                    }
                    if ([self.delegate respondsToSelector:@selector(pausePlayVoice:)]) {
                        [self.delegate pausePlayVoice:self];
                    }
                    return;
                }
                //如果还没有开始播放，停止计数器
                status = PlayStatus_Stop;
                if ([self.delegate respondsToSelector:@selector(stopPlayVoice:)]) {
                    [self.delegate stopPlayVoice:self];
                }
            }else{
                status = PlayStatus_Playing;
                [[Player sharePlayer] addVoiceFile:self.filePath delegate:self];
                
            }
            
        }else{
            if ([self.delegate respondsToSelector:@selector(stopPlayVoice:)]) {
                [self.delegate stopPlayVoice:self];
            }
        }
    }else{
        self.filePath = nil;
        if ([self.delegate respondsToSelector:@selector(noDownload:)]) {
            [self.delegate noDownload:self];
        }
        if ([self.delegate respondsToSelector:@selector(stopPlayVoice:)]) {
            [self.delegate stopPlayVoice:self];
        }
    }
}
-(void)setFlyVoiceUrl:(NSString *)voiceUrl delegate:(id)aDelegate
{
    self.delegate = aDelegate;
    status = PlayStatus_Default;
    self.voiceUrl = voiceUrl;
    if (voiceUrl) {
        self.filePath = voiceUrl;
    }else{
        self.filePath = nil;
    }
}
-(void)setFlyVoiceFile:(NSString *)voiceFile delegate:(id)aDelegate
{
    self.delegate = aDelegate;
    status = PlayStatus_Default;
    self.filePath = voiceFile;
}
-(void)setVoiceFile:(NSString *)aFilePath delegate:(id)aDelegate
{
    self.delegate = aDelegate;
    status = PlayStatus_Default;
    self.filePath = aFilePath;
    [[Player sharePlayer] removeVoiceDelegate:self];
    if ([[Player sharePlayer] isPlayerUrl:self.filePath]) {
        if (![[Player sharePlayer] isPlaying:self.filePath]) {
            if ([[Player sharePlayer] isPauseing:self.filePath]) {
                status = PlayStatus_Pause;
                if ([self.delegate respondsToSelector:@selector(playDuration:currentTime:)]) {
                    NSTimeInterval playCurrentTime = [[Player sharePlayer] playCurrentTime:self.filePath];
                    NSTimeInterval playDuration = [[Player sharePlayer] playDuration:self.filePath];
                    [self.delegate playDuration:playDuration currentTime:playCurrentTime];
                }
                if ([self.delegate respondsToSelector:@selector(pausePlayVoice:)]) {
                    [self.delegate pausePlayVoice:self];
                }
                return;
            }
            //如果还没有开始播放，停止计数器
            status = PlayStatus_Stop;
            if ([self.delegate respondsToSelector:@selector(stopPlayVoice:)]) {
                [self.delegate stopPlayVoice:self];
            }
        }else{
            status = PlayStatus_Playing;
            [[Player sharePlayer] addVoiceFile:self.filePath delegate:self];
            
        }
        
    }else{
        if ([self.delegate respondsToSelector:@selector(stopPlayVoice:)]) {
            [self.delegate stopPlayVoice:self];
        }
    }
}
-(void)stopPlay
{
    if (self.status == PlayStatus_Loading) {
//        [self.downloader cancel];
//        self.downloader = nil;
        status = PlayStatus_Default;
        if ([self.delegate respondsToSelector:@selector(stopDownload:)]) {
            [self.delegate stopDownload:self];
        }
        return;
    }
    if (self.status == PlayStatus_Playing) {
        [self pausePlay];
        return;
    }
}
/*传话筒 试听 停止*/
- (void)airFoneStopPaly
{
    if (self.status == PlayStatus_Playing || self.status == PlayStatus_Pause) {
        status = PlayStatus_Stop;
        [[Player sharePlayer] stopPlayer];
    }
}

//播放点击
-(void)startPlay
{
    if (self.status == PlayStatus_Loading) {
//        [self.downloader cancel];
//        self.downloader = nil;
        status = PlayStatus_Default;
        if ([self.delegate respondsToSelector:@selector(stopDownload:)]) {
            [self.delegate stopDownload:self];
        }
        return;
    }
    if (self.status == PlayStatus_Playing) {
        [self pausePlay];
        return;
    }
    if (self.filePath && self.filePath.length > 0) {
        //如果有本地语音地址，直接播放
        [self playFilePathVoice:self.filePath];
        
    }else if (self.voiceUrl && self.voiceUrl.length > 0) {
        //如果来自网络，先下载再播放
//        if (!self.downloader) {
//            Downloader *downLoad = [[Downloader alloc] initWithString:self.voiceUrl delegate:self];
//            self.downloader = downLoad;
//            [downLoad release];
//        }
//        if ([self.downloader getDownloadFilePath]) {
//            //已经下载
//            NSString *downloadPath = [self.downloader getDownloadFilePath];
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            if (![fileManager fileExistsAtPath:[downloadPath stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]]) {
//                [VoiceConverter amrToWav:downloadPath];
//            }
//            [self playFilePathVoice:[downloadPath stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
//            return;
//        }
        status = PlayStatus_Loading;
        [Player sharePlayer].downloadUrl = self.voiceUrl;
//        [self.downloader download];
        if ([self.delegate respondsToSelector:@selector(startDownload:)]) {
            [self.delegate startDownload:self];
        }
    }
    
}
-(void)startPlay:(float)progress
{
    if (status == PlayStatus_Pause || status == PlayStatus_Playing) {
        if (progress == 1) {
            [[Player sharePlayer] stopPlayer];
            return;
        }
        NSTimeInterval playDuration = [[Player sharePlayer] playDuration:self.filePath];
        [[Player sharePlayer] playFilePathVoice:self.filePath currentTime:playDuration * progress];
    }
    
}



-(void)pausePlay
{
    [[Player sharePlayer] pausePlayer];
}
-(void)playFilePathVoice:(NSString *)file
{
    [Player sharePlayer].downloadUrl = nil;
    self.filePath = file;
    NSTimeInterval playCurrentTime = [[Player sharePlayer] playCurrentTime:self.filePath];
    [[Player sharePlayer] playFilePathVoice:file currentTime:playCurrentTime delegate:self];
    status = PlayStatus_Playing;
}

- (void)setPlayCurrentTime
{
    NSTimeInterval playCurrentTime = [[Player sharePlayer] playCurrentTime:self.filePath];
    NSTimeInterval playDuration = [[Player sharePlayer] playDuration:self.filePath];
    if ([self.delegate respondsToSelector:@selector(playDuration:currentTime:)]) {
        [self.delegate playDuration:playDuration currentTime:playCurrentTime];
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
#pragma mark -
#pragma mark DownloaderDelegate Methods
//-(void)downloader:(Downloader *)downloader didDownloadFile:(NSString *)path
//{
//    NSLog(@"down--%@",path);
//    
//    if ([KL_Util objectIsNull:path]) {
//        [KL_Util showToast:@"下载语音失败"];
//        if ([self.delegate respondsToSelector:@selector(downloadFail)]) {
//            [self.delegate downloadFail];
//        }
//        return;
//    }
//    if ([self.delegate respondsToSelector:@selector(downloadSuccess:)]) {
//        [self.delegate downloadSuccess:YES];
//    }
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if (![fileManager fileExistsAtPath:[path stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]]) {
//        [VoiceConverter amrToWav:path];
//    }
//    if (self.onlyDowndFile) {
//        status = PlayStatus_Default;
//        return;
//    }
//    if (![downloader.url isEqualToString:[Player sharePlayer].downloadUrl]) {
//        return;
//    }
//    [self playFilePathVoice:[path stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
//}
//-(void)downloader:(Downloader *)downloader didFailWithError:(NSString *)error
//{
//    status = PlayStatus_Default;
//    if ([self.delegate respondsToSelector:@selector(downloadSuccess:)]) {
//        [self.delegate downloadSuccess:NO];
//    }
//}
//
-(void)dealloc
{
//    [[Player sharePlayer] removeVoiceFile:self.filePath];
    [[Player sharePlayer] removeVoiceDelegate:self];
    
    _delegate = nil;
    self.voiceUrl = nil;
    self.filePath = nil;
    
//    if (self.downloader) {
//        [self.downloader cancel];
//    }
//    
//    self.downloader = nil;
//
}
-(void)playDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime
{
    CSLog(@"play duration--%f   currentime---%f",duration,currentTime);
    if ([self.delegate respondsToSelector:@selector(playDuration:currentTime:)]) {
        [self.delegate playDuration:duration currentTime:currentTime];
    }
    
}
-(void)playStop
{
    CSLog(@"playStop");
    status = PlayStatus_Stop;
    if ([self.delegate respondsToSelector:@selector(stopPlayVoice:)]) {
        [self.delegate stopPlayVoice:self];
    }
    if ([self.delegate respondsToSelector:@selector(stopPlayVoice:stopType:)]) {
        [self.delegate stopPlayVoice:self stopType:StopType_Nature];
    }
}
-(void)playerPause
{
    CSLog(@"playerPause");
    status = PlayStatus_Pause;
    if ([self.delegate respondsToSelector:@selector(pausePlayVoice:)]) {
        [self.delegate pausePlayVoice:self];
    }
    if ([self.delegate respondsToSelector:@selector(stopPlayVoice:stopType:)]) {
        [self.delegate stopPlayVoice:self stopType:StopType_Manual];
    }
}
-(void)playStart
{
    status = PlayStatus_Playing;
    if ([self.delegate respondsToSelector:@selector(startPlayVoice:)]) {
        [self.delegate startPlayVoice:self];
    }
}
@end
