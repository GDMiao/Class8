//
//  CoretextButton.m
//  CoreTextViewDome
//
//  Created by chuliangliang on 15/6/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CoretextButton.h"
#import "UIImageView+WebCache.h"

@interface CoretextButton ()
@property (strong,nonatomic) NSString *imageUrl;
@property (strong,nonatomic) UIImage *placeHoldImage;
@end
@implementation CoretextButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageview1 = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView = imageview1;
        [self addSubview:imageview1];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = self.bounds;
        self.button = button1;
        [self addSubview:button1];
    }
    return self;
}
-(void)setImageUrl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage
{
    self.imageUrl = imageUrl;
    self.placeHoldImage = placeholderImage;    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeholderImage];
}
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}
@end
