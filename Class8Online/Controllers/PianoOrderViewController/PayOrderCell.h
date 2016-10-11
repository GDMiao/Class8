//
//  PayOrderCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/27.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayOrderCell : UITableViewCell
{
    CGFloat height;
}
@property (weak, nonatomic) IBOutlet UILabel *titleName;
@property (weak, nonatomic) IBOutlet UILabel *subName;
@property (weak, nonatomic) IBOutlet UIImageView *selectImge;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLine;
@property (strong, nonatomic) NSMutableDictionary *dict;

+ (PayOrderCell *)payOrderCellShared;

- (CGFloat)updataPayInfoDictionary:(NSMutableDictionary *)dict;
@end
