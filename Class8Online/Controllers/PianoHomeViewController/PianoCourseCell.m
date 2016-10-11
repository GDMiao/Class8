//
//  PianoCourseCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "PianoCourseCell.h"

@interface PianoCourseCell ()

@property (weak, nonatomic) IBOutlet UIImageView *courseImg;
@property (weak, nonatomic) IBOutlet UILabel *titleStr;
@property (weak, nonatomic) IBOutlet UILabel *dataStr;
@property (weak, nonatomic) IBOutlet UILabel *timeStr;
@property (weak, nonatomic) IBOutlet UILabel *nameStr;
@property (weak, nonatomic) IBOutlet UIImageView *pricebkImg;
@property (weak, nonatomic) IBOutlet UILabel *priceStr;
@property (weak, nonatomic) IBOutlet UILabel *playStly;
@property (weak, nonatomic) IBOutlet UIImageView *icon_name;
@property (weak, nonatomic) IBOutlet UIImageView *icon_time;


@end

@implementation PianoCourseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


+ (PianoCourseCell *)sharCourseCell
{
    static PianoCourseCell *sharedInstance = nil;
    static dispatch_once_t onceToKen;
    dispatch_once(&onceToKen, ^{
        sharedInstance = [[PianoCourseCell alloc]init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PianoCourseCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

- (CGFloat)setCourseCellContent:(NSString *)title sectionHidden:(BOOL)ishidden
{
    height = 0;
    self.left = 0;self.top = 0;
    if (ishidden == YES) {
        self.sectionView.left = 0;
        self.sectionView.top = 0;
        self.sectionView.hidden = NO;
        
        self.courseImg.left = 20;
        self.courseImg.top = self.sectionView.bottom;
        
        self.playStly.left = self.courseImg.left + 10;
        self.playStly.top = self.courseImg.top + 10;

        
        self.titleStr.text = title;
        [self.titleStr sizeToFit];
        self.titleStr.left = self.courseImg.right + 10;
        self.titleStr.top = self.courseImg.top + 10;
        
        self.icon_name.left = self.titleStr.left;
        self.icon_name.top = self.titleStr.bottom + 10;
        self.icon_time.left = self.icon_name.left;
        self.icon_time.top = self.icon_name.bottom + 10;
        
        self.nameStr.left = self.icon_name.right + 10;
        self.nameStr.top = self.icon_name.top;
        
        self.dataStr.left = self.icon_time.right + 10;
        self.dataStr.top = self.icon_time.top;
        
        self.timeStr.left = self.dataStr.right + 10;
        self.timeStr.top = self.dataStr.top;
        
        self.pricebkImg.left = self.timeStr.right + 10;
        self.pricebkImg.top = self.timeStr.top;
        
        self.priceStr.left = self.pricebkImg.left;
        self.priceStr.top = self.pricebkImg.top;
        
        height = self.courseImg.bottom + 10;
    }else{
//        self.backgroundColor = [UIColor greenColor];
        self.sectionView.hidden = YES;
        self.courseImg.left = 20;
        self.courseImg.top = 10;
        
        self.playStly.left = self.courseImg.left + 10;
        self.playStly.top = self.courseImg.top + 10;
        
        
        self.titleStr.text = title;
        [self.titleStr sizeToFit];
        self.titleStr.left = self.courseImg.right + 10;
        self.titleStr.top = self.courseImg.top + 10;
        
        self.icon_name.left = self.titleStr.left;
        self.icon_name.top = self.titleStr.bottom + 10;
        self.icon_time.left = self.icon_name.left;
        self.icon_time.top = self.icon_name.bottom + 10;
        
        self.nameStr.left = self.icon_name.right + 10;
        self.nameStr.top = self.icon_name.top;
        
        self.dataStr.left = self.icon_time.right + 10;
        self.dataStr.top = self.icon_time.top;
        
        self.timeStr.left = self.dataStr.right + 10;
        self.timeStr.top = self.dataStr.top;
        
        self.pricebkImg.left = self.timeStr.right + 10;
        self.pricebkImg.top = self.timeStr.top;
        
        self.priceStr.left = self.pricebkImg.left;
        self.priceStr.top = self.pricebkImg.top;
        
        height = self.courseImg.bottom + 10;
    }
//    CSLog(@"%f",height);
    return height;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
