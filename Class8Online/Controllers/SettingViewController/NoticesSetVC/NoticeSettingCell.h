//
//  NoticeSettingCell.h
//  Class8Online
//
//  Created by chuliangliang on 15/9/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIImageView *rightIcon;
@property (weak, nonatomic) IBOutlet UIImageView *line;
- (void)setContentlabelText:(NSString *)text;
@end
