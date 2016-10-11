//
//  StarsView.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/21.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "StarsView.h"

const int totalStarsCount = 5;
@implementation StarsView
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}


- (void)_initSubViews
{
    for (int i = 0 ; i < totalStarsCount; i ++) {
        UIImageView *v =[[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:v];
    }
}

- (void)layoutSubviews
{
    CGFloat line = 3;   //每个星星间隔
    CGFloat oneStarWidth = (self.width -(totalStarsCount-1) * line) /totalStarsCount;
    if (oneStarWidth > self.height) {
        oneStarWidth = self.height;
        line = (self.width-oneStarWidth*totalStarsCount)/(totalStarsCount -1);
    }
    self.height = oneStarWidth;
    self.width = oneStarWidth*totalStarsCount+(totalStarsCount-1)*line;
    
    CGFloat y = 0;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imgView = (UIImageView *)obj;
        imgView.frame = CGRectMake(idx*(oneStarWidth+line), y, oneStarWidth, oneStarWidth);
    }];
}

- (void)updateContent:(CGFloat)pf
{
    
    int completeSatrsCount = (int)pf;
    BOOL hasHalfStar = pf-completeSatrsCount > 0;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *starIcon = nil;
        if (idx < completeSatrsCount && completeSatrsCount != 0) {
            starIcon = [UIImage imageNamed:@"星选中"];
        }else if (hasHalfStar && completeSatrsCount  == idx) {
            starIcon = [UIImage imageNamed:@"半颗星"];
        }else{
            starIcon = [UIImage imageNamed:@"星未选中"];
        }
       UIImageView *imgView = (UIImageView *)obj;
        imgView.image = starIcon;
    }];
    [self layoutIfNeeded];
}

@end
