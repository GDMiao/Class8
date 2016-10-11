//
//  HelpFeedbackCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/21.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "HelpFeedbackCell.h"

@implementation HelpFeedbackCell
{
    CGFloat cellHeight;
}

+ (HelpFeedbackCell *)shareHelpFeedBackCell
{
    static HelpFeedbackCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HelpFeedbackCell" owner:self options:nil];
    self = [nib lastObject];
    
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    

    
}

- (CGFloat)setHelpCellContent:(NSString *)text
{
    cellHeight = 0;
    
    self.questionL.left = 19;
    self.questionL.top = 25;
    
    
    self.titleL.text = @"课吧反馈";
    [self.titleL sizeToFit];
    self.titleL.top= self.questionL.top;
    self.titleL.left = self.questionL.right + 6;
    
    self.answerL.left = self.questionL.left;
    self.answerL.top = self.questionL.bottom + 18;
    
    self.contentL.text = text;
    self.contentL.font = [UIFont systemFontOfSize:16];
    self.contentL.numberOfLines = 0;
    self.contentL.width = SCREENWIDTH - self.contentL.left - 22;
    [self.contentL sizeToFit];
    self.contentL.top = self.answerL.top;
    self.contentL.left = self.titleL.left;
    
    
    
    cellHeight = self.contentL.bottom + 25;

    self.bottomline.frame = CGRectMake(0, cellHeight - 1, SCREENWIDTH, 1);
    
    return cellHeight;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
