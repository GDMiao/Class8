//
//  AppDelegate.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "AppDelegate.h"
#import "PayOrderViewController.h"
#import "BasicNavigationController.h"
#import "LoginViewController.h"
#import "UserAccount.h"
#import "UserCenterViewController.h"
#import "FirstLoginViewController.h"
#import "Downloader.h"
#import "KeepOnLineUtils.h"
#import "TabbarViewController.h"
//#import "JPUSHService.h"
#import "CourseDetailViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "TabBarControllerConfig.h"

#import "WXApi.h"
#import "WXApiManager.h"

static NSString *appKey = @"66465648c27868b901398234";
static NSString *channel = @"App store";
static BOOL isProduction = false;

#define WXAppID @"wx706efc08ccb68bc0"

@interface AppDelegate ()<WXApiDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.hasAutoPortrait = NO;
    
    //注册通知监听用户被踢<在其他地方/设备登录>
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidKickOut) name:KNotificationDidKickOut object:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    //清除通知数
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    

//    self.tabBarControllerConfig = [[TabBarControllerConfig alloc] init];
//    [self.window setRootViewController:self.tabBarControllerConfig.tabBarController];
//    [self.window makeKeyAndVisible];
    
    
    self.tabbarNavVC = [[BasicNavigationController alloc] initWithRootViewController:[[TabbarViewController alloc] initWithNibName:nil bundle:nil]];
    self.window.rootViewController = self.tabbarNavVC;
    
//    if (![UserAccount shareInstance].autoLogin) {
//        //未登录过 弹出页面
//        CSLog(@"AppDelegate==> 未登录过弹出登录页面");
//        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
//        loginVC.isPushed = NO;
//        BasicNavigationController *navFirstLoginVc = [[BasicNavigationController alloc] initWithRootViewController:loginVC];
//        [self.tabbarNavVC presentViewController:navFirstLoginVc animated:NO completion:NULL];
//
//    }else {
//        CSLog(@"AppDelegate==> 自动登录");
//    }
    //自动清除过期数据
    [FILECACHEMANAGER clearInvalidateCacheFile];
    
    // 正式 WXAppID
    //向微信注册wxb4ba3c02aa476ea1  测试
    [WXApi registerApp:WXAppID withDescription:@"demo 2.0_DLMusic"];
   
    return YES;
}






#pragma mark - 
#pragma mark - 
- (void)userDidKickOut {
    CSLog(@"AppDelegate==> 收到用户被踢通知弹出登录页面");
    
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    loginVC.isPushed = NO;
    BasicNavigationController *navFirstLoginVc = [[BasicNavigationController alloc] initWithRootViewController:loginVC];
    [self.tabbarNavVC presentViewController:navFirstLoginVc animated:NO completion:NULL];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //app 挂起 (后台/电话/锁屏)
//    [KEEPONELINEUTILS disConnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //已经进入后台
    //开启后台任务
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // app 进入前台
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //app 重新激活
    [KEEPONELINEUTILS connectToServer];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //app 意外停止
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    
    if (self.hasAutoPortrait) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}


#pragma mark__ 微信 OpenURl



//微信支付返回程序  // 废弃
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
//}

//  废弃
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    int paycode = [PayOrderViewController PaySharSingleton].payMethodCode;
    if (paycode == 1) {
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
            }];
        }
        return YES;
    }else{
        return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
  
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    int paycode = [PayOrderViewController PaySharSingleton].payMethodCode;
    if (paycode == 0) {
        return [WXApi handleOpenURL:url delegate:self];
        
        
    }
    else if (paycode == 1){
    if ([url.host isEqualToString:@"safepay"]) {
        
        NSString *quer = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //跳转支付宝钱包进行支付，处理支付结果 resultDic key： memo、result、resultStatus
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            if (resultDic) {
                NSString *resultString = [resultDic objectForKey:@"resultStatus"];
                CSLog(@"resultStatus___= %@",resultString);
                if ([resultString isEqualToString:@"9000"]) {
                    CSLog(@"恭喜你,支付成功!");
                    [self showAlertView:@"支付结果" Message:@"订单已经支付成功"];
                    
                }else if ([resultString isEqualToString:@"6001"])
                {
                    [self showAlertView:@"支付结果" Message:@"订单已经支付过了"];
                }
                
                else{
                    [self showAlertView:@"支付结果" Message:@"支付失败"];
                }
                
            }
        }];
    }
    }
    return YES;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg,*strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！"];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        //        [alert release];
    }
    
}


- (void)showAlertView:(NSString *)strTitle Message:(NSString *)strMsg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
//        CourseDetailViewController *corseDvc = [[CourseDetailViewController alloc]initWithNibName:nil bundle:nil];
//        [self.tabbarNavVC popToViewController:corseDvc animated:YES];
        
        UserCenterViewController *userVC = [[UserCenterViewController alloc]initMyOrderResult:[UserAccount shareInstance].loginUser];
        [self.tabbarNavVC pushViewController:userVC animated:YES];
    }
    
}









@end
