//
//  StudentListCell.h
//  Class8Online
//
//  Created by chuliangliang on 15/8/3.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@interface StudentListCell : UITableViewCell
{
    CGFloat cellHeight;
}

@property (weak, nonatomic) IBOutlet UIImageView *unReadMsgIcon;
@property (assign, nonatomic) CGFloat cellAllWidth;
@property (weak, nonatomic) IBOutlet UIImageView *maskAvatarView;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *contenLabel;
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) long long courseid,classid;
@property (weak, nonatomic) IBOutlet UIImageView *lineImgView;



+ (StudentListCell *)shareStudentCell;
- (CGFloat) setCellContent:(User *)user;
@end
