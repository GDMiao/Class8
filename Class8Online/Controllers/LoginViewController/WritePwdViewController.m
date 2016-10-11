//
//  WritePwdViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "WritePwdViewController.h"
#import "EditUserInfoViewController.h"
#import "KeepOnLineUtils.h"

#define FIRSTtEXT 3006
#define SECTEXT 3007
@interface WritePwdViewController ()
{
    UITapGestureRecognizer *tapGesture;
}
@property (assign, nonatomic) WritePwdVCType vcType;
@end

@implementation WritePwdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil aVCType:(WritePwdVCType )p
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.vcType = p;
    }
    return self;
}

- (void)dealloc {
    self.scrollView = nil;
    self.firstPwdTextField = nil;
    self.secPwdTextField = nil;
    self.doneButton = nil;
    if (tapGesture) {        
        [self.allContentView removeGestureRecognizer:tapGesture];
    }
    self.mobiNumString = nil;
    self.mobileVerifySerialid = nil;
    self.VerifCode = nil;
    self.msgLabel = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:CSLocalizedString(@"writePwd_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    
    self.msgLabel.text = CSLocalizedString(@"writePwd_VC_pwdMsg_Text");
    self.firstPwdTextField.placeholder = CSLocalizedString(@"writePwd_VC_firstPwd_placeholder");
    self.secPwdTextField.placeholder = CSLocalizedString(@"writePwd_VC_secPwd_placeholder");
    [self.doneButton setTitle:CSLocalizedString(@"writePwd_VC_doneBtn_nomalText") forState:UIControlStateNormal];
    
    UIView *emailLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.firstPwdTextField.height, self.firstPwdTextField.height)];
    emailLeftView.backgroundColor = [UIColor clearColor];
    UIImageView *leftIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.firstPwdTextField.height - 15) * 0.5, (self.firstPwdTextField.height - 19) * 0.5, 15, 19)];
    leftIcon.image = [UIImage imageNamed:@"密码"];
    [emailLeftView addSubview:leftIcon];
    self.firstPwdTextField.leftView = emailLeftView;
    self.firstPwdTextField.leftViewMode =  UITextFieldViewModeAlways;
    self.firstPwdTextField.tag = FIRSTtEXT;
    
    
    UIView *pwdLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.secPwdTextField.height, self.secPwdTextField.height)];
    pwdLeftView.backgroundColor = [UIColor clearColor];
    UIImageView *rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.secPwdTextField.height - 15) * 0.5, (self.secPwdTextField.height - 19) * 0.5, 15, 19)];
    rightIcon.image = [UIImage imageNamed:@"密码"];
    [pwdLeftView addSubview:rightIcon];
    self.secPwdTextField.leftView = pwdLeftView;
    self.secPwdTextField.leftViewMode =  UITextFieldViewModeAlways;
    self.secPwdTextField.tag = SECTEXT;

    self.doneButton.left = (self.allContentView.width - self.doneButton.width) * 0.5;
    [self.doneButton setBackgroundImage:[UIImage imageNamed:@"更换"] forState:UIControlStateNormal];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoradTagAction)];
    [self.allContentView addGestureRecognizer:tapGesture];

}

//点击手势隐藏键盘
- (void)hiddenKeyBoradTagAction {
    [self.firstPwdTextField resignFirstResponder];
    [self.secPwdTextField resignFirstResponder];
}


#pragma mark-
#pragma mark-  UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == FIRSTtEXT) {
        [self.secPwdTextField becomeFirstResponder];
    }else if (textField.tag == SECTEXT) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkContenInfo {
    if (![Utils isPasswordStandard:self.firstPwdTextField.text]) {
        [Utils showToast:CSLocalizedString(@"writePwd_VC_pwd_invalid")];
        return NO;
    }
    if (![self.firstPwdTextField.text isEqualToString:self.secPwdTextField.text]) {
        [Utils showToast:CSLocalizedString(@"writePwd_VC_pwd_no_consistent")];
        return NO;
    }
    return YES;
}

- (IBAction)doneAction:(UIButton *)sender {
    [self hiddenKeyBoradTagAction];
    if (![self checkContenInfo]) {
        return;
    }
    
    [self showHUD:nil];
    
    switch (self.vcType) {
        case WritePwdVCType_Register:
        {
            //注册
        }
            break;
            case WritePwdVCType_ResetPwd:
        {
            //重置密码
            [self resetHttp];
            [http_ resetPwd:self.mobiNumString mobileVerifySerialid:self.mobileVerifySerialid verifyCode:self.VerifCode strNewPwd:self.firstPwdTextField.text jsonResponseDelegate:self];
        }
            break;
            case WritePwdVCType_ChanegPwd:
        {
            //密码修改
            [self resetHttp];
            [http_  changeUserPassWord:[UserAccount shareInstance].uid oldPwd:[UserAccount shareInstance].loginPwd newPwd:self.firstPwdTextField.text jsonResponseDelegate:self];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [self hiddenHUD];
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"mchangepasswordbyold" ].location != NSNotFound) {
        NSDictionary *dic = [request responseJSON];
        int status = [dic codeForKey:@"status"];
        if (status == 0) {
            [Utils showToast:CSLocalizedString(@"writePwd_VC_success")];
            [[UserAccount shareInstance] userLogout];
            [KEEPONELINEUTILS changToLoginServer];
            [self showLoginVC];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }else if (status == -3) {
            [Utils showToast:CSLocalizedString(@"writePwd_VC_pwd_error")];
        }else {
            [Utils showToast:CSLocalizedString(@"writePwd_VC_unKnown_error")];
        }
    }else if ([urlString rangeOfString:@"mobileresetpwd"].location != NSNotFound) {
        //密码找回
        NSDictionary *dic = [request responseJSON];
        int status = [dic codeForKey:@"status"];
        int updatecode = [dic codeForKey:@"updatecode"];
        if (status == 0) {
            [Utils showToast:CSLocalizedString(@"writePwd_VC_success")];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            if (updatecode == -3) {
                [Utils showToast:CSLocalizedString(@"writePwd_VC_verify_error")];
            }else if (updatecode == -4) {
                [Utils showToast:CSLocalizedString(@"writePwd_VC_not_bindTel")];
            }else {
                [Utils showToast:CSLocalizedString(@"writePwd_VC_unKnown_error")];
            }
        }
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    [Utils showToast:CSLocalizedString(@"writePwd_VC_faild")];
}
@end
