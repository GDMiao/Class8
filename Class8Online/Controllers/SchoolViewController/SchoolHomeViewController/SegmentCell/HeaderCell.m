//
//  HeaderCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/15.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "HeaderCell.h"

@implementation HeaderCell

- (void)dealloc
{
    self.headerL = nil;
    self.moreBt = nil;
}

+ (HeaderCell *)shareHeaderCell
{
    static HeaderCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

- (CGFloat)setheaderCellContent:(NSString *)title
{
    cellHeight = 0;
  
    self.headerL.text = title;
    [self.headerL sizeToFit];
    self.headerL.top = 20.0;
    self.headerL.left = 25.0;
    
    self.moreBt.top = 22.5;
    self.moreBt.left = self.headerL.right + 197;
    self.moreBt.right = SCREENWIDTH - 18.5;
    
    cellHeight = self.headerL.bottom;
    return cellHeight;
}

- (void)awakeFromNib {
    // Initialization code
    
    [self.headerL setFont:[UIFont systemFontOfSize:15]];
    [self.moreBt setImage:[UIImage imageNamed:@"icon_9"] forState:UIControlStateNormal];

    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
