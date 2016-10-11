//
//  CoretextButton.h
//  CoreTextViewDome
//
//  Created by chuliangliang on 15/6/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoretextButton : UIView

@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UIButton *button;
-(void)setImageUrl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
