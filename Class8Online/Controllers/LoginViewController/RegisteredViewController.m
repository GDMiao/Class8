//
//  RegisteredViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "RegisteredViewController.h"
#import "WritePwdViewController.h"


#define TELL 3003
#define YZNUMBER 3004
#define Timerinvalidate 60
@interface RegisteredViewController () <UITextFieldDelegate>
{
    UITapGestureRecognizer *tapGesture;
    int toalTime;
    
}
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) long long serialid; //获取验证码的时的 标记号
@property (assign, nonatomic) RegVCStyle regStyle; //此页面类型
@property (strong, nonatomic) NSDictionary *verifyTelCodeDic; //验证码配置信息
@property (strong, nonatomic) UIButton *yzmRightBtn;
@property (strong, nonatomic) UIImageView *leftIcon,*yzmLeftIcon;
@end

@implementation RegisteredViewController
@synthesize regStyle;
- (id)initWithRegistered:(BOOL)registerd
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (registerd) {
            regStyle = RegVCStyle_Default;
        }else {
            regStyle = RegVCStyle_ForgetPwd;
        }
    }
    return self;
}

- (id)initWithRegVCStyle:(RegVCStyle)style
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        regStyle = style;
    }
    return self;
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.scrollView = nil;
    self.telTextField = nil;
    self.yzNumTextField = nil;
    self.nextBtn = nil;
    self.bottomView = nil;
    self.logoImg = nil;
    self.leftIcon = nil;
    self.yzmLeftIcon = nil;
    self.yzmRightBtn = nil;
    self.changeMobiBlock = nil;
    if (tapGesture) {
        [self.allContentView removeGestureRecognizer:tapGesture];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.serialid = 0;
    self.telTextField.placeholder = CSLocalizedString(@"register_VC_telNum_placeholder");
    self.yzNumTextField.placeholder = CSLocalizedString(@"register_VC_VerifyCode_placeholder");

    self.allContentView.backgroundColor = [UIColor colorWithWhite:242/255.0 alpha:1];
    
    switch (regStyle) {
        case RegVCStyle_Default:
        {
            //注册
            [self.titleView setTitleText:CSLocalizedString(@"register_VC_nav_register_title") withTitleStyle:CTitleStyle_FirstLogin];
            self.bottomView.hidden = NO;
            self.scrollView.frame = CGRectMake(0, IS_IOS7 ? 64 :44 , SCREENWIDTH, self.allContentView.height - self.bottomView.height - (IS_IOS7?64:44));

        }
            break;
        case RegVCStyle_ForgetPwd:
        {
            //密码找回
            [self.titleView setTitleText:CSLocalizedString(@"register_VC_nav_resetpwd_title") withTitleStyle:CTitleStyle_OnlyBack];
            self.bottomView.hidden = YES;
            self.scrollView.frame = CGRectMake(0, IS_IOS7 ? 64 :44 , SCREENWIDTH, self.allContentView.height - (IS_IOS7?64:44));

        }
            break;
        case RegVCStyle_BindTel:
        {
            //绑定手机号
            [self.titleView setTitleText:CSLocalizedString(@"register_VC_nav_bindTel_title") withTitleStyle:CTitleStyle_OnlyBack];
            self.bottomView.hidden = YES;
            self.scrollView.frame = CGRectMake(0, IS_IOS7 ? 64 :44 , SCREENWIDTH, self.allContentView.height - (IS_IOS7?64:44));

        }
            break;
        default:
            break;
    }
    // Class logo
    self.logoImg.top = 75;
    self.logoImg.left = (self.allContentView.width - self.logoImg.width) * 0.5;

    
//    self.telTextField.layer.borderColor = [UIColor colorWithWhite:219/255.0 alpha:1].CGColor;
//    self.telTextField.layer.borderWidth = 1.0f;
//    self.telTextField.layer.cornerRadius = 5.0f;
//    
//    self.yzNumTextField.layer.borderColor = [UIColor colorWithWhite:219/255.0 alpha:1].CGColor;
//    self.yzNumTextField.layer.borderWidth = 1.0f;
//    self.yzNumTextField.layer.cornerRadius = 5.0f;

    self.telTextField.left = 0;
    self.telTextField.top = self.logoImg.bottom + 49;
    UIView *line0 = [[UIView alloc]initWithFrame:CGRectMake(0, self.telTextField.bottom - 0.5, self.telTextField.width, 1)];
    line0.backgroundColor = [UIColor colorWithWhite:222/255.0 alpha:1];
    [self.scrollView addSubview:line0];
    self.yzNumTextField.left = self.telTextField.left;
    self.yzNumTextField.top = self.telTextField.bottom;
    
    UIView *emailLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.telTextField.height, self.telTextField.height)];
    emailLeftView.backgroundColor = [UIColor clearColor];
    self.leftIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.telTextField.height - 23) * 0.5, (self.telTextField.height - 23) * 0.5, 23, 23)];
    self.leftIcon.image = [UIImage imageNamed:@"37"];
    [emailLeftView addSubview:self.leftIcon];
    self.telTextField.leftView = emailLeftView;
    self.telTextField.leftViewMode =  UITextFieldViewModeAlways;
    
    UIView *emailRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, self.telTextField.height)];
    emailRightView.backgroundColor = [UIColor clearColor];
    UIButton *emRightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    emRightbtn.frame = emailRightView.bounds;
    [emRightbtn setImage:[UIImage imageNamed:@"36"] forState:UIControlStateNormal];
    [emRightbtn addTarget:self action:@selector(clearEmail) forControlEvents:UIControlEventTouchUpInside];
    [emailRightView addSubview:emRightbtn];
    self.telTextField.rightView = emailRightView;
    self.telTextField.rightViewMode =  UITextFieldViewModeWhileEditing;
    self.telTextField.tag = TELL;
    
    
    UIView *yzmLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.yzNumTextField.height, self.yzNumTextField.height)];
    yzmLeftView.backgroundColor = [UIColor clearColor];
    self.yzmLeftIcon = [[UIImageView alloc]initWithFrame:CGRectMake((self.yzNumTextField.height - 23) * 0.5, (self.yzNumTextField.height - 23) * 0.5, 23, 23)];
    self.yzmLeftIcon.image = [UIImage imageNamed:@"38"];
    [yzmLeftView addSubview:self.yzmLeftIcon];
    self.yzNumTextField.leftView = yzmLeftView;
    self.yzNumTextField.leftViewMode =  UITextFieldViewModeAlways;
    self.yzNumTextField.tag = YZNUMBER;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoradTagAction)];
    [self.allContentView addGestureRecognizer:tapGesture];
    
    
    
    UIView *yzmRightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 110, self.yzNumTextField.height)];
//    yzmRightView.backgroundColor = [UIColor cyanColor];
    self.yzmRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.yzmRightBtn setTitle:@"获取" forState:UIControlStateNormal];
    [self.yzmRightBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.yzmRightBtn setTitleColor:MakeColor(0x19, 0x76, 0xd2) forState:UIControlStateNormal];
//    yzmRightBtn.backgroundColor = [UIColor yellowColor];
    self.yzmRightBtn.frame = CGRectMake((yzmRightView.width - 90) *0.3, (yzmRightView.height - 35) * 0.5, 90, 35);
//    yzmRightBtn.right = yzmRightView.width - 23;
    self.yzmRightBtn.layer.borderWidth = 1;
    self.yzmRightBtn.layer.borderColor = MakeColor(0x19, 0x76, 0xd2).CGColor;
    self.yzmRightBtn.layer.masksToBounds = YES;
    self.yzmRightBtn.layer.cornerRadius = 5;
    [yzmRightView addSubview:self.yzmRightBtn];
    [self.yzmRightBtn addTarget:self action:@selector(getNumAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.yzNumTextField.rightView = yzmRightView;
    self.yzNumTextField.rightViewMode = UITextFieldViewModeAlways;
    
    
    self.nextBtn.left = self.yzNumTextField.left;
    self.nextBtn.top = self.yzNumTextField.bottom + 23;
    self.nextBtn.layer.masksToBounds = YES;
    self.nextBtn.layer.cornerRadius = 5;

    
    [self.nextBtn setTitle:CSLocalizedString(@"register_VC_nextBtn_nomalText") forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"登录"] forState:UIControlStateNormal];
    self.nextBtn.left = (self.allContentView.width - self.nextBtn.width ) * 0.5;
    
    
}


//点击手势隐藏键盘
- (void)hiddenKeyBoradTagAction {
    [self.telTextField resignFirstResponder];
    [self.yzNumTextField resignFirstResponder];
}


- (void)clearEmail {
    self.telTextField.text = @"";
}

- (void)startTimer {
    if (!self.timer) {
        self.yzmRightBtn.enabled = NO;
        [self.yzmRightBtn setTitle:[NSString stringWithFormat:@"%@(%d)",CSLocalizedString(@"register_VC_time_countDownText"),60]
                        forState:UIControlStateDisabled];
        toalTime = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        
        self.yzmRightBtn.enabled = YES;
        [self.yzmRightBtn setTitle:CSLocalizedString(@"register_VC_getVerifyCodeBtn_nomalText") forState:UIControlStateNormal];
    }
}
- (void)timerAction {

    if (toalTime >= Timerinvalidate) {
        [self stopTimer];
    }
    toalTime++;
    [self.yzmRightBtn setTitle:[NSString stringWithFormat:@"%@(%d)",
                              CSLocalizedString(@"register_VC_time_countDownText"),
                              Timerinvalidate - toalTime]
                    forState:UIControlStateDisabled];
    
}
#pragma mark-
#pragma mark-  UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == TELL) {
        [self.yzNumTextField becomeFirstResponder];
    }else if (textField.tag == YZNUMBER) {
        [textField resignFirstResponder];
    }
    return NO;
}


- (BOOL)checkContenInfo {
    if (![Utils checkTellPhoneNumber:self.telTextField.text]) {
        [Utils showToast:CSLocalizedString(@"register_VC_input_telNum")];
        return NO;
    }
    return YES;
}


- (void)getNumAction:(UIButton *)sender {
    [self hiddenKeyBoradTagAction];
    
    if (![self checkContenInfo]) {
        return;
    }
    [self startTimer];
    switch (regStyle) {
        case RegVCStyle_Default:
        {
            //注册=> 获取验证码
        }
            break;
        case RegVCStyle_ForgetPwd:
        {
            //找回密码 => 获取验证码
            [self showHUD:nil];
            [self resetHttp];
            [http_ getuserMobile:self.telTextField.text numberType:11 jsonResponseDelegate:self];

        }
            break;
        case RegVCStyle_BindTel:
        {
            //绑定手机号 => 获取验证码
            [self showHUD:nil];
            [self resetHttp];
            [http_ getuserMobile:self.telTextField.text numberType:2 jsonResponseDelegate:self];

        }
            break;
        default:
            break;
    }
}

- (IBAction)nextAction:(UIButton *)sender {
    [self hiddenKeyBoradTagAction];

    if (![self checkContenInfo]) {
        return;
    }
    
    NSString *verCode = [self.yzNumTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (verCode.length <= 0) {
        [Utils showToast:CSLocalizedString(@"register_VC_input_VerifyCode")];
        return;
    }
    
    switch (regStyle) {
        case RegVCStyle_Default:
        {
            //注册==> 检测 验证码
        }
            break;
        case RegVCStyle_ForgetPwd:
        {
            //密码忘记 找回密码 => 检测 验证码
            WritePwdViewController *pwdVC =[[WritePwdViewController alloc] initWithNibName:nil bundle:nil aVCType:WritePwdVCType_ResetPwd];
            pwdVC.mobileVerifySerialid = [self.verifyTelCodeDic stringForKey:@"verifycode"];
            pwdVC.mobiNumString = self.telTextField.text;
            pwdVC.VerifCode = self.yzNumTextField.text;
            [self.navigationController pushViewController:pwdVC animated:YES];
        }
            break;
        case RegVCStyle_BindTel:
        {
            //绑定手机号 => 检测 验证码
            [self showHUD:nil];
            [self resetHttp];
            [http_ verifyTelCode:[self.verifyTelCodeDic longForKey:@"verifycode"] userid:[UserAccount shareInstance].uid telNum:self.telTextField.text telCode:self.yzNumTextField.text jsonResponseDelegate:self];

        }
            break;
        default:
            break;
    }

}


- (IBAction)loginAction:(UIButton *)sender {
    [self hiddenKeyBoradTagAction];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark -
- (void)requestFinished:(ASIHTTPRequest *)request {
    [self hiddenHUD];
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"msendBindMobileVerifyCode"].location != NSNotFound) {
        self.verifyTelCodeDic = [request responseJSON];
        int updatecode = [self.verifyTelCodeDic codeForKey:@"verifycode"];
        int status = [self.verifyTelCodeDic codeForKey:@"status"];
        if (status == 0 && updatecode >0 ) {
            [Utils showToast:CSLocalizedString(@"register_VC_verifyCode_didsend")];
        }else {
            if (regStyle == RegVCStyle_BindTel) {
                //绑定手机
                if (updatecode == -4) {
                    [Utils showToast:CSLocalizedString(@"register_VC_userNotExist")];
                }else if (updatecode == -5) {
                    [Utils showToast:CSLocalizedString(@"register_VC_didBingTel")];
                }else {
                    [Utils showToast:CSLocalizedString(@"register_VC_sendVerifyCode_error")];
                }
            }else {
                [Utils showToast:CSLocalizedString(@"register_VC_sendVerifyCode_error")];
            }
        }
    }else if ([urlString rangeOfString:@"mverifyBindMobile"].location != NSNotFound) {
        NSDictionary *repDic = [request responseJSON];
        int status = [repDic codeForKey:@"status"];
        if (status == 0) {
            [Utils showToast:CSLocalizedString(@"register_VC_bindTel_done")];
            [UserAccount shareInstance].loginUser.mobile = self.telTextField.text;
            if (self.changeMobiBlock) {
                self.changeMobiBlock(self.telTextField.text);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {
            int updatecode = [repDic codeForKey:@"updatecode"];
            if (updatecode == -3) {
                [Utils showToast:CSLocalizedString(@"register_VC_verifyCode_error")];
            }else if (updatecode == -4) {
                [Utils showToast:CSLocalizedString(@"register_VC_userNotExist")];
            }else if (updatecode == -5) {
                [Utils showToast:CSLocalizedString(@"register_VC_didBingTel")];
            }else {
                [Utils showToast:CSLocalizedString(@"register_VC_Unknown_Error")];
            }
        }        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [self hiddenHUD];
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"msendBindMobileVerifyCode"].location != NSNotFound) {
        [Utils showToast:CSLocalizedString(@"register_VC_sendVerifyCode_error")];
        
    }else if ([urlString rangeOfString:@"mverifyBindMobile"].location != NSNotFound) {
        [Utils showToast:CSLocalizedString(@"register_VC_bindTel_error")];
    }
}

#pragma mark__
#pragma mark__UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL buttonEnable = NO;
    int stringAllLenght = textField.text.length;
    if (textField.tag == TELL) {
        if ([string isEqualToString:@""]) {
            stringAllLenght-=1;
        }else {
            stringAllLenght += string.length;
        }
        if (self.telTextField.text.length >= 0 && stringAllLenght>0) {
            buttonEnable = YES;
            self.leftIcon.image = [UIImage imageNamed:@"37-2"];
        }else {
            buttonEnable = NO;
            self.leftIcon.image = [UIImage imageNamed:@"37"];
        }
        
    }else if (textField.tag == YZNUMBER) {
        
        if ([string isEqualToString:@""]) {
            stringAllLenght = 0;
        }else {
            stringAllLenght += string.length;
        }
        if (self.yzNumTextField.text.length >= 0 && stringAllLenght>0) {
            buttonEnable = YES;
            self.yzmLeftIcon.image = [UIImage imageNamed:@"38-2"];
        }else {
            buttonEnable = NO;
            self.yzmLeftIcon.image = [UIImage imageNamed:@"38"];
        }
    }

    return YES;
}



@end
