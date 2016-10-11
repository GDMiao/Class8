//
//  UserCenterViewController.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/14.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "StarsView.h"
@interface UserCenterViewController : BasicViewController




@property (weak, nonatomic) IBOutlet UIView *navContentView;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *navBjImg;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *headerDefaultImg;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *userSexImg;
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UIImageView *teaRzIcon; //教师认证标记
@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIView *teaHearderView;
@property (weak, nonatomic) IBOutlet UILabel *courseCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *line1;
@property (weak, nonatomic) IBOutlet UILabel *pfLabel;

@property (weak, nonatomic) IBOutlet StarsView *starsview;

@property (weak, nonatomic) IBOutlet UILabel *pfCountLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)chatAction:(UIButton *)sender;
- (IBAction)leftBtnAction:(UIButton *)sender;


- (id)initMyOrderResult:(User *)user;
- (id)initWithUser:(User *)user;
- (id)initWithUiD:(long long)uid isTeacher:(BOOL)isTea;
@end
