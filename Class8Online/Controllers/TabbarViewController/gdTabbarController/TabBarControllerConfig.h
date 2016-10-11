//
//  TabBarControllerConfig.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/2.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicViewController.h"
#import "CYLTabBarController.h"
@class AllCoursesViewController;
@class SchoolHomeViewController;
@class UserHomeViewController;
@class AllTeachersViewController;

@interface TabBarControllerConfig : BasicViewController
{
    SchoolHomeViewController    *schoolHomeVC;
    AllCoursesViewController    *allCoursesVC;
    UserHomeViewController      *userHomeVC;
    AllTeachersViewController   *allTeaVC;
}
@property (nonatomic, strong) CYLTabBarController *tabBarController;

@end
