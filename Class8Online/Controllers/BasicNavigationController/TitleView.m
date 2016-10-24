//
//  TitleView.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "TitleView.h"
#define BUTTON_LEFT 1001
#define BUTTON_RIGHT 1002

@interface TitleView ()
@property (strong, nonatomic)UILabel *titleLabel;
@property (strong, nonatomic)UIButton *leftButton;
@property (strong, nonatomic)UIButton *rightButton;
@property (strong, nonatomic)UIImageView *bjImgView;
@end

@implementation TitleView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}
- (void)awakeFromNib {
    [self _initView];
}
- (void)dealloc {
    self.titleLabel = nil;
    self.leftButton = nil;
    self.rightButton= nil;
    self.bjImgView = nil;
    self.delegate = nil;
}
- (void)_initView {

    self.bjImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.bjImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bjImgView.userInteractionEnabled = YES;
    [self addSubview:self.bjImgView];
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.numberOfLines = 1;

    [self addSubview:self.titleLabel];
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.tag = BUTTON_LEFT;
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.leftButton  addTarget:self action:@selector(buttonsAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    self.rightButton.tag = BUTTON_RIGHT;
    [self.rightButton  addTarget:self action:@selector(buttonsAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightButton];

    
}
- (void)buttonsAction:(UIButton *)button {
    if (BUTTON_RIGHT == button.tag) {
        if ([self.delegate respondsToSelector:@selector(rightClicked:)]) {
            [self.delegate rightClicked:self];
        }
        
    }else if (BUTTON_LEFT == button.tag) {
        if ([self.delegate respondsToSelector:@selector(leftClicked:)]) {
            [self.delegate leftClicked:self];
        }
    }
}
- (void)setTitleText:(NSString *)title
{
    if (self.titleLabel) {
        self.titleLabel.text = title;
    }
}
- (void)setTitleText:(NSString *)title withTitleStyle:(CTitleStyle)style
{
    if (CTitleStyle_FirstLogin == style) {
        self.backgroundColor = [UIColor clearColor];
        self.leftButton.hidden = YES;
        self.bjImgView.hidden = YES;
        self.rightButton.hidden = YES;
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = title;
        self.titleLabel.frame = CGRectMake(54, IS_IOS7?20:0, SCREENWIDTH - 108, IS_IOS7?self.height - 20:self.height);

        
    } else if (CTitleStyle_Setting == style) {
        self.backgroundColor = [UIColor clearColor];
        self.bjImgView.hidden = YES;
        
        //左按钮
        self.leftButton.hidden = NO;
       
        self.leftButton.frame = CGRectMake(5,IS_IOS7?20 + ((self.height - 20) - 44) * 0.5:(self.height- 44) * 0.5, 44, 44);
        [self.leftButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
        
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.text = title;
        self.titleLabel.frame = CGRectMake(54, IS_IOS7?20:0, SCREENWIDTH - 108, IS_IOS7?self.height - 20:self.height);
    }else if (style == CTitleStyle_Home) {
        //首页
        self.rightButton.hidden = YES;
        self.leftButton.hidden = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        UIImage *navImg = [UIImage imageNamed:@"nav顶"];
        navImg = [navImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.bjImgView.image = navImg;
        self.bjImgView.frame = self.bounds;

        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = title;
        self.titleLabel.frame = CGRectMake(54, IS_IOS7?20:0, SCREENWIDTH - 108, IS_IOS7?self.height - 20:self.height);
                
    }else if (CTitleStyle_OnlyBack == style) {
        self.rightButton.hidden = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        UIImage *navImg = [UIImage imageNamed:@"nav顶"];
        navImg = [navImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.bjImgView.image = navImg;
        self.bjImgView.frame = self.bounds;

    
        self.leftButton.frame = CGRectMake(5,IS_IOS7?20 + ((self.height - 20) - 44) * 0.5:(self.height- 44) * 0.5, 44, 44);
        [self.leftButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = title;
        self.titleLabel.frame = CGRectMake(54, IS_IOS7?20:0, SCREENWIDTH - 108, IS_IOS7?self.height - 20:self.height);
        
    }else if (CTitleStyle_OnlyRight == style) {
        //只有右侧按钮
        self.leftButton.hidden = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        UIImage *navImg = [UIImage imageNamed:@"nav顶"];
        navImg = [navImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.bjImgView.image = navImg;
        self.bjImgView.frame = self.bounds;

        
        self.rightButton.hidden = NO;
        self.rightButton.frame = CGRectMake(self.width - 44 - 5,IS_IOS7?20 + ((self.height - 20) - 44) * 0.5:(self.height- 44) * 0.5, 44, 44);
        [self.rightButton setTitle:@"提交" forState:UIControlStateNormal];
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = title;
        self.titleLabel.frame = CGRectMake(54, IS_IOS7?20:0, SCREENWIDTH - 108, IS_IOS7?self.height - 20:self.height);

    }else if (CTitleStyle_AlphaNoStatus == style) {
        //黑色半透明导航 白色字体 只有返回按钮 没有状态栏
        self.rightButton.hidden = YES;
        self.leftButton.hidden = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.bjImgView.image = [UIImage imageNamed:@"视频播放状态栏"];
        self.bjImgView.frame = self.bounds;
        
        
        self.leftButton.frame = CGRectMake(5,0, 44, 44);
        [self.leftButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = title;
        self.titleLabel.frame = CGRectMake(54, 0, SCREENWIDTH - 108, self.height);
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    }else if (CTitleStyle_LeftAndRight == style) {

        self.backgroundColor = [UIColor whiteColor];
        UIImage *navImg = [UIImage imageNamed:@"nav顶"];
        navImg = [navImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.bjImgView.image = navImg;
        self.bjImgView.frame = self.bounds;
        
        
        //左右按钮
        self.leftButton.hidden = NO;
      
        self.leftButton.frame = CGRectMake(5,IS_IOS7?20 + ((self.height - 20) - 44) * 0.5:(self.height- 44) * 0.5, 44, 44);
        [self.leftButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
        
        self.rightButton.hidden = NO;
    
        self.rightButton.frame = CGRectMake(self.width - 44 - 5,IS_IOS7?20 + ((self.height - 20) - 44) * 0.5:(self.height- 44) * 0.5, 44, 44);
        [self.rightButton setTitle:@"设置" forState:UIControlStateNormal];
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = title;
      
        self.titleLabel.frame = CGRectMake(54, IS_IOS7?20:0, SCREENWIDTH - 108, IS_IOS7?self.height - 20:self.height);
    }else if (CTitleStyle_Camera == style) {
        self.backgroundColor = [UIColor blackColor];
        self.bjImgView.hidden = YES;
        self.titleLabel.hidden = YES;
        
        self.leftButton.frame = CGRectMake(5, 0, 44, 44);
        [self.leftButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        
        self.rightButton.frame = CGRectMake(SCREENWIDTH - 49, 0, 44, 44);
        [self.rightButton setImage:[UIImage imageNamed:@"翻转镜头"] forState:UIControlStateNormal];
    }
}


- (void)setleftButtonText:(NSString *)text
{
    if (self.leftButton) {
        [self.leftButton setTitle:text forState:UIControlStateNormal];
    }
}
- (void)setRightButonText:(NSString *)text
{
    if (self.rightButton) {
        [self.rightButton setTitle:text forState:UIControlStateNormal];
    }
}
- (void)setleftButtonImg:(UIImage *)img
{
    if (self.leftButton) {
        [self.leftButton setTitle:@"" forState:UIControlStateNormal];
        [self.leftButton setImage:img forState:UIControlStateNormal];
    }

}
- (void)setRightButonImg:(UIImage *)img
{
    if (self.rightButton) {
        [self.rightButton setTitle:@"" forState:UIControlStateNormal];
        [self.rightButton setImage:img forState:UIControlStateNormal];
    }

}
-  (UIButton *)titleLeftButton
{
    return self.leftButton;
}
- (UIButton *)titleRightButton {
    return self.rightButton;
}
@end
