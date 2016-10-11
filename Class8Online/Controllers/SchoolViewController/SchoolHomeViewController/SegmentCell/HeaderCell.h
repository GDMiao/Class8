//
//  HeaderCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/3/15.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HeaderCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UILabel *headerL;
@property (weak, nonatomic) IBOutlet UIButton *moreBt;


+ (HeaderCell *)shareHeaderCell;

- (CGFloat)setheaderCellContent:(NSString *)title;



@end
