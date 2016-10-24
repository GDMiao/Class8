//
//  BasicViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "FirstLoginViewController.h"
#import "CNetworkManager.h"
#import "BasicNavigationController.h"
#import "LoginViewController.h"

@interface BasicViewController ()
@end

@implementation BasicViewController

- (void)dealloc {
    self.titleView = nil;
    self.allContentView = nil;
    [self releaseHttp];
    self.tabbarVC = nil;
}

///销毁网络请求
- (void)releaseHttp {
    if (http_) {
        http_ = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.delegate = self;
    
    if (IS_IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (self.titleView) {
        //有导航
        if ([self isKindOfClass:NSClassFromString(@"FirstLoginViewController")] || [self isKindOfClass:NSClassFromString(@"LoginViewController")] || [self isKindOfClass:NSClassFromString(@"RegisteredViewController")]) {
            CSLog(@"ios10: %d-- or ios7: %d--" , IS_IOS10 , IS_IOS7);
            self.titleView.frame = CGRectMake(0, 0, SCREENWIDTH, IS_IOS7?64:44);
            self.allContentView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);

        }else if ([self isKindOfClass:NSClassFromString(@"LiveRoomViewController")]|| [self isKindOfClass:NSClassFromString(@"LiveViewController")]){
            self.titleView.frame = CGRectMake(0, 0, SCREENWIDTH,44);
            self.allContentView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        } else if ([self isKindOfClass:NSClassFromString(@"CameraViewController")]) {
            self.titleView.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
            self.allContentView.frame = CGRectMake(0, self.titleView.bottom, SCREENWIDTH, SCREENHEIGHT - self.titleView.height);
        }else{
            CSLog(@"iosSystemNum: %@-- ios10: %d-- or ios7: %d--" ,[[UIDevice currentDevice] systemVersion], IS_IOS10 , IS_IOS7);
          
            
            self.titleView.frame = CGRectMake(0, 0, SCREENWIDTH, IS_IOS7?64:44);
            self.allContentView.frame = CGRectMake(0, self.titleView.bottom, SCREENWIDTH, SCREENHEIGHT - self.titleView.height);
        }
    }else {
        //无导航
        CSLog(@"iosSystemNum: %@-- ios10: %d-- or ios7: %d--" ,[[UIDevice currentDevice] systemVersion], IS_IOS10 , IS_IOS7);
        self.allContentView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    }
 
}

- (void)resetHttp
{
    if (!http_) {
        http_ = [[HttpRequest alloc] init];
    }
}

//====================================================
//
//显示指示器 SVProgressHUD
//
//====================================================
/**
 * 显示指示器
 **/
- (void)showHUD:(NSString *)title
{
    title = title ? title : @"";
    if (!(title.length > 0)) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }else {
        [SVProgressHUD showWithStatus:title maskType:SVProgressHUDMaskTypeBlack];
    }
}
/**
 * 隐藏指示器
 **/
- (void)hiddenHUD {
    [SVProgressHUD dismiss];
}

/**
 * 错误状态
 **/
- (void)showHUDEorror:(NSString *)title {
    [SVProgressHUD showErrorWithStatus:title];
}
/**
 * 成功状态
 **/
- (void)showHUDSuccess:(NSString *)title {
    [SVProgressHUD showSuccessWithStatus:title];
}


//====================================================
//
//显示指示器 状态栏颜色
//
//====================================================

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)showLoginVC
{
    if (![UserAccount shareInstance].loginUser) {
//        FirstLoginViewController *firstLoginVC =[[FirstLoginViewController alloc] initWithNibName:nil bundle:nil];
//        firstLoginVC.isPush = NO;
//        BasicNavigationController *navFirstLoginVc = [[BasicNavigationController alloc] initWithRootViewController:firstLoginVC];
//        [self presentViewController:navFirstLoginVc animated:YES completion:NULL];
        
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
        loginVC.isPushed = NO;
        BasicNavigationController *navFirstLoginVc = [[BasicNavigationController alloc] initWithRootViewController:loginVC];
        
        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        [self presentViewController:navFirstLoginVc animated:YES completion:NULL];

        return YES;
    }
    return NO;
}

//====================================================
//
//titleView Delegate
//
//====================================================

#pragma mark -
#pragma mark - TitltViewDelegate
//左侧点击
-(void)leftClicked:(TitleView *)view {
    [self.navigationController popViewControllerAnimated:YES];
}

//右侧点击
-(void)rightClicked:(TitleView *)view
{
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:StopAVAudioPlayer object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    if ([self isKindOfClass:NSClassFromString(@"LiveViewController")]) {
        appdelegate.hasAutoPortrait = YES;
    }else {
        appdelegate.hasAutoPortrait = NO;
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}

/**
 * 打开左侧视图
 **/
- (void)openLeftVC {
}

- (BOOL) isVisible {
    return (self.isViewLoaded && self.view.window);
}

/**
 * http请求成功后的回调
 */
- (void)requestFinished:(ASIHTTPRequest *) request
{
}
/**
 * http请求失败后的回调
 */
- (void)requestFailed:(ASIHTTPRequest *) request
{
}

@end
