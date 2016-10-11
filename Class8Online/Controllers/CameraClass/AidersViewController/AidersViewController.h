//
//  AidersViewController.h
//  Class8Camera
//
//  Created by chuliangliang on 15/7/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface AidersViewController : BasicViewController <UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
- (IBAction)ChangeBtnClick:(id)sender;
- (IBAction)CloseBtnClick:(id)sender;
- (IBAction)connectAction:(UIButton *)sender;

@end
