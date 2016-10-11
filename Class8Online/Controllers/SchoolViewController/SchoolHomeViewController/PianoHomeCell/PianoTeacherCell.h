//
//  PianoTeacherCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@interface PianoTeacherCell : UITableViewCell
{
    CGFloat height;
}

@property (weak, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) User *user;

+ (PianoTeacherCell *)sharTeacell;

- (CGFloat)setTeaCellContent:(User *)user sectionView:(BOOL)isShow;
@end
