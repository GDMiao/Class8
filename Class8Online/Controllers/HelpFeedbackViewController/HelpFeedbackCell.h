//
//  HelpFeedbackCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/3/21.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpFeedbackCell : UITableViewCell

+ (HelpFeedbackCell *)shareHelpFeedBackCell;

@property (weak, nonatomic) IBOutlet UILabel *questionL;
@property (weak, nonatomic) IBOutlet UILabel *answerL;

@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;

@property (weak, nonatomic) IBOutlet UIImageView *bottomline;
- (CGFloat)setHelpCellContent:(NSString *)text;

@end
