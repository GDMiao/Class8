//
//  AllTeachersCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/17.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "AllTeachersCell.h"
#import "UIImageView+WebCache.h"
#import "User.h"
@implementation AllTeachersCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (AllTeachersCell *)sharAllTeaCell{
    static AllTeachersCell *sharedInstance = nil;
    static dispatch_once_t onceToKen;
    dispatch_once(&onceToKen, ^{
        sharedInstance = [[AllTeachersCell alloc]init];
    });
    return sharedInstance;
}

-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AllTeachersCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}




- (CGFloat)setALLTeaCellContent:(User *)user
{
    height = 0;
    self.user = user;
    self.left = 0;self.top = 0;
        
        [self.teaImg sd_setImageWithURL:[NSURL URLWithString:self.user.avatar] placeholderImage:[UIImage imageNamed:@"默认头像"]];
        self.teaImg.left = 20;
        self.teaImg.top = 10;
        if ([self.user.realname isEqualToString:@""]) {
            self.nameStr.text = @"这老师没写名字" ;
        }else{
            self.nameStr.text = self.user.realname;
        }
        [self.nameStr sizeToFit];
        self.nameStr.left = self.teaImg.right + 10;
        self.nameStr.top = self.teaImg.top + 10;
        
        
        self.medalsImg.left = self.nameStr.right + 10;
        self.medalsImg.top = self.nameStr.top;
        self.medalsImg.hidden = YES;
    
    NSString *organizationName = self.user.organization.length > 0 ? self.user.organization : @"未加入机构";
        self.organizationStr.text =  [NSString stringWithFormat:@"机构名称:%@",organizationName];;
   
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
    
    //    CSLog(@"%f",height);
    return height;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
