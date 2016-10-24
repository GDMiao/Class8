//
//  PianoTeacherCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "PianoTeacherCell.h"
#import "User.h"
#import "UIImageView+WebCache.h"
@interface PianoTeacherCell ()

@property (weak, nonatomic) IBOutlet UIImageView *teaImg;
@property (weak, nonatomic) IBOutlet UILabel *nameStr;
@property (weak, nonatomic) IBOutlet UIImageView *medalsImg;
@property (weak, nonatomic) IBOutlet UILabel *organizationStr;
@property (weak, nonatomic) IBOutlet UILabel *scoreStr;
@property (weak, nonatomic) IBOutlet UIImageView *logoImg;
@property (weak, nonatomic) IBOutlet UILabel *courseNumStr;

@property (weak, nonatomic) IBOutlet UIImageView *bottonLine;
@end

@implementation PianoTeacherCell

+ (PianoTeacherCell *)sharTeacell
{
    static PianoTeacherCell *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PianoTeacherCell alloc]init];
    });
    return sharedInstance;


}

- (void)dealloc
{
    self.user = nil;
    self.sectionView = nil;
    self.teaImg = nil;
    self.nameStr = nil;
    self.medalsImg = nil;
    self.organizationStr = nil;
    self.scoreStr = nil;
    self.logoImg = nil;
    self.courseNumStr = nil;
    self.bottonLine = nil;
}

-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PianoTeacherCell" owner:self options:nil];
    self = [nib lastObject];
    
    if (self) {
    }
    return self;
}

- (CGFloat)setTeaCellContent:(User *)user sectionView:(BOOL)isShow
{
    height = 0;
    self.user = user;
    self.left = 0;self.top = 0;
    if (isShow == YES) {
        self.sectionView.left = 0;
        self.sectionView.top = 0;
        self.sectionView.hidden = NO;
        
        [self.teaImg sd_setImageWithURL:[NSURL URLWithString:self.user.headimageUrl] placeholderImage:[UIImage imageNamed:@"默认头像"]];
        self.teaImg.left = 20;
        self.teaImg.top = self.sectionView.bottom + 10;
        
        NSString *realName = self.user.realname.length > 0 ? self.user.realname :@"      ";
        
        self.nameStr.text = realName;
        [self.nameStr sizeToFit];
//        self.nameStr.backgroundColor = [UIColor redColor];
        self.nameStr.left = self.teaImg.right + 10;
        self.nameStr.top = self.teaImg.top + 10;
        
        
        self.medalsImg.left = self.nameStr.right + 10;
        self.medalsImg.top = self.nameStr.top;
        self.medalsImg.hidden = YES;
        
        NSString *organizationName = self.user.company.length > 0 ? self.user.company : @"未加入机构";
        
        self.organizationStr.text = [NSString stringWithFormat:@"机构名称：%@",organizationName];
        [self.organizationStr sizeToFit];
        self.organizationStr.left = self.nameStr.left;
        self.organizationStr.top = self.nameStr.bottom + 10;
        
        self.logoImg.left = self.organizationStr.right + 10;
        self.logoImg.top = self.organizationStr.top;
        self.logoImg.hidden = YES;
        
        self.scoreStr.text = [NSString stringWithFormat:@"评分:%0.1f",self.user.pfCount];
        [self.scoreStr sizeToFit];
        self.scoreStr.left = self.organizationStr.left;
        self.scoreStr.top = self.organizationStr.bottom+ 10;
        
        self.courseNumStr.text = [NSString stringWithFormat:@"课程:%d",self.user.courseCount];
        [self.courseNumStr sizeToFit];
        self.courseNumStr.left = self.scoreStr.right + 10;
        self.courseNumStr.top = self.scoreStr.top;
        
        height = self.teaImg.bottom + 10;
        self.bottonLine.left = 0;
        self.bottonLine.top = height - 1;
    }else
    {
        self.sectionView.hidden = YES;
        
        [self.teaImg sd_setImageWithURL:[NSURL URLWithString:self.user.headimageUrl] placeholderImage:[UIImage imageNamed:@"默认头像"]];
        self.teaImg.left = 20;
        self.teaImg.top = 10;
        
        NSString *realName = self.user.realname.length > 0 ? self.user.realname :@"      ";
        
        self.nameStr.text = realName;
        [self.nameStr sizeToFit];
        //        self.nameStr.backgroundColor = [UIColor redColor];
        self.nameStr.left = self.teaImg.right + 10;
        self.nameStr.top = self.teaImg.top + 10;
        
        
        self.medalsImg.left = self.nameStr.right + 10;
        self.medalsImg.top = self.nameStr.top;
        self.medalsImg.hidden = YES;
        
        NSString *organizationName = self.user.company.length > 0 ? self.user.company : @"未加入机构";
        
        self.organizationStr.text = [NSString stringWithFormat:@"机构名称：%@",organizationName];
        [self.organizationStr sizeToFit];
        self.organizationStr.left = self.nameStr.left;
        self.organizationStr.top = self.nameStr.bottom + 10;
        
        self.logoImg.left = self.organizationStr.right + 10;
        self.logoImg.top = self.organizationStr.top;
        self.logoImg.hidden = YES;
        
        self.scoreStr.text = [NSString stringWithFormat:@"评分:%0.1f",self.user.pfCount];
        [self.scoreStr sizeToFit];
        self.scoreStr.left = self.organizationStr.left;
        self.scoreStr.top = self.organizationStr.bottom+ 10;
        
        self.courseNumStr.text = [NSString stringWithFormat:@"课程:%d",self.user.courseCount];
        [self.courseNumStr sizeToFit];
        self.courseNumStr.left = self.scoreStr.right + 10;
        self.courseNumStr.top = self.scoreStr.top;
        
        height = self.teaImg.bottom + 10;
        self.bottonLine.left = 0;
        self.bottonLine.top = height - 1;
    }
//    CSLog(@"%f",height);
    return height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
