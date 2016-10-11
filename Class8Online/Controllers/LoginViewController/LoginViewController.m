//
//  LoginViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisteredViewController.h"
#import "KeepOnLineUtils.h"
#import "AidersViewController.h"

#define EMAILTEXTFIELDTAG 3001
#define PWDTEXTFIELDTAG 3002
@interface LoginViewController ()
{
    UITapGestureRecognizer *tapGesture;
}
@property (strong, nonatomic) UIImageView *leftIcon,*pwdleftIcon;
@end

@implementation LoginViewController
@synthesize isPushed;

- (void)dealloc {
    if (tapGesture) {
        [self.allContentView removeGestureRecognizer:tapGesture];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.emailTextField = nil;
    self.pwdTextField = nil;
    self.loginButton = nil;
    self.scrollView = nil;
    self.forGotPwdBtn = nil;
    self.classHelperButton = nil;
    self.classLogoImg = nil;
    self.leftIcon = nil;
    self.pwdleftIcon = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:@"login" withTitleStyle:CTitleStyle_OnlyBack];
    
    self.allContentView.backgroundColor = [UIColor colorWithWhite:242/255.0 alpha:1];
    
    self.allContentView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    self.scrollView.frame = self.allContentView.bounds;
    
    // Class logo
    self.classLogoImg.top = 75;
    self.classLogoImg.left = (self.allContentView.width - self.classLogoImg.width) * 0.5;

    // emailTextField
    self.emailTextField.top = self.classLogoImg.bottom + 49;
    self.emailTextField.left = 0;
    self.emailTextField.width = self.allContentView.width;
    self.emailTextField.height = 47;
    self.emailTextField.placeholder = CSLocalizedString(@"login_VC_account_placeholder");
    self.emailTextField.text = [Utils objectIsNotNull:[UserAccount shareInstance].loginName]?[UserAccount shareInstance].loginName:@"";
    self.pwdTextField.top = self.emailTextField.bottom;
    self.pwdTextField.left = self.emailTextField.left;
    self.pwdTextField.width = self.emailTextField.width;
    self.pwdTextField.height = self.emailTextField.height;
    self.pwdTextField.placeholder = CSLocalizedString(@"login_VC_pwd_placeholder");
    self.pwdTextField.text = [Utils objectIsNotNull:[UserAccount shareInstance].loginPwd]?[UserAccount shareInstance].loginPwd:@"";

    UIView *emailLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.emailTextField.height, self.emailTextField.height)];
    emailLeftView.backgroundColor = [UIColor clearColor];
    self.leftIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.emailTextField.height - 16) * 0.5, (self.emailTextField.height - 23) * 0.5, 16, 23)];
    if ([self.emailTextField.text isEqualToString: @""]) {
        self.leftIcon.image = [UIImage imageNamed:@"32"];
    }else
    {
        self.leftIcon.image = [UIImage imageNamed:@"32-2"];
    }
    [emailLeftView addSubview:self.leftIcon];
    self.emailTextField.leftView = emailLeftView;
    self.emailTextField.leftViewMode =  UITextFieldViewModeAlways;

    
    UIView *emailRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, self.emailTextField.height)];
    emailRightView.backgroundColor = [UIColor clearColor];
    UIButton *emRightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    emRightbtn.frame = emailRightView.bounds;
    [emRightbtn setImage:[UIImage imageNamed:@"36"] forState:UIControlStateNormal];
    
    [emRightbtn addTarget:self action:@selector(clearEmail) forControlEvents:UIControlEventTouchUpInside];
    [emailRightView addSubview:emRightbtn];
    self.emailTextField.rightView = emailRightView;
    self.emailTextField.rightViewMode =  UITextFieldViewModeWhileEditing;
    self.emailTextField.tag = EMAILTEXTFIELDTAG;

    
    UIView *pwdLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.pwdTextField.height, self.pwdTextField.height)];
    pwdLeftView.backgroundColor = [UIColor clearColor];
    self.pwdleftIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.pwdTextField.height - 16) * 0.5, (self.pwdTextField.height - 23) * 0.5, 16, 23)];
    
    if ([self.pwdTextField.text isEqualToString: @""]) {
        self.pwdleftIcon.image = [UIImage imageNamed:@"31"];
    }else
    {
        self.pwdleftIcon.image = [UIImage imageNamed:@"31-2"];
    }
    [pwdLeftView addSubview:self.pwdleftIcon];
    self.pwdTextField.leftView = pwdLeftView;
    self.pwdTextField.leftViewMode =  UITextFieldViewModeAlways;
    self.pwdTextField.tag = PWDTEXTFIELDTAG;
    
    UIView *pwdRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, self.pwdTextField.height)];
    pwdRightView.backgroundColor = [UIColor clearColor];
    UIButton *pwdRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pwdRightBtn.frame = pwdRightView.bounds;
    [pwdRightBtn setImage:[UIImage imageNamed:@"33"] forState:UIControlStateNormal];
    [pwdRightBtn setImage:[UIImage imageNamed:@"33-2"] forState:UIControlStateSelected];
    [pwdRightBtn addTarget:self action:@selector(passWordVisible:) forControlEvents:UIControlEventTouchUpInside];
    [pwdRightView addSubview:pwdRightBtn];
    self.pwdTextField.rightView = pwdRightView;
    self.pwdTextField.rightViewMode = UITextFieldViewModeAlways;

    
    UIView *line0= [[UIView alloc] initWithFrame:CGRectMake(0, self.emailTextField.top - 0.5, self.emailTextField.width, 1)];
    line0.backgroundColor = [UIColor colorWithWhite:222/255.0 alpha:1];
    [self.scrollView addSubview:line0];

    
    UIView *line1= [[UIView alloc] initWithFrame:CGRectMake(0, self.emailTextField.bottom - 0.5, self.emailTextField.width, 1)];
    line1.backgroundColor = [UIColor colorWithWhite:222/255.0 alpha:1];
    [self.scrollView addSubview:line1];

    UIView *line2= [[UIView alloc] initWithFrame:CGRectMake(0, self.pwdTextField.bottom - 0.5, self.pwdTextField.width, 1)];
    line2.backgroundColor = [UIColor colorWithWhite:222/255.0 alpha:1];
    [self.scrollView addSubview:line2];

    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoradTagAction)];
    [self.allContentView addGestureRecognizer:tapGesture];
    
    // forGotPwdbtn
    self.forGotPwdBtn.top = self.pwdTextField.bottom + 17;
    self.forGotPwdBtn.right = SCREENWIDTH - 15;
    [self.forGotPwdBtn setTitle:CSLocalizedString(@"login_VC_forgotpwd_nomalText") forState:UIControlStateNormal];
    
    
    
    self.loginButton.top = self.forGotPwdBtn.bottom + 16;
    self.loginButton.left = (self.allContentView.width - self.loginButton.width) * 0.5;
    self.loginButton.height = 45;
    [self.loginButton setTitle:CSLocalizedString(@"login_VC_loginBtn_nomalText") forState:UIControlStateNormal];
    self.loginButton.layer.masksToBounds = YES;
    self.loginButton.layer.cornerRadius = 5;
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"更换"] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"登录灰"] forState:UIControlStateDisabled];
    
    
    self.classHelperButton.top = self.loginButton.bottom + 18;
    self.classHelperButton.left = self.loginButton.left;
    self.classHelperButton.width = self.loginButton.width;
    self.classHelperButton.height = self.loginButton.height;
    self.classHelperButton.layer.borderWidth = 1;
    self.classHelperButton.layer.masksToBounds = YES;
    self.classHelperButton.layer.cornerRadius = 5;
    self.classHelperButton.layer.borderColor = MakeColor(0x19, 0x76, 0xd2).CGColor;
    
    
    [self updateLoginBtnState];
    CSLog(@"viewDidLoad==> 记住密码: bool   = %d, 自动登录:bool = %d",[UserAccount shareInstance].mindPwd,[UserAccount shareInstance].autoLogin);
}


/**
 * 更新 登录按钮状态 灰色/蓝色
 **/
- (void)updateLoginBtnState {
    if (self.pwdTextField.text.length > 0 && self.emailTextField.text.length > 0) {
        [self changeLoginButtonState:YES];
    }else {
        [self changeLoginButtonState:NO];
    }
}

- (void)changeLoginButtonState:(BOOL)enable {
    self.loginButton.enabled = enable;
}

//点击手势隐藏键盘
- (void)hiddenKeyBoradTagAction {
    [self.emailTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
}

- (void)rightClicked:(TitleView *)view {
    [self hiddenKeyBoradTagAction];
    
    if (isPushed) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}
- (void)clearEmail {
    self.emailTextField.text = @"";
}

- (void)passWordVisible:(UIButton *)button
{
    button.selected = !button.selected;
    self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)siginButton:(id)sender {
    
    RegisteredViewController *regiVC = [[RegisteredViewController alloc] initWithRegistered:YES];
    [self.navigationController  pushViewController:regiVC animated:YES];
}

- (BOOL)checkContenInfo {
    
//    if (![Utils checkTellPhoneNumber:self.emailTextField.text]) {
//        [Utils showToast:@"请输入正确的手机号码"];
//        return NO;
//    }
    NSString *userAccountString = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (userAccountString.length <=0 ) {
        [Utils showToast:CSLocalizedString(@"login_VC_not_userName")];
        return NO;
    }
    
    NSString *pwd = [self.pwdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (pwd.length <= 0) {
        [Utils showToast:CSLocalizedString(@"login_VC_not_pwd")];
        return NO;
    }
    return YES;
}
- (IBAction)loginButton:(id)sender {
    [self hiddenKeyBoradTagAction];
    
    
    //暂时取消验证
    if (![self checkContenInfo]) {
        return;
    }
    
    __weak LoginViewController *wself = self;
   [KEEPONELINEUTILS login:self.emailTextField.text passWord:self.pwdTextField.text result:^{
       LoginViewController *sself = wself;
       if (isPushed) {
           [sself.navigationController popViewControllerAnimated:YES];
       }else {
           [sself dismissViewControllerAnimated:YES completion:NULL];
       }
   }];
}

//修改为忘记密码
- (IBAction)lookButton:(id)sender {
    RegisteredViewController *regiVC = [[RegisteredViewController alloc] initWithRegistered:NO];
    [self.navigationController  pushViewController:regiVC animated:YES];

}

// 课吧助手
- (IBAction)classHelpButton:(UIButton *)sender {
    CSLog(@"课吧助手");
    //课吧助手
//    AidersViewController *homeVC = [[AidersViewController alloc]initWithNibName:nil bundle:nil];
//    [self.navigationController pushViewController:homeVC animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark-
#pragma mark-  UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == EMAILTEXTFIELDTAG) {
        [self.pwdTextField becomeFirstResponder];
    }else if (textField.tag == PWDTEXTFIELDTAG) {
        [textField resignFirstResponder];
    }
    return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL buttonEnable = NO;
    int stringAllLenght = textField.text.length;
    if (textField.tag == EMAILTEXTFIELDTAG) {
        if ([string isEqualToString:@""]) {
            stringAllLenght-=1;
        }else {
            stringAllLenght += string.length;
        }
        if (self.pwdTextField.text.length > 0 && stringAllLenght>0) {
            buttonEnable = YES;
            self.leftIcon.image = [UIImage imageNamed:@"32-2"];
        }else {
            buttonEnable = NO;
            self.leftIcon.image = [UIImage imageNamed:@"32"];
        }
    }else if (textField.tag == PWDTEXTFIELDTAG) {
        
        if ([string isEqualToString:@""]) {
            stringAllLenght = 0;
        }else {
            stringAllLenght += string.length;
        }
        if (self.emailTextField.text.length > 0 && stringAllLenght>0) {
            buttonEnable = YES;
            self.pwdleftIcon.image = [UIImage imageNamed:@"31-2"];
        }else {
            buttonEnable = NO;
            self.pwdleftIcon.image = [UIImage imageNamed:@"31"];
        }
    }
    [self changeLoginButtonState:buttonEnable];
    return YES;
}
@end
