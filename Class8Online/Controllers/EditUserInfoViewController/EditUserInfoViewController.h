//
//  EditUserInfoViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "IBActionSheet.h"

typedef enum
{
    EditUserInfoStyle_NickAndAvatar = 0,    // 编辑用户头像+昵称
    EditUserInfoStyle_OnlyNick,             // 只编辑昵称
    EditUserInfoStyle_CameraDevName,        // 编辑摄像头工具 设备名
}EditUserInfoStyle;

typedef  void (^EdituserCallBack) (NSString *nick);

@interface EditUserInfoViewController : BasicViewController


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (copy, nonatomic) EdituserCallBack block;
@property (strong,nonatomic) NSString *nameDivece;
@property (assign, nonatomic) long long uid;

- (IBAction)avatarAction:(UIButton *)sender;
- (IBAction)doneAction:(UIButton *)sender;

- (id)initWithEditStyle:(EditUserInfoStyle)style;
@end
