//
//  ChangePhoneNumberViewController.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/12.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "ChangePhoneNumberViewController.h"

@interface ChangePhoneNumberViewController ()

@end

@implementation ChangePhoneNumberViewController

- (void)dealloc
{
    self.iconImg = nil;
    self.phoneNumberLabel = nil;
    self.ChangeBtn = nil;
    self.block = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:CSLocalizedString(@"changeTelNum_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    
    [self.ChangeBtn setBackgroundImage:[UIImage imageNamed:@"更换"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *mobi = [UserAccount shareInstance].loginUser.mobile;
    if ([Utils objectIsNotNull:mobi]) {
        self.phoneNumberLabel.text = mobi;
        [self.ChangeBtn setTitle:CSLocalizedString(@"changeTelNum_VC_bindtelBtn_nomalTitle_change") forState:UIControlStateNormal];
    }else {
        self.phoneNumberLabel.text = CSLocalizedString(@"changeTelNum_VC_bindTel_msg");
        [self.ChangeBtn setTitle:CSLocalizedString(@"changeTelNum_VC_bindtelBtn_nomalTitle_bind") forState:UIControlStateNormal];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeBtnClick:(id)sender {
    CSLog(@"更改");
    RegisteredViewController *regVC = [[RegisteredViewController alloc] initWithRegVCStyle:RegVCStyle_BindTel];
    regVC.changeMobiBlock = self.block;
    [self.navigationController pushViewController:regVC animated:YES];
}
@end
