//
//  RecordInputView.m
//  InPutBoxView
//
//  Created by chuliangliang on 15-1-6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
//由于时间紧迫 有可能不是非常完美 欢迎大家指正
//
//QQ: 949977202
//Email: chuliangliang300@sina.com

#import "RecordInputView.h"
#import "Recorder.h"
#define DelayTime 1.0f      //连续按触发录音的时间间隔
#define VoiceMaxTime 180.0 //录音最大时间180 秒
#define IOS7   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
typedef NS_ENUM(NSInteger, RecordStatus)
{
    RecordStatus_Default,   //按钮初始状态 (未录音)
    RecordStatus_Started,   //录音中
    RecordStatus_Out,       //松开取消发送
    RecordStatus_Cancel,    //取消发送
    RecordStatus_Finish,    //发送
};


@interface RecordInputView ()<RecorderDelegate>

@property (nonatomic, strong) UIButton *recordButton;       //录音按钮

@property (nonatomic, strong) UIImageView *recordAnimteImg; //录音动画
@property (nonatomic, strong) UIView *maskBackView;         //透明的录音背景 防止录音的时候 点击 和 操作
@property (nonatomic, strong) NSArray *images;              //动画图片数组

@property (nonatomic, assign) double lastTouchDownTime;     //最近一次按下时间
@property (nonatomic, assign) RecordStatus status;          //录音状态

@property (nonatomic, assign) id<RecordInputViewDelegate>delegate;
@end


@implementation RecordInputView
@synthesize recordButton;
@synthesize recordAnimteImg;
@synthesize maskBackView;
@synthesize lastTouchDownTime;
@synthesize status;
@synthesize images;
- (void)dealloc {
    self.delegate = nil;
}
- (id)initWithDelegate:(id)aDelegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.delegate = aDelegate;
        [self _initView];
    }
    return self;
}
- (void)_initView {
    self.backgroundColor = [UIColor clearColor];
    lastTouchDownTime = 0;
    status = RecordStatus_Default;
    images = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"灌水动画1"], [UIImage imageNamed:@"灌水动画2"],[UIImage imageNamed:@"灌水动画"],nil];

    
    //录音按钮
    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage2 = [UIImage imageNamed:@"灌水按住说话"];
    buttonImage2 = [buttonImage2 stretchableImageWithLeftCapWidth:floorf(buttonImage2.size.width/2) topCapHeight:floorf(buttonImage2.size.height/2)];
    UIImage *buttonImageSelect2 = [UIImage imageNamed:@"灌水按住说话_highlight"];
    buttonImageSelect2 = [buttonImageSelect2 stretchableImageWithLeftCapWidth:floorf(buttonImageSelect2.size.width/2) topCapHeight:floorf(buttonImageSelect2.size.height/2)];
    recordButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    recordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    recordButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [recordButton setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    [recordButton setBackgroundImage:buttonImageSelect2 forState:UIControlStateHighlighted];
    
    [recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(recordButtonTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [recordButton addTarget:self action:@selector(recordButtonTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
    
    [recordButton setTitle:@"按住开始录音" forState:UIControlStateNormal];
    [recordButton setTitleColor:[UIColor colorWithRed:0x55/255.0 green:0x55/255.0 blue:0x55/255.0 alpha:1] forState:UIControlStateNormal];
    
    [self addSubview:recordButton];

}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

//开始动画
- (void)startImgAnimate {
    if (!maskBackView) {
        
        UIWindow *keyWin = [UIApplication sharedApplication].delegate.window;

        maskBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, keyWin.bounds.size.width, keyWin.bounds.size.height)];
        maskBackView.backgroundColor = [UIColor clearColor];
        [keyWin addSubview:maskBackView];
        
        recordAnimteImg = [[UIImageView alloc] initWithFrame:CGRectMake((keyWin.bounds.size.width - 150) * 0.5,
                                      (keyWin.bounds.size.height - 150 ) * 0.5 ,
                                                                        150,
                                                                        150)];
        recordAnimteImg.backgroundColor = [UIColor clearColor];
        [maskBackView addSubview:recordAnimteImg];
    }

    
    recordAnimteImg.animationImages = images;
    recordAnimteImg.animationDuration = 0.6;
    recordAnimteImg.animationRepeatCount = 0;
    [recordAnimteImg startAnimating];
    
}

//结束
- (void)stopImgAnimate {
    
    [recordAnimteImg stopAnimating];
    if (maskBackView && maskBackView.superview != nil) {
        [maskBackView removeFromSuperview];
        maskBackView = nil;
    }
}

- (void)puseImgAnimate {
    
    [recordAnimteImg stopAnimating];
    recordAnimteImg.image = [UIImage imageNamed:@"灌水删除"];
    
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

//停止录音
- (void)stopRecord {
    [[Recorder shareRecorder] stopRecord];
}
////////////////////////////////////////////////////////////////////////////////////


//录音开始
-(void)recordButtonTouchDown
{
    lastTouchDownTime = [[NSDate date] timeIntervalSince1970];
    //延迟开始录音
    [self performSelector:@selector(startRecord) withObject:nil afterDelay:DelayTime];
}

//延迟开始录音
- (void)startRecord {
    status = RecordStatus_Started;
    //开始录音
    if (IOS7) {
        if ([[Recorder shareRecorder] canRecord]) {
            [Recorder shareRecorder].recorderDelegate = self;
            [[Recorder shareRecorder] startRecord];
            [self startImgAnimate];
            
        }else{
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            CFShow(CFBridgingRetain(infoDictionary));
            //app名称
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
            if (app_Name.length <= 0) {
                app_Name = [infoDictionary objectForKey:@"BundleDisplayName"];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"请在手机的设置->隐私->麦克风中允许\"%@\"使用该设备",app_Name] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else{
        [Recorder shareRecorder].recorderDelegate = self;
        [[Recorder shareRecorder] startRecord];
        [self startImgAnimate];
    }

}
//录音结束
-(void)recordButtonTouchUpInside
{
    double nowTime = [[NSDate date] timeIntervalSince1970];
    if (nowTime - lastTouchDownTime < DelayTime) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startRecord) object:nil];
        return;
    }

    if (RecordStatus_Started == status) {
        status = RecordStatus_Finish;
        [self stopImgAnimate];
        [self stopRecord];
    }
    
}

//外面松手会取消发送
-(void)recordButtonTouchDragOutside
{
    if (RecordStatus_Out != status) {
        status = RecordStatus_Out;
        [self puseImgAnimate];
    }
    
}
//回到录制
-(void)recordButtonTouchDragInside
{
    if (RecordStatus_Out == status) {
        status = RecordStatus_Started;
        [self startImgAnimate];
    }
}

//录音取消
-(void)recordButtonTouchUpOutside
{
    if (RecordStatus_Out == status) {
        status = RecordStatus_Cancel;
        [self stopImgAnimate];
        [self stopRecord];
    }
}
////////////////////////////////

#pragma mark-
#pragma mark- RecorderDelegate
//当前录音时间
-(void)recorderCurrentTime:(NSTimeInterval)currentTime
{
    int time = (int)currentTime + 1;
    //录音进行
    
    if (time >= VoiceMaxTime) {
        status = RecordStatus_Finish;
        [self stopImgAnimate];
        [self stopRecord];
    }
}
//录音结束
-(void)recorderStop:(NSString *)filePath voiceName:(NSString *)fileName duration:(NSTimeInterval)duration
{
    int time = (int)duration + 1;
    if (RecordStatus_Finish == status) {
        if (time > 1) {
            if ([self.delegate  respondsToSelector:@selector(recordInputView:recordFilePath:fileTime:)]) {
                [self.delegate recordInputView:self recordFilePath:filePath fileTime:time];
            }
        }else {
            
        }
    }
}
//开始录音
-(void)recorderStart {
    status = RecordStatus_Started;
}

@end
