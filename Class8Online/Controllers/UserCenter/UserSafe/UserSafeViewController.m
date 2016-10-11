//
//  UserSafeViewController.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "UserSafeViewController.h"
#import "PersonalInfoTableViewCell.h"
#import "WritePwdViewController.h"
#import "ChangePhoneNumberViewController.h"

@interface UserSafeViewController ()

@end

@implementation UserSafeViewController

- (void)dealloc
{
    self.topImg = nil;
    self.topLabel = nil;
    self.bottomImg = nil;
    self.bottomLabel = nil;
    self.rightLabel = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.titleView setTitleText:CSLocalizedString(@"userSafe_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    
    self.topImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH , 47)];
    self.topImg.backgroundColor = [UIColor whiteColor];
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 47)];
    self.topLabel.text = CSLocalizedString(@"userSafe_VC_update_pwd");
    self.topLabel.font = [UIFont systemFontOfSize:15];
    self.topLabel.textColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    [self.topImg addSubview:self.topLabel];
    UIImageView * arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头"]];
    arrowImg.size = CGSizeMake(8, 14);
    arrowImg.right = self.topImg.width - 15;
    arrowImg.top = (self.topImg.height - arrowImg.height) / 2;
    [self.topImg addSubview:arrowImg];
    [self.allContentView addSubview:self.topImg];
    
    self.bottomImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.topImg.bottom , SCREENWIDTH, 47)];
    self.bottomImg.backgroundColor = [UIColor whiteColor];
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 47)];
    self.bottomLabel.text = CSLocalizedString(@"userSafe_VC_change_tel");
    self.bottomLabel.font = [UIFont systemFontOfSize:15];
    self.bottomLabel.textColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    [self.bottomImg addSubview:self.bottomLabel];
    UIImageView * arrowImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头"]];
    arrowImg2.size = CGSizeMake(8, 14);
    arrowImg2.right = self.topImg.width - 15;
    arrowImg2.top = (self.topImg.height - arrowImg.height) / 2;
    [self.bottomImg addSubview:arrowImg2];
    [self.allContentView addSubview:self.bottomImg];
    
    self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 45)];
    self.rightLabel.text = [UserAccount shareInstance].loginUser.mobile;
    self.rightLabel.textAlignment = NSTextAlignmentRight;
    self.rightLabel.font = [UIFont systemFontOfSize:13];
    self.rightLabel.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1];
    self.rightLabel.right = self.bottomImg.width - 40;
    [self.bottomImg addSubview:self.rightLabel];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, self.bottomImg.width - 8, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1];
    [self.bottomImg addSubview:lineView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topClick)];
    [self.topImg addGestureRecognizer:tap];
    self.topImg.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomClick)];
    [self.bottomImg addGestureRecognizer:tap2];
    self.bottomImg.userInteractionEnabled = YES;
    
}

- (void)topClick
{
    [self yzPwd];
}

- (void)bottomClick
{
    ChangePhoneNumberViewController * changeVC = [[ChangePhoneNumberViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:changeVC animated:YES];
}

- (void)yzPwd {
    NSString *message;
    if (IS_IOS5) {
        message = CSLocalizedString(@"userSafe_VC_pwd_alert_msg_ios5_before");
    }else{
        message = CSLocalizedString(@"userSafe_VC_pwd_alert_msg_ios5_after");
    }
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:CSLocalizedString(@"userSafe_VC_pwd_alert_title")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:CSLocalizedString(@"userSafe_VC_pwd_alert_cancel")
                                              otherButtonTitles:CSLocalizedString(@"userSafe_VC_pwd_alert_ok"), nil];
    if (IS_IOS5) {
        alterView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    }else{
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 90.0, 230.0, 25.0)];
        [textField setBackgroundColor:[UIColor whiteColor]];
        textField.tag = 10001;
        [alterView addSubview:textField];
        textField.secureTextEntry = YES;
        
        [alterView setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];  //可以调整弹出框在屏幕上的位置
    }
    [alterView show];

}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *text = @"";
        if (IS_IOS7) {
            UITextField *tf=[alertView textFieldAtIndex:0];
            text = tf.text;
        }else{
            UITextField *tf=(UITextField *)[alertView viewWithTag:10001];
            text = tf.text;
        }
        if ([text isEqualToString:[UserAccount shareInstance].loginPwd]) {
            WritePwdViewController * writeVC = [[WritePwdViewController alloc] initWithNibName:nil bundle:nil aVCType:WritePwdVCType_ChanegPwd];
            [self.navigationController pushViewController:writeVC animated:YES];
        }else {
            [Utils showAlert:CSLocalizedString(@"userSafe_VC_pwd_error")];
        }
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
