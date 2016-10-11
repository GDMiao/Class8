//
//  PlayerManager.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/11.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "PlayerManager.h"

@implementation PlayerManager


//=============================
// playerDelegate
//=============================
#pragma mark -
#pragma mark - playerDelegate
-(void)playDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime
{
    if ([self.delegate respondsToSelector:@selector(playDuration:currentTime:)]) {
        [self.delegate playDuration:duration currentTime:currentTime];
    }
}
-(void)playStop
{
    if ([self.delegate respondsToSelector:@selector(stopPlayVoice:)]) {
        [self.delegate stopPlayVoice:self];
    }
}
-(void)playerPause
{
    if ([self respondsToSelector:@selector(pausePlayVoice:)]) {
        [self.delegate pausePlayVoice:self];
    }
}
-(void)playStart
{
    if ([self.delegate respondsToSelector:@selector(startPlayVoice:)]) {
        [self.delegate startPlayVoice:self];
    }
}



- (void)setVoicePath:(NSString *)filePath callBack:(id)aDelegate
{
    self.delegate = aDelegate;
    if (filePath) {
        
    }
}

- (void)playVoice
{

}

- (void)stopVoice
{

}

@end
