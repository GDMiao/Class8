//
//  ChangePhoneNumberViewController.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/12.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "RegisteredViewController.h"


@interface ChangePhoneNumberViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *ChangeBtn;

@property (copy, nonatomic) ChangeMobioBlock block;
- (IBAction)changeBtnClick:(id)sender;

@end
