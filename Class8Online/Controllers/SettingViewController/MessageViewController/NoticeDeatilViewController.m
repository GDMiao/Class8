//
//  NoticeDeatilViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/9/6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "NoticeDeatilViewController.h"
#import "NoticesModel.h"
#import "UIImageView+WebCache.h"
#import "PersonalInfoViewController.h"
@interface NoticeDeatilViewController ()
@property (strong , nonatomic)NoticesModel *notice;
@end

@implementation NoticeDeatilViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil AtNotice:(NoticesModel *)notice
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.notice = notice;
    }
    return self;
}

- (void)dealloc {

    self.scrollView = nil;
    self.topLineImgView = nil;
    self.topView = nil;
    self.iconImgView = nil;
    self.iconMaskView = nil;
    self.owernTextLabel = nil;
    self.timeLabel = nil;
    self.titleLabel = nil;
    self.lineImgView = nil;
    self.contentLabel = nil;
    self.iconButton = nil;
    self.notice = nil;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:self.notice.title withTitleStyle:CTitleStyle_OnlyBack];
    
    self.scrollView.frame = self.allContentView.bounds;
    self.scrollView.backgroundColor = [UIColor colorWithWhite:242/255.0 alpha:1.0];
    self.iconButton.adjustsImageWhenHighlighted = NO;
    [self setTopViewContent];
    [self setNoticeContent];
}

- (void)setTopViewContent
{
    self.iconMaskView.image = [UIImage imageNamed:@"学生大头像遮罩"];
    UIImage *line = [UIImage imageNamed:@"分隔线"];
    line = [line resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    self.topLineImgView.image = line;
    self.topView.backgroundColor = [UIColor whiteColor];

    
    self.topView.frame = CGRectMake(0, 0, self.allContentView.width, 70);
    self.iconImgView.top = (self.topView.height - self.iconImgView.height ) * 0.5;
    self.iconImgView.left = 18;
    
    UIImage *headImgPlace = nil;
    BOOL iconButtonHidden = YES;
    switch (self.notice.noticeType) {
        case NoticesType_Tea:
        {
            headImgPlace = [UIImage imageNamed:@"默认头像"];
            iconButtonHidden = NO;
        }
            break;
        case NoticesType_System:
        {
            headImgPlace = [UIImage imageNamed:@"公共号"];
            iconButtonHidden = YES;
        }
            break;
        case NoticesType_School:
        {
            headImgPlace = [UIImage imageNamed:@"学校头像"];
            iconButtonHidden = YES;
        }
            break;
        default:
        {
            iconButtonHidden = YES;
            headImgPlace = [UIImage imageNamed:@"默认头像"];
        }
            break;
    }
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:self.notice.iconUrl] placeholderImage:headImgPlace];
    self.iconMaskView.frame = self.iconImgView.frame;
    self.iconButton.frame = self.iconImgView.frame;
    self.iconButton.hidden = iconButtonHidden;
    
    self.owernTextLabel.text = self.notice.strPublicName;
    [self.owernTextLabel sizeToFit];
    self.owernTextLabel.left = self.iconImgView.right + 10;
    self.owernTextLabel.width = self.topView.width - self.owernTextLabel.left - 10;
    

    self.timeLabel.text = self.notice.dateString;
    [self.timeLabel sizeToFit];
    self.timeLabel.left = self.owernTextLabel.left;
    self.timeLabel.width = self.owernTextLabel.width;

    self.owernTextLabel.top = (self.topView.height - self.owernTextLabel.height - self.timeLabel.height - 20) * 0.5;
    self.timeLabel.top = self.owernTextLabel.bottom + 20;
    
    self.topLineImgView.frame = CGRectMake(0, self.topView.height -1, self.topView.width, 1);
    
}


- (void)setNoticeContent {
    self.titleLabel.width = self.scrollView.width - 18 * 2;
    self.titleLabel.text = self.notice.subTitle;
    [self.titleLabel sizeToFit];
    self.titleLabel.left = 18;
    self.titleLabel.top = self.topView.bottom + 10;
    
    UIImage *line = [UIImage imageNamed:@"分隔线"];
    line = [line resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    self.lineImgView.image = line;
    self.lineImgView.frame = CGRectMake(8, self.titleLabel.bottom + 10, self.scrollView.width - 8, 1);
    
    self.contentLabel.width = self.scrollView.width - 18 * 2.0;
    self.contentLabel.text = self.notice.content;
    [self.contentLabel sizeToFit];
    self.contentLabel.left = self.titleLabel.left;
    self.contentLabel.top = self.lineImgView.bottom + 10;
    
    self.scrollView.contentSize = CGSizeMake(self.allContentView.width, self.contentLabel.bottom + 10);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)iconAction:(UIButton *)sender {
//    PersonalInfoViewController * personalVC = [[PersonalInfoViewController alloc] initWithNibName:nil bundle:nil aTUserid:self.notice.senderid];
//    [self.navigationController pushViewController:personalVC animated:YES];

}
@end
