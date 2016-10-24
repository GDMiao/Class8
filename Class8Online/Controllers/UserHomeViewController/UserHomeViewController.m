//
//  UserHomeViewController.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/14.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "UserHomeViewController.h"
#import "UserHomeCell.h"
#import "MainViewController.h"
#import "AidersViewController.h"
#import "UserAccount.h"
#import "UIImageView+WebCache.h"
#import "UserCenterViewController.h"
#import "SettingViewController.h"
#import "PersonalInfoViewController.h"
#import "VideoViewController.h"
#import "LoginViewController.h"
#import "BasicNavigationController.h"

@interface UserHomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    NSMutableArray *tableViewData;
    BOOL didLoadUserInfo;
}
@end

@implementation UserHomeViewController

- (void)dealloc {
    [self resetHttp];
    self.topView = nil;
    self.topImageView= nil;
    self.tableView= nil;
    self.avatar = nil;
    self.nameLabel = nil;
    self.nickLabel = nil;
    self.schoolNameLabel = nil;
    self.editInfo = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    didLoadUserInfo = NO;
    self.topView.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.width/2.0915);//2.0915 为本地素材宽高比
    self.tableView.frame = CGRectMake(0, self.topView.bottom, self.allContentView.width, self.allContentView.height - self.topView.bottom-49);
    self.tableView.contentInset = UIEdgeInsetsMake(14, 0, 5, 0);
    self.tableView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadUserInfoData];
    [self _updateTopViewContent];
    [self createTableViewData];
}

- (void)_updateTopViewContent
{
    self.topImageView.image = [UIImage imageNamed:@"wbj"];
    self.avatar.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatar.layer.borderWidth = 1.5;
    self.avatar.layer.cornerRadius = self.avatar.width*0.5;
    self.avatar.layer.masksToBounds = YES;
    NSString *avatartUrl = [UserAccount shareInstance].loginUser.avatar;
    if ([avatartUrl rangeOfString:@"http://"].location == NSNotFound) {
        avatartUrl = [NSString stringWithFormat:@"%@%@",UserAvatarBasicUrl,avatartUrl];
//        CSLog(@"avatartUrl%@__",avatartUrl);
    }
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:avatartUrl] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    self.avatar.top = 28+(IS_IOS7 ? 20:0);
    CSLog(@"ios10: %d-- or ios7: %d--" , IS_IOS10 , IS_IOS7);

    self.avatar.left = 28;
    self.avatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *avaterTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapGestureAction:)];
    avaterTap.delegate = self;
    [self.avatar addGestureRecognizer:avaterTap];
    
    NSString *realName = [UserAccount shareInstance].loginUser.realname ? [UserAccount shareInstance].loginUser.realname:@"";
    self.nameLabel.text = realName.length > 0 ? realName : @"请登录";
    [self.nameLabel sizeToFit];
    self.nameLabel.top = self.avatar.top + 8;
    self.nameLabel.left = self.avatar.right + 15;
    
    NSString *nickstr = [UserAccount shareInstance].loginUser.nickName?[UserAccount shareInstance].loginUser.nickName:@"";
    self.nickLabel.text = nickstr.length > 0 ?[NSString stringWithFormat:@"(%@)",nickstr]: @"";
    [self.nickLabel sizeToFit];
    self.nickLabel.left = self.nameLabel.right + 9;
    self.nickLabel.bottom = self.nameLabel.bottom;
    
    NSString *schooleName = [Utils objectIsNotNull:[UserAccount shareInstance].loginUser.schoolName]?[UserAccount shareInstance].loginUser.schoolName:[UserAccount shareInstance].loginUser.company;
    self.schoolNameLabel.text = schooleName;
    self.schoolNameLabel.text = [UserAccount shareInstance].loginUser.signature;
    [self.schoolNameLabel sizeToFit];
    self.schoolNameLabel.top = self.nameLabel.bottom + 9;
    self.schoolNameLabel.left = self.nameLabel.left;
    self.editInfo.top = 10+(IS_IOS7?20:0);
    self.editInfo.right = self.topView.width - 14;
}

- (void)avatarTapGestureAction:(UITapGestureRecognizer *)tapGesture
{
    if (![UserAccount shareInstance].loginUser) {
        
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
        loginVC.isPushed = NO;
        BasicNavigationController *navFirstLoginVc = [[BasicNavigationController alloc] initWithRootViewController:loginVC];
        
//        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        [self presentViewController:navFirstLoginVc animated:YES completion:NULL];
        
       
    }

}

- (void)createTableViewData
{
    NSDictionary *item1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"icon_13",IconName,@"我的主页",TitleTxt_left, nil];
//    NSDictionary *item2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"icon_12",IconName,@"我的课程",TitleTxt_left, nil];
    NSDictionary *item3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"icon_11",IconName,@"课吧助手",TitleTxt_left, nil];
    NSDictionary *item4 = [[NSDictionary alloc] initWithObjectsAndKeys:@"icon_10",IconName,@"设置",TitleTxt_left, nil];
//    NSDictionary *item5 = [[NSDictionary alloc] initWithObjectsAndKeys:@"icon_11",IconName,@"录像播放测试",TitleTxt_left, nil];
//    NSDictionary *item6 = [[NSDictionary alloc] initWithObjectsAndKeys:@"icon_10",IconName,@"登录", TitleTxt_left,nil];
    
    tableViewData = [[NSMutableArray alloc] initWithObjects:item1,item3,item4, nil];
    [self.tableView reloadData];
}


- (void)loadUserInfoData
{
    if (didLoadUserInfo) {
        return;
    }
    [self resetHttp];
    [http_ getUserInfo:[UserAccount shareInstance].loginUser.uid userType:[UserAccount shareInstance].loginUser.authority==UserAuthorityType_TEACHER?UserAuthorityType_TEACHER:30 jsonResponseDelegate:self];
    [self showHUD:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self hiddenHUD];
    
    NSString * str = [request.url absoluteString];
    if ([str rangeOfString:@"mlistpersonaldata"].location != NSNotFound){
        //获取用户信息
        User *tmpUser = [[User alloc] initLoginUserInfoWithJSON:[request responseJSON]];
        if (tmpUser.code_ == 0) {
            didLoadUserInfo = YES;
            int user_authority = [UserAccount shareInstance].loginUser.authority;
            tmpUser.authority = user_authority;
            [UserAccount shareInstance].loginUser = tmpUser;
            [self _updateTopViewContent];
        }
    }else {
        [Utils showToast:CSLocalizedString(@"person_VC_net_unknow_error")];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hiddenHUD];
    [Utils showToast:CSLocalizedString(@"person_VC_net_faild")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableViewData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idtifier = @"userHome-cell";
    UserHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"UserHomeCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:idtifier];
        cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    }
    NSInteger idx = indexPath.row;
    cell.isLastCell = idx == (tableViewData.count-1);
    cell.idx = idx;
    [cell setCellContent:[tableViewData objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //我的主页
            if (![UserAccount shareInstance].loginUser) {
                CSLog(@"您未登录");
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您未登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
                [alertView show];
                return;
                
            }
            UserCenterViewController *userCenter = [[UserCenterViewController alloc] initWithUser:[UserAccount shareInstance].loginUser];
            [self.tabbarVC.navigationController pushViewController:userCenter animated:YES];
        }
            break;
//        case 1:
//        {
//            //我的课程
//            MainViewController *myCourseVC = [[MainViewController alloc] initWithNibName:nil bundle:nil];
//            [self.tabbarVC.navigationController pushViewController:myCourseVC animated:YES];
//        }
//            break;
        case 1:
        {
            //课吧助手
            AidersViewController *homeVC = [[AidersViewController alloc]initWithNibName:nil bundle:nil];
            [self.tabbarVC.navigationController pushViewController:homeVC animated:YES];

        }
            break;
        case 2:
        {
            //设置
            SettingViewController *setVC = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
            [self.tabbarVC.navigationController pushViewController:setVC animated:YES];
        }
            break;
        
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        CSLog(@"登录");
        [self showLoginVC];
    }
    
}
- (IBAction)editInfoAction:(UIButton *)sender {
    CSLog(@"编辑资料");
    PersonalInfoViewController *pinfoVC =[[PersonalInfoViewController alloc] initWithUser:[UserAccount shareInstance].loginUser];
    [self.tabbarVC.navigationController pushViewController:pinfoVC animated:YES];
}
@end
