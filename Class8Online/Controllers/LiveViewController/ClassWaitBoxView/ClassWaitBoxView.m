//
//  ClassWaitBoxView.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/25.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "ClassWaitBoxView.h"
#define IconSize CGSizeMake(75, 69)
@interface ClassWaitBoxView ()

@property (strong ,nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIImageView *icon;
@end

@implementation ClassWaitBoxView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews {
    self.backgroundColor = [UIColor blackColor];
    
    
    self.icon = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.icon.image = [UIImage imageNamed:@"课程无视频"];
    [self addSubview:self.icon];
    
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.textAlignment =  NSTextAlignmentCenter;
    self.contentLabel.numberOfLines = 1;
    self.contentLabel.backgroundColor = [self backgroundColor];
    self.contentLabel.textColor = MakeColor(0x19, 0x76, 0xd2);
    self.contentLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:self.contentLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.icon.frame = CGRectMake((self.width-IconSize.width)*0.5, 0, IconSize.width, IconSize.height);
    
    self.contentLabel.text = CSLocalizedString(@"live_VC_class_not_begin");
    [self.contentLabel sizeToFit];
    self.contentLabel.left = (self.width - self.contentLabel.width) * 0.5;
    
    self.icon.top = (self.height - self.icon.height - self.contentLabel.height - 14) *0.5;
    self.contentLabel.top =self.icon.bottom + 14;
}

@end
