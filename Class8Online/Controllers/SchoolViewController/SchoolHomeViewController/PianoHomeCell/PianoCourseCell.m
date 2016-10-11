
//  PianoCourseCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "PianoCourseCell.h"
#import "CourseModel.h"
#import "UIImageView+WebCache.h"
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

@property (weak, nonatomic) IBOutlet UIImageView *bottonLine;

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

- (CGFloat)setCourseCellContent:(CourseModel *)course sectionHidden:(BOOL)ishidden
{
    height = 0;
    self.left = 0;self.top = 0;
    self.course = course;
    if (ishidden == YES) {
        
        self.sectionView.left = 0;
        self.sectionView.top = 0;
        self.sectionView.hidden = NO;
    
        
        self.courseImg.left = 20;
        self.courseImg.top = self.sectionView.bottom+ 10;
        if (self.course.coverUrl) {
            [self.courseImg sd_setImageWithURL:[NSURL URLWithString:self.course.coverUrl] placeholderImage:[UIImage imageNamed:@"默认课程"]];
        }
        
//        if (![self.course.recordUrl isEqualToString:@""]) {
//            self.playStly.text = @"录播";
//            self.playStly.backgroundColor = [UIColor greenColor];
//        }else{
//            self.playStly.text = @"直播";
//            self.playStly.backgroundColor = [UIColor redColor];
//        }
//        
//        self.playStly.left = self.courseImg.left;
//        self.playStly.top = self.courseImg.top;

        
        self.titleStr.text = self.course.courseName;
        [self.titleStr sizeToFit];
    
        self.titleStr.left = self.courseImg.right + 10;
        self.titleStr.top = self.courseImg.top + 10;
        self.titleStr.width = SCREENWIDTH - (self.courseImg.right +10 + 10);
        
        self.icon_name.left = self.titleStr.left;
        self.icon_name.top = self.titleStr.bottom + 10;
        self.icon_time.left = self.icon_name.left;
        self.icon_time.top = self.icon_name.bottom + 10;
        
        self.nameStr.text = self.course.teaName;
        [self.nameStr sizeToFit];
        self.nameStr.left = self.icon_name.right + 10;
        self.nameStr.top = self.icon_name.top;
        
//        if(self.course.startTime){
//            NSString *datastr = [NSMutableString stringWithFormat:@"%@",self.course.startTime];
//            //        datastr = [datastr substringFromIndex:5];
//            datastr = [datastr substringToIndex:5];
////            NSLog(@"%@",datastr);
//            self.dataStr.text = datastr;
//        }
        self.dataStr.text = self.course.startTime;
        [self.dataStr sizeToFit];
        self.dataStr.left = self.icon_time.right + 10;
        self.dataStr.top = self.icon_time.top;
        
//        if (self.course.startTime) {
//            NSString *timestr = [NSMutableString stringWithFormat:@"%@",self.course.startTime];
//            timestr = [timestr substringFromIndex:6];
////            NSLog(@"%@",timestr);
//            self.timeStr.text = timestr;
//        }
        self.timeStr.text = @"";
        self.timeStr.left = self.dataStr.right + 10;
        self.timeStr.top = self.dataStr.top;
        
        self.pricebkImg.left = self.timeStr.right + 10;
        self.pricebkImg.top = self.timeStr.top;
        self.pricebkImg.width = 70;
        self.pricebkImg.right = SCREENWIDTH - 20;
        
        self.priceStr.text = [NSString stringWithFormat:@" %@元",self.course.priceTotal];
        [self.priceStr sizeToFit];
        self.priceStr.left = self.pricebkImg.left + (self.pricebkImg.width - self.priceStr.width) /2;
        self.priceStr.top = self.pricebkImg.top + (self.pricebkImg.height - self.priceStr.height) /2;
        
        
        height = self.courseImg.bottom + 10;
        self.bottonLine.left = 0;
        self.bottonLine.top = height - 1;
    }else{
//        self.backgroundColor = [UIColor greenColor];
        self.sectionView.hidden = YES;
        
        self.courseImg.left = 20;
        self.courseImg.top = 10;
        if (self.course.coverUrl) {
            [self.courseImg sd_setImageWithURL:[NSURL URLWithString:self.course.coverUrl] placeholderImage:[UIImage imageNamed:@"默认课程"]];
        }
        
//        if (![self.course.recordUrl isEqualToString:@""]) {
//            self.playStly.text = @"录播";
//            self.playStly.backgroundColor = [UIColor greenColor];
//        }else{
//            self.playStly.text = @"直播";
//            self.playStly.backgroundColor = [UIColor redColor];
//        }
//        
//        self.playStly.left = self.courseImg.left;
//        self.playStly.top = self.courseImg.top;
        
        
        self.titleStr.text = self.course.courseName;
        [self.titleStr sizeToFit];
        self.titleStr.left = self.courseImg.right + 10;
        self.titleStr.top = self.courseImg.top + 10;
        self.titleStr.width = SCREENWIDTH - (self.courseImg.right +10 + 10);
        
        self.icon_name.left = self.titleStr.left;
        self.icon_name.top = self.titleStr.bottom + 10;
        self.icon_time.left = self.icon_name.left;
        self.icon_time.top = self.icon_name.bottom + 10;
        
        self.nameStr.text = self.course.teaName;
        [self.nameStr sizeToFit];
        self.nameStr.left = self.icon_name.right + 10;
        self.nameStr.top = self.icon_name.top;
        
//        if(self.course.startTime){
//        NSString *datastr = [NSMutableString stringWithFormat:@"%@",self.course.startTime];
////        datastr = [datastr substringFromIndex:5];
//        datastr = [datastr substringToIndex:5];
////        NSLog(@"%@",datastr);
//        self.dataStr.text = datastr;
//        }
        self.dataStr.text = self.course.startTime;
        [self.dataStr sizeToFit];
        self.dataStr.left = self.icon_time.right + 10;
        self.dataStr.top = self.icon_time.top;
        
//        if (self.course.startTime) {
//            NSString *timestr = [NSMutableString stringWithFormat:@"%@",self.course.startTime];
//            timestr = [timestr substringFromIndex:6];
////            NSLog(@"%@",timestr);
//            self.timeStr.text = timestr;
//        }
        self.timeStr.text = @"";
        [self.timeStr sizeToFit];
        self.timeStr.left = self.dataStr.right + 10;
        self.timeStr.top = self.dataStr.top;
        
        self.pricebkImg.left = self.timeStr.right + 10;
        self.pricebkImg.top = self.timeStr.top;
        self.pricebkImg.width = 70;
        self.pricebkImg.right = SCREENWIDTH - 20;
        
        self.priceStr.text = [NSString stringWithFormat:@" %@元",self.course.priceTotal];
        [self.priceStr sizeToFit];
        self.priceStr.left = self.pricebkImg.left + (self.pricebkImg.width - self.priceStr.width) /2;
        self.priceStr.top = self.pricebkImg.top + (self.pricebkImg.height - self.priceStr.height) /2;
        
        height = self.courseImg.bottom + 10;
        self.bottonLine.left = 0;
        self.bottonLine.top = height - 1;
    }
//    CSLog(@"%f",height);
    return height;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
