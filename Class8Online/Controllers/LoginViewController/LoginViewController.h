//
//  LoginViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface LoginViewController : BasicViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *classHelperButton;
@property (weak, nonatomic) IBOutlet UIButton *forGotPwdBtn;

@property (weak, nonatomic) IBOutlet UIImageView *classLogoImg;

@property (assign, nonatomic) BOOL isPushed; //是否导航进来
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;









- (IBAction)siginButton:(id)sender;
- (IBAction)loginButton:(id)sender;
- (IBAction)lookButton:(id)sender; //修改为忘记密码

@end
