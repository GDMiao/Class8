//
//  StarTeacherCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/15.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "StarTeacherCell.h"
#import "UIImageView+WebCache.h"

@implementation StarTeacherCell

+ (StarTeacherCell *)shareTeacherCell
{
    static StarTeacherCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StarTeacherCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.starTeaIconImg = nil;
    self.starTeaNameL = nil;
    self.starTeaidn = nil;
    self.scoreL = nil;
    self.courseL = nil;
    self.stuL = nil;
    self.bottomline = nil;
    self.user = nil;
    self.MaskIcon = nil;
}

- (void)awakeFromNib {
    // Initialization code
    self.bottomline.backgroundColor = MakeColor(0xe3, 0xe4, 0xe5);
    self.MaskIcon.image = [UIImage imageNamed:@"学生大头像遮罩"];
}

- (CGFloat)setCellContentModel:(User *)user
{
    cellHeight = 0;
    self.user = user;
    
    NSString *avatartUrl = self.user.avatar;
    if ([avatartUrl rangeOfString:@"http://"].location == NSNotFound) {
        avatartUrl = [NSString stringWithFormat:@"%@%@",UserAvatarBasicUrl,avatartUrl];
    }
    [self.starTeaIconImg sd_setImageWithURL:[NSURL URLWithString:avatartUrl] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    self.starTeaIconImg.top = 15;
    self.starTeaIconImg.left = 20;

    self.starTeaNameL.text = self.user.nickName;
    [self.starTeaNameL sizeToFit];
    self.starTeaNameL.top = 21;
    self.starTeaNameL.left = self.starTeaIconImg.right + 16;
    self.MaskIcon.left = self.starTeaIconImg.left;
    self.MaskIcon.top = self.starTeaIconImg.top;

    //认证
    self.starTeaidn.top = self.starTeaNameL.top + (self.starTeaNameL.height - self.starTeaidn.height) * 0.5;
    self.starTeaidn.left = self.starTeaNameL.right + 7;

    
    CGFloat ontItemWidth = (SCREENWIDTH - self.starTeaNameL.left - 20)/3.0;
    //评分
//    self.scoreL.text = [NSString stringWithFormat:@"评分%0.1f",self.user.pfCount];
    self.scoreL.text = @"评分5.0";
    [self.scoreL sizeToFit];
    self.scoreL.top = self.starTeaNameL.bottom + 13;
    self.scoreL.left = self.starTeaNameL.left;

    //课程数
    self.courseL.text = [NSString stringWithFormat:@"课程%d",self.user.courseCount];
    [self.courseL sizeToFit];
    self.courseL.top = self.scoreL.top;
    self.courseL.left = self.starTeaNameL.left + ontItemWidth;

    //学生总数
    NSString *stuCountString = @"0";
    if (self.user.stuCount > 1000) {
        stuCountString = [NSString stringWithFormat:@"学生%0.2fk",self.user.stuCount/1000.0];
    }else {
        stuCountString = [NSString stringWithFormat:@"学生%d",self.user.stuCount];
    }
    
    self.stuL.text = stuCountString;
    [self.stuL sizeToFit];
    self.stuL.top = self.courseL.top;
    self.stuL.left = self.starTeaNameL.left + ontItemWidth * 2;
    
    cellHeight = self.starTeaIconImg.bottom + 15;
    
    self.bottomline.frame = CGRectMake(0, cellHeight-1, SCREENWIDTH, 1);
    return cellHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
