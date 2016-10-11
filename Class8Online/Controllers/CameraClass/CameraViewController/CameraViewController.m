//
//  CameraViewController.m
//  Class8Camera
//
//  Created by chuliangliang on 15/7/18.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//  ///////////////////////////////////////////////////////

#import "CameraViewController.h"
#import "MediaCollection.h"
#include "PublishInterface.h"
#import "CNETModels.h"
#import "AppDelegate.h"

#import "CameraClientManager.h"

#define MIC 100
#define MASKBtn 101
#define CLOSEMask 102

const int alertTag_Del = 200;
const int alertTag_End = 201;
const int alertTag_Back = 202;
const int alertTag_teaLeave = 203;

@interface CameraViewController ()<CameraClientManagerDelegate>
{
    MediaCollection *mediaCollection;
    BOOL isPushVideo;
    UIImageView *cameraIcon;
    float brightness; //当前屏幕亮度
    
    MediaLevel videoLevel;
    VideoSize vSize;
    
    CGFloat lastRotate; //最后的旋转角度 初始化为0
}
@property (strong, nonatomic) NSString *pushaddr;
@property (strong, nonatomic) UIButton *flashBtn;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIButton *closeMaskViewBtn;

@end

@implementation CameraViewController
- (void)dealloc {
    if (mediaCollection) {
        [mediaCollection stopMediaCollection];
        mediaCollection = nil;
    }
    self.videoView = nil;
    self.bottomView = nil;
    self.pushaddr = nil;
    self.micBtn = nil;
    self.cameraStatusBtn = nil;
    self.tItleLabel = nil;
    if (_maskView) {
        [_maskView removeFromSuperview];
        _maskView = nil;
    }
    self.statusView = nil;;
    self.maskViewBtn = nil;
    self.buttonsView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _maskView.backgroundColor = [UIColor blackColor];
        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        [appdelegate.window addSubview:_maskView];
        
        self.closeMaskViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeMaskViewBtn.frame = CGRectMake(5, 0, 44, 44);
        self.closeMaskViewBtn.tag = CLOSEMask;
        [self.closeMaskViewBtn setImage:[UIImage imageNamed:@"返回箭头"] forState:UIControlStateNormal];
        [self.closeMaskViewBtn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
        [_maskView addSubview:self.closeMaskViewBtn];
        
    }
    return _maskView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    videoLevel = SMOOTHLEVEL;
    vSize = VideoSize_288_352;
    lastRotate = 0;
    
    //注册通知监听设备方向 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    
    self.maskView.hidden = YES;
    isPushVideo = NO;
    [self.titleView setTitleText:@"" withTitleStyle:CTitleStyle_Camera];
    brightness = [[UIScreen mainScreen] brightness];
    
    self.flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashBtn.frame = CGRectMake(self.titleView.titleRightButton.left - 44 - 5, 0, 44, 44);
    [self.flashBtn setImage:[UIImage imageNamed:@"闪光灯"] forState:UIControlStateNormal];
    [self.titleView addSubview:self.flashBtn];
    [self.flashBtn addTarget:self action:@selector(flashBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    // camera status Button set frame
    self.bottomView.top = self.videoView.bottom;
    self.bottomView.left = 0;
    self.bottomView.height = self.allContentView.height - self.videoView.height;
    self.bottomView.width = self.allContentView.width;
    
    
    CGFloat viewsAllHieght = self.bottomView.height - self.buttonsView.height;
    
    self.cameraStatusBtn.left = (viewsAllHieght - self.cameraStatusBtn.width) * 0.5;
    self.cameraStatusBtn.userInteractionEnabled = NO;
    self.cameraStatusBtn.adjustsImageWhenDisabled = NO;
    [self updateStatusBtnImg];
    
    
    self.statusView.frame = CGRectMake((self.bottomView.width-viewsAllHieght)*0.5, 0, viewsAllHieght, viewsAllHieght);
    self.tItleLabel.frame = CGRectMake(0, 0, self.statusView.width, 17);
    
    
    self.cameraStatusBtn.top = (viewsAllHieght - self.cameraStatusBtn.height - 10 - self.tItleLabel.height) * 0.5;
    self.tItleLabel.top = self.cameraStatusBtn.bottom + 10;
    
    cameraIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.cameraStatusBtn.left + (self.cameraStatusBtn.width - 26) * 0.5, (self.cameraStatusBtn.height - 27) * 0.5 + self.cameraStatusBtn.top, 26, 27)];
    cameraIcon.image = [UIImage imageNamed:@"摄像头icon"];
    cameraIcon.center = self.cameraStatusBtn.center;
    [self.cameraStatusBtn.superview addSubview:cameraIcon];

    
    
    //tools View buttons Set Frame
    self.micBtn.left = 30;
    self.micBtn.tag = MIC;
    self.micBtn.top = self.cameraStatusBtn.top + (self.cameraStatusBtn.height - self.micBtn.height) * 0.5;
    [self updateMicIcon:YES];
    
    
    self.maskViewBtn.right = self.allContentView.width-30;
    self.maskViewBtn.top = self.micBtn.top;
    self.maskViewBtn.tag = MASKBtn;
    [self.maskViewBtn setImage:[UIImage imageNamed:@"关闭屏幕"] forState:UIControlStateNormal];

    //创建动画
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    [opacityAnimation setDuration:0.9];
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    opacityAnimation.autoreverses = YES;
    opacityAnimation.cumulative = NO;
    opacityAnimation.removedOnCompletion = NO; //No Remove
    opacityAnimation.repeatCount = FLT_MAX;
    [cameraIcon.layer addAnimation:opacityAnimation forKey:@"AnimatedKey"];
    [cameraIcon stopAnimating];
    cameraIcon.layer.speed = 0.0;

    
    //初始化视频预览页
    InitLibEnv((__bridge HWND)(self.videoView),8,32000);
    mediaCollection = (__bridge MediaCollection *)getMediaMediaCollection();
    
    self.buttonsView.layer.borderColor = [UIColor purpleColor].CGColor;
    self.buttonsView.layer.borderWidth =1.0;
    CGFloat oneItemWidth = 40;
    NSInteger items = self.buttonsView.subviews.count;
    CGFloat btn_x = (self.buttonsView.width - oneItemWidth * items) / (items + 1);
    [self.buttonsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = (UIButton *)obj;
        btn.adjustsImageWhenDisabled = NO;
        btn.left = btn_x * (idx + 1) +  oneItemWidth * idx;
        
    }];
}

//通知监听设备方向 <目前弃用>
-(void)deviceOrientationDidChange:(NSObject*)sender{
    mediaCollection = (__bridge MediaCollection *)getMediaMediaCollection();
    if (mediaCollection) {
        [mediaCollection.video refreshCameraDevicePortait];
    }
    //更新UI
    CGFloat nowRotate = acosf(self.micBtn.transform.a);
    CSLog(@"麦克风当前角度: %f",lastRotate );
    
   UIDeviceOrientation devOrientainon = [[UIDevice currentDevice] orientation];
    switch (devOrientainon) {
        case UIDeviceOrientationPortrait:
        {
            CSLog(@"竖屏");
            UIButton *leftBtn = [self.titleView titleLeftButton];
            UIButton *rightBtn = [self.titleView titleRightButton];
            self.micBtn.transform = CGAffineTransformIdentity;
            self.flashBtn.transform = CGAffineTransformIdentity;
            self.statusView.transform = CGAffineTransformIdentity;
            leftBtn.transform = CGAffineTransformIdentity;
            rightBtn.transform = CGAffineTransformIdentity;
            
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            CSLog(@"倒立");
            UIButton *leftBtn = [self.titleView titleLeftButton];
            UIButton *rightBtn = [self.titleView titleRightButton];
            self.micBtn.transform = CGAffineTransformIdentity;
            self.flashBtn.transform = CGAffineTransformIdentity;
            self.statusView.transform = CGAffineTransformIdentity;
            leftBtn.transform = CGAffineTransformIdentity;
            rightBtn.transform = CGAffineTransformIdentity;
            
            
            self.micBtn.transform = CGAffineTransformRotate(self.micBtn.transform, M_PI);
            self.flashBtn.transform = CGAffineTransformRotate(self.flashBtn.transform, M_PI);
            self.statusView.transform = CGAffineTransformRotate(self.statusView.transform, M_PI);
            leftBtn.transform = CGAffineTransformRotate(leftBtn.transform, M_PI);
            rightBtn.transform = CGAffineTransformRotate(rightBtn.transform, M_PI);


        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            CSLog(@"左横屏");

            UIButton *leftBtn = [self.titleView titleLeftButton];
            UIButton *rightBtn = [self.titleView titleRightButton];
            self.micBtn.transform = CGAffineTransformIdentity;
            self.flashBtn.transform = CGAffineTransformIdentity;
            self.statusView.transform = CGAffineTransformIdentity;
            leftBtn.transform = CGAffineTransformIdentity;
            rightBtn.transform = CGAffineTransformIdentity;

            self.micBtn.transform = CGAffineTransformRotate(self.micBtn.transform, M_PI_2);
            self.flashBtn.transform = CGAffineTransformRotate(self.flashBtn.transform, M_PI_2);
            self.statusView.transform = CGAffineTransformRotate(self.statusView.transform, M_PI_2);
            leftBtn.transform = CGAffineTransformRotate(leftBtn.transform, M_PI_2);
            rightBtn.transform = CGAffineTransformRotate(rightBtn.transform, M_PI_2);

        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            CSLog(@"右横屏");
            UIButton *leftBtn = [self.titleView titleLeftButton];
            UIButton *rightBtn = [self.titleView titleRightButton];
            self.micBtn.transform = CGAffineTransformIdentity;
            self.flashBtn.transform = CGAffineTransformIdentity;
            self.statusView.transform = CGAffineTransformIdentity;
            leftBtn.transform = CGAffineTransformIdentity;
            rightBtn.transform = CGAffineTransformIdentity;
            
            self.micBtn.transform = CGAffineTransformRotate(self.micBtn.transform,-M_PI_2);
            self.flashBtn.transform = CGAffineTransformRotate(self.flashBtn.transform,-M_PI_2);
            self.statusView.transform = CGAffineTransformRotate(self.statusView.transform,-M_PI_2);
            leftBtn.transform = CGAffineTransformRotate(leftBtn.transform,-M_PI_2);
            rightBtn.transform = CGAffineTransformRotate(rightBtn.transform,-M_PI_2);


        }
            break;
        default:
            break;
    }
}

- (void)leftClicked:(TitleView *)view
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:CSLocalizedString(@"class8_VC_cam_Course_not_over_whether_return")
                                                  delegate:self
                                         cancelButtonTitle:CSLocalizedString(@"class8_VC_cam_no")
                                         otherButtonTitles:CSLocalizedString(@"class8_VC_cam_yes"), nil];
    alert.tag = alertTag_Back;
    [alert show];

}
- (void)rightClicked:(TitleView *)view {
    [self switchCamera];
}

- (void)flashBtnAction {
    [self switchFlash];
}

- (void)updateStatusBtnImg
{
    if (isPushVideo) {
        [self.cameraStatusBtn setImage:[UIImage imageNamed:@"摄像"] forState:UIControlStateNormal];
        
        self.tItleLabel.text = CSLocalizedString(@"class8_VC_cam_Live_to_enable");
        self.tItleLabel.textColor = [UIColor colorWithRed:23/255.0 green:95/255.0 blue:195/255.0 alpha:1];
        
        //开始动画
        cameraIcon.layer.speed = 1.0;
        cameraIcon.layer.beginTime = 0.0;
        CFTimeInterval pausedTime = [cameraIcon.layer timeOffset];
        CFTimeInterval timeSincePause = [cameraIcon.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        cameraIcon.layer.beginTime = timeSincePause;

    }else {
        //停止动画
        CFTimeInterval pausedTime = [cameraIcon.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        cameraIcon.layer.speed = 0.0;
        cameraIcon.layer.timeOffset = pausedTime;

        [self.cameraStatusBtn setImage:[UIImage imageNamed:@"摄像灰"] forState:UIControlStateNormal];
        self.tItleLabel.text = CSLocalizedString(@"class8_VC_cam_Live_is_not_enabled");
        self.tItleLabel.textColor = [UIColor colorWithWhite:123/255.0 alpha:1];
    }
}

- (void)updateMicIcon:(BOOL) on
{
    if (on) {
        [self.micBtn setImage:[UIImage imageNamed:@"声音开启"] forState:UIControlStateNormal];
        
    }else {
        [self.micBtn setImage:[UIImage imageNamed:@"关闭声音"] forState:UIControlStateNormal];
    }
}

#pragma mark-
#pragma mark- 开始音视频传输
- (void)startPushRtmpStream:(NSString *)rtmpUrl {
    
    if (isPushVideo && ![self.pushaddr isEqualToString:rtmpUrl] && [Utils objectIsNotNull:self.pushaddr]) {
        [self stopPushRtmpStream];
    }
    CSLog(@"\n旧地址:%@\n new地址: %@",self.pushaddr,rtmpUrl);
    self.pushaddr = rtmpUrl;
    const char *szURl = [self.pushaddr UTF8String];//  "rtmp://10.2.2.234:1935/live/cll123|@|udp://10.2.2.234:36556/live/20000_10000_10009097";
    int nStreamType = SOURCECAMERA;
    MediaLevel m = videoLevel;

    MasterSlave ms;
    if ([Utils hasAudioUrl:self.pushaddr]) {
        nStreamType = SOURCECAMERA|SOURCEDEVAUDIO;
        ms = MAINCAMERA;
        
        [self.buttonsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = (UIButton *)obj;
            btn.enabled = YES;
        }];

    }else {
        [self.buttonsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = (UIButton *)obj;
            btn.enabled = NO;
        }];

        nStreamType = SOURCECAMERA;
        ms = SUBCAMERA;
        vSize = VideoSize_288_352;
    }
    
    [mediaCollection.video changeSessionPreset:vSize];
    struct PublishParam param;
    param.VU[0].nSelectCameraID = 0;
    param.VU[0].nType = SOURCECAMERA|SOURCEDEVAUDIO;
    param.nVUNum = 1;
    param.ml = m;
    param.ms = ms;
    rtmpPushStreamToServerBegin(szURl,nStreamType,param);
    
    isPushVideo = YES;
    [self updateStatusBtnImg];
}

#pragma mark-
#pragma mark- 停止音视频传输
- (void)stopPushRtmpStream
{
    CSLog(@"停止音视频传输 : %@",self.pushaddr);
    const char *szURl = [self.pushaddr UTF8String]; //"rtmp://10.2.2.234:1935/live/cll123|@|udp://10.2.2.234:36556/live/20000_10000_10009097";
    rtmpPushStreamToServerEnd(szURl);
    isPushVideo = NO;
    [self updateStatusBtnImg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];  //开启设备方向监听<目前弃用>
    [CAMERACLIENTMANAGER addMobiDidConnectChooseDelegate:self];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications]; //关闭设备方向监听<目前弃用>
    [CAMERACLIENTMANAGER delMobiDidConnectChooseDelegate];
}

#pragma mark - button Actions
- (IBAction)changeVideoSize:(UIButton *)sender {
    
    videoLevel = SMOOTHLEVEL;
    vSize = VideoSize_288_352;
    switch (sender.tag) {
        case 100:
        {
            
            //标清
            videoLevel = SMOOTHLEVEL;
            vSize = VideoSize_288_352;
        }
            break;
        case 101:
        {
            //高清
            videoLevel = STANDARRDLEVEL;
            vSize = VideoSize_480_640;
        }
            break;
        case 102:
        {
            //超清
            videoLevel = HIGHLEVEL;
            vSize = VideoSize_720_1280;
        }
            break;
            
        default:
            break;
    }
    const char *szURl = [self.pushaddr UTF8String];
    rtmpPushStreamToServerChangeML(szURl, videoLevel);
    
    mediaCollection = (__bridge MediaCollection *)getMediaMediaCollection();
    [mediaCollection.video changeSessionPreset:vSize];

}

- (IBAction)buttonActions:(UIButton *)sender {
    NSInteger buttonTag = sender.tag;
    switch (buttonTag) {
        case MIC:
        {
            //麦克风开启/关闭
            [self switchMic];
        }
            break;
        case MASKBtn:
        {
            //显示遮罩
            self.maskView.hidden = NO;
            brightness = [[UIScreen mainScreen] brightness];
            [[UIScreen mainScreen] setBrightness:0.0];
        }
            break;
        case CLOSEMask:
        {
            //隐藏遮罩
            self.maskView.hidden = YES;
            [[UIScreen mainScreen] setBrightness:brightness];
        }
            break;
        default:
            break;
    }
}

/**
 * 返回
 **/
- (void)goBack {
    CSLog(@"发送主动停止视频传输协议");
    [CAMERACLIENTMANAGER mobileCameraOffWithTeaId:self.tid];

    if (_maskView && _maskView.superview) {
        _maskView.hidden = YES;
        [[UIScreen mainScreen] setBrightness:brightness];
    }
    UninitLibEnv();
    [mediaCollection stopMediaCollection];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *麦克风关闭/开启
 **/
- (void)switchMic {
    if (mediaCollection.audio.isMicruning) {
        [mediaCollection.audio stopRecord];
        [self updateMicIcon:NO];
    }else {
        [mediaCollection.audio startRecord];
        [self updateMicIcon:YES];
    }
}

/**
 * 闪光灯 开启/关闭
 **/
- (void)switchFlash {
    mediaCollection.video.capTureFlashOn = !mediaCollection.video.capTureFlashOn;
}

/**
 * 摄像头切换
 **/
- (void)switchCamera {
    mediaCollection.video.swichCaptureBack = !mediaCollection.video.swichCaptureBack;
    self.flashBtn.hidden = !mediaCollection.video.swichCaptureBack;
}


/**
 *镜头拉近
 **/
- (void)cameraNearly {
    mediaCollection.video.cameraAddNearly = 0.3;
}

/**
 * 镜头拉远
 **/
- (void)cameraPullaway {
    mediaCollection.video.cameraPullAway= 0.3;
}


#pragma mark-
#pragma mark - CameraClientManagerDelegate
//成功后的回调
- (void) cameraClientManagerFinish:(id)value cNetworkRecType:(int) pType
{
    switch (pType) {
        case CCP_ChooseMobile:
        {
            ChooseMobileMdoel *chooseMobiModel = (ChooseMobileMdoel *)value;
            self.tid = chooseMobiModel.tid;
            switch (chooseMobiModel.chooseStyle) {
                case ChooseMobiStyle_STOP:
                {
                    [self stopPushRtmpStream];
                }
                    break;
                case ChooseMobiStyle_CHOOSE:
                {
                    CSLog(@"小助手推流地址：%@",chooseMobiModel.pushaddr);
                    [self startPushRtmpStream:chooseMobiModel.pushaddr];
                }
                    break;
                default:
                    break;
            }
            [CAMERACLIENTMANAGER returnChooseAt:chooseMobiModel];
        }
            break;
        case CCP_Kick:
        {
            KickModel *kModel = (KickModel *)value;
            switch (kModel.kickStyle) {
                case KickStyle_DELETE_DEVICE:
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:CSLocalizedString(@"class8_VC_cam_device_deleted")
                                                                  delegate:self
                                                         cancelButtonTitle:CSLocalizedString(@"class8_VC_cam_end_sure")
                                                         otherButtonTitles:nil, nil];
                    alert.tag = alertTag_Del;
                    [alert show];

                }
                    break;
                case KickStyle_CLASS_END:
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:CSLocalizedString(@"class8_VC_cam_end_of_course")
                                                                  delegate:self
                                                         cancelButtonTitle:CSLocalizedString(@"class8_VC_cam_end_sure")
                                                         otherButtonTitles:nil, nil];
                    alert.tag = alertTag_End;
                    [alert show];

                }
                    break;
                case KickStyle_MOBILE_OFF:
                {
                
                }
                    break;
                case KickStyle_TEACHER_LEAVE:
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:CSLocalizedString(@"class8_VC_cam_tea_leave")
                                                                  delegate:self
                                                         cancelButtonTitle:CSLocalizedString(@"class8_VC_cam_end_sure")
                                                         otherButtonTitles:nil, nil];
                    alert.tag = alertTag_teaLeave;
                    [alert show];

                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}
//失败后的回调
- (void) cameraClientManagerFaild:(id)value cNetworkRecType:(int) pType
{
    
}

#pragma mark-
#pragma mark - 连接断开 与服务器断开
- (void) cameraClientManagerDiddisConnectServer:(BOOL)isLoginServer
{
    if (!isLoginServer) {
        [Utils showToast:@"与服务器连接中断"];
        if (_maskView && _maskView.superview) {
            _maskView.hidden = YES;
            [[UIScreen mainScreen] setBrightness:brightness];
        }
        UninitLibEnv();
        [mediaCollection stopMediaCollection];
        [self.navigationController popViewControllerAnimated:NO];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case alertTag_Del:
        case alertTag_End:
        case alertTag_teaLeave:
        {
            [self goBack];
        }
            break;
        case alertTag_Back:
        {
            if (buttonIndex == alertView.cancelButtonIndex) {
                return;
            }
            [self goBack];
        }
            break;
        default:
            break;
    }
}
@end
