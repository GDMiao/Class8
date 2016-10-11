//
//  PersonalInfoTableViewCell.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/14.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "PersonalInfoTableViewCell.h"
#import "UIImageView+WebCache.h"
@implementation PersonalInfoTableViewCell

-(void)dealloc
{
    self.titleLab = nil;
    self.subTitleLab = nil;
    self.arrowImgView = nil;
    self.bottomLine = nil;
    self.topLine = nil;
    self.headerImgView = nil;
    self.headerBgView = nil;
}

-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PersonalInfoTableViewCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

+ (PersonalInfoTableViewCell *)sharePersonalInfoCell
{
    static PersonalInfoTableViewCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)awakeFromNib {
    // Initialization code
    self.topLine.backgroundColor = MakeColor(0xe3, 0xe4, 0xe5);
    self.bottomLine.backgroundColor = MakeColor(0xe3, 0xe4, 0xe5);
}


- (CGFloat)updateCellContent:(NSDictionary *)dic
{
    cellHeight = 0;
    
    self.titleLab.text = [dic stringForKey:LEFT_TXT];
    [self.titleLab sizeToFit];
    self.titleLab.left = 20;
    self.titleLab.top = 15;
    cellHeight = self.titleLab.bottom+15;
    
    NSString *avatarUrl = [dic stringForKey:AvatarUsrl];
    BOOL isAvatar = [Utils objectIsNotNull:avatarUrl];
    self.headerImgView.hidden = YES;
    self.headerBgView.hidden = YES;
    self.subTitleLab.hidden = YES;
    if (isAvatar) {
        self.headerImgView.hidden = NO;
        self.headerBgView.hidden = NO;
        if ([avatarUrl rangeOfString:@"http://"].location == NSNotFound) {
            avatarUrl = [NSString stringWithFormat:@"%@%@",UserAvatarBasicUrl,avatarUrl];
        }
        [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"默认头像"]];
        self.headerImgView.right = SCREENWIDTH-30;
        self.headerImgView.top = 8;
        self.headerBgView.frame = self.headerImgView.frame;
        cellHeight = self.headerImgView.bottom+8;
    }else {
        self.subTitleLab.hidden = NO;
        self.subTitleLab.text = [dic stringForKey:RIGHT_TXT];
        [self.subTitleLab sizeToFit];
        CGFloat subMaxWidth = SCREENWIDTH-30-self.titleLab.right -10;
        if (self.subTitleLab.width >subMaxWidth) {
            self.subTitleLab.width = subMaxWidth;
        }
        self.subTitleLab.right = SCREENWIDTH-30;
        self.subTitleLab.top = (cellHeight - self.subTitleLab.height) *0.5;
    }
    
    BOOL hasEdit = [dic boolForKey:HAS_EDIT];
    self.arrowImgView.hidden = !hasEdit;
    self.arrowImgView.right = SCREENWIDTH-14;
    self.arrowImgView.top = (cellHeight-self.arrowImgView.height) * 0.5;
    
    self.topLine.hidden = YES;
    if (self.hasTopLine) {
        self.topLine.hidden = NO;
        self.topLine.frame = CGRectMake(0, 0, SCREENWIDTH, 1);
        self.bottomLine.frame = CGRectMake(20, cellHeight-1, SCREENWIDTH-20, 1);
    }else if (self.hasBottomLine) {
        self.bottomLine.frame = CGRectMake(0, cellHeight-1, SCREENWIDTH, 1);
    }else {
        self.bottomLine.frame = CGRectMake(20, cellHeight-1, SCREENWIDTH-20, 1);
    }
    return cellHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
