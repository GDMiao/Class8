//
//  AppDelegate.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BasicNavigationController;
@class TabBarControllerConfig;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BasicNavigationController *tabbarNavVC;
@property (strong, nonatomic) TabBarControllerConfig *tabBarControllerConfig;
@property (assign, nonatomic) BOOL hasAutoPortrait;
@end

