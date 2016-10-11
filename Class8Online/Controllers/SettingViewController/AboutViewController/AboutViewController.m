//
//  AboutViewController.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "AboutViewController.h"
#import "QRCodeViewController.h"
#define TOPIMGTAG 7663

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)dealloc
{
    self.iconImg = nil;
    self.version = nil;
    self.topImg = nil;
    self.bottomImg = nil;
    self.topLabel = nil;
    self.bottomLabel = nil;
    self.statusSubLabel = nil;
    self.statusLabel = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.topLabel.text = CSLocalizedString(@"about_VC_download");
    self.bottomLabel.text = CSLocalizedString(@"about_VC_go_AppStore");
    self.statusLabel.text = CSLocalizedString(@"about_VC_status_text");
    self.statusSubLabel.text = CSLocalizedString(@"about_VC_status_sub_text");
    
    
    [self.titleView setTitleText:CSLocalizedString(@"about_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    
    self.version.text = [NSString stringWithFormat:@"Class8 V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    self.iconImg.left = (SCREENWIDTH - self.iconImg.width) / 2;
    
    self.topImg.width = SCREENWIDTH;
    self.topImg.backgroundColor = [UIColor whiteColor];
    self.topLabel.top = (self.topImg.height - self.topLabel.height) / 2;
    [self.topImg addSubview:self.topLabel];
    UIImageView * arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头"]];
    arrowImg.size = CGSizeMake(8, 14);
    arrowImg.right = self.topImg.width - 15;
    arrowImg.top = self.topImg.height / 2 - (arrowImg.height / 2);
    [self.topImg addSubview:arrowImg];
    
    self.bottomImg.width = SCREENWIDTH;
    self.bottomImg.backgroundColor = [UIColor whiteColor];
    self.bottomLabel.top = (self.topImg.height - self.topLabel.height) / 2;
    [self.bottomImg addSubview:self.bottomLabel];
    UIImageView * arrowImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头"]];
    arrowImg2.size = CGSizeMake(8, 14);
    arrowImg2.right = self.topImg.width - 15;
    arrowImg2.top = self.topImg.height / 2 - (arrowImg.height / 2);
    [self.bottomImg addSubview:arrowImg2];
    
    UIImageView * lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, self.bottomImg.width - 8, 1)];
    lineImg.image = [UIImage imageNamed:@"分隔线"];
    [self.bottomImg addSubview:lineImg];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topClick)];
    [self.topImg addGestureRecognizer:tap];
    self.topImg.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomClick)];
    [self.bottomImg addGestureRecognizer:tap2];
    self.bottomImg.userInteractionEnabled = YES;
    
}

- (void)topClick
{
    CSLog(@"二维码扫描");
    QRCodeViewController *qrcodeVC = [[QRCodeViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:qrcodeVC animated:YES];
}

- (void)bottomClick
{
    CSLog(@"去APP评分");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppevaluationUrl]];
}

@end
