//
//  RegisteredViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

typedef enum {
    RegVCStyle_Default,     //默认 注册
    RegVCStyle_ForgetPwd,   //忘记密码
    RegVCStyle_BindTel,     //绑定手机号
}RegVCStyle;

typedef void (^ChangeMobioBlock) (NSString *mobi);
@interface RegisteredViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *yzNumTextField;

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImg;
@property (copy, nonatomic) ChangeMobioBlock changeMobiBlock;

- (id)initWithRegistered:(BOOL)registerd;

- (id)initWithRegVCStyle:(RegVCStyle)style;

- (IBAction)nextAction:(UIButton *)sender;
- (IBAction)loginAction:(UIButton *)sender;
@end
