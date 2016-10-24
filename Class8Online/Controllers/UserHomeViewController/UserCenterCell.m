//
//  UserConterCell.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/16.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "UserCenterCell.h"
#import "UIImageView+WebCache.h"
#import "CourseModel.h"

@implementation UserCenterCell


- (void)dealloc {

    self.courseView = nil;
    self.courseIcon = nil;
    self.courseNameLabel = nil;
    self.userTypeIcon = nil;
    self.userTypeDesLabel = nil;
    self.courseProIcon = nil;
    self.courseProLabel1 = nil;
    self.courseLine = nil;
    self.cellDelegate = nil;
    self.isLiveOrRecord = nil;
    self.priceBgImg = nil;
    self.priceLabel = nil;
}

+ (UserCenterCell *)shareCourseCell
{
    static UserCenterCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserCenterCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}



- (void)awakeFromNib {
    // Initialization code
    self.courseLine.backgroundColor = MakeColor(0xe3, 0xe4, 0xe5);
    
}


- (CGFloat)setCellContent:(CourseModel *)courseModel withCellStyleTxt:(NSString *)cellTxt userinfoModel:(User *)u
{
    cellHeight = 0.0;
    self.course = courseModel;
    self.cellStyleTxt = cellTxt;
    self.user = u;
    
    [self updateCourseData];
    
 
    return cellHeight;
}

- (void)updateCourseData
{
    self.courseView.frame = CGRectMake(0, cellHeight, SCREENWIDTH, 10);
    //课程封面
    [self.courseIcon sd_setImageWithURL:[NSURL URLWithString:self.course.courseIcon] placeholderImage:[UIImage imageNamed:@"默认课程"]];
    self.courseIcon.top = 17;
    self.courseIcon.left = 14;
    
    
    if (self.course.recordUrl) {
        self.isLiveOrRecord.text = @"直播";
        self.isLiveOrRecord.backgroundColor = MakeColor(0x29, 0x169, 0x237);
    }else{
        self.isLiveOrRecord.text = @"录播";
        self.isLiveOrRecord.backgroundColor = MakeColor(0x236, 0x78, 0x83);
    }
    self.isLiveOrRecord.hidden = YES;
    self.isLiveOrRecord.left = self.courseIcon.left ;
    self.isLiveOrRecord.top = self.courseIcon.top;
    
    //课程名
    self.courseNameLabel.text = self.course.courseName;
    [self.courseNameLabel sizeToFit];
    self.courseNameLabel.left = self.courseIcon.right+12;
    self.courseNameLabel.top = 20;
    self.courseNameLabel.width = SCREENWIDTH - self.courseNameLabel.left-12;
    
    self.userTypeIcon.left = self.courseNameLabel.left;
    self.userTypeIcon.top = self.courseNameLabel.bottom + 12;
    
    // 老师名字 或者 报名人数
    if ([self.cellStyleTxt isEqualToString:@"我的订购"]) {
        NSString *teaname = self.course.teaName;
        self.userTypeDesLabel.text = [NSString stringWithFormat:@"老师姓名:%@",teaname];
    }else if ([self.cellStyleTxt isEqualToString:@"我的创建"] || [self.cellStyleTxt isEqualToString:@"教师首页"]){
        int bmrs = self.course.stuCount;
        self.userTypeDesLabel.text = [NSString stringWithFormat:@"报名人数:%d/8",bmrs];
    }
    [self.userTypeDesLabel sizeToFit];
    self.userTypeDesLabel.left = self.userTypeIcon.right + 5;
    self.userTypeDesLabel.top = self.courseNameLabel.bottom + 10;
    
    
    //课程进度
    self.courseProIcon.left = self.userTypeIcon.left;
    self.courseProIcon.top = self.userTypeDesLabel.bottom + 12;
    
    if([self.cellStyleTxt isEqualToString:@"教师首页"]){
        if (self.course.teaHomeStartTime.length > 0) {
            NSString *datastr = [NSMutableString stringWithFormat:@"%@",self.course.teaHomeStartTime];
            NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:datastr];
            [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:80.0/255.0 green:179.0/255.0 blue:57.0/255.0 alpha:1] range:NSMakeRange(11, 5)];
            self.courseProLabel1.attributedText = AttributedStr;
        }
        
    }else{
        NSString *datastr = [NSMutableString stringWithFormat:@"%@",self.course.startTime];
        self.courseProLabel1.text = datastr;
    }


    [self.courseProLabel1 sizeToFit];
    self.courseProLabel1.left = self.courseProIcon.right + 5;
    self.courseProLabel1.top = self.userTypeDesLabel.bottom + 10;
    

    self.priceBgImg.left = self.courseProLabel1.right + 22;
    self.priceBgImg.top = self.userTypeDesLabel.bottom + 5;
    self.priceBgImg.right = SCREENWIDTH - 20;
    
    if ([self.course.price_total isEqualToString:@"0"]) {
        self.priceLabel.text = @" 免费";
    }else{
        self.priceLabel.text = [NSString stringWithFormat:@"%@元",self.course.priceTotal];
    }
    
    [self.priceLabel sizeToFit];
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
//    self.priceLabel.left = self.priceBgImg.left + (self.priceBgImg.width/2 - self.priceLabel.width/2);
//    self.priceLabel.top = self.priceBgImg.top + (self.priceBgImg.height - self.priceLabel.height) /2;;
    self.priceLabel.frame = self.priceBgImg.frame;
    self.priceLabel.left = self.priceBgImg.left + 5;
    self.courseView.height = self.courseIcon.bottom + 17;
    self.courseLine.frame = CGRectMake(0, self.courseView.height-1, SCREENWIDTH, 1);

    
    cellHeight = self.courseView.bottom;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
