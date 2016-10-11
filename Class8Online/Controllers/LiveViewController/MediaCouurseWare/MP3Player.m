//
//  MP3Player.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/7/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MP3Player.h"

@implementation MP3Player

- (void)dealloc
{
    self.audioPlayer = nil;
}

+ (id)SharePlayer
{
    static MP3Player * mp3Player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mp3Player = [[MP3Player alloc] init];
    });
    return mp3Player;
}

- (void)playMusicWithPath:(NSString *)path
{
    self.audioPlayer = nil;
    if (path.length <= 0) {
        return;
    }
    self.isPlayeing = NO;
    self.audioPlayer = [[AVAudioPlayer alloc]
                            initWithContentsOfURL:[NSURL fileURLWithPath:
                                                   path]
                            error:nil];


    self.audioPlayer.delegate = self;
//    [self.audioPlayer play];
}

- (void)play
{
   self.isPlayeing = [self.audioPlayer play];
}

- (void)pause
{
    [self.audioPlayer pause];

}
- (void)stop {
    [self.audioPlayer stop];
}
- (void)setPlayerCurrentTime:(float)time
{
    if (time >= 0 && time <= self.audioPlayer.duration) {
        [self.audioPlayer pause];
        self.audioPlayer.currentTime = time;
        [self.audioPlayer play];
    }
}

@end
