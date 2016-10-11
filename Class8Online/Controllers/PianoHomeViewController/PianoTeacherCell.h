//
//  PianoTeacherCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PianoTeacherCell : UITableViewCell
{
    CGFloat height;
}

@property (weak, nonatomic) IBOutlet UIView *sectionView;


+ (PianoTeacherCell *)sharTeacell;

- (CGFloat)setTeaCellContent:(NSString *)title sectionView:(BOOL)isShow;
@end
