//
//  InputMoreView.m
//  InPutBoxView
//
//  Created by chuliangliang on 15-1-6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
//由于时间紧迫 有可能不是非常完美 欢迎大家指正
//
//QQ: 949977202
//Email: chuliangliang300@sina.com

#import "InputMoreView.h"
#define  MaxkHieght 160
#define ItemsSize CGSizeMake(50, 70)
#define ItemsIconSize CGSizeMake(50, 50)

#define SCREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width

#define OneLineCount 3
#define LineWidth (SCREEN_WIDTH - OneLineCount * ItemsSize.width) / (OneLineCount + 1)
#define StartX LineWidth
#define StartY 20
@interface MoreButton : UIView
{
    UIButton *button;
    UILabel *label;
    UIImageView *iconView;
 }

- (void)setHilightImage:(UIImage *)himg;
- (void)setImage:(UIImage *)img;

- (void)setTitleText:(NSString *)text;
- (void)setTexthighlightedColor:(UIColor *)color;
- (void)setTextColor:(UIColor *)color;
- (void)settextFont:(UIFont *)font;

- (void)addTarget:(id)target action:(SEL)action;

@property (nonatomic, assign)SEL tapAction;
@property (nonatomic, assign)id owerTarget;

@end

@implementation MoreButton
@synthesize tapAction;
@synthesize owerTarget;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ItemsIconSize.width, ItemsIconSize.height)];
        iconView.highlighted = NO;
        iconView.userInteractionEnabled = YES;
        [self addSubview:iconView];
        

        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, ItemsIconSize.width, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textColor = [UIColor colorWithRed:0x60/255.0 green:0x60/255.0 blue:0x60/255.0 alpha:1];
        label.highlightedTextColor = [UIColor colorWithRed:0x60/255.0 green:0x60/255.0 blue:0x60/255.0 alpha:1];
        label.highlighted = NO;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];

        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonTouchUpDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:button];

    }
    return self;
}



- (void)buttonTouchUpInside:(UIButton *)button{
    iconView.highlighted  = NO;
    label.highlighted = NO;
    if([owerTarget respondsToSelector:tapAction]) {
        [owerTarget performSelectorOnMainThread:tapAction withObject:self waitUntilDone:YES];
    }

}
- (void)buttonTouchUpDown:(UIButton *)button {
    iconView.highlighted  = YES;
    label.highlighted = YES;
}

- (void)buttonTouchUpOutside:(UIButton *)button {
    iconView.highlighted = NO;
    label.highlighted = NO;
}

////////////////////////////////////////////////////////////////////////////
- (void)addTarget:(id)target action:(SEL)action {
    owerTarget = target;
    tapAction = action;

}

////////////////////////////////////////////////////////////////////////////
- (void)setHilightImage:(UIImage *)himg {
    iconView.highlightedImage = himg;
}

////////////////////////////////////////////////////////////////////////////
- (void)setImage:(UIImage *)img {
    iconView.image = img;
}

////////////////////////////////////////////////////////////////////////////
// Label
////////////////////////////////////////////////////////////////////////////
- (void)setTexthighlightedColor:(UIColor *)color
{
    label.highlightedTextColor = color;
}

////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor *)color
{
    label.textColor = color;
}
////////////////////////////////////////////////////////////////////////////
- (void)setTitleText:(NSString *)text {
    label.text = text;
}
////////////////////////////////////////////////////////////////////////////
- (void)settextFont:(UIFont *)font {
    label.font = font;
}
@end

@interface InputMoreView ()
@property (nonatomic, weak) id<InputMoreViewDelegate>delegate;
@property (nonatomic, strong) NSArray *items;
@end

@implementation InputMoreView

- (void)dealloc {
    self.delegate = nil;
}
- (id)initWithFrame:(CGRect)frame items:(NSArray *)aItems delegate:(id/*<InputMoreViewDelegate>*/)aDelegate
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, MaxkHieght)];
    if(self){
        self.delegate = aDelegate;
        self.items = aItems;
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat sizeHeidth = ItemsSize.height;
    CGFloat sizeWidth = ItemsSize.width;
    CGFloat x = StartX;
    CGFloat y = StartY;
    
    int forCount = (int)self.items.count;
    
    for (int i= 0; i < forCount; i++) {
        
        if (i % OneLineCount == 0) {
            x = StartX;
            if (i != 0) {
                y += sizeHeidth + LineWidth;
            }
        }else {
            x += sizeWidth + LineWidth;
        }
        
        buttonCongfig config;
        NSValue *value =  [self.items objectAtIndex:i];
        [value getValue:&config];
        NSString *img = [NSString stringWithUTF8String:config.imageName];
        NSString *hImg = [NSString stringWithUTF8String:config.hilightImgName];
        NSString *title = [NSString stringWithUTF8String:config.title];
        int buttonTag = config.tag;
        
        MoreButton *moreButton = [[MoreButton alloc] initWithFrame:CGRectMake(x, y, sizeWidth, sizeHeidth)];
        [moreButton setImage:[UIImage imageNamed:img]];
        [moreButton setHilightImage:[UIImage imageNamed:hImg]];
        [moreButton setTitleText:title];
        [moreButton setTextColor:[UIColor colorWithRed:0x60/255.0 green:0x60/255.0 blue:0x60/255.0 alpha:1]];
        [moreButton setTexthighlightedColor:[UIColor blackColor]];
        moreButton.tag = buttonTag;
        [moreButton addTarget:self action:@selector(buttonAction:)];
        [self addSubview:moreButton];
    }
}
- (void)buttonAction:(MoreButton *)mButton {
    if ([self.delegate respondsToSelector:@selector(inputMoreView:didSelectInde:)]) {
        [self.delegate inputMoreView:self didSelectInde:mButton.tag];
    }
}
@end
