//
//  MediaPreView.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MediaPreView.h"
#import "CLPlayer.h"

@interface MediaPreView ()
@property (strong ,nonatomic) CLPlayer *mediaPlayer;
@property (strong ,nonatomic) UILabel *titleLabel;
@end

@implementation MediaPreView

- (void)dealloc {
    if (_audioPath) {
        _audioPath = nil;
    }
    self.mediaPlayer = nil;
    self.titleLabel = nil;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews
{
    
    self.backgroundColor = [UIColor blackColor];
    
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14.0];
    self.titleLabel.backgroundColor = [UIColor blackColor];
    self.titleLabel.text = CSLocalizedString(@"live_VC_courseWare_Media_loading");
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.titleLabel];
    
    
    if (self.audioPath && self.audioPath.length > 0) {
        [self resetMdeiaPlay];
    }
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"audioPlayIcon.gif" ofType:nil];
//    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
//    imageView = [[SCGIFImageView alloc] initWithGIFData:data];
//    imageView.start = NO;
//    imageView.hidden = YES;
//    imageView.frame  = self.bounds;
//    [self addSubview:imageView];
    


}

/*重置播放器*/
- (void)resetMdeiaPlay
{
    if (self.mediaPlayer) {
        [self.mediaPlayer stop];
        [self.mediaPlayer removeFromSuperview];
        self.mediaPlayer = nil;
    }
    self.mediaPlayer = [[CLPlayer alloc] initWithFrame:self.bounds videoUrl:[NSURL fileURLWithPath:self.audioPath]];
    self.mediaPlayer.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:self.mediaPlayer atIndex:0];

}
- (void)setAudioPath:(NSString *)audioPath {
    if (_audioPath != audioPath) {
        _audioPath = nil;
        _audioPath = [audioPath copy];
    }
    
    BOOL fileExist = [FILECACHEMANAGER fileExisted:[audioPath lastPathComponent] fileType:FileType_Audio];
    self.titleLabel.hidden = fileExist;
    if (fileExist) {
        //存在
//        self.mediaPlayer.movieUrl = [NSURL fileURLWithPath:audioPath];
        [self resetMdeiaPlay];
    }
    
}
- (void)showTitle:(NSString *)text
{
    self.titleLabel.text = text;
}

- (void)stop
{
    [self.mediaPlayer stop];
}
- (void)play
{
    [self.mediaPlayer play];
}
- (void)pause
{
    [self.mediaPlayer pause];
}
- (void)playAtTime:(float)time
{
    [self.mediaPlayer playAtTime:time];
}

@end
