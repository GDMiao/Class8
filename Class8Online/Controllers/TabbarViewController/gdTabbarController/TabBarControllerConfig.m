//
//  TabBarControllerConfig.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/2.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//
#import "BasicViewController.h"
#import "BasicNavigationController.h"
@import Foundation;
@import UIKit;
@interface CYLBaseNavigationController : UINavigationController
@end
@implementation CYLBaseNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end

#import "TabBarControllerConfig.h"
#import "AllCoursesViewController.h"
#import "AllTeachersViewController.h"
#import "SettingViewController.h"
#import "KeepOnLineUtils.h"
#import "SchoolHomeViewController.h"
#import "UserHomeViewController.h"
#define TabbarViewHeight 49.0f
#define IconSize CGSizeMake(27, 27)
#define ItemTitleLine 2.0f
@interface TabBarControllerConfig ()

//@property (nonatomic, readwrite, strong) CYLTabBarController *tabBarController;
//@property (nonatomic, readonly, strong) CYLTabBarController *tabBarController;
//@property (nonatomic, strong, readonly) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *viewControllers;
@end

@implementation TabBarControllerConfig

- (CYLTabBarController *)tabBarController
{
     if (_tabBarController == nil) {
         schoolHomeVC = [[SchoolHomeViewController alloc] initWithNibName:nil bundle:nil];
         schoolHomeVC.tabbarVC = self;
         schoolHomeVC.view.width = SCREENWIDTH;
         schoolHomeVC.view.height = SCREENHEIGHT;
         UINavigationController *firstNavigationController = [[BasicNavigationController alloc]
                                                              initWithRootViewController:schoolHomeVC];
         
         
         allCoursesVC = [[AllCoursesViewController alloc] initWithNibName:nil bundle:nil];
         allCoursesVC.tabbarVC = self;
         allCoursesVC.view.width = SCREENWIDTH;
         allCoursesVC.view.height = SCREENHEIGHT;
         UINavigationController *secondNavigationController = [[BasicNavigationController alloc]
                                                              initWithRootViewController:allCoursesVC];
         [secondNavigationController setNavigationBarHidden:YES];
         
      
         allTeaVC = [[AllTeachersViewController alloc]initWithNibName:nil bundle:nil];
         allTeaVC.tabbarVC = self;
         allTeaVC.view.width = SCREENWIDTH;
         allTeaVC.view.height = SCREENHEIGHT;
         UINavigationController *thirdNavigationController = [[BasicNavigationController alloc]
                                                               initWithRootViewController:allTeaVC];
         
         
         userHomeVC = [[UserHomeViewController alloc] initWithNibName:nil bundle:nil];
         userHomeVC.tabbarVC = self;
         userHomeVC.view.width = SCREENWIDTH;
         userHomeVC.view.height = SCREENHEIGHT;

         UINavigationController *fourthNavigationController = [[BasicNavigationController alloc]
                                                               initWithRootViewController:userHomeVC];

         CYLTabBarController *tabBarController = [[CYLTabBarController alloc] init];

                  self.viewControllers = @[
         firstNavigationController,
         secondNavigationController,
         thirdNavigationController,
         fourthNavigationController
         ];

         /**
          * 以下两行代码目的在于手动设置让TabBarItem只显示图标，不显示文字，并让图标垂直居中。
          * 等效于在`-setUpTabBarItemsAttributesForController`方法中不传`CYLTabBarItemTitle`字段。
          * 更推荐后一种做法。
          */
         //tabBarController.imageInsets = UIEdgeInsetsMake(4.5, 0, -4.5, 0);
         //tabBarController.titlePositionAdjustment = UIOffsetMake(0, MAXFLOAT);
         
         // 在`-setViewControllers:`之前设置TabBar的属性，设置TabBarItem的属性，包括 title、Image、selectedImage。
         [self setUpTabBarItemsAttributesForController:tabBarController];
         
         [tabBarController setViewControllers:self.viewControllers];
         // 更多TabBar自定义设置：比如：tabBarItem 的选中和不选中文字和背景图片属性、tabbar 背景图片属性
         [self customizeTabBarAppearance:tabBarController];
         _tabBarController = tabBarController;
     }
    return _tabBarController;
}

/**
 *  在`-setViewControllers:`之前设置TabBar的属性，设置TabBarItem的属性，包括 title、Image、selectedImage。
 */
- (void)setUpTabBarItemsAttributesForController:(CYLTabBarController *)tabBarController {
    
    //alloc init items
    NSArray *nomalIcons = @[@"icon_6-1",@"icon_4-1",@"icon_3-1"];
    NSArray *hIcons = @[@"icon_6",@"icon_4",@"icon_3"];
    NSDictionary *dict1 = @{
                            CYLTabBarItemTitle : @"Piano",
                            CYLTabBarItemImage : @"icon_6-1",
                            CYLTabBarItemSelectedImage : @"icon_6",
                            };
    NSDictionary *dict2 = @{
                            CYLTabBarItemTitle : @"课程",
                            CYLTabBarItemImage : @"icon_4-1",
                            CYLTabBarItemSelectedImage : @"icon_4",
                            };
    NSDictionary *dict3 = @{
                            CYLTabBarItemTitle : @"老师",
                            CYLTabBarItemImage : @"icon_3-1",
                            CYLTabBarItemSelectedImage : @"icon_3",
                            };
    NSDictionary *dict4 = @{
                            CYLTabBarItemTitle : @"我的",
                            CYLTabBarItemImage : @"icon_3-1",
                            CYLTabBarItemSelectedImage : @"icon_3"
                            };
    NSArray *tabBarItemsAttributes = @[
                                       dict1,
                                       dict2,
                                       dict3,
                                       dict4
                                       ];
    tabBarController.tabBarItemsAttributes = tabBarItemsAttributes;
}

/**
 *  更多TabBar自定义设置：比如：tabBarItem 的选中和不选中文字和背景图片属性、tabbar 背景图片属性
 */
- (void)customizeTabBarAppearance:(CYLTabBarController *)tabBarController {
#warning CUSTOMIZE YOUR TABBAR APPEARANCE
    // Customize UITabBar height
    // 自定义 TabBar 高度
    // tabBarController.tabBarHeight = 40.f;
    
    // set the text color for unselected state
    // 普通状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    // set the text color for selected state
    // 选中状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
    
    // set the text Attributes
    // 设置文字属性
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    // Set the dark color to selected tab (the dimmed background)
    // TabBarItem选中后的背景颜色
    // [self customizeTabBarSelectionIndicatorImage];
    
    // update TabBar when TabBarItem width did update
    // If your app need support UIDeviceOrientationLandscapeLeft or UIDeviceOrientationLandscapeRight，
    // remove the comment '//'
    // 如果你的App需要支持横竖屏，请使用该方法移除注释 '//'
    // [self updateTabBarCustomizationWhenTabBarItemWidthDidUpdate];
    
    // set the bar shadow image
    // This shadow image attribute is ignored if the tab bar does not also have a custom background image.So at least set somthing.
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UITabBar appearance] setShadowImage:[UIImage imageNamed:@"tapbar_top_line"]];
    
    // set the bar background image
    // 设置背景图片
    // UITabBar *tabBarAppearance = [UITabBar appearance];
    // [tabBarAppearance setBackgroundImage:[UIImage imageNamed:@"tabbar_background"]];
    
    // remove the bar system shadow image
    // 去除 TabBar 自带的顶部阴影
    // [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
}

- (void)updateTabBarCustomizationWhenTabBarItemWidthDidUpdate {
    void (^deviceOrientationDidChangeBlock)(NSNotification *) = ^(NSNotification *notification) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if ((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) {
            NSLog(@"Landscape Left or Right !");
        } else if (orientation == UIDeviceOrientationPortrait){
            NSLog(@"Landscape portrait!");
        }
        [self customizeTabBarSelectionIndicatorImage];
    };
    [[NSNotificationCenter defaultCenter] addObserverForName:CYLTabBarItemWidthDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:deviceOrientationDidChangeBlock];
}

- (void)customizeTabBarSelectionIndicatorImage {
    ///Get initialized TabBar Height if exists, otherwise get Default TabBar Height.
    UITabBarController *tabBarController = [self cyl_tabBarController] ?: [[UITabBarController alloc] init];
    CGFloat tabBarHeight = tabBarController.tabBar.frame.size.height;
    CGSize selectionIndicatorImageSize = CGSizeMake(CYLTabBarItemWidth, tabBarHeight);
    //Get initialized TabBar if exists.
    UITabBar *tabBar = [self cyl_tabBarController].tabBar ?: [UITabBar appearance];
    [tabBar setSelectionIndicatorImage:
     [[self class] imageWithColor:[UIColor redColor]
                             size:selectionIndicatorImageSize]];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width + 1, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
