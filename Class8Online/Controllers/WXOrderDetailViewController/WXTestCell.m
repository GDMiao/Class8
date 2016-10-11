//
//  WXTestCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "WXTestCell.h"

@implementation WXTestCell
+ (WXTestCell *)shareHeaderCell
{
    static WXTestCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WXTestCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.appid.left = self.left + 20;
    self.appid.top = self.top + 20;
    
    self.noncestr.left = self.appid.left;
    self.noncestr.top = self.appid.bottom + 10;
    
    self.package.left = self.appid.left;
    self.package.top = self.noncestr.bottom + 10;
    self.partnerid.left = self.appid.left;
    self.partnerid.top = self.package.bottom + 10;
    self.prepayid.left = self.appid.left;
    self.prepayid.top = self.partnerid.bottom+ 10;
    self.sign.left = self.appid.left;
    self.sign.top = self.prepayid.bottom + 10;
    self.timestamp.left = self.appid.left;
    self.timestamp.top = self.sign.bottom + 10;
    // Initialization code
}
// set cell data and UI
- (CGFloat)setWXtestCellcontentWith:(NSDictionary *)dit
{
    CGFloat cellheight;
    cellheight = self.timestamp.bottom + 20;
    
    return cellheight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
