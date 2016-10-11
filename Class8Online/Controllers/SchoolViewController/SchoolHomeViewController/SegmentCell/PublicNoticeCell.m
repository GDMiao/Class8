//
//  PublicNoticeCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/15.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "PublicNoticeCell.h"
#import "SchoolNoticeModel.h"

@implementation PublicNoticeCell

+ (PublicNoticeCell *)shareNoiceCell
{
    static PublicNoticeCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PublicNoticeCell" owner:self options:nil];
    self = [nib lastObject];
    
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.pointImage = nil;
    self.publicNoticeL = nil;
    self.notice = nil;
}

- (void)awakeFromNib {
    // Initialization code
    
    self.pointImage.image = [UIImage imageNamed:@"icon_8"];
    self.line.backgroundColor = MakeColor(0xe3, 0xe4, 0xe5);
}


- (CGFloat)setCellContent:(SchoolNoticeModel *)notice
{
    self.notice = notice;
    cellHeight = 0;
    
    
    self.publicNoticeL.text = self.notice.title;
    [self.publicNoticeL sizeToFit];
    self.publicNoticeL.top = 20;
    
    self.pointImage.left = 23;
    self.pointImage.top = self.publicNoticeL.top + (self.publicNoticeL.height - self.pointImage.height) * 0.5;
    self.publicNoticeL.left = self.pointImage.right + 7;
    cellHeight = self.publicNoticeL.bottom + (self.showLine?20:0);
    
    self.line.hidden = !self.showLine;
    self.line.frame = CGRectMake(0, cellHeight-1, SCREENWIDTH, 1);
    return cellHeight;
}


- (CGFloat)setCellNoticeContent:(SchoolNoticeModel *)notice
{
    self.notice = notice;
    cellHeight = 0;
    
    
    self.publicNoticeL.text = self.notice.title;
    self.publicNoticeL.highlightedTextColor = MakeColor(0x42, 0x87, 0xb7);
    [self.publicNoticeL setFont:[UIFont systemFontOfSize:18.0]];
    [self.publicNoticeL sizeToFit];
    self.publicNoticeL.top = 11;
    
    [self.pointImage setHighlightedImage:[UIImage imageNamed:@"icon_8_1"]];
    self.pointImage.left = 23;
    self.pointImage.top = self.publicNoticeL.top + (self.publicNoticeL.height - self.pointImage.height) * 0.5;
    self.publicNoticeL.left = self.pointImage.right + 11;
    cellHeight = self.publicNoticeL.bottom + 11;
    
    self.line.frame = CGRectMake(self.publicNoticeL.left, cellHeight-1, SCREENWIDTH - self.publicNoticeL.left - 15, 1);
    return cellHeight;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.publicNoticeL.highlighted = selected;
    self.pointImage.highlighted = selected;

    // Configure the view for the selected state
}

@end
