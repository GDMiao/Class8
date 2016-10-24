//
//  PersonalInfoViewController.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "SexSelectViewController.h"
#import "EditUserInfoViewController.h"
#import "PersonalInfoTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UserDescriptionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ChangePhoneNumberViewController.h"
#import "BirthdayPickView.h"

typedef enum {
    PersonalRequestStyle_Unknown = 0,
    PersonalRequestStyle_GetUserInfo,
    PersonalRequestStyle_UploadAvaatr,
    PersonalRequestStyle_UpdateAvatar,
    PersonalRequestStyle_UpdateBirthDay,
}PersonalRequestStyle;

#define TableView_SECTION @"section_"
@interface PersonalInfoViewController ()
{
    BOOL isMySelf;
    NSString *newUerAvaatrUrl;
    long long birthday;
}
@property (nonatomic, strong) NSMutableDictionary *tableViewDataDic;
@property (nonatomic, assign) PersonalRequestStyle requestStyle;
@property (nonatomic, strong) BirthdayPickView *birPick;

@end

@implementation PersonalInfoViewController
@synthesize requestStyle;
- (id)initWithUser:(User *)user
{
    self = [super  initWithNibName:nil bundle:nil];
    if (self) {
        self.user = user;
        if (self.user.uid == [UserAccount shareInstance].uid) {
            isMySelf = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    self.tableView = nil;
    self.user = nil;
    self.birPick = nil;
    self.tableViewDataDic = nil;
    if (newUerAvaatrUrl) {
        newUerAvaatrUrl = nil;
    }
}

- (void)createTableViewData
{
    if (!self.tableViewDataDic) {
        self.tableViewDataDic = [[NSMutableDictionary alloc] init];
    }
    [self.tableViewDataDic removeAllObjects];

    NSMutableDictionary *section1_dic1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"头像",LEFT_TXT,self.user.avatar,AvatarUsrl,[NSNumber numberWithBool:YES],HAS_EDIT,nil];
    NSMutableDictionary *section1_dic2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"用户ID",LEFT_TXT,[NSString stringWithFormat:@"%lld",self.user.uid],RIGHT_TXT,nil];
    NSMutableDictionary *section1_dic3 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"姓名",LEFT_TXT,self.user.realname,RIGHT_TXT,nil];
    NSMutableDictionary *section1_dic4 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"昵称",LEFT_TXT,self.user.nickName,RIGHT_TXT,[NSNumber numberWithBool:YES],HAS_EDIT,nil];
    NSMutableDictionary *section1_dic5 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"手机号",LEFT_TXT,self.user.mobile,RIGHT_TXT,[NSNumber numberWithBool:YES],HAS_EDIT,nil];
    NSMutableArray *section1 = [[NSMutableArray alloc] initWithObjects:section1_dic1,section1_dic2,section1_dic3,section1_dic4,section1_dic5, nil];

/*
    NSMutableDictionary *section2_dic1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"学校",LEFT_TXT,self.user.schoolName,RIGHT_TXT,nil];
    NSMutableDictionary *section2_dic2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"院系",LEFT_TXT,self.user.departments,RIGHT_TXT,nil];
    NSMutableDictionary *section2_dic3 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"专业",LEFT_TXT,self.user.professional,RIGHT_TXT,nil];
    NSMutableDictionary *section2_dic4 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"班级",LEFT_TXT,self.user.grade,RIGHT_TXT,nil];
    NSMutableDictionary *section2_dic5 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"身份",LEFT_TXT,self.user.authority==UserAuthorityType_TEACHER?@"老师":@"学生",RIGHT_TXT,nil];
    NSMutableArray *section2 = [[NSMutableArray alloc] initWithObjects:section2_dic1,section2_dic2,section2_dic3,section2_dic4,section2_dic5, nil];
*/

    NSMutableDictionary *section3_dic1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"性别",LEFT_TXT,self.user.gender==UserGender_MALE?@"男":@"女",RIGHT_TXT,[NSNumber numberWithBool:YES],HAS_EDIT,nil];
    
    
    NSString *birString = [Utils birthdayString:self.user.birthday];
    
    NSMutableDictionary *section3_dic2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"生日",LEFT_TXT,birString,RIGHT_TXT,[NSNumber numberWithBool:YES],HAS_EDIT,nil];
    NSMutableDictionary *section3_dic3 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"签名",LEFT_TXT,self.user.description__,RIGHT_TXT,[NSNumber numberWithBool:YES],HAS_EDIT,nil];
    NSMutableArray *section3 = [[NSMutableArray alloc] initWithObjects:section3_dic1,section3_dic2,section3_dic3, nil];

    [self.tableViewDataDic setObject:section1 forKey:[NSString stringWithFormat:@"%@%d",TableView_SECTION,0]];
//    [self.tableViewDataDic setObject:section2 forKey:[NSString stringWithFormat:@"%@%d",TableView_SECTION,1]];
    [self.tableViewDataDic setObject:section3 forKey:[NSString stringWithFormat:@"%@%d",TableView_SECTION,1]];
    
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    requestStyle = PersonalRequestStyle_Unknown;
    birthday = 0;
    
    [self.titleView setTitleText:CSLocalizedString(@"person_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.allContentView.width, self.allContentView.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:247/255.0 alpha:1];;
    if (IS_IOS7) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if (IS_IOS8) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    [self.allContentView addSubview:self.tableView];
    [self createTableViewData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (PersonalRequestStyle_GetUserInfo == requestStyle) {
        //暂时弃用  永久为No
//        [self resetHttp];
//        [http_ getUserInfo:0 userType:self.user.authority ==UserAuthorityType_TEACHER?40:30 jsonResponseDelegate:self];
//        [self showHUD:nil];
    }
}


#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableViewDataDic.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.tableViewDataDic arrayForKey:[NSString stringWithFormat:@"%@%ld",TableView_SECTION,(long)section]];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [self.tableViewDataDic arrayForKey:[NSString stringWithFormat:@"%@%ld",TableView_SECTION,(long)indexPath.section]];
    return [[PersonalInfoTableViewCell sharePersonalInfoCell] updateCellContent:[arr objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *idtifier = @"person-cell";
    PersonalInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"PersonalInfoTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:idtifier];
        cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    }
    NSArray *arr = [self.tableViewDataDic arrayForKey:[NSString stringWithFormat:@"%@%ld",TableView_SECTION,(long)indexPath.section]];
    cell.hasTopLine = indexPath.row==0;
    cell.hasBottomLine = arr.count-1==indexPath.row;
    [cell updateCellContent:[arr objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *arr = [self.tableViewDataDic arrayForKey:[NSString stringWithFormat:@"%@%ld",TableView_SECTION,(long)indexPath.section]];
    NSDictionary *dic =[arr objectAtIndex:indexPath.row];
    BOOL hasEdit = [dic boolForKey:HAS_EDIT];
    if (hasEdit) {
        NSString *txt_title = [dic stringForKey:LEFT_TXT];
        if ([txt_title isEqualToString:@"头像"]) {
            //编辑头像
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                      delegate:self
                                                             cancelButtonTitle:CSLocalizedString(@"person_VC_takePhoto_cancel")
                                                        destructiveButtonTitle:nil
                                                             otherButtonTitles:CSLocalizedString(@"person_VC_takePhoto"),
                                           CSLocalizedString(@"person_VC_photoslib"),nil];
            [actionSheet showInView:self.view];

        }else if ([txt_title isEqualToString:@"昵称"]){
            //昵称
            __weak PersonalInfoViewController *wself = self;
            EditUserInfoViewController * editVC = [[EditUserInfoViewController alloc] initWithEditStyle:EditUserInfoStyle_OnlyNick];
            editVC.uid = self.user.uid;
            [editVC setBlock:^(NSString * nick){
                PersonalInfoViewController *sself = wself;
                sself.user.nickName = nick;
                [sself createTableViewData];
            }];
            [self.navigationController pushViewController:editVC animated:YES];

        }else if ([txt_title isEqualToString:@"手机号"]){
            //手机号
            __weak PersonalInfoViewController *wself = self;
            ChangePhoneNumberViewController * changeVC = [[ChangePhoneNumberViewController alloc] initWithNibName:nil bundle:nil];
            [changeVC setBlock:^(NSString *newMobi){
                PersonalInfoViewController *sself = wself;
                sself.user.mobile = newMobi;
                [sself createTableViewData];
            }];
            [self.navigationController pushViewController:changeVC animated:YES];

        }else if ([txt_title isEqualToString:@"性别"]){
            //性别
            __weak PersonalInfoViewController *wself = self;
            SexSelectViewController *sexVC = [[SexSelectViewController alloc] initWithNibName:nil bundle:nil];
            sexVC.uid = self.user.uid;
            sexVC.userSex = self.user.gender;
            [sexVC setBlock:^(int sex){
                PersonalInfoViewController *sself = wself;
                sself.user.gender = sex;
                [sself createTableViewData];
            }];
            [self.navigationController pushViewController:sexVC animated:YES];
        }else if ([txt_title isEqualToString:@"生日"]){
            //生日
            if (!self.birPick) {
                __weak PersonalInfoViewController *wself = self;
                self.birPick = [[BirthdayPickView alloc] initWithFrame:self.allContentView.bounds];
                [self.birPick setBlock:^(BOOL isCancel, NSDate *birDate){
                    PersonalInfoViewController *sself = wself;
                    [sself updateUserBirthday:birDate isCancel:isCancel];
                }];
                [self.allContentView addSubview:self.birPick];
            }
            [self.birPick showOrHidden:YES];
            
        }else if ([txt_title isEqualToString:@"签名"]){
            //签名
            __weak PersonalInfoViewController *wself = self;
            UserDescriptionViewController * descriptionVC = [[UserDescriptionViewController alloc] initWithNibName:nil bundle:nil];
            descriptionVC.uid = self.user.uid;
            descriptionVC.oldDescriptionTxt = self.user.description__;
            [descriptionVC setDescriptionCallBack:^(NSString *newDesTxt){
                PersonalInfoViewController *sself = wself;
                sself.user.description__ = newDesTxt;
                [sself createTableViewData];
            }];
            [self.navigationController pushViewController:descriptionVC animated:YES];
        }

    }
}

#pragma mark - ACTIONSHEET

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self showCamera];
    } else if (buttonIndex == 1) {
        [self selectExistingPicture];
    }
}

//=========================================
// 相册和相机
//=========================================
-(void)showCamera
{
    //判断是否有拍照功能
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if (IS_IOS7) {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];  //获取对摄像头的访问权限
            if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:CSLocalizedString(@"person_VC_not_takePhoto")
                                                               delegate:nil
                                                      cancelButtonTitle:CSLocalizedString(@"person_VC_takePhoto_alert_ok")
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        //模式窗体转化到图片选取界面
        UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
        imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        //将图片选取器呈现给用户
        [self presentViewController:imagePickerController animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:CSLocalizedString(@"person_VC_no_campare")
                              delegate:nil
                              cancelButtonTitle:CSLocalizedString(@"person_VC_takePhoto_cancel")
                              otherButtonTitles:nil];
        [alert show];
    }
}

//选取相册中的图片
- (void)selectExistingPicture
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker =[[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:CSLocalizedString(@"person_VC_not_photoslib")
                              message:CSLocalizedString(@"person_VC_no_photoslib")
                              delegate:nil
                              cancelButtonTitle:CSLocalizedString(@"person_VC_takePhoto_cancel")
                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * img = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imgData = UIImageJPEGRepresentation(img, 0.6);

    requestStyle = PersonalRequestStyle_UploadAvaatr;
    [self showHUD:nil];
    [self resetHttp];
    [http_ uploadUserAvatar:imgData userId:self.user.uid jsonResponseDelegate:self];

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateUserBirthday:(NSDate *)birDate isCancel:(BOOL)cancel
{
 
    if (!cancel) {
        requestStyle = PersonalRequestStyle_UpdateBirthDay;
        [self showHUD:nil];
        [self resetHttp];
        long long  birTimeInterval = [birDate timeIntervalSince1970];
        birthday = birTimeInterval;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:[NSNumber numberWithLongLong:birTimeInterval] forKey:@"newBirthDay"];
        [params setValue:[NSNumber numberWithLongLong:self.user.uid] forKey:@"userid"];
        [http_  updateUserInfoparams:params jsonResponseDelegate:self];

    }
    [self.birPick showOrHidden:NO];

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (PersonalRequestStyle_UploadAvaatr != requestStyle) {
        [self hiddenHUD];
    }
    NSString * str = [request.url absoluteString];
    if ([str rangeOfString:@"upload/avatar"].location != NSNotFound) {
        NSDictionary * dic = [request responseJSON];
        if ([dic codeForKey:@"status"] != 0) {
            [self hiddenHUD];
            [Utils showToast:CSLocalizedString(@"person_VC_upload_avatar_faild")];
            requestStyle = PersonalRequestStyle_Unknown;
            return;
        }
        requestStyle = PersonalRequestStyle_UpdateAvatar;
        newUerAvaatrUrl = [dic stringForKey:@"url"];
        [self resetHttp];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:newUerAvaatrUrl forKey:@"avatarUrl"];
        [params setValue:[NSNumber numberWithLongLong:self.user.uid] forKey:@"userid"];
        [http_  updateUserInfoparams:params jsonResponseDelegate:self];

        
    }else if ([str rangeOfString:@"mobileupdatepersonaldata"].location != NSNotFound) {
        //更新用户信息
        NSDictionary *dic = [request responseJSON];
        int code_status = [dic codeForKey:@"status"];
        if (code_status == 0) {
            [Utils showToast:@"更新成功"];
            switch (requestStyle) {
                case PersonalRequestStyle_UpdateAvatar:
                {
                    //更新用户头像
                    self.user.avatar = newUerAvaatrUrl;
                    [self createTableViewData];
                }
                    break;
                case PersonalRequestStyle_UpdateBirthDay:
                {
                    //更新用户生日
                    self.user.birthday = birthday;
                    [self createTableViewData];
                }
                    break;
                default:
                    break;
            }
        }else {
            [Utils showToast:@"更新失败"];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hiddenHUD];    
    NSString * str = [request.url absoluteString];
    if ([str rangeOfString:@"user_avatar"].location != NSNotFound ) {
        [Utils showToast:CSLocalizedString(@"person_VC_upload_avatar_faild")];
    }else {
        [Utils showToast:CSLocalizedString(@"person_VC_net_faild")];
    }
}

@end
