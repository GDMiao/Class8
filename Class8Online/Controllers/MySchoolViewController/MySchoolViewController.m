//
//  MySchoolViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/8/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MySchoolViewController.h"
#import "UIImageView+WebCache.h"

@interface MySchoolViewController ()

@end

@implementation MySchoolViewController

- (void)dealloc {
    self.nameBjImg = nil;
    self.bjImgView = nil;
    self.nameLabel = nil;
    
    self.userName = nil;
    self.stuNumbaerLabel = nil;
    self.avatar = nil;

    self.bottomBjImg = nil;
    self.bottomView = nil;
    self.yxLabel = nil;
    self.yxLine = nil;
    self.zyLabel = nil;
    self.zyLine = nil;
    self.bjLabel = nil;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];    
    [self.titleView setTitleText:CSLocalizedString(@"mySchool_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    
    self.avatar.layer.cornerRadius = self.avatar.width * 0.5;
    self.avatar.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatar.layer.borderWidth = 2.0f;
    self.avatar.layer.masksToBounds = YES;
    
    
    [self updateUserEduInfo];
    //获取教育信息
    [self getUserEduInfo];
}

/**
 * 更新用户教育信息
 **/
- (void)updateUserEduInfo
{
    UIImage *bjImg = [UIImage imageNamed:[Utils getMySchoolBjImg]];
    CGSize showSize = bjImg.size;
    self.bjImgView.image = bjImg;
    self.bjImgView.size = showSize;
    self.bjImgView.top = (self.allContentView.height - self.bjImgView.height) * 0.5;
    self.bjImgView.left = (self.allContentView.width - self.bjImgView.width) * 0.5;
    
    
    UIImage *schoolNameBjimg = [UIImage imageNamed:@"我的学校底"];
    self.nameBjImg.image = schoolNameBjimg;
    
    self.nameLabel.text = [Utils objectIsNotNull:[UserAccount shareInstance].loginUser.schoolName]?[UserAccount shareInstance].loginUser.schoolName:@" ";
    [self.nameLabel sizeToFit];
    
    self.nameBjImg.frame = CGRectMake(40+ self.bjImgView.left, self.bjImgView.top + 18, self.bjImgView.width-80, self.nameLabel.height + 12);
    self.nameLabel.top  = (self.nameBjImg.height-self.nameLabel.height)*0.5 + self.nameBjImg.top;
    self.nameLabel.left = 15 + self.nameBjImg.left;
    self.nameLabel.width = self.nameBjImg.width -30;
    
    
    [self setBottomInfo];
    
    [self setCenterInfo];

}

- (void)setCenterInfo
{
    self.userName.text = [Utils objectIsNotNull:[UserAccount shareInstance].loginUser.realname]?[UserAccount shareInstance].loginUser.realname:[UserAccount shareInstance].loginUser.nickName;
    [self.userName sizeToFit];
    
    self.stuNumbaerLabel.text = [UserAccount shareInstance].loginUser.stuNo;
    [self.stuNumbaerLabel sizeToFit];
    
    NSString *avatartUrl = [UserAccount shareInstance].loginUser.avatar;
    if ([avatartUrl rangeOfString:@"http://"].location == NSNotFound) {
        avatartUrl = [NSString stringWithFormat:@"%@%@",UserAvatarBasicUrl,avatartUrl];
    }
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:avatartUrl] placeholderImage:[UIImage imageNamed:@"我的学校头像"]];
    
    CGFloat totalHieght = self.avatar.height + self.userName.height + self.stuNumbaerLabel.height + 10 + 8;
    
    self.avatar.top = (self.bottomView.top - self.nameBjImg.bottom - totalHieght) * 0.5 + self.nameBjImg.bottom;
    self.avatar.left = (self.bjImgView.width - self.avatar.width) * 0.5 + self.bjImgView.left;
    
    self.userName.top = self.avatar.bottom + 10;
    self.userName.left = (self.bjImgView.width - self.userName.width) * 0.5 + self.bjImgView.left;
    
    self.stuNumbaerLabel.top = self.userName.bottom + 8;
    self.stuNumbaerLabel.left = (self.bjImgView.width - self.stuNumbaerLabel.width) * 0.5 + self.bjImgView.left;
}

- (void)setBottomInfo{
    
    UIImage *bottomImg = [UIImage imageNamed:@"我的学校框"];
    [bottomImg resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    self.bottomBjImg.image = bottomImg;
    UIImage *line = [UIImage imageNamed:@"我的学校线"];
    line = [line resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.yxLine.image = line;
    self.zyLine.image = line;
    
    
    self.bottomView.bottom = self.bjImgView.bottom - 20;
    self.bottomView.left = self.bjImgView.left + (self.bjImgView.width - self.bottomView.width) * 0.5;
    
    //院系
    self.yxLabel.text = [NSString stringWithFormat:@"  %@:  %@",
                         CSLocalizedString(@"mySchool_VC_departments"),
                         [UserAccount shareInstance].loginUser.departments];
    //专业
    self.zyLabel.text = [NSString stringWithFormat:@"  %@:  %@",
                         CSLocalizedString(@"mySchool_VC_professional"),
                         [UserAccount shareInstance].loginUser.professional];
    //年级
    self.bjLabel.text = [NSString stringWithFormat:@"  %@:  %@",
                         CSLocalizedString(@"mySchool_VC_grade"),
                         [UserAccount shareInstance].loginUser.grade];
    
}

- (void)getUserEduInfo
{
    [self showHUD:nil];
    [self resetHttp];
    [http_ getUserEduInfo:[UserAccount shareInstance].uid jsonResponseDelegate:self];
}

#pragma mark - 
#pragma mark - HttpRequestDelegate
/**
 * http请求成功后的回调
 */
- (void)requestFinished:(ASIHTTPRequest *) request
{
    [self hiddenHUD];
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"mobilelistpersonaledudata"].location != NSNotFound) {
        //获取学生教育信息
        NSDictionary *eduDic = [request responseJSON];
        NSDictionary *eduinfoDic = [eduDic objectForKey:@"info"];
        if ([eduDic codeForKey:@"status"] == 0) {
            User *u = [UserAccount shareInstance].loginUser;
            u.schoolName = [eduinfoDic stringForKey:@"university"];
            u.stuNo = [eduinfoDic stringForKey:@"studentid"];
            u.departments = [eduinfoDic stringForKey:@"college"];
            u.professional = [eduinfoDic stringForKey:@"major"];
            u.grade = [eduinfoDic stringForKey:@"collegeClassName"];
            [self updateUserEduInfo];
        }else {
            [Utils showToast:CSLocalizedString(@"mySchool_VC_load_faild")];
        }
    }
    
}

/**
 * http请求失败后的回调
 */
- (void)requestFailed:(ASIHTTPRequest *) request
{
    [self hiddenHUD];
    [Utils showToast:CSLocalizedString(@"mySchool_VC_load_faild")];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
