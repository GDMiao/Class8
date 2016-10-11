//
//  PublicNoticeCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/3/15.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SchoolNoticeModel;
@interface PublicNoticeCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UIImageView *pointImage;
@property (weak, nonatomic) IBOutlet UILabel *publicNoticeL;
@property (weak, nonatomic) IBOutlet UIImageView *line;

@property (assign, nonatomic) BOOL showLine;
@property (strong, nonatomic) SchoolNoticeModel *notice;
+ (PublicNoticeCell *)shareNoiceCell;
- (CGFloat)setCellContent:(SchoolNoticeModel *)notice;
- (CGFloat)setCellNoticeContent:(SchoolNoticeModel *)notice;
@end
