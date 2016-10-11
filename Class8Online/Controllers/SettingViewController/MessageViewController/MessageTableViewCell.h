//
//  MessageTableViewCell.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/8/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoticesModel.h"


@interface MessageTableViewCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *teacherLab;
@property (weak, nonatomic) IBOutlet UILabel *notificationLab;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UIImageView *headerBgImg;
@property (weak, nonatomic) IBOutlet UIImageView *lineImg;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconNewImgView;
@property (strong, nonatomic) NoticesModel *notice;
@property (assign, nonatomic) UIViewController *viewController;

- (IBAction)avatarAvtion:(UIButton *)sender;


+ (MessageTableViewCell *)shareMsgCell;

- (CGFloat )setContentNotice:(NoticesModel *)notice;

@end
