//
//  WhiteBoradBackView.m
//  Class8Online
//
//  Created by chuliangliang on 15/6/26.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "WhiteBoradBackView.h"

@implementation WhiteBoradBackView
- (void)dealloc {
    self.wbView = nil;
}
- (void)updateFrame:(CGRect)frame isAnimate:(BOOL)animate
{
    if (animate) {
        float drPdfMinScale = 1;
        float viewWidth = frame.size.width;
        float viewHeight = frame.size.height;
        drPdfMinScale = MIN(viewWidth/self.wbView.width, viewHeight/self.wbView.height);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
            self.wbView.transform = CGAffineTransformScale(self.wbView.transform, drPdfMinScale, drPdfMinScale);
            self.wbView.left = (self.width - self.wbView.width) * 0.5;
            self.wbView.top = (self.height - self.wbView.height) * 0.5;
        }];
    }else {
        float drPdfMinScale = 1;
        float viewWidth = frame.size.width;
        float viewHeight = frame.size.height;
        drPdfMinScale = MIN(viewWidth/self.wbView.width, viewHeight/self.wbView.height);
        
        self.frame = frame;
        self.wbView.transform = CGAffineTransformScale(self.wbView.transform, drPdfMinScale, drPdfMinScale);
        self.wbView.left = (self.width - self.wbView.width) * 0.5;
        self.wbView.top = (self.height - self.wbView.height) * 0.5;
        
    }
}

@end
