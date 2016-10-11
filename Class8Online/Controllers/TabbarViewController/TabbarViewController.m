//
//  TabbarViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/8/6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "TabbarViewController.h"
#import "AllCoursesViewController.h"
#import "AllTeachersViewController.h"
#import "SettingViewController.h"
#import "KeepOnLineUtils.h"
#import "SchoolHomeViewController.h"
#import "UserHomeViewController.h"
#define TabbarViewHeight 49.0f
#define IconSize CGSizeMake(27, 27)
#define ItemTitleLine 2.0f


@interface TabbarItem : UIView

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *button;


- (void)setIconHighlightImg:(UIImage *)hImg; /*选中时的文本颜色*/
- (void)setTextHighlightColor:(UIColor *)hColor; /*选中时的文本颜色*/

- (id)initWithFrame:(CGRect)frame aIcon:(UIImage *)icon aTitle:(NSString *)title;
- (void)addTarget:(id)target action:(SEL)action;
- (void)didSelected:(BOOL)select;
@end


@implementation TabbarItem

- (id)initWithFrame:(CGRect)frame aIcon:(UIImage *)icon aTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        //icon
        if(icon) {
            self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IconSize.width, IconSize.height)];
            self.iconImgView.image = icon;
            self.iconImgView.highlightedImage = icon;
            self.iconImgView.highlighted = NO;
            [self addSubview:self.iconImgView];
        }
        
        //lable
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        self.titleLabel.textColor = [UIColor colorWithRed:104/255.0 green:108/255.0 blue:113/255.0 alpha:1];
        self.titleLabel.highlightedTextColor = [UIColor colorWithRed:104/255.0 green:108/255.0 blue:113/255.0 alpha:1];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = title;
        [self.titleLabel sizeToFit];
        [self addSubview:self.titleLabel];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = self.bounds;
        self.button.adjustsImageWhenDisabled = NO;
        self.button.adjustsImageWhenHighlighted = NO;
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews {
    
    CGRect iconRect = self.iconImgView.frame;
    CGRect labelRect = self.titleLabel.frame;
    CGSize vSize = self.frame.size;
    
    iconRect.origin.x = (vSize.width - iconRect.size.width) * 0.5;
    iconRect.origin.y = (vSize.height - iconRect.size.height - labelRect.size.height -ItemTitleLine) * 0.5;
    
    labelRect.origin.x = (vSize.width - labelRect.size.width) * 0.5;
    labelRect.origin.y = iconRect.origin.y+ItemTitleLine + iconRect.size.height;
    
    self.iconImgView.frame = iconRect;
    self.titleLabel.frame = labelRect;
    
    self.button.frame = self.bounds;
}

- (void)didSelected:(BOOL)select
{
    self.iconImgView.highlighted = select;
    self.titleLabel.highlighted = select;
}

/*选中时的文本颜色*/
- (void)setIconHighlightImg:(UIImage *)hImg
{
    self.iconImgView.highlightedImage = hImg;
}

/*选中时的文本颜色*/
- (void)setTextHighlightColor:(UIColor *)hColor
{
    self.titleLabel.highlightedTextColor = hColor;
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    self.button.tag = tag;
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
@end



@interface TabbarViewController ()
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation TabbarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        

        
        
        schoolHomeVC = [[SchoolHomeViewController alloc] initWithNibName:nil bundle:nil];
        schoolHomeVC.tabbarVC = self;
        schoolHomeVC.view.width = SCREENWIDTH;
        schoolHomeVC.view.height = SCREENHEIGHT;
        
        
        allCoursesVC = [[AllCoursesViewController alloc] initWithNibName:nil bundle:nil];
        allCoursesVC.tabbarVC = self;
        allCoursesVC.view.width = SCREENWIDTH;
        allCoursesVC.view.height = SCREENHEIGHT;
//        [secondNavigationController setNavigationBarHidden:YES];
        
        
        allTeaVC = [[AllTeachersViewController alloc]initWithNibName:nil bundle:nil];
        allTeaVC.tabbarVC = self;
        allTeaVC.view.width = SCREENWIDTH;
        allTeaVC.view.height = SCREENHEIGHT;
        
        
        userHomeVC = [[UserHomeViewController alloc] initWithNibName:nil bundle:nil];
        userHomeVC.tabbarVC = self;
        userHomeVC.view.width = SCREENWIDTH;
        userHomeVC.view.height = SCREENHEIGHT;

        
        self.viewControllers = [NSArray arrayWithObjects:schoolHomeVC,allCoursesVC, allTeaVC,userHomeVC, nil];
        
        //注册登录成功的通知 <自动登录/手动登录>
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccess) name:KNotificationDidLoginSuccess object:nil];

    }
    
    return self;
}

/**
 *登录成功
 **/
- (void)LoginSuccess {
    [schoolHomeVC beginLoadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentIndex =0;
    [self changeVCWithindex:self.currentIndex];
    
    self.tabbarBgImgView.userInteractionEnabled = YES;
    self.allContentView.backgroundColor = [UIColor blackColor];
    self.tabbarView.frame = CGRectMake(0, self.allContentView.height - TabbarViewHeight, self.allContentView.width, TabbarViewHeight);
    UIImage *tabbarImg = [UIImage imageNamed:@"tabbar底"];
    tabbarImg = [tabbarImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.tabbarBgImgView.image = tabbarImg;
    
    //alloc init items
    NSArray *nomalIcons = @[@"DHome20-2",@"DHome23-2",@"DHome21-2",@"DHome22-2"];
    NSArray *hIcons = @[@"DHome20",@"DHome23",@"DHome21",@"DHome22"];
//    NSArray *titles = @[@"学校",CSLocalizedString(@"tab_VC_clasListText"),CSLocalizedString(@"tab_VC_courseText"),CSLocalizedString(@"tab_VC_userAccount")];
    
    NSUInteger itemsCount = self.viewControllers.count;
    CGSize itemSize = CGSizeMake(self.tabbarBgImgView.bounds.size.width / itemsCount, TabbarViewHeight);
    float x = 0;
    for (int i = 0; i < itemsCount; i ++) {
        NSString *nomalImgName = nomalIcons[i];
        NSString *hImgName = hIcons[i];
//        NSString *titleText = titles[i];
        NSString *titleText = @"";

        
        TabbarItem *tmpTabbarItem = [[TabbarItem alloc] initWithFrame:CGRectMake(x, 0, itemSize.width, itemSize.height)
                                                                aIcon:[UIImage imageNamed:nomalImgName]
                                                               aTitle:titleText];
        x += itemSize.width;
        tmpTabbarItem.tag = i;
        [tmpTabbarItem setTextHighlightColor:[UIColor colorWithRed:23/255.0 green:95/255.0 blue:199/255.0 alpha:1]];
        [tmpTabbarItem setIconHighlightImg:[UIImage imageNamed:hImgName]];
        [tmpTabbarItem addTarget:self action:@selector(selectItemAction:)];
        [tmpTabbarItem didSelected:(self.currentIndex == i)];
        [self.tabbarBgImgView addSubview:tmpTabbarItem];
    }

    if ([UserAccount shareInstance].autoLogin) {
        [self showHUD:nil];
    }
}

- (void)selectItemAction:(TabbarItem *)item {
    NSInteger index = item.tag;
    if (self.currentIndex == index) {
        return;
    }
    
    self.currentIndex = index;
    [self.tabbarBgImgView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TabbarItem *tmpTabbarItem = (TabbarItem *)obj;
        [tmpTabbarItem didSelected:(self.currentIndex == idx)];
        
    }];
    CSLog(@"选择index: %ld",(long)item.tag);
   
    
    [self changeVCWithindex:self.currentIndex];
}

- (void)changeVCWithindex:(NSInteger )idx
{
    if (currentViewController) {
        [currentViewController.view removeFromSuperview];
    }
    currentViewController = [self.viewControllers objectAtIndex:idx];
    [self.allContentView insertSubview:currentViewController.view atIndex:0];
}

@end
