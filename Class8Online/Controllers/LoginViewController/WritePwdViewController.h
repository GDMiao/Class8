//
//  WritePwdViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

typedef enum
{
    WritePwdVCType_Register,        /*注册*/
    WritePwdVCType_ResetPwd,        /*密码重置*/
    WritePwdVCType_ChanegPwd,       /*密码修改*/
}WritePwdVCType;

@interface WritePwdViewController : BasicViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil aVCType:(WritePwdVCType )p;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *firstPwdTextField;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UITextField *secPwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (assign, nonatomic) BOOL isRegistered; //是否注册 默认 no
@property (strong, nonatomic) NSMutableDictionary *userDic;
@property (strong, nonatomic) NSString *oldPwd,
*mobiNumString,  //手机号码 <密码找回时>
*mobileVerifySerialid, //验证码流水号
*VerifCode;             //验证码
- (IBAction)doneAction:(UIButton *)sender;

@end
