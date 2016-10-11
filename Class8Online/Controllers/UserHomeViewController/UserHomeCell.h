//
//  UserHomeCell.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/14.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IconName @"icon_name"
#define TitleTxt_left @"title_text_left"

@interface UserHomeCell : UITableViewCell
@property (assign, nonatomic) NSInteger idx;
@property (assign, nonatomic) BOOL isLastCell;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *jtImg;
@property (weak, nonatomic) IBOutlet UIImageView *line;
@property (weak, nonatomic) IBOutlet UIImageView *topLine;
- (void)setCellContent:(NSDictionary *)dic;
@end
