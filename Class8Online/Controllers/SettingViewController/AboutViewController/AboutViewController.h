//
//  AboutViewController.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface AboutViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UIImageView *topImg;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImg;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusSubLabel;
@end
