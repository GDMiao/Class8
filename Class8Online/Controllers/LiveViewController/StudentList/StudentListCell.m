//
//  StudentListCell.m
//  Class8Online
//
//  Created by chuliangliang on 15/8/3.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "StudentListCell.h"
#import "UIImageView+WebCache.h"

@implementation StudentListCell

+ (StudentListCell *)shareStudentCell
{
    static StudentListCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudentListCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}


- (void)awakeFromNib {
    [self _initSubViews];
}


- (void)dealloc {
    self.userAvatarView = nil;
    self.maskAvatarView = nil;
    self.contenLabel = nil;
    self.user = nil;
    self.unReadMsgIcon = nil;
    self.lineImgView = nil;
}

- (void)_initSubViews {
    self.maskAvatarView.image = [UIImage imageNamed:@"学生大头像遮罩"];
    self.maskAvatarView.highlightedImage = [UIImage imageNamed:@"按下头像遮罩"];
    UIImage *selectImg = [UIImage imageNamed:@"在线列表按下"];
    selectImg = [selectImg resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectImg];
    
    self.unReadMsgIcon.image = [UIImage imageNamed:@"对话留言"];
    
    UIImage *lineImg = [UIImage imageNamed:@"分隔线"];
    lineImg = [lineImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.lineImgView.image = lineImg;
}

- (CGFloat) setCellContent:(User *)user
{
    self.user = user;
    cellHeight = 0;
    
    self.userAvatarView.top = 10;
    self.userAvatarView.left = 10;
    [self.userAvatarView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%lld/%d/%lld.jpg",SignPicDown,self.courseid,0/*self.classid*/,self.user.uid]] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    self.maskAvatarView.frame = self.userAvatarView.frame;
    
    self.unReadMsgIcon.left = self.userAvatarView.right + 6;
    self.unReadMsgIcon.hidden = !self.user.hasUnReadMsg;
    
    NSString *u_showString = [Utils objectIsNotNull:self.user.realname]?self.user.realname:self.user.nickName;
    self.contenLabel.text = self.user.authority == UserAuthorityType_TEACHER?[NSString stringWithFormat:@"%@(%@)",
                                                                              u_showString,CSLocalizedString(@"live_VC_role_tea")] :u_showString;
    self.contenLabel.top = 0;
    self.contenLabel.left = self.unReadMsgIcon.right + 6;
    self.contenLabel.textColor = self.user.authority == UserAuthorityType_TEACHER?MakeColor(0x19, 0x76, 0xd2) :MakeColor(0xc6, 0xc6, 0xc6);
    self.contenLabel.width = self.cellAllWidth;
    
    
    cellHeight = self.userAvatarView.bottom + 10;
    self.contenLabel.height = cellHeight - 1;
    self.unReadMsgIcon.top = (cellHeight - self.unReadMsgIcon.height) * 0.5 - 0.5;
    
    self.lineImgView.frame = CGRectMake(self.unReadMsgIcon.left, cellHeight - 1, self.cellAllWidth-self.unReadMsgIcon.left, 1);
    return cellHeight;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
