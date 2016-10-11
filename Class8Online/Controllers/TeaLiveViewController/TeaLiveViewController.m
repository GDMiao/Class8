//
//  TeaLiveViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/11/23.
//  Copyright © 2015年 chuliangliang. All rights reserved.
//

#import "TeaLiveViewController.h"
#import "TeaLiveRoomControll.h"



@interface TeaLiveViewController () <TeaLiveControllDelegate>
{
    UIButton *beginButton;
}
@property (nonatomic, strong) NSString *courseName, /*课程名字*/
*mediaPushAdress;   /*媒体推流地址*/
@property (nonatomic, assign) long long cid,classid;
@property (nonatomic, strong) TeaLiveRoomControll *liveControll;
@end


@implementation TeaLiveViewController

- (void)dealloc {
    self.courseName = nil;
    self.mediaPushAdress = nil;
    self.liveControll = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (id)initWithCourseName:(NSString *)cName courseID:(long long)cid classID:(long long)classid
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.courseName = cName;
        self.cid = cid;
        self.classid = classid;
    }
    return self;
}

- (TeaLiveRoomControll *)liveControll
{
    if (!_liveControll) {
        _liveControll = [[TeaLiveRoomControll alloc] initWithCourseID:self.cid classID:self.classid];
        _liveControll.delegate = self;
    }
    return _liveControll;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ClassRoomLog(@"TeaLiveViewController ==> 延迟禁用设备锁屏");
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    });
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:self.courseName withTitleStyle:CTitleStyle_OnlyBack];
    //监听用户在其他地方登录

    
    beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beginButton.frame = CGRectMake(20, 20, 60, 30);
    [beginButton setTitle:@"上课" forState:UIControlStateNormal];
    [beginButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [beginButton addTarget:self action:@selector(beginClassAction) forControlEvents:UIControlEventTouchUpInside];
    [self.allContentView addSubview:beginButton];
    
    
    [self intoClassRoom];
}

- (void)leftClicked:(TitleView *)view {
    
    //离开课堂
    [self.liveControll leaveClassRoom];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//开始上课
- (void)beginClassAction {
    ClassRoomLog(@"TeaLiveViewController ==> 开始上课/下课");
    [self.liveControll classBeginOrEnd];
}



#pragma mark-
#pragma mark - 进入课堂
- (void)intoClassRoom
{
    [self.liveControll intoClassRoom:NO];
}


#pragma mark-
#pragma mark - TeaLiveControllDelegate 直播课堂控制器 代理
/**
 * isSuccess 进入课堂 失败/成功
 **/
- (void)liveControllIntoLiveRoom:(BOOL)isSuccess
{
    if (!isSuccess) {
        //失败
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [Utils showToast:@"进入成功"];
    [self liveControllUpdateClsssState:self.liveControll.roomStatus];
}


/**
 * 用户在其他地方登陆
 **/
- (void)liveControllUserLoginWithOtherLocation
{

}

/**
 * 程序退到后台
 **/
- (void)liveControllApplicationWillResignActive
{

}

/**
 * 程序进入前台
 **/
- (void)liveControllApplicationWillBecame
{
    
}

/**
 * 更新课堂状态
 **/
- (void)liveControllUpdateClsssState:(TeaLiveRoomSatus)status
{
    ClassRoomLog(@"TeaLiveViewController ==> 当前课堂状态 %d",status);
    if (status == TeaLiveRoomSatus_ON_AND_BEGIN) {
        //正在上课
        [beginButton setTitle:@"下课" forState:UIControlStateNormal];
    }else {
        [beginButton setTitle:@"上课" forState:UIControlStateNormal];
    }
}



@end
