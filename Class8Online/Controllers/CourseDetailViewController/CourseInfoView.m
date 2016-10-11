//
//  CourseInfoView.m
//  Class8Online
//
//  Created by chuliangliang on 15/5/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CourseInfoView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "CourseDetailModel.h"


@implementation IntoClassRoomAnimateButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews
{
    self.backgroundColor = [UIColor clearColor];
    
    self.icon1 = [[UIImageView alloc] initWithFrame:self.bounds];
    self.icon1.image = [UIImage imageNamed:@"进入课堂1"];
    self.icon1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.icon1];
    
    self.icon2 = [[UIImageView alloc] initWithFrame:self.icon1.bounds];
    self.icon2.image = [UIImage imageNamed:@"进入课堂2"];
    self.icon2.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.icon1 addSubview:self.icon2];
    [self addAnimation];
    
    
    self.btn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame = self.bounds;
    self.btn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:self.btn];
}
- (void)addTarget:(id)target action:(SEL)action
{
    [self.btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

/**
 *添加闪烁动画
 **/
- (void)addAnimation
{
    //创建动画
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    [opacityAnimation setDuration:0.9];
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    opacityAnimation.autoreverses = YES;
    opacityAnimation.cumulative = NO;
    opacityAnimation.removedOnCompletion = NO; //No Remove
    opacityAnimation.repeatCount = FLT_MAX;
    [self.icon2.layer addAnimation:opacityAnimation forKey:@"AnimatedKey"];
    [self.icon2 stopAnimating];
    self.icon2.layer.speed = 0.0;
}

- (void)beginAnimate
{
    //开始动画
    self.icon2.layer.speed = 1.0;
    self.icon2.layer.beginTime = 0.0;
    CFTimeInterval pausedTime = [self.icon2.layer timeOffset];
    CFTimeInterval timeSincePause = [self.icon2.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.icon2.layer.beginTime = timeSincePause;

}
- (void)stopAnimate
{
    //停止动画
    CFTimeInterval pausedTime = [self.icon2.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.icon2.layer.speed = 0.0;
    self.icon2.layer.timeOffset = pausedTime;
}

@end



@interface CourseInfoView ()
@property (strong, nonatomic) CourseDetailModel *courseModel;
@end

@implementation CourseInfoView

- (void)dealloc {

    self.courseCoverImg = nil;
    self.courseCoverImgMask = nil;
    self.nameLabel = nil;
    self.joinClassRoom = nil;
    self.segmentedControl = nil;
}
- (void)updateCourseInfo:(CourseDetailModel *)courseModel
{
    self.courseModel = courseModel;
    [self setNeedsLayout];
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initSubViews];
    }
    return self;
}
- (void)_initSubViews {

    
    self.courseCoverImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.courseCoverImg.userInteractionEnabled = YES;
    [self addSubview:self.courseCoverImg];
    
    
    self.courseCoverImgMask = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.courseCoverImgMask.userInteractionEnabled = YES;
    UIImage *courseMaskImg = [UIImage imageNamed:@"视频播放状态栏"];
    courseMaskImg = [courseMaskImg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.courseCoverImgMask.image = courseMaskImg;
    [self addSubview:self.courseCoverImgMask];
    
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.font = [UIFont systemFontOfSize:20];
    [self.courseCoverImgMask addSubview:self.nameLabel];
    
    
//    self.joinClassRoom = [[IntoClassRoomAnimateButton alloc] initWithFrame:CGRectZero];
//    [self addSubview:self.joinClassRoom];

    
    
    UIImage *segBjImg = [UIImage imageNamed:@"讨论底"];
    segBjImg = [segBjImg resizableImageWithCapInsets:UIEdgeInsetsMake(4, 1, 4, 1)];
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[
                                                                                CSLocalizedString(@"courseDetail_infoView_Segment_itme01"),CSLocalizedString(@"courseDetail_infoView_Segment_itme02"),
                                                                                CSLocalizedString(@"courseDetail_infoView_Segment_itme03")]];
    self.segmentedControl.selectionIndicatorHeight = 4.0f;
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.backgroundImage = segBjImg;
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:80/255.0 green:185/255.0 blue:54/255.0 alpha:1];
    self.segmentedControl.textFont = [UIFont systemFontOfSize:15.0f];
    self.segmentedControl.textColor = [UIColor colorWithWhite:51/255.0 alpha:1];
    self.segmentedControl.selectedTextColor = [UIColor colorWithRed:80/255.0 green:185/255.0 blue:54/255.0 alpha:1];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.segmentWidthStyle =  HMSegmentedControlSegmentWidthStyleFixed;
    self.segmentedControl.verticalDividerEnabled = NO;
    self.segmentedControl.verticalDividerColor = [UIColor colorWithWhite:220/255.0 alpha:1];
    self.segmentedControl.verticalDividerWidth = 1.0f;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [self addSubview:self.segmentedControl];
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //课程封面
    self.courseCoverImg.frame = CGRectMake(0, 0,SCREENWIDTH , SCREENWIDTH / (5/3.0));
    [self.courseCoverImg sd_setImageWithURL:[NSURL URLWithString:self.courseModel.courseCoverURL] placeholderImage:[UIImage imageNamed:@"默认课程"]];
    
    //封面遮罩
    self.courseCoverImgMask.frame = CGRectMake(0,self.courseCoverImg.bottom - 35, self.courseCoverImg.width, 35);
    
    //进入课堂按钮
    CGFloat btnWidth = 50.0f;
    self.joinClassRoom.frame = CGRectMake(self.width-btnWidth - 16, self.courseCoverImg.bottom - btnWidth -8, btnWidth, btnWidth);
    [self.joinClassRoom beginAnimate];
    
    //课程名字
    self.nameLabel.text = self.courseModel.courseName;
    [self.nameLabel sizeToFit];
    self.nameLabel.left = 16;
    self.nameLabel.top = (self.courseCoverImgMask.height - self.nameLabel.height) * 0.5;
    self.nameLabel.width = SCREENWIDTH - 2 * self.nameLabel.left;
    
    self.segmentedControl.frame = CGRectMake(0, self.courseCoverImg.bottom, self.courseCoverImg.width, 37);
    
}

@end
