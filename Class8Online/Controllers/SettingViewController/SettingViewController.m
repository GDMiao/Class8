//
//  SettingViewController.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"
#import "AboutViewController.h"
#import "EditUserInfoViewController.h"
#import "UserSafeViewController.h"
#import "NotificationTableViewCell.h"
#import "CNetworkManager.h"
#import "PersonalInfoViewController.h"
#import "KeepOnLineUtils.h"
#import "UIImageView+WebCache.h"
#import "MessageViewController.h"
#import "MySchoolViewController.h"
#import "NoticeSettingViewController.h"
#import "AidersViewController.h"
#import "HelpFeedbackViewController.h"


@interface SettingViewController ()<CNetworkCallBackDelegate>
@property (strong, nonatomic) NSMutableArray *tableViewData;
@end

@implementation SettingViewController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}
- (void)awakeFromNib {
}

- (void)dealloc {
    self.tableViewData = nil;
    self.settingTable= nil;
    self.nameStr = nil;
}
- (void)_initTableViewData {
    if (!self.tableViewData) {
        self.tableViewData = [[NSMutableArray alloc] init];
    }


    
    NSMutableArray * arr0 = [[NSMutableArray alloc] init];
    NSMutableDictionary *arr0_dic0 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"账号安全",SETTINGCELL_ICON,
                                      CSLocalizedString(@"setting_VC_userSafe"),SETTINGCELL_LEFTTITLE,
                                       nil];
    [arr0 addObject:arr0_dic0];
    
    NSMutableArray * arr1 = [[NSMutableArray alloc] init];
    NSMutableDictionary *arr1_dic0 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"课程提醒",SETTINGCELL_ICON,
                                      CSLocalizedString(@"setting_VC_course_remind"),SETTINGCELL_LEFTTITLE,
                                      nil];
    [arr1 addObject:arr1_dic0];
    NSMutableDictionary *arr1_dic1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"消息通知",SETTINGCELL_ICON,
                                      CSLocalizedString(@"setting_VC_msgCencer"),
                                      SETTINGCELL_LEFTTITLE, nil];
    [arr1 addObject:arr1_dic1];
   

    NSMutableArray * arr2 = [[NSMutableArray alloc] init];
    
//    NSMutableDictionary *arr2_dic0 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"仅通过Wi-Fi观看",SETTINGCELL_ICON,CSLocalizedString(@"setting_VC_onlyWiFi_Watch"),SETTINGCELL_LEFTTITLE, nil];
//    [arr2 addObject:arr2_dic0];
    
    NSMutableDictionary *arr2_dic1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"清楚缓存",SETTINGCELL_ICON,
                                      CSLocalizedString(@"setting_VC_clear_cache"),SETTINGCELL_LEFTTITLE,
                                      CSLocalizedString(@"setting_VC_calculate_cache"),SETTINGCELL_RIGHTTITLE, nil];

    [arr2 addObject:arr2_dic1];
    
    NSMutableDictionary *arr2_dic2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"帮助与反馈",SETTINGCELL_ICON,CSLocalizedString(@"settting_VC_help_feedback"),SETTINGCELL_LEFTTITLE, nil];
    [arr2 addObject:arr2_dic2];
    NSMutableDictionary *arr2_dic3 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"打赏我们吧,来个好评",SETTINGCELL_ICON,CSLocalizedString(@"settting_VC_reward_praise"),SETTINGCELL_LEFTTITLE, nil];
    [arr2 addObject:arr2_dic3];
    
    NSMutableDictionary *arr2_dic4 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"关于课吧",SETTINGCELL_ICON,
                                      CSLocalizedString(@"setting_VC_about"),SETTINGCELL_LEFTTITLE,
                                      [NSString stringWithFormat:@"V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]],SETTINGCELL_RIGHTTITLE, nil];
    [arr2 addObject:arr2_dic4];

    [self.tableViewData addObject:arr0];
    [self.tableViewData addObject:arr1];
    [self.tableViewData addObject:arr2];

    
    if ([UserAccount shareInstance].loginUser) {
        NSMutableArray * arr3 = [[NSMutableArray alloc] init];
        NSMutableDictionary *arr3_dic0 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"退出登录",SETTINGCELL_ICON,
                                          CSLocalizedString(@"setting_VC_exit"),SETTINGCELL_LEFTTITLE, nil];
        [arr3 addObject:arr3_dic0];
        [self.tableViewData addObject:arr3];
    }
    

    
    [self.settingTable reloadData];
}

- (void)updateUserInfo {
    CSLog(@"updateUserInfo");
    [self.tableViewData removeAllObjects];
    [self _initTableViewData];
    
    __weak SettingViewController *wself = self;
    [FILECACHEMANAGER getCacheFileSizeCallBack:^(NSString *sizeString) {
        SettingViewController *sself = wself;
        NSMutableDictionary *arr1_dic1 = [[sself.tableViewData objectAtIndex:2] objectAtIndex:0];
        [arr1_dic1 setObject:sizeString forKey:SETTINGCELL_RIGHTTITLE];
        [sself.settingTable reloadData];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:CSLocalizedString(@"setting_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];

    self.allContentView.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1];
    
    self.settingTable = [[UITableView alloc] initWithFrame:self.allContentView.bounds style:UITableViewStyleGrouped];
    self.settingTable.backgroundColor = [UIColor clearColor];
    self.settingTable.backgroundView = nil;
    self.settingTable.delegate = self;
    self.settingTable.dataSource = self;
    self.settingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.settingTable.contentInset = UIEdgeInsetsMake(0, 0, 54, 0);
    [self.allContentView addSubview:self.settingTable];
    
    __weak SettingViewController *wself = self;
    [FILECACHEMANAGER getCacheFileSizeCallBack:^(NSString *sizeString) {
        SettingViewController *sself = wself;
        NSMutableDictionary *arr2_dic1 = [[sself.tableViewData objectAtIndex:2] objectAtIndex:0];
        [arr2_dic1 setObject:sizeString forKey:SETTINGCELL_RIGHTTITLE];
        [sself.settingTable reloadData];
    }];
    
}
- (void)leftClicked:(TitleView *)view {
//    [self openLeftVC];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUserInfo];
}


#pragma mark -
#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableViewData) {
        return self.tableViewData.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableViewData) {
        return [[self.tableViewData objectAtIndex:section] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 13;
    }else if (section == 3){
        return 8;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idtifier = @"cell-setting";
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"SettingTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:idtifier];
        cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    }
    
    NSDictionary * dic = [[self.tableViewData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell setContentDic:dic];
    if (indexPath.row == 0) {
        cell.lineImg.hidden = YES;
    }
//    if(indexPath.section == 2 && indexPath.row == 0){
//        cell.onlywifi.hidden = NO;
//        cell.subTitleLab.hidden = YES;
//        cell.rightImg.hidden = YES;
//        
//    }
    if(indexPath.section == 3 && indexPath.row == 0){
        cell.onlywifi.hidden = YES;
        cell.subTitleLab.hidden = YES;
        cell.rightImg.hidden = YES;
        cell.titleLab.left = (cell.width - cell.titleLab.width) * 0.5;
        cell.titleLab.top = (cell.height - cell.titleLab.height) * 0.5;
        
        cell.titleLab.textAlignment = NSTextAlignmentCenter;
        cell.titleLab.textColor = MakeColor(0x19, 0x76, 0xd2);
        cell.titleLab.font = [UIFont systemFontOfSize:17];
        [cell.titleLab sizeToFit];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

- (void)switchChange:(UISwitch *)swtch
{
    if (swtch.isOn) {
        CSLog(@"开启");
    } else {
        CSLog(@"关闭");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {               //  账号安全
                if (![self showLoginVC]) {
                    UserSafeViewController * USVC = [[UserSafeViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:USVC animated:YES];
            }
        }
        }
            break;
        case 1: {
            if (indexPath.row == 0) {               //  课程提醒
                NoticeSettingViewController *noticeVC= [[NoticeSettingViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:noticeVC animated:YES];
            } else if (indexPath.row == 1) {        //  消息通知
                MessageViewController * messageVC = [[MessageViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:messageVC animated:YES];
            }
        }
            break;
        case 2: {
//            if (indexPath.row == 0) {
//                //
//                CSLog(@"仅在wifi下观看");
//            }
//            else
            if (indexPath.row == 0) {               //  清除缓存
                NSMutableDictionary * dic = [[self.tableViewData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                if (![[dic stringForKey:SETTINGCELL_RIGHTTITLE] isEqualToString:@"0.0kb"]) {
                    [self showHUD:CSLocalizedString(@"setting_VC_clearing_cache")];
                    __weak NSMutableDictionary *d = dic;
                    __weak SettingViewController *wself = self;
                    [FILECACHEMANAGER clearCacheFileCallBack:^(NSString *sizeString) {
                        [d setObject:sizeString forKey:SETTINGCELL_RIGHTTITLE];
                        SettingViewController *sself = wself;
                        [sself showHUDSuccess:nil];
                        [sself.settingTable reloadData];
                    }];
                }
            }else if (indexPath.row == 1){
                CSLog(@"帮助与反馈");
                HelpFeedbackViewController *helpFeedVC = [[HelpFeedbackViewController alloc]initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:helpFeedVC animated:YES];
                
            }else if (indexPath.row == 2){
                CSLog(@"打赏");
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppevaluationUrl]];
            }else if(indexPath.row == 3) {                                //  关于
                AboutViewController * aboutVC = [[AboutViewController alloc] init];
                [self.navigationController pushViewController:aboutVC animated:YES];
            }
        }
            break;
            
        case 3: {                                   //  退出账号
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                      delegate:self
                                                             cancelButtonTitle:CSLocalizedString(@"setting_VC_logout_cancel") destructiveButtonTitle:CSLocalizedString(@"setting_VC_logout") otherButtonTitles:nil, nil];
            [actionSheet showInView:self.view];
        }
            break;
            
        default:
            break;
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        CSLog(@"退出登录");
        [[UserAccount shareInstance] userLogout];
        [KEEPONELINEUTILS changToLoginServer];
        
//        [self showLoginVC];
    }else {
        CSLog(@"取消");
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
