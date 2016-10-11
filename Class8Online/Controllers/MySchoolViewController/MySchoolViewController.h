//
//  MySchoolViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/8/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface MySchoolViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIImageView *bjImgView;
@property (weak, nonatomic) IBOutlet UIImageView *nameBjImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;  //学校名
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *userName;     //用户名
@property (weak, nonatomic) IBOutlet UILabel *stuNumbaerLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBjImg;
@property (weak, nonatomic) IBOutlet UILabel *yxLabel;
@property (weak, nonatomic) IBOutlet UIImageView *yxLine;
@property (weak, nonatomic) IBOutlet UILabel *zyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *zyLine;
@property (weak, nonatomic) IBOutlet UILabel *bjLabel;

@end
