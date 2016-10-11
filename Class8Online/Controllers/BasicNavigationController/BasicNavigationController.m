//
//  BasicNavigationController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicNavigationController.h"

@interface BasicNavigationController ()

@end

@implementation BasicNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;

    //创建一个高20的假状态栏
//    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 20)];
//    //设置成绿色
//    statusBarView.backgroundColor=[UIColor blueColor];
//    // 添加到 navigationBar 上
//    [self.navigationBar addSubview:statusBarView];
    //    隐藏NavigationBar（导航栏） 可用
    //    [self.navigationController setNavigationBarHidden:YES];
    
    // 创建一个 statusBar view 添加背景色
//    UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
//    
//    statusBarView.backgroundColor=[UIColor blueColor];
//    
//    [self.view addSubview:statusBarView];
//    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    if ([self.topViewController isKindOfClass:NSClassFromString(@"LiveRoomViewController")]|| [self.topViewController isKindOfClass:NSClassFromString(@"LiveViewController")]|| [self.topViewController isKindOfClass:NSClassFromString(@"CameraViewController")])  { // 如果是这个 vc 则支持自动旋转
        return YES;
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)MSSlidingViewControllerShouldAutorotate
{
    if ([self.topViewController isKindOfClass:NSClassFromString(@"LiveRoomViewController")])  { // 如果是这个 vc 则支持自动旋转
        return YES;
    }
    return NO;
}

@end
