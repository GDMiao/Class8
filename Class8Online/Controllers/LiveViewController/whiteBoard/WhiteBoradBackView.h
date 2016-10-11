//
//  WhiteBoradBackView.h
//  Class8Online
//
//  Created by chuliangliang on 15/6/26.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhiteBoradBackView : UIView
@property (strong, nonatomic) UIView *wbView;
- (void)updateFrame:(CGRect)frame isAnimate:(BOOL)animate;
@end
