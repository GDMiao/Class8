//
//  PDFBackView.m
//  Class8Online
//
//  Created by chuliangliang on 15/6/25.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "PDFBackView.h"
@interface PDFBackView ()
@end

@implementation PDFBackView
- (void)dealloc {
    self.pdfView = nil;

}
- (id)initWithFrame:(CGRect)frame {
     self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews
{
    self.pdfView = [[DrawPDFView alloc] initWithFrame:self.bounds];
    self.pdfView.lineColor_ = [UIColor whiteColor];
    self.pdfView.textColor_ = [UIColor whiteColor];
    self.pdfView.textFont_ = [UIFont systemFontOfSize:14.0f];
    self.pdfView.lineWidth_ = 1;
    self.pdfView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.pdfView];
}

/**
 * 更新坐标放大比例 弃用 for 2015/06/29
 **/
- (void)updateFrame:(CGRect)frame isAnimate:(BOOL)animate
{
    if (animate) {
        float drPdfMinScale = 1;
        float viewWidth = frame.size.width;
        float viewHeight = frame.size.height;
        drPdfMinScale = MIN(viewWidth/self.pdfView.width, viewHeight/self.pdfView.height);

        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
            self.pdfView.transform = CGAffineTransformScale(self.pdfView.transform, drPdfMinScale, drPdfMinScale);
            self.pdfView.left = (self.width - self.pdfView.width) * 0.5;
            self.pdfView.top = (self.height - self.pdfView.height) * 0.5;
        }];
    }else {
        float drPdfMinScale = 1;
        float viewWidth = frame.size.width;
        float viewHeight = frame.size.height;
        drPdfMinScale = MIN(viewWidth/self.pdfView.width, viewHeight/self.pdfView.height);
        
        self.frame = frame;
        self.pdfView.transform = CGAffineTransformScale(self.pdfView.transform, drPdfMinScale, drPdfMinScale);
        self.pdfView.left = (self.width - self.pdfView.width) * 0.5;
        self.pdfView.top = (self.height - self.pdfView.height) * 0.5;

    }
}


@end
