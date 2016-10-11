//
//  AllTeachersCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/17.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@interface AllTeachersCell : UITableViewCell
{
    CGFloat height;
}
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UIImageView *teaImg;
@property (weak, nonatomic) IBOutlet UILabel *nameStr;
@property (weak, nonatomic) IBOutlet UIImageView *medalsImg;
@property (weak, nonatomic) IBOutlet UILabel *organizationStr;
@property (weak, nonatomic) IBOutlet UILabel *scoreStr;
@property (weak, nonatomic) IBOutlet UIImageView *logoImg;
@property (weak, nonatomic) IBOutlet UILabel *courseNumStr;

@property (weak, nonatomic) IBOutlet UIImageView *bottonLine;
+ (AllTeachersCell *)sharAllTeaCell;
- (CGFloat)setALLTeaCellContent:(User *)user;
@end
