//
//  CourseDescriptionView.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/21.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarsView.h"
#import "HttpRequest.h"

@class CourseDetailModel;
@interface CourseDescriptionView : UIView<HttpRequestDelegate>
{
    BOOL showMoreView;
    HttpRequest *http_;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoBgImg;
@property (weak, nonatomic) IBOutlet UILabel *coursePrice;
@property (weak, nonatomic) IBOutlet UILabel *teachingTea;
@property (weak, nonatomic) IBOutlet UILabel *organization;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *lessonstime;
@property (weak, nonatomic) IBOutlet UIImageView *jqBgImg;
@property (weak, nonatomic) IBOutlet UILabel *jqLabel;
@property (weak, nonatomic) IBOutlet UILabel *mzLabel;
@property (weak, nonatomic) IBOutlet UIImageView *xzLabel;
@property (weak, nonatomic) IBOutlet UILabel *zzLable;
@property (weak, nonatomic) IBOutlet UILabel *pfLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *infoBottomLine;
@property (weak, nonatomic) IBOutlet StarsView *t_starsView;


@property (weak, nonatomic) IBOutlet UILabel *courseMb;
@property (weak, nonatomic) IBOutlet UITextView *mbTextView;
@property (weak, nonatomic) IBOutlet UIImageView *desbottomLine;
@property (weak, nonatomic) IBOutlet UIButton *infobutton;

@property (assign, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) CourseDetailModel *course;
@property (assign, nonatomic) long long classidid;


- (IBAction)avatarAction:(UIButton *)sender;

- (void)updateContent:(CourseDetailModel *)courseModel;
@end
