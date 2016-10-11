//
//  TabbarViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/8/6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@class AllCoursesViewController;
@class SchoolHomeViewController;
@class UserHomeViewController;
@class AllTeachersViewController;
@interface TabbarViewController : BasicViewController
{
    UIViewController    *currentViewController;
    UIViewController    *lastViewController;
    NSMutableArray      *tabBarItemsArray;
    
    
    SchoolHomeViewController    *schoolHomeVC;
    AllCoursesViewController    *allCoursesVC;
    UserHomeViewController      *userHomeVC;
    AllTeachersViewController   *allTeaVC;
}
@property (weak, nonatomic) IBOutlet UIView *tabbarView;
@property (weak, nonatomic) IBOutlet UIImageView *tabbarBgImgView;

@property (nonatomic, strong, readonly) NSArray *viewControllers;
@property (nonatomic, assign, readonly) NSInteger currentIndex;

@end