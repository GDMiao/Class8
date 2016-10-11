//
//  VoicePlayerView.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/11.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "VoicePlayerView.h"
#import "PlayVoice.h"

@interface VoicePlayerView ()<PlayVoiceDelegate>
{
    UIImageView *backImgView;
    UIImageView *playIconView;
    UILabel* contentLabel;
    UIButton *playButton;
}
@property (nonatomic,retain) PlayVoice *playVoice;
@end

@implementation VoicePlayerView
@synthesize ownerType;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 90, 40)];
    if (self) {
        ownerType = ChatVoiceOwnerType_Me;
        [self _initView];
    }
    return self;
}

- (void)dealloc {
    self.playVoice.delegate = nil;
}
- (void)_initView {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationStopPlayAnimate) name:StopPlayVoiceAnimate object:nil];
    
    
    //背景图片
    backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    UIImage *nomalImg = nil;
    if (ChatVoiceOwnerType_Me == ownerType) {
        //自己
        nomalImg = [UIImage imageNamed:@"自己对话背景"];
        nomalImg = [nomalImg resizableImageWithCapInsets:UIEdgeInsetsMake(25.0f, 15.0f, 15.0f, 25.0f)];
    }else if (ChatVoiceOwnerType_Other == ownerType) {
        //别人
        nomalImg = [UIImage imageNamed:@"别人对话背景"];
        nomalImg = [nomalImg resizableImageWithCapInsets:UIEdgeInsetsMake(25.0f, 25.0f, 15.0f, 15.0f)];
        
    }
    [backImgView setImage:nomalImg];
    [self addSubview:backImgView];
    
    
    
    //播放 标志图标
    playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(30, (self.height - 12) * 0.5, 11, 12)];
    UIImage *iconNomalImg = nil;
    if (ChatVoiceOwnerType_Me == ownerType) {
        iconNomalImg = [UIImage imageNamed:@"传话筒播放自己"];
        
    }else if (ChatVoiceOwnerType_Other == ownerType) {
        iconNomalImg = [UIImage imageNamed:@"传话筒播放别人"];
    }
    playIconView.image = iconNomalImg;
    [self addSubview:playIconView];
    
    
    
    //语音时长
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(playIconView.right + 5, (self.height - 13) * 0.5, 45, 13)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.text = @"";
    contentLabel.font = [UIFont systemFontOfSize:12.0f];
    if (ChatVoiceOwnerType_Me == ownerType) {
        contentLabel.textColor = [UIColor whiteColor];
    }else if (ChatVoiceOwnerType_Other == ownerType) {
        contentLabel.textColor = [UIColor blackColor];
    }
    [self addSubview:contentLabel];
    
    
    //播放按钮
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.adjustsImageWhenHighlighted = NO;
    playButton.frame = CGRectMake(0, 0, self.width, self.height);
    [playButton addTarget:self action:@selector(playVoiceAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playButton];
    
    //语音播放器
     self.playVoice = [[PlayVoice alloc] init];

}

//获取动画素材图片
- (NSArray *)getIconImgAnimateImgArr {
    
    if (ChatVoiceOwnerType_Me == ownerType) {
        //自己
        NSArray *tempArr = @[[UIImage imageNamed:@"自己语音对话1"],[UIImage imageNamed:@"自己语音对话2"],[UIImage imageNamed:@"自己语音对话3"]];
        return tempArr;
    }else if (ChatVoiceOwnerType_Other == ownerType) {
        //他人
        NSArray *tempArr = @[[UIImage imageNamed:@"别人语音对话1"],[UIImage imageNamed:@"别人语音对话2"],[UIImage imageNamed:@"别人语音对话3"]];
        return tempArr;
    }
    return nil;
}


//播放语音
- (void)playVoiceAction {
    CSLog(@"播放语音");
    PlayStatus playStatus = self.playVoice.status;
    if (playStatus == PlayStatus_Playing) {
        [self.playVoice airFoneStopPaly];
    }else {
        [self.playVoice airFoneStopPaly];
        [self.playVoice startPlay];
    }
}


- (void)updateVoicePath:(NSString *)path voiceShowTitle:(NSString *)title
{
    self.filePath = path;
    [self resetViewWithTitle:title];
    [self.playVoice setVoiceUrl:self.filePath delegate:self];
}


//重新布局
- (void)resetViewWithTitle:(NSString *)title {
    
    if (ChatVoiceOwnerType_Me == ownerType) {
        //自己
        UIImage *nomalImg = [UIImage imageNamed:@"自己对话背景"];
        nomalImg = [nomalImg resizableImageWithCapInsets:UIEdgeInsetsMake(25.0f, 15.0f, 15.0f, 25.0f)];
        [backImgView setImage:nomalImg];
        backImgView.frame = CGRectMake(0, 0, self.width, self.height);
        
        //ICON
        playIconView.frame = CGRectMake(15, (self.height - 12) * 0.5, 11, 12);
        playIconView.image = [UIImage imageNamed:@"自己语音对话"];
        
        
        //语音时长
        contentLabel.frame = CGRectMake(0, 0, 40, 15);
        contentLabel.textAlignment = NSTextAlignmentRight;
        contentLabel.text = title;
        [contentLabel sizeToFit];
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.top = (self.height - contentLabel.height ) * 0.5;
        contentLabel.left = playIconView.right + 5;

        playButton.frame = CGRectMake(0, 0, self.width, self.height);
        
        
    }else if (ChatVoiceOwnerType_Other == ownerType) {
        //他人
        UIImage *nomalImg = [UIImage imageNamed:@"别人对话背景"];
        nomalImg = [nomalImg resizableImageWithCapInsets:UIEdgeInsetsMake(25.0f, 25.0f, 15.0f, 15.0f)];
        [backImgView setImage:nomalImg];
        backImgView.frame = CGRectMake(0, 0, self.width, self.height);
        
        //ICON
        playIconView.frame = CGRectMake(30, (self.height - 12) * 0.5, 11, 12);
        playIconView.image = [UIImage imageNamed:@"别人语音对话"];
        
        
        //语音时长
        contentLabel.frame = CGRectMake(playIconView.right + 5, 0, 40, 15);
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.text = title;
        [contentLabel sizeToFit];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.top = (self.height - contentLabel.height ) * 0.5;
        
        playButton.frame = CGRectMake(0, 0, self.width, self.height);

    }
}




//=================================
// 动画
//=================================
//开始播放动画
- (void)playImgstartAnimate {
    
    NSArray *imgArr = [self getIconImgAnimateImgArr];
    [playIconView setAnimationImages:imgArr];
    [playIconView setAnimationDuration:0.5];
    [playIconView startAnimating];
}
//停止播放动画
- (void)stopImgAnimate {
    [playIconView stopAnimating];
    UIImage *iconNomalImg = nil;
    if (ChatVoiceOwnerType_Me == ownerType) {
        iconNomalImg = [UIImage imageNamed:@"自己语音对话"];
    }else if (ChatVoiceOwnerType_Other == ownerType) {
        iconNomalImg = [UIImage imageNamed:@"别人语音对话"];
    }
    playIconView.image = iconNomalImg;
}



//=================================
// PlayViewDelegate
//=================================
#pragma mark - 
#pragma mark - PlayViewDelegate
//播放中
-(void)playDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime
{
//    CSLog(@"播放中");
}

//开始播放
-(void)startPlayVoice:(PlayVoice *)aPlayVoice
{
//    CSLog(@"开始播放");
    [self playImgstartAnimate];
}

//停止播放
-(void)stopPlayVoice:(PlayVoice *)aPlayVoice
{
    [self stopImgAnimate];
//    CSLog(@"停止播放");
}

@end
