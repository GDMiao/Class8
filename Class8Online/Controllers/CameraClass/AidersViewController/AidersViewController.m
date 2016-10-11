//
//  AidersViewController.m
//  Class8Camera
//
//  Created by chuliangliang on 15/7/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//  Class8 小助手 ********

#import "AidersViewController.h"
#import "EditUserInfoViewController.h"
#import "CameraViewController.h"
#import "CNETModels.h"
#import "CameraClientManager.h"


@interface AidersViewController ()<CameraClientManagerDelegate>
@end
@implementation AidersViewController

- (void)dealloc
{
    self.bgImage = nil;
    self.nicknameLabel = nil;
    self.changeBtn = nil;
    self.codeTextField = nil;
    self.closeBtn = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.titleView setTitleText:CSLocalizedString(@"class8_VC_aiders_title") withTitleStyle:CTitleStyle_OnlyBack];
    
    self.bgImage.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.width/1.8497);
    
    
    self.nicknameLabel.text = [UserAccount shareInstance].deviceName;
    [self.nicknameLabel sizeToFit];
    CGFloat lableMaxWidth = self.allContentView.width - self.changeBtn.width - 20;
    if (self.nicknameLabel.width > lableMaxWidth) {
        self.nicknameLabel.width = lableMaxWidth;
    }
    self.nicknameLabel.left = (self.allContentView.width - self.nicknameLabel.width-self.changeBtn.width-20) * 0.5;
    self.nicknameLabel.top = self.bgImage.bottom+25;
    
    self.changeBtn.left = self.nicknameLabel.right + 13;
    self.changeBtn.top = self.nicknameLabel.top + (self.nicknameLabel.height - self.changeBtn.height) * 0.5;

    self.codeTextField.text = [UserAccount shareInstance].codeString;
    self.codeTextField.frame = CGRectMake(14, self.nicknameLabel.bottom+25, self.allContentView.width-28, 39);
    
    
    self.closeBtn.right = self.codeTextField.right - 13;
    self.closeBtn.top = self.codeTextField.top + (self.codeTextField.height - self.closeBtn.height) * 0.5;
    
    self.connectBtn.frame =CGRectMake(self.codeTextField.left, self.codeTextField.bottom+18, self.codeTextField.width, 41);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CSLog(@"%@",textField.text);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.codeTextField resignFirstResponder];
    return  YES;
}

- (BOOL)checkCode {
    NSString *code = [self.codeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (code.length <= 0) {
        [Utils showToast:CSLocalizedString(@"class8_VC_aiders_password_cannot_empty")];
        return NO;
    }
    if (code.length > 10) {
        [Utils showToast:CSLocalizedString(@"class8_VC_aiders_password_is_too_long")];
        return NO;
    }
    if (![Utils hasCameraAuthor]||![Utils canUseMic]) {
        return NO;
    }
    return YES;
}


- (IBAction)ChangeBtnClick:(id)sender {
    CSLog(@"修改");
    EditUserInfoViewController * edit = [[EditUserInfoViewController alloc] initWithEditStyle:EditUserInfoStyle_CameraDevName];
    edit.nameDivece = self.nicknameLabel.text;
    __weak AidersViewController *wself = self;
    [edit setBlock:^(NSString * nick){
        AidersViewController *sself = wself;
        sself.nicknameLabel.text = nick;
        [sself.nicknameLabel sizeToFit];
        CGFloat lableMaxWidth = sself.allContentView.width - sself.changeBtn.width - 20;
        if (sself.nicknameLabel.width > lableMaxWidth) {
            sself.nicknameLabel.width = lableMaxWidth;
        }
        sself.nicknameLabel.left = (sself.allContentView.width - sself.nicknameLabel.width-sself.changeBtn.width-20) * 0.5;
        sself.nicknameLabel.top = sself.bgImage.bottom+25;
        
        sself.changeBtn.left = sself.nicknameLabel.right + 13;
        sself.changeBtn.top = sself.nicknameLabel.top + (sself.nicknameLabel.height - sself.changeBtn.height) * 0.5;

    }];
    
    [self.navigationController pushViewController:edit animated:YES];
}

- (IBAction)connectAction:(UIButton *)sender {
    CSLog(@"连接课堂");
    [self.codeTextField resignFirstResponder];
    if ([self checkCode]) {
        [self showHUD:nil];
        [CAMERACLIENTMANAGER mobileConnectClassWithcode:self.codeTextField.text
                                             deviceName:self.nicknameLabel.text
                                       responseDelegate:self];
    }
    
}
- (IBAction)CloseBtnClick:(id)sender {
    self.codeTextField.text = @"";
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)pushToCameraVC:(long long)tid {
    [UserAccount shareInstance].codeString = self.codeTextField.text;
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:nil bundle:nil];
    cameraVC.tid = tid;
    [self.navigationController pushViewController:cameraVC animated:YES];
}


#pragma mark-
#pragma mark - CameraClientManagerDelegate
//成功后的回调
- (void) cameraClientManagerFinish:(id)value cNetworkRecType:(int) pType
{
    if (pType == CCP_MobileConnectClass) {
        [self showHUDSuccess:CSLocalizedString(@"class8_VC_aiders_test_successful")];
        MobileConnectClassRespModel* mobi = (MobileConnectClassRespModel *)value;
        long long tid = mobi.tid;
        [self pushToCameraVC:tid];
    }
}
//失败后的回调
- (void) cameraClientManagerFaild:(id)value cNetworkRecType:(int) pType
{
    if (pType == CCP_MobileConnectClass) {
        [self showHUDEorror:value];
    }else if (pType == CCP_NOT_Net){
        [self hiddenHUD];
        [Utils showAlert:(NSString *)value];
    }else {
        [self hiddenHUD];
    }
}

@end
