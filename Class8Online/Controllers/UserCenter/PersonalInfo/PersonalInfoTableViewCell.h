//
//  PersonalInfoTableViewCell.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/14.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>


#define LEFT_TXT @"left_txt"
#define RIGHT_TXT @"right_txt"
#define AvatarUsrl @"avatar_url"
#define HAS_EDIT @"has_edit"


@interface PersonalInfoTableViewCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLab;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView;
@property (weak, nonatomic) IBOutlet UIImageView *headerBgView;
@property (weak, nonatomic) IBOutlet UIImageView *topLine;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLine;
@property (assign, nonatomic) BOOL hasTopLine,hasBottomLine;

+ (PersonalInfoTableViewCell *)sharePersonalInfoCell;
- (CGFloat)updateCellContent:(NSDictionary *)dic;

@end
