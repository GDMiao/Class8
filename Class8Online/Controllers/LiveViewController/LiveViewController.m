//
//  LiveViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "LiveViewController.h"
#import "HMSegmentedControl.h"
#import "HFBrowserView.h"
#import "RoomWithChatView.h"
#import "CNetworkManager.h"
#import "KeepOnLineUtils.h"
#import "SignOutViewController.h"
#import "CourseWareListView.h"
#import "StudentListView.h"
#import "UIImage+Resize.h"

#define TopContenView_Top 0
#define TopContenView_Height (SCREENWIDTH / 4 * 3)

#define DefaultSelectedIndex 0
#define SegmentedControlHeight 38

#define TOOLSView_Height 44.0f

const int AlertViewTag_Sigin = 1001;            //签到提示窗
const int AlertViewTag_Siginout = 1002;         //签退提示窗
const int AlertViewTag_SiginNotCamp = 1003;     //签到提示窗 没有摄像头或者相册

const int liveSegmentRoomChatIndex = 0;         //群聊窗口在选择控件的索引值
const int liveSegmentCourseWareIndex = 1;       //课件列表窗口在选择控件的索引值
const int liveSegmentStudenListIndex = 2;       //用户列表窗口在选择控件的索引值


typedef enum {
    ClassState_Nomal = 0,
    ClassState_ClassBegin,
    ClassState_ClassOver,
    ClassState_ReConnect,
}ClassState;



@interface LiveViewController ()<HFBrowserViewSourceDelegate,HFBrowserViewDelegate,RoomWithChatViewDelegate,CNetworkManagerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    BOOL devicePortrait;
    BOOL showToolsView;
    BOOL isSigin;                                                       //是否是签到照相
    
    int currentClassModel;
}
@property (strong, nonatomic) NSString *roomName,                       //当前显示课堂名称
*teaMediaSrcUrl;
@property (assign, nonatomic) long long cid,classid,askStuUid;          //askStuUid 被提问的学生UID 当没有被提问的学生时此属性为-1
@property (assign, nonatomic) int teaVideoId,                           /*教师视频路数*/
segmentCurrentIndex;                                                    /*选择控件当前显示的索引值*/

@property (assign, nonatomic) ClassState crState;                       // 课堂状态


@property (strong, nonatomic) HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) HFBrowserView *browserView;

@property (strong, nonatomic) RoomWithChatView *roomChatView;
@property (strong, nonatomic) CourseWareListView *courseWareList;
@property (strong, nonatomic) StudentListView *stuListView;


@property (strong, nonatomic) UIView *toolsView;                        //底部感工具栏
@property (strong, nonatomic) UIButton *fullScreenButton;               //全屏/退出全屏 按钮

@property (strong, nonatomic) NSMutableDictionary *userListDic;         //用户列表
@property (strong, nonatomic) NSMutableDictionary *userVideoListDic;    //用户视频列表

@end

@implementation LiveViewController
@synthesize crState;
@synthesize segmentCurrentIndex;
-(id)initWithRoomName:(NSString *)roomName coureid:(long long)cid classid:(long long)classid
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.roomName = roomName;
        self.cid = cid;
        self.classid = classid;
    }
    return self;
}
- (void)dealloc
{
    ClassRoomLog(@"在线课堂销毁...");
    self.roomName = nil;
    self.teaMediaSrcUrl = nil;
    self.topContenView = nil;
    self.bottomView = nil;
    self.segmentedControl = nil;
    self.roomChatView = nil;
    self.toolsView = nil;
    self.fullScreenButton = nil;
    self.userListDic = nil;
    self.userVideoListDic = nil;
    CSLog(@"topContenView == %@",self.topContenView);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self hasKeyBoradWillSHowNotification:YES];

    
//    if (!isSigin) {
//        [self inToClassRoom];
//    }

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ClassRoomLog(@"在线课堂 == > 延迟禁用设备锁屏");
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    });
    [self showClassAlert];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    [self hasKeyBoradWillSHowNotification:NO];
}

/**
 * 是否监听键盘弹出通知
 **/
- (void)hasKeyBoradWillSHowNotification:(BOOL)obs
{
    int currentIndex = [self.browserView getCurrentPage];
    if (currentIndex == liveSegmentRoomChatIndex) {
        //群聊
        self.roomChatView.inPutTextView.hasShowKeyBorad = obs;
        self.stuListView.uChatbgView.uChatView.inPutTextView.hasShowKeyBorad = NO;
    }else if (currentIndex == liveSegmentStudenListIndex){
        //在线用户列表
        self.roomChatView.inPutTextView.hasShowKeyBorad = NO;
        self.stuListView.uChatbgView.uChatView.inPutTextView.hasShowKeyBorad = obs;
    }
}

/**
 *隐藏键盘
 **/
- (void)hiddenKeyBorad
{
    int currentIndex = [self.browserView getCurrentPage];
    if (currentIndex == liveSegmentRoomChatIndex) {
        //群聊
        if ([self.roomChatView.inPutTextView isEditing]) {
            [self.roomChatView.inPutTextView hiddenAll];
        }
    }else if (currentIndex == liveSegmentStudenListIndex){
        //在线用户列表
        if ([self.stuListView.uChatbgView.uChatView.inPutTextView isEditing]) {
            [self.stuListView.uChatbgView.uChatView.inPutTextView hiddenAll];
        }
    }
}

//====================
// 获取课堂
//===================
//TODO: 程序退到后台
- (void) applicationWillResignActive: (NSNotification *)notification
{
//    ClassRoomLog(@"在线课堂断线重新连接 == >>进入后台");
//    if (self.topContenView.video) {
//        [self.topContenView.video stop];
//    }
//    CNETWORKMANAGER.hasNotNetWork = YES;
//    [CNETWORKMANAGER userLeaveCourse:self.cid userid:[UserAccount shareInstance].uid responseDelegate:self];
//    [CNETWORKMANAGER removeClassInfoDelegate];
}
/**
 * 程序进入前台
 **/
- (void) applicationWillBecame: (NSNotification *)notification {
//    ClassRoomLog(@"在线课堂断线重新连接 == >>回到前台");
//    [self.userListDic removeAllObjects];
//    
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
//    crState = ClassState_ReConnect;
//    [self showClassAlert];
}

/**
 *用户在其他地方被登录
 **/
- (void)userLoginWithOtherLocation {
    [self.topContenView classOver];
    if (!devicePortrait) {
        [self fullScreenAction:nil];
        return;
    }
    [CNETWORKMANAGER removeClassInfoDelegate]; //移除课堂相关信息监听
    [self.navigationController popViewControllerAnimated:YES];

}

//网络重新连接通知并登录成功
- (void)didConnectNotification {
    ClassRoomLog(@"在线课堂断线重新连接并且成功登录");
    [CNETWORKMANAGER userIntoClassRoom:self.cid classID:self.classid responseDelegate:self];
    [CNETWORKMANAGER addClassInfoDelegate:self]; //课堂相关信息监听
}

- (void)inToClassRoom {
    [self showHUD:nil];
    [CNETWORKMANAGER userIntoClassRoom:self.cid classID:self.classid responseDelegate:self];
    [CNETWORKMANAGER addClassInfoDelegate:self]; //课堂相关信息监听
}

- (void)showClassAlert {
    switch (crState) {
        case ClassState_ClassBegin:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CSLocalizedString(@"live_VC_sigin_title")
                                                            message:CSLocalizedString(@"live_VC_sigin_text")
                                                           delegate:self cancelButtonTitle:nil
                                                  otherButtonTitles:CSLocalizedString(@"live_VC_sigin_ok"), nil];
            alert.tag = AlertViewTag_Sigin;
            [alert show];
            
        }
            break;
            
        case ClassState_ClassOver:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CSLocalizedString(@"live_VC_sigin_out_title")
                                                            message:CSLocalizedString(@"live_VC_sigin_out_text")
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:CSLocalizedString(@"live_VC_sigin_out_ok"), nil];
            alert.tag = AlertViewTag_Siginout;
            [alert show];
        }
            break;
        case ClassState_ReConnect:
        {
            if ([Utils IsEnableNetWork]) {
                [self showHUD:CSLocalizedString(@"live_VC_tcp_connecting")];
            }
        }
            break;
        default:
            break;
    }
    
    crState = ClassState_Nomal;

}
#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (AlertViewTag_Sigin == alertView.tag) {
        //签到
        if (buttonIndex == [alertView cancelButtonIndex]) {
            return;
        }
        isSigin = YES;
        [self showCamera];
    }else if (AlertViewTag_Siginout == alertView.tag) {
        //签退
        if (!devicePortrait) {
            [self fullScreenAction:nil];
        }
        
        SignOutViewController *signOutVC = [[SignOutViewController alloc] initWithNibName:nil bundle:nil];
        __weak LiveViewController *wself = self;
        [signOutVC setCallBack:^(int scores, NSString *text){
            LiveViewController *sself = wself;
            [sself evaluateClass:scores commentText:text];
        }];
        [self presentViewController:signOutVC animated:YES completion:NULL];
    }else if (AlertViewTag_SiginNotCamp == alertView.tag) {
        [self classBeginToPlayTeaVideo];
        
    }
    
}

//=========================================
// 相册和相机
//=========================================
-(void)showCamera
{
    //判断是否有拍照功能
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if (IS_IOS7) {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];  //获取对摄像头的访问权限
            if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:CSLocalizedString(@"live_VC_camera_authString")
                                                               delegate:nil
                                                      cancelButtonTitle:CSLocalizedString(@"live_VC_camera_cancel")
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        //模式窗体转化到图片选取界面
        UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
        imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        if (isSigin) {
            //签到默认使用前摄像头
            BOOL isRearSupport = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
            if (isRearSupport) {
                imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
        }
        imagePickerController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        //将图片选取器呈现给用户
        [self presentViewController:imagePickerController animated:YES completion:NULL];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:CSLocalizedString(@"live_VC_not_camera")
                              delegate:self
                              cancelButtonTitle:CSLocalizedString(@"live_VC_camera_cancel")
                              otherButtonTitles:nil];
        alert.tag = AlertViewTag_SiginNotCamp;
        [alert show];
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate 当用户成功拍摄了照片，或从图片库中选取一张图片将会调用这个方法
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerEditedImage];
    image = [image fixOrientation];
    
    NSString *fileName = [self createFilename];
    NSString *filePath = [[FILECACHEMANAGER getFileRootPathWithFileType:FileType_Img] stringByAppendingPathComponent:fileName];
    
    [UIImageJPEGRepresentation(image, 0.3) writeToFile:filePath atomically:YES];
    
    if (isSigin) {
        [self beginSigin:filePath];
    }else {
        
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        if (isSigin) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        }
    }];
}
//创建图片文件名字
- (NSString *)createFilename {
    return [NSString stringWithFormat:@"%lld.jpg",[UserAccount shareInstance].uid];
//    NSDate *date_ = [NSDate date];
//    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
//    [dateformater setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
//    NSString *timeFileName = [dateformater stringFromDate:date_];
//    return timeFileName;
}

//不拍照或者不选取任何图片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //选取器解除自身
    [picker dismissViewControllerAnimated:YES completion:^{
        if (isSigin) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            ClassRoomLog(@"不拍照或者不选取任何图片 == > 开始播放视频");
            [self classBeginToPlayTeaVideo];
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    devicePortrait = YES;
    showToolsView = YES;
    isSigin = NO;
    segmentCurrentIndex = liveSegmentRoomChatIndex;
    [self.titleView setTitleText:self.roomName  withTitleStyle:CTitleStyle_AlphaNoStatus];
    
    self.topContenView.frame = CGRectMake(0, TopContenView_Top, self.allContentView.width, TopContenView_Height);
    self.bottomView.frame = CGRectMake(0, self.topContenView.bottom, self.allContentView.width, self.allContentView.height - self.topContenView.height);
    
    [self _initHMSegmentedControl]; /*初始化选择组件*/
    [self _initHFBrowserView];      /*初始化预览组件*/
    [self _initToolsView];          /*初始化 <ppt/白板/主视频> 底部工具栏*/
    
    UITapGestureRecognizer *topViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topViewTapGesture)];
    [self.topContenView addGestureRecognizer:topViewTapGesture];
    
    
    //监听网络是否重新连接并且登录成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectNotification)
                                                 name:KNotificationDidLoginSuccess object:nil];
    //监听程序退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    //监听程序回到前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillBecame:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    //监听用户在其他地方登录
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoginWithOtherLocation)
                                                name:KNotificationDidKickOut object:nil];
    
    [self inToClassRoom];
}
//========================================================
//TODO: 更新选择控件标题 --- 学生列表数
//========================================================
- (void)upDateSegmentWithStudentList:(int)uCount {
    //暂时取消显示在线人数
//    [self.segmentedControl upDateTitle:[NSString stringWithFormat:@"%@(%d)",CSLocalizedString(@"live_VC_stu_online"),uCount] itemAtIndex:2];
}

//========================================================
//TODO: 初始化控件
//========================================================
- (void)_initHMSegmentedControl {
    
    UIImage *segBjImg = [UIImage imageNamed:@"讨论底"];
    segBjImg = [segBjImg resizableImageWithCapInsets:UIEdgeInsetsMake(4, 1, 4, 1)];
//    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"公屏",@"课件",@"在线(0)"]];
//    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionImages:@[[UIImage imageNamed:@"讨论"],
//                                                                                [UIImage imageNamed:@"课件"],
//                                                                                [UIImage imageNamed:@"用户在线"]]
//                                                        sectionSelectedImages:@[[UIImage imageNamed:@"讨论点击"],
//                                                                                [UIImage imageNamed:@"课件点击"],
//                                                                                [UIImage imageNamed:@"用户在线点击"]]
//                                                            titlesForSections:@[CSLocalizedString(@"live_VC_room_chat"),
//                                                                                CSLocalizedString(@"live_VC_courseWare"),
//                                                                                CSLocalizedString(@"live_VC_stu_online_0")]];
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[CSLocalizedString(@"live_VC_room_chat"),
                                                                                CSLocalizedString(@"live_VC_courseWare"),
                                                                                CSLocalizedString(@"live_VC_stu_online")]];
    self.segmentedControl.frame = CGRectMake(0, 0, self.bottomView.width, SegmentedControlHeight);
    self.segmentedControl.selectionIndicatorHeight = 2.0f;
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.backgroundImage = segBjImg;
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:80/255.0 green:185/255.0 blue:54/255.0 alpha:1];
    self.segmentedControl.textFont = [UIFont systemFontOfSize:14.0f];
    self.segmentedControl.textColor = [UIColor colorWithWhite:51/255.0 alpha:1];
    self.segmentedControl.selectedTextColor = [UIColor colorWithRed:80/255.0 green:185/255.0 blue:54/255.0 alpha:1];
    self.segmentedControl.selectedSegmentIndex = liveSegmentRoomChatIndex;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.segmentWidthStyle =  HMSegmentedControlSegmentWidthStyleFixed;
    self.segmentedControl.verticalDividerEnabled = NO;
    self.segmentedControl.verticalDividerColor = [UIColor colorWithWhite:220/255.0 alpha:1];
    self.segmentedControl.verticalDividerWidth = 1.0f;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.bottomView addSubview:self.segmentedControl];

    
}

- (void)_initHFBrowserView
{
    self.browserView = [[HFBrowserView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.bottom, self.bottomView.width, self.bottomView.height - self.segmentedControl.bottom)];
    self.browserView.bounces = NO;
    self.browserView.scrollEnabled = YES;
    self.browserView.scrollsToTop = NO;
    self.browserView.sourceDelegate = self;
    self.browserView.dragDelegate = self;
    self.browserView.clipsToBounds = NO;
    [self.browserView setInitialPageIndex:DefaultSelectedIndex];
    [self.browserView reloadData];
    [self.bottomView addSubview:self.browserView];

}
- (void) _initToolsView {
    self.toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topContenView.bottom - TOOLSView_Height, self.topContenView.width, TOOLSView_Height)];
    self.toolsView.backgroundColor = [UIColor clearColor];
    self.toolsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    UIImageView *alphaView = [[UIImageView alloc] initWithFrame:self.toolsView.bounds];
    alphaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    alphaView.image = [UIImage imageNamed:@"视频播放状态栏"];
    [self.toolsView addSubview:alphaView];
    
    [self.topContenView addSubview:self.toolsView];
    
    
    self.fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenButton.frame = CGRectMake(self.toolsView.width - TOOLSView_Height, 0, TOOLSView_Height, TOOLSView_Height);
    [self.fullScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    self.fullScreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.toolsView addSubview:self.fullScreenButton];
    [self updateFullScreenButtonIcon];
    
    
}

- (StudentListView *)stuListView {
 
    if (!_stuListView) {
        _stuListView = [[StudentListView alloc] initWithFrame:self.browserView.bounds uCHatViewShowAtViewController:self];
        _stuListView.courseid = self.cid;
        _stuListView.classid = self.classid;
        __weak LiveViewController *wself = self;
        [self.stuListView setUCountBlock:^(int uCount){
            LiveViewController *sself = wself;
            [sself upDateSegmentWithStudentList:uCount];
        }];
    }
    return _stuListView;
}
- (NSMutableDictionary *)userListDic {
    if (!_userListDic) {
        _userListDic = [[NSMutableDictionary alloc] init];
    }
    return _userListDic;
}

//========================================================
//TODO: 组件响应方法
//========================================================
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    int currIndex = segmentedControl.selectedSegmentIndex;
    ClassRoomLog(@"选择: %d", currIndex);
    [self.browserView setInitialPageIndex:currIndex animated:YES];
    segmentCurrentIndex = currIndex;
    [self.segmentedControl hiddenBadge:currIndex];
    
}
#pragma mark- 更新全屏按钮状态
- (void)updateFullScreenButtonIcon {
    if (devicePortrait) {
        //当前竖屏显示
        [self.fullScreenButton setImage:[UIImage imageNamed:@"视频最大化按钮"] forState:UIControlStateNormal];
    }else {
        //当前横屏显示
        [self.fullScreenButton setImage:[UIImage imageNamed:@"视频恢复"] forState:UIControlStateNormal];
    }
}


- (void)fullScreenAction:(UIButton *)button {
    if (devicePortrait) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
        UIInterfaceOrientation orientation = UIInterfaceOrientationLandscapeRight;
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
        
    }else {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
        UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
    }
}

- (void)topViewTapGesture {
    //显示/隐藏工具栏
    [self showOrHiddenToolsView];
    
}
//显示/隐藏工具栏
- (void)showOrHiddenToolsView {
    
    if (showToolsView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.titleView.bottom = 0;
            self.toolsView.top = self.topContenView.bottom;
            self.toolsView.alpha = 0;
        } completion:^(BOOL finished) {
            showToolsView = NO;
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.titleView.top = 0;
            self.toolsView.bottom = self.topContenView.bottom;
            self.toolsView.alpha = 1;
        } completion:^(BOOL finished) {
            showToolsView = YES;
        }];
    }
}

- (void)leftClicked:(TitleView *)view {
    
    if (!devicePortrait) {
        [self fullScreenAction:nil];
        return;
    }
    
    //离开课堂
    [CNETWORKMANAGER userLeaveCourse:self.classid userid:[UserAccount shareInstance].loginUser.uid responseDelegate:self];
    [CNETWORKMANAGER removeClassInfoDelegate]; //移除课堂相关信息监听
    
    [self.topContenView classOver];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark HFBrowserView Delegate
-(NSUInteger)numberOfPageInBrowserView:(HFBrowserView *)browser
{
    return 3;
}
-(UIView *)browserView:(HFBrowserView *)browser viewAtIndex:(NSUInteger)index
{
    if (index ==0 ) {
        if (!self.roomChatView) {
            self.roomChatView = [[RoomWithChatView alloc] initWithFrame:browser.bounds atDelegate:self];
            self.roomChatView.courseID = self.cid;
            self.roomChatView.classID = self.classid;
            self.roomChatView.myUid = [UserAccount shareInstance].uid;
            [self.roomChatView initChatDataWithDatabase];

        }
        return self.roomChatView;
    }else if (index == 1) {
        return self.courseWareList;
    }else if (index == 2) {
        return self.stuListView;
    }
    return nil;
}
-(void)browserViewlDidEndDecelerating:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex
{
    [self.segmentedControl setSelectedSegmentIndex:pageIndex animated:YES];
    [self.segmentedControl hiddenBadge:pageIndex];
    segmentCurrentIndex = pageIndex;
    
    [self refreshCurrentView];
}


-(void)browserViewlDidEndScrollingAnimation:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex
{
    //显示第几个视图了
    [self refreshCurrentView];
    
}


- (void)refreshCurrentView {
    int currentIndex = [self.browserView getCurrentPage];
    self.roomChatView.inPutTextView.hasShowKeyBorad = (currentIndex==liveSegmentRoomChatIndex);
    self.stuListView.uChatbgView.uChatView.inPutTextView.hasShowKeyBorad = (currentIndex==liveSegmentStudenListIndex);
}

#pragma mark-
#pragma mark- RoomWithChatViewDelegate
- (CGRect )roomWithChatViewViewChangedHeight:(CGFloat)height
{
    CGFloat tvTop = [self getTableViewTop];
    CGFloat  tvAlpha = [self getableViewAlpha];
    CSLog(@"TOP高度: %f",tvTop);
    
    self.bottomView.frame = CGRectMake(0, tvTop, self.allContentView.width, self.allContentView.height - tvTop);
    self.roomChatView.tableView.alpha = tvAlpha;
    self.segmentedControl.top = 0;
    self.browserView.top = self.segmentedControl.bottom;
    self.browserView.height = self.bottomView.height - self.segmentedControl.height;
    return CGRectMake(0,0, self.bottomView.width, self.bottomView.height - self.segmentedControl.height);
}

- (CGFloat)getTableViewTop {
    
    if (self.roomChatView.inPutTextView.height == 50) {
        return self.topContenView.bottom;
    }
    return self.topContenView.top - self.segmentedControl.height;
}
- (CGFloat)getableViewAlpha {
    if (self.roomChatView.inPutTextView.height == 50) {
        self.browserView.scrollEnabled = YES;
        return 1;
    }
    self.browserView.scrollEnabled = NO;
    return 0.7;
}


#pragma mark - 
#pragma mark -  
//===============================
//TODO: 设备横屏/竖屏切换
//==============================
- (void)viewWillLayoutSubviews {
    
    UIInterfaceOrientation interfaceOrientation=[[UIApplication sharedApplication] statusBarOrientation];

    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        //翻转为竖屏时
        if (!devicePortrait) {
            
            devicePortrait = YES;
            self.bottomView.hidden = NO;
            
            self.allContentView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
            self.topContenView.frame = CGRectMake(0, TopContenView_Top, SCREENWIDTH, TopContenView_Height);
            
            
            
            //视频 Frame
            self.topContenView.clVideo.frame = CGRectMake(self.topContenView.width, 0, self.topContenView.width, self.topContenView.height);
            
            //PDF Frame
            [self.topContenView.pdfBgView updateFrame:self.topContenView.bounds currentShowSmallView:NO];
            
            //图片课件
            self.topContenView.imgView.frame = self.topContenView.bounds;
            
            //白板 Frame
            [self.topContenView.whiteBgView updateFrame:self.topContenView.bounds isAnimate:NO];
            
            //媒体播放器<音频> Frame
            self.topContenView.mediaPlayerView.frame = self.topContenView.bounds;
            
            //控制个人聊天页的显示与隐藏
            if (_stuListView) {
                [_stuListView deviceOrientation:YES];
            }
            
            //工具栏
            if (showToolsView) {
                self.titleView.top = 0;
                self.titleView.width = self.allContentView.width;
                self.toolsView.bottom = self.topContenView.bottom;
            }else {
                self.titleView.bottom = 0;
                self.titleView.width = self.allContentView.width;
                self.toolsView.top = self.topContenView.bottom;
            }
            
            
            //更新全屏按钮图片
            [self updateFullScreenButtonIcon];
        }
        
        
    }else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        //翻转为横屏时
        if (devicePortrait) {
            devicePortrait = NO;
            [self hiddenKeyBorad];
            self.bottomView.hidden = YES;
            
            if (IS_IOS8) {
                self.allContentView.frame = CGRectMake(0, 0,SCREENWIDTH, SCREENHEIGHT);
            }else {
                self.allContentView.frame = CGRectMake(0, 0,SCREENHEIGHT,SCREENWIDTH);
            }
            
            
            
            self.topContenView.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.height);
            
            //视频 Frame
            self.topContenView.clVideo.frame = CGRectMake(self.topContenView.width, 0, self.topContenView.width, self.topContenView.height);
            
            //PDF Frame
            [self.topContenView.pdfBgView updateFrame:self.topContenView.bounds currentShowSmallView:NO];
            
            //图片课件
            self.topContenView.imgView.frame = self.topContenView.bounds;
            
            //白板 Frame
            [self.topContenView.whiteBgView updateFrame:self.topContenView.bounds isAnimate:NO];
            
            //媒体播放器<音频> Frame
            self.topContenView.mediaPlayerView.frame = self.topContenView.bounds;
            
            //控制个人聊天页的显示与隐藏
            if (_stuListView) {
                [_stuListView deviceOrientation:NO];
            }

            
            //工具栏/ 导航
            if (showToolsView) {
                self.toolsView.bottom = self.topContenView.bottom;
                
                self.titleView.top = 0;
                self.titleView.width = self.allContentView.width;
            }else {
                self.toolsView.top = self.topContenView.bottom;
                self.titleView.width = self.allContentView.width;
                self.titleView.bottom = 0;
            }
            //更新全屏按钮图片
            [self updateFullScreenButtonIcon];
        }
        
    }
}

#pragma mark-
#pragma mark- 我自己进入课堂
- (void)mySelfIntoClassRooom:(UserWelecomeModel *)userWel
{
    self.askStuUid = userWel.askStuUID;
    
    switch (userWel.classstate) {
        case WelClassStateModelType_CLASS_WAIT_ON:
        {
            //准备中
        }
            break;
        case WelClassStateModelType_CLASS__ON_NOT_BEGIN:
        {
            //正在进行,但未上课
        }
            break;
        case WelClassStateModelType_CLASS_ON_AND_BEGIN:
        {
            //上课中
//            if (userWel.signSatate == 0) {
//                //未签到过
//                [self hiddenKeyBorad];
//                if ([self isVisible]) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CSLocalizedString(@"live_VC_sigin_title")
//                                                                    message:CSLocalizedString(@"live_VC_sigin_text")
//                                                                   delegate:self
//                                                          cancelButtonTitle:nil
//                                                          otherButtonTitles:CSLocalizedString(@"live_VC_sigin_ok"), nil];
//                    alert.tag = AlertViewTag_Sigin;
//                    [alert show];
//                }else if (userWel.signSatate == 1) {
//                    //已经签到过
//                    crState = ClassState_ClassBegin;
//                }else if (userWel.signSatate == 2) {
//                    //下课未签退
//                }
//            }else {
//                //正在上课
//                [self classBeginToPlayTeaVideo];
//            }
            [self.topContenView allocConten:userWel];
            [self classBeginToPlayTeaVideo];
            if (userWel.current.showType == CurrentShowModelType_BLANK || (userWel.current.page <=0 && userWel.current.name == nil)) {
                [self.topContenView changeViewToStyle:LiveCurrentStyle_Video isAnimate:NO];
            }
        }
            break;
        case WelClassStateModelType_CLASS_NOT_ON:
        {
            //未开始
//            [Utils showToast:@"未上课"];
        }
            break;
        default:
            break;
    }
    
}

- (void)userEnter:(UserEnterModel *)userEnt
{
    if (userEnt.user.uid != [UserAccount shareInstance].uid && userEnt.user.authority == UserAuthorityType_TEACHER) {
        self.teaMediaSrcUrl = userEnt.user.pulladdr;
        self.topContenView.mediaSrcUrl = self.teaMediaSrcUrl;
        self.stuListView.teaUID = userEnt.user.uid;
        ClassRoomLog(@"教师进入课堂后=>音视频地址: %@",self.teaMediaSrcUrl);
    }
    if (userEnt.user.uid != [UserAccount shareInstance].uid) {
        [self.userListDic setObject:userEnt.user forKey:[NSString stringWithFormat:@"%lld",userEnt.user.uid]];
        
        NSString *userVideo = userEnt.user.pulladdr;
        if ([Utils objectIsNotNull:userVideo]) {
            [self.userVideoListDic setObject:userVideo forKey:[NSString stringWithFormat:@"%lld",userEnt.user.uid]];
        }
        [self.stuListView insertUser:userEnt.user];
    }

}

- (void)classSatate:(SetClassStateModel *)cState
{
    self.classid = cState.classid;
    switch (cState.classstate) {
        case SetClassStateModelType_CLASS_BEGIN:
        {
//            [self hiddenKeyBorad];
//            if ([self isVisible]) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CSLocalizedString(@"live_VC_sigin_title")
//                                                                message:CSLocalizedString(@"live_VC_sigin_text")
//                                                               delegate:self
//                                                      cancelButtonTitle:nil
//                                                      otherButtonTitles:CSLocalizedString(@"live_VC_sigin_ok"), nil];
//                alert.tag = AlertViewTag_Sigin;
//                [alert show];
//            }else {
//                crState = ClassState_ClassBegin;
//            }
            self.teaVideoId = 1;
            [self.topContenView changeViewToStyle:LiveCurrentStyle_Video isAnimate:NO];
            ClassRoomLog(@"开始上课 == > 课堂签到");
        }
            break;
        case SetClassStateModelType_CLASS_END:
        {
            [self hiddenKeyBorad];
            if ([self isVisible]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CSLocalizedString(@"live_VC_sigin_out_title")
                                                                message:CSLocalizedString(@"live_VC_sigin_out_text")
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:CSLocalizedString(@"live_VC_sigin_out_ok"), nil];
                alert.tag = AlertViewTag_Siginout;
                [alert show];
            }else {
                crState = ClassState_ClassOver;
            }
            
            ClassRoomLog(@"下课签退 并且清除所有数据(聊天/用户列表除外)");
    
            [self.topContenView classOver];
            [self.courseWareList classOver];
            
        }
            break;
        default:
            break;
    }

}

- (void)classAction:(ClassActionModel *)cActionModel
{
 
    switch (cActionModel.actiontype) {
        case ClassActionModelType_KICKOUT:
        {
            //老师吧学生踢出房间
            if (cActionModel.uid == [UserAccount shareInstance].uid) {
                //自己
                if (!devicePortrait) {
                    [self fullScreenAction:nil];
                }
                [self leftClicked:nil];
                
            }else{
                //他人
                NSString *uid_key = [NSString stringWithFormat:@"%lld",cActionModel.uid];
                [self.userListDic removeObjectForKey:uid_key];
                [self.userVideoListDic removeObjectForKey:uid_key];
                [self.stuListView delUser:cActionModel.uid];
                if (cActionModel.uid == self.askStuUid) {
                    [self.topContenView stopStuVideo];
                }
            }
        }
            break;
        case ClassActionModelType_ALLOW_SPEAK:{
            //提问学生
            self.askStuUid = cActionModel.uid;
            NSString *stuVideoUrl = [self.userVideoListDic objectForKey:[NSString stringWithFormat:@"%lld",cActionModel.uid]];
            if (cActionModel.uid != [UserAccount shareInstance].uid) {
                ClassRoomLog(@"被提问学生的音视频地址: %@",stuVideoUrl);
                User *u = [self.userListDic objectForKey:[NSString stringWithFormat:@"%lld",cActionModel.uid]];
                [self roomChatAddSystemMessage:[NSString stringWithFormat:@"%@\"%@\"%@",
                                                CSLocalizedString(@"live_VC_tea_ask"),
                                                [Utils objectIsNotNull:u.realname]?u.realname:[NSString stringWithFormat:@"%lld",cActionModel.uid],
                                                CSLocalizedString(@"live_VC_role_stu")]];
                [self.topContenView playStuVideo:stuVideoUrl];
            }else {
                ClassRoomLog(@"被提问学生(登录用户)的音视频地址: %@",[UserAccount shareInstance].loginUser.pushaddr);
                [self.topContenView startLoginUserVideo:[UserAccount shareInstance].loginUser.pushaddr];
            }
        }
            break;
        case ClassActionModelType_CLEAN_SPEAK:
        {
            //取消提问 <清除举手状态>
            self.askStuUid = -1;
            if (cActionModel.uid != [UserAccount shareInstance].uid) {
                ClassRoomLog(@"教师取消提问学生: UID== %lld",cActionModel.uid);
                [self.topContenView stopStuVideo];
            }else {
                ClassRoomLog(@"教师取消提问学生(登录用户): UID== %lld",cActionModel.uid);
                [self.topContenView stopLoginUserVideo];
            }
        }
            break;
        case ClassActionModelType_MUTE:
        {
            //禁言
            ClassRoomLog(@"对用户禁言: uid: %lld",cActionModel.uid);
            if (cActionModel.uid == [UserAccount shareInstance].uid) {
                self.roomChatView.canSendMsg_person = NO;
            }
        }
            break;
        case ClassActionModelType_UNMUTE:
        {
            //关闭禁言
            ClassRoomLog(@"对用户恢复禁言: uid: %lld",cActionModel.uid);
            if (cActionModel.uid == [UserAccount shareInstance].uid) {
                self.roomChatView.canSendMsg_person = YES;
            }
        }
            break;
        default:
            break;
    }

}

/**
 * 处理接收到的聊天消息
 **/
- (void)chatMsgRec:(SendTextMsgModel *)sendMsgModel
{
    
    NSString *sendUserName = @"";
    if (sendMsgModel.uid == [UserAccount shareInstance].uid) {
        sendUserName = [Utils objectIsNotNull:[UserAccount shareInstance].loginUser.realname] ?[UserAccount shareInstance].loginUser.realname:[NSString stringWithFormat:@"%lld",sendMsgModel.uid];
    }else {
        User *u = [self.userListDic objectForKey:[NSString stringWithFormat:@"%lld",sendMsgModel.uid]];
        sendUserName = u?u.realname:[NSString stringWithFormat:@"%lld",sendMsgModel.uid];
    
    }
    
    if (sendMsgModel.recvtype == MsgRecvType_CLASS) {
        //课堂内群聊
        ClassRoomLog(@"课堂内群聊");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithLongLong:sendMsgModel.msgId],CHAT_msgId,                   /*消息id*/
                                 [NSNumber numberWithLongLong:[UserAccount shareInstance].uid],CHAT_ownerUid,   /*登录用户id*/
                                 [NSNumber numberWithLongLong:sendMsgModel.uid],CHAT_sendUid,                   /*发送者id*/
                                 [NSNumber numberWithLongLong:sendMsgModel.recvid],CHAT_reciveUid,              /*接收者id*/
                                 [NSNumber numberWithLongLong:self.cid],CHAT_courseID,                          /*课程id*/
                                 [NSNumber numberWithLongLong:sendMsgModel.time],CHAT_time,                     /*消息时间*/
                                 [NSNumber numberWithLongLong:self.classid],CHAT_classId,                       /*课节id*/
                                 [NSNumber numberWithLongLong:0],CHAT_groupId,                                  /*分组id<暂时未启用使用0占位>*/
                                 [NSNumber numberWithInt:MsgType_Room],CHAT_msgStyle,                           /*消息类型*/
                                 [NSNumber numberWithBool:sendMsgModel.isMe],CHAT_isMe,                         /*是否是登录用户发送的*/
                                 [NSNumber numberWithBool:NO],CHAT_isSystemMsg,                                 /*是否是系统消息*/
                                 sendUserName,CHAT_sendUserNick,                                                /*发送者昵称*/
                                 sendMsgModel.text,CHAT_contentText,nil];                                       /*消息内容*/
            [self.roomChatView insertChatMsgIntoDB:dic];
        });
    }else if (sendMsgModel.recvtype == MsgRecvType_USER) {
        //私聊
        ClassRoomLog(@"课堂内私聊 msg:%@",sendMsgModel.text);
        ClassRoomLog(@"senddUID:%lld,RecUID:%lld",sendMsgModel.uid,sendMsgModel.recvid);

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithLongLong:sendMsgModel.msgId],CHAT_msgId,                   /*消息id*/
                                 [NSNumber numberWithLongLong:[UserAccount shareInstance].uid],CHAT_ownerUid,   /*登录用户id*/
                                 [NSNumber numberWithLongLong:sendMsgModel.uid],CHAT_sendUid,                   /*发送者id*/
                                 [NSNumber numberWithLongLong:sendMsgModel.recvid],CHAT_reciveUid,              /*接收者id*/
                                 [NSNumber numberWithLongLong:self.cid],CHAT_courseID,                          /*课程id*/
                                 [NSNumber numberWithLongLong:sendMsgModel.time],CHAT_time,                     /*消息时间*/
                                 [NSNumber numberWithLongLong:self.classid],CHAT_classId,                       /*课节id*/
                                 [NSNumber numberWithLongLong:0],CHAT_groupId,                                  /*分组id<暂时未启用使用0占位>*/
                                 [NSNumber numberWithInt:MsgType_One],CHAT_msgStyle,                            /*消息类型*/
                                 [NSNumber numberWithBool:sendMsgModel.isMe],CHAT_isMe,                         /*是否是登录用户发送的*/
                                 [NSNumber numberWithBool:NO],CHAT_isSystemMsg,                                 /*是否是系统消息*/
                                 sendUserName,CHAT_sendUserNick,                                                /*发送者昵称*/
                                 sendMsgModel.text,CHAT_contentText,nil];                                       /*消息内容*/
            [self.stuListView.uChatbgView.uChatView insertChatMsgIntoDB:dic];
        });
        if (segmentCurrentIndex != liveSegmentStudenListIndex) {
            [self.segmentedControl showBadge:liveSegmentStudenListIndex];
        }
    }

}

/**
 * 增加群聊中系统消息
 **/
- (void)roomChatAddSystemMessage:(NSString *)msg
{
    ClassRoomLog(@"课堂内群聊");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDate *nowDate = [NSDate date];
        long long msgid = [nowDate timeIntervalSince1970]*1000;
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithLongLong:msgid],CHAT_msgId,                                /*消息id*/
                             [NSNumber numberWithLongLong:[UserAccount shareInstance].uid],CHAT_ownerUid,   /*登录用户id*/
                             [NSNumber numberWithLongLong:0],CHAT_sendUid,                                  /*发送者id*/
                             [NSNumber numberWithLongLong:0],CHAT_reciveUid,                                /*接收者id*/
                             [NSNumber numberWithLongLong:self.cid],CHAT_courseID,                          /*课程id*/
                             [NSNumber numberWithLongLong:0],CHAT_time,                                     /*消息时间 会在内部填充 */
                             [NSNumber numberWithLongLong:self.classid],CHAT_classId,                       /*课节id*/
                             [NSNumber numberWithLongLong:0],CHAT_groupId,                                  /*分组id<暂时未启用使用0占位>*/
                             [NSNumber numberWithInt:MsgType_Room],CHAT_msgStyle,                           /*消息类型*/
                             [NSNumber numberWithBool:NO],CHAT_isMe,                                        /*是否是登录用户发送的*/
                             [NSNumber numberWithBool:YES],CHAT_isSystemMsg,                                /*是否是系统消息*/
                             @"",CHAT_sendUserNick,                                                         /*发送者昵称*/
                             msg,CHAT_contentText,nil];                                                     /*消息内容*/
        [self.roomChatView insertChatMsgIntoDB:dic];
    });

}

#pragma mark - 评价课堂
- (void)evaluateClass:(int)scores commentText:(NSString *)text {
    ClassRoomLog(@"评价课堂: \n\n\n\n\n1、text: %@\n\n2、cid:%lld \n\n3、classid:%lld",text,self.cid,self.classid);
    [CNETWORKMANAGER classRoomSignOut:scores commentText:text userid:[UserAccount shareInstance].uid courseId:self.cid classID:self.classid];
}

#pragma mark - 
#pragma mark- 开始播放教师视频
- (void)classBeginToPlayTeaVideo
{
    [self.topContenView clMovePlyerStatrPlay:MAX(1, self.teaVideoId)];
    if (self.askStuUid != -1) {
        NSString *stuVideoUrl = [self.userVideoListDic objectForKey:[NSString stringWithFormat:@"%lld",self.askStuUid]];
        [self.topContenView playStuVideo:stuVideoUrl];
        ClassRoomLog(@"提问学生uid: %lld url:%@",self.askStuUid,stuVideoUrl);
    }

}


#pragma mark -
#pragma mark - CNetworkManagerDelegate
//成功后的回调
- (void) cNetWorkCallBackFinish:(id)value cNetworkRecType:(int) pType
{
    
    switch (pType) {
        case CNW_UserEnter:
        {
            [self userEnter:(UserEnterModel *)value];
        }
            break;
        case CNW_UserWelecome:
        {
            [self hiddenHUD];
            //进入课堂
            UserWelecomeModel *userWel = (UserWelecomeModel *)value;
            self.classid = userWel.classid; //记录当前课节id
            //保存用户视频地址列表
            if (!self.userVideoListDic) {
                self.userVideoListDic = [[NSMutableDictionary alloc] init];
            }
            [self.userVideoListDic addEntriesFromDictionary:userWel.userListWithVideoUrlDic];
            
            //用户列表
            self.stuListView.courseid = self.cid;
            self.stuListView.classid = self.classid;
            self.stuListView.teaUID = userWel.teaUid;

            
            //下载课件
            //课件列表
            if (!self.courseWareList) {
                self.courseWareList = [[CourseWareListView alloc] initWithFrame:self.browserView.bounds atTableViewData:userWel.cousewarelist];
            }
            
            //记录音视频地址及视频路数
            self.teaMediaSrcUrl = userWel.teaVideoSrcUrl;
            self.teaVideoId=  userWel.teachervedio==100?0:userWel.teachervedio;
            ClassRoomLog(@"进入课堂成功音视频地址: %@",self.teaMediaSrcUrl);
            [self.topContenView createVideoPlayer:self.teaMediaSrcUrl playVideoId:MAX(1, self.teaVideoId+1)];
            [self mySelfIntoClassRooom:userWel];
            
            //课堂权限
            currentClassModel = userWel.classmode;
            if ((currentClassModel & WelClassModelType_SPEAKABLE ) == WelClassModelType_SPEAKABLE) {
                ClassRoomLog(@"初始进入课堂权限: 可以举手");
            }else {
                ClassRoomLog(@"初始进入课堂权限: 禁止举手");
            }
            
            if ((currentClassModel & WelClassModelType_TEXTABLE ) == WelClassModelType_TEXTABLE) {
                ClassRoomLog(@"初始进入课堂权限: 可以聊天");
                self.roomChatView.canSendMsg = YES;
            }else {
                ClassRoomLog(@"初始进入课堂权限: 禁止聊天");
                self.roomChatView.canSendMsg = NO;
            }
            
        }
            break;
        case CNW_SendMsgRet:
        {
            //聊天接收<包括自己发送>
            [self chatMsgRec:(SendTextMsgModel *)value];

        }
            break;
        case CNW_QueryUserListResp:
        {
            //获取用户列表
            [self.userListDic addEntriesFromDictionary:(NSMutableDictionary *)value];
            [self.stuListView initTableData:self.userListDic];
            ClassRoomLog(@"获取用户列表");

        }
            break;
        case CNW_UserLeaveRet:
        {
            //离开课堂
            UserLeaveModel *userLeaveModel = (UserLeaveModel *)value;
            NSString *uid_key = [NSString stringWithFormat:@"%lld",userLeaveModel.uid];
            [self.userListDic removeObjectForKey:uid_key];
            [self.userVideoListDic removeObjectForKey:uid_key];
            [self.stuListView delUser:userLeaveModel.uid];
            
            ClassRoomLog(@"用户离开UId:%lld  self.ASKStuUID:%lld",userLeaveModel.uid,self.askStuUid);
            if (userLeaveModel.uid == self.askStuUid) {
                [self.topContenView stopStuVideo];
            }
        }
            break;
        case CNW_SwitchClassShow:
        {
            //课堂展示内容变更
            [self.topContenView updateCourseWera:(SwitchClassShowModel *)value];
            
        }
            break;
        case CNW_SetMainShow:
        {
            //主窗口/小窗口切换
            [self.topContenView updateMainShow:(SetMainShowModel *)value];
        }
            break;
        case CNW_AddCourseWare:
        {
            //增加/删除/关闭课件
            AddCourseWareModel *addCWModel = (AddCourseWareModel *)value;
            if (addCWModel.actiontype == AddCourseWareModelType_ADD && segmentCurrentIndex != liveSegmentCourseWareIndex) {
                [self.segmentedControl showBadge:liveSegmentCourseWareIndex];
            }
            [self.topContenView addCourseWare:addCWModel];          //头部内容展示区更新显示课件 并处理文件缓存
            [self.courseWareList updateCourseWare:addCWModel];      //课件列表同步课件列表 只负责同步列表及下载 不处理文件缓存
        }
            break;
        case CNW_SetClassState:
        {
            //上课.下课
            [self classSatate:(SetClassStateModel *)value];
        }
            break;
        case CNW_SetClassMode:
        {
            //课堂设置 <禁言/恢复禁言等>
            SetClassMode_obj *setModel = (SetClassMode_obj *)value;
            
            if ((setModel.classmode &SetClassMode_objType_TEXTABLE) != (currentClassModel & SetClassMode_objType_TEXTABLE)) {
                //聊天/禁止聊天
                if (setModel.classmode & SetClassMode_objType_TEXTABLE) {
                    ClassRoomLog(@"课堂设置 => 可以聊天");
                    self.roomChatView.canSendMsg = YES;
                    [self roomChatAddSystemMessage:CSLocalizedString(@"live_VC_tea_room_chat")];
                }else {
                    ClassRoomLog(@"课堂设置 => 禁止聊天");
                    [self roomChatAddSystemMessage:CSLocalizedString(@"live_VC_tea_room_chat_not")];
                    self.roomChatView.canSendMsg = NO;
                }
            }else if ((setModel.classmode &SetClassMode_objType_SPEAKABLE) != (currentClassModel & SetClassMode_objType_SPEAKABLE)){
            
                if (setModel.classmode & SetClassMode_objType_SPEAKABLE) {
                    ClassRoomLog(@"课堂设置 => 允许举手");
                    [self roomChatAddSystemMessage:CSLocalizedString(@"live_VC_tea_hand")];
                    self.roomChatView.canSendMsg = YES;
                }else {
                    ClassRoomLog(@"课堂设置 => 禁止举手");
                    [self roomChatAddSystemMessage:CSLocalizedString(@"live_VC_tea_hand_not")];
                    self.roomChatView.canSendMsg = NO;
                }
                
            }
            
            currentClassModel = setModel.classmode;
            
        }
            break;
        case CNW_ClassActions:
        {
            //课堂发生的事件<举手提问/踢人等>
            [self classAction:(ClassActionModel *)value];
        }
            break;
        case CNW_WhiteBoardEvent:
        {
            //白板  操作
            WhiteBoardEventModel *whiteEvent = (WhiteBoardEventModel *)value;
            WhiteBoardActionModel *whiteAction = whiteEvent.wbActionModel;
            [self.topContenView updateWhiteBoardAction:whiteAction];
        }
            break;
        case CNW_CreateWhiteBoard: {
            //创建白板
            CreateWhiteBoardModel *createWhite = (CreateWhiteBoardModel *)value;
            [self.topContenView createWhiteBoard:createWhite];
        }
            break;
        case CNW_SetTeacherVedioRet:
        {
            SetTeacherVedioModel *tvideoModel = (SetTeacherVedioModel *)value;
            ClassRoomLog(@"老师切换视频id:%d",tvideoModel.teachervedio);
            if (tvideoModel.teachervedio < 100) {
                [self.topContenView changePlayerWithVideo:MAX(1, tvideoModel.teachervedio+1) srcUrl:self.teaMediaSrcUrl];
            }else {
                ClassRoomLog(@"老师切换三路同时显示");
            }
            
        }
            break;
        default:
            break;
    }
}
//失败后的回调
- (void) cNetWorkCallBackFaild:(id)value cNetworkRecType:(int) pType
{
    [self showHUDEorror:value];
    [CNETWORKMANAGER removeDelegateWithType:(CNetworkRecProtocol)pType];
    if (pType == CNW_UserWelecome) {
        [CNETWORKMANAGER removeClassInfoDelegate];
        if (!devicePortrait) {
            [self fullScreenAction:nil];
        }
        [self leftClicked:nil];
        
    }
}


#pragma mark-
#pragma mark- 签到的图片本地路径 开始上传
//签到的图片本地路径
- (void)beginSigin:(NSString *)imgPath {

    [self classBeginToPlayTeaVideo];
    ClassRoomLog(@"签到的图片本地路径: %@",imgPath);

    
    [self resetHttp];
    [http_ upLoadPic:imgPath courseid:self.cid classid:self.classid userid:[UserAccount shareInstance].uid jsonResponseDelegate:self];
}

#pragma mark -
#pragma mark - 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *urlString  =[[request url] absoluteString];
    if ([urlString rangeOfString:@"signin_img"].location != NSNotFound) {
        int code = [[request responseJSON] intForKey:@"code"];
        if (code == 200) {
            [CNETWORKMANAGER classRoomSign:self.cid userId:[UserAccount shareInstance].uid classid:self.classid];
            ClassRoomLog(@"签到的图片上传成功");
        }else {
            ClassRoomLog(@"签到的图片上传失败");
        }
    }
}


#pragma mark-
#pragma mark- 失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSString *urlString  =[[request url] absoluteString];
    if ([urlString rangeOfString:@"signin_img"].location != NSNotFound) {
        [Utils showToast:CSLocalizedString(@"live_VC_sigin_upload_avatar_faild")];
    }
}

@end
