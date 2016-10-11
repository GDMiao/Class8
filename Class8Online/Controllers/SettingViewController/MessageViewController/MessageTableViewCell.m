//
//  MessageTableViewCell.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/8/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "PersonalInfoViewController.h"
@implementation MessageTableViewCell

- (IBAction)avatarAvtion:(UIButton *)sender {
    CSLog(@"进入uid: %lld 资料页",self.notice.senderid);
//    PersonalInfoViewController * personalVC = [[PersonalInfoViewController alloc] initWithNibName:nil bundle:nil aTUserid:self.notice.senderid];
//    [self.viewController.navigationController pushViewController:personalVC animated:YES];

}

+ (MessageTableViewCell *)shareMsgCell
{
    static MessageTableViewCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
        
    }
    return self;
}


- (void)dealloc
{
    self.headerImg = nil;
    self.headerBgImg = nil;
    self.titleLab = nil;
    self.teacherLab = nil;
    self.notificationLab = nil;
    self.dateLab = nil;
    self.iconNewImgView = nil;
    self.avatarButton = nil;
    self.lineImg = nil;
    self.notice = nil;
    self.viewController = nil;
}

- (void)awakeFromNib {
    // Initialization code
    self.avatarButton.adjustsImageWhenHighlighted = NO;
}


- (CGFloat )setContentNotice:(NoticesModel *)notice
{
    cellHeight = 0;
    
    self.notice = notice;
    self.width = SCREENWIDTH;
    
    self.headerImg.left = 13;
    self.headerImg.top = 12;
    UIImage *headImgPlace = nil;
    BOOL avatarButtonEnable = NO;
    switch (self.notice.noticeType) {
        case NoticesType_Tea:
        {
            headImgPlace = [UIImage imageNamed:@"默认头像"];
            avatarButtonEnable = YES;
        }
            break;
        case NoticesType_System:
        {
            headImgPlace = [UIImage imageNamed:@"公共号"];
            avatarButtonEnable = NO;
        }
            break;
        case NoticesType_School:
        {
            headImgPlace = [UIImage imageNamed:@"学校头像"];
            avatarButtonEnable = NO;
        }
            break;
        default:
        {
            headImgPlace = [UIImage imageNamed:@"默认头像"];
            avatarButtonEnable = NO;
        }
            break;
    }
    [self.headerImg sd_setImageWithURL:[NSURL URLWithString:notice.iconUrl] placeholderImage:headImgPlace];
    
    self.headerImg.top = 12;
    self.headerImg.left = 13;
    self.headerBgImg.frame = self.headerImg.frame;
    self.avatarButton.frame = self.headerImg.frame;
    self.avatarButton.hidden = !avatarButtonEnable;
    
    self.titleLab.text = self.notice.title;
    [self.titleLab sizeToFit];
    self.titleLab.width = SCREENWIDTH - self.titleLab.left - 13;
    self.titleLab.left =  self.headerImg.right + 12;
    self.titleLab.top = 19;
    cellHeight = self.titleLab.bottom;
    
    self.teacherLab.text = self.notice.strPublicName;
    [self.teacherLab sizeToFit];
    self.teacherLab.top = cellHeight + 10;
    self.teacherLab.left = self.titleLab.left;
    cellHeight = self.teacherLab.bottom;
    
    
    self.iconNewImgView.left = self.teacherLab.right + 10;
    self.iconNewImgView.top = self.teacherLab.top;
    self.iconNewImgView.hidden = self.notice.readFlag;
    
    self.notificationLab.text = self.notice.subTitle;
    [self.notificationLab sizeToFit];
    self.notificationLab.width = SCREENWIDTH - self.notificationLab.left - 13;
    self.notificationLab.top = cellHeight + 15;
    self.notificationLab.left = self.titleLab.left;
    cellHeight = self.notificationLab.bottom;
    
    self.dateLab.text = self.notice.dateString;
    [self.dateLab sizeToFit];
    self.dateLab.left = self.titleLab.left;
    self.dateLab.top = cellHeight + 11;
    self.dateLab.width = SCREENWIDTH - self.dateLab.left - 13;
    cellHeight = self.dateLab.bottom;
    
    cellHeight = MAX(cellHeight + 19, self.headerImg.bottom + 12);
    self.lineImg.frame = CGRectMake(0, cellHeight - 1, SCREENWIDTH, 1);
    

    return cellHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
