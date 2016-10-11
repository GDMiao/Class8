//
//  FirstLoginViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/5/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "FirstLoginViewController.h"
#import "LoginViewController.h"
#import "RegisteredViewController.h"

@interface FirstLoginViewController ()<UIScrollViewDelegate>

@end

@implementation FirstLoginViewController

- (void)dealloc {
    self.scrollView = nil;
    self.registeredButton = nil;
    self.loginButton = nil;
    self.pageControl = nil;
    self.bjImg = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.titleView setTitleText:@"" withTitleStyle:CTitleStyle_FirstLogin];
    
    self.bjImg.frame = self.allContentView.bounds;
    self.bjImg.image = [UIImage imageNamed:[Utils vcbgImgName]];
    self.bjImg.contentMode = UIViewContentModeScaleAspectFill;


    
    self.loginButton.bottom = self.allContentView.height - 44;
    self.registeredButton.bottom = self.allContentView.height - 90;
    self.pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(0,self.registeredButton.top - 30, SCREENWIDTH, 20)];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    self.pageControl.coreNormalColor = [UIColor whiteColor];
    self.pageControl.strokeNormalColor = [UIColor whiteColor];
    self.pageControl.strokeSelectedColor = [UIColor whiteColor];
    self.pageControl.coreSelectedColor = [UIColor whiteColor];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.pageControlStyle = PageControlStyleStrokedCircle;
    [self.allContentView addSubview:self.pageControl];
    
    self.scrollView.frame = CGRectMake(0, IS_IOS7?20:0, SCREENWIDTH,self.pageControl.top - (IS_IOS7?20:0));
    self.scrollView.contentSize = CGSizeMake(SCREENWIDTH * 2, self.scrollView.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    

    UIImageView *imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - (192 - 82)) * 0.5, (self.scrollView.height - (160 - 22)) * 0.5, 192, 160)];
    imageview1.image = [UIImage imageNamed:@"Logo"];
    [self.scrollView addSubview:imageview1];
    
    
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, self.scrollView.height)];
    v2.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH + (SCREENWIDTH - 146) * 0.5, (self.scrollView.height - 290) * 0.5, 146, 290)];
    imageview2.image = [UIImage imageNamed:@"文曲星"];
    
    [v2 addSubview:imageview2];
    
    [self.scrollView addSubview:imageview2];

    self.registeredButton.left = (SCREENWIDTH - self.registeredButton.width) * 0.5;
    self.loginButton.left = (SCREENWIDTH - self.loginButton.width) * 0.5;
    [self.registeredButton setBackgroundImage:[UIImage imageNamed:@"注册按钮"] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"登录按钮"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offsetx = scrollView.contentOffset.x + SCREENWIDTH *0.5;
    int page = offsetx / SCREENWIDTH;
    [self.pageControl setCurrentPage:page];
    
}
- (IBAction)loginAction:(UIButton *)sender {
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    loginVC.isPushed = self.isPush;
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)registeredAction:(UIButton *)sender {
    RegisteredViewController *registVC = [[RegisteredViewController alloc] initWithRegistered:YES];
    [self.navigationController pushViewController:registVC animated:YES];
}
@end
