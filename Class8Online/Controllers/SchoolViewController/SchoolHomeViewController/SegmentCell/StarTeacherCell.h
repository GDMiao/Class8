//
//  StarTeacherCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/3/15.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface StarTeacherCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UIImageView *starTeaIconImg;
@property (weak, nonatomic) IBOutlet UILabel *starTeaNameL;
@property (weak, nonatomic) IBOutlet UIImageView *starTeaidn;
@property (weak, nonatomic) IBOutlet UILabel *scoreL;
@property (weak, nonatomic) IBOutlet UILabel *courseL;
@property (weak, nonatomic) IBOutlet UILabel *stuL;
@property (weak, nonatomic) IBOutlet UIImageView *MaskIcon;

@property (weak, nonatomic) IBOutlet UIView *bottomline;

@property (strong, nonatomic) User *user;

+ (StarTeacherCell *)shareTeacherCell;
- (CGFloat)setCellContentModel:(User *)user;
@end
