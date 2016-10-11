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
    self.courseProLabel2 = nil;
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
    }else if ([self.cellStyleTxt isEqualToString:@"我的创建"]){
        int bmrs = self.course.stuCount;
        self.userTypeDesLabel.text = [NSString stringWithFormat:@"报名人数:%d/4",bmrs];
    };
    [self.userTypeDesLabel sizeToFit];
    self.userTypeDesLabel.left = self.userTypeIcon.right + 5;
    self.userTypeDesLabel.top = self.courseNameLabel.bottom + 10;
    
    
    //课程进度
    self.courseProIcon.left = self.userTypeIcon.left;
    self.courseProIcon.top = self.userTypeDesLabel.bottom + 12;
    
    if(self.course.startTime){
        NSString *datastr = [NSMutableString stringWithFormat:@"%@",self.course.startTime];
        //        datastr = [datastr substringFromIndex:5];
        datastr = [datastr substringToIndex:10];

        self.courseProLabel1.text = datastr;
    }

    [self.courseProLabel1 sizeToFit];
    self.courseProLabel1.left = self.courseProIcon.right + 5;
    self.courseProLabel1.top = self.userTypeDesLabel.bottom + 10;
    
    if (self.course.startTime) {
        NSString *timestr = [NSMutableString stringWithFormat:@"%@",self.course.startTime];
        timestr = [timestr substringFromIndex:11];

        self.courseProLabel2.text = timestr;
    }

    [self.courseProLabel2 sizeToFit];
    self.courseProLabel2.left = self.courseProLabel1.right +5;
    self.courseProLabel2.top = self.courseProLabel1.top;

    self.priceBgImg.left = self.courseProLabel2.right + 22;
    self.priceBgImg.top = self.userTypeDesLabel.bottom + 5;
    self.priceBgImg.right = SCREENWIDTH - 20;
    
    if ([self.course.price_total isEqualToString:@"0"]) {
        self.priceLabel.text = @" 免费";
    }else{
        self.priceLabel.text = [NSString stringWithFormat:@" %@元",self.course.priceTotal];
    }
    
    [self.priceLabel sizeToFit];
    self.priceLabel.left = self.priceBgImg.left + (self.priceBgImg.width/2 - self.priceLabel.width/2);
    self.priceLabel.top = self.priceBgImg.top + (self.priceBgImg.height - self.priceLabel.height) /2;;

    self.courseView.height = self.courseIcon.bottom + 17;
    self.courseLine.frame = CGRectMake(0, self.courseView.height-1, SCREENWIDTH, 1);

    
    cellHeight = self.courseView.bottom;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
