//
//  CLEmojiInpuView.m
//  EmojiView
//
//  Created by chuliangliang on 15/5/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CLEmojiInpuView.h"
#import "CLEmojiView.h"
#import "StyledPageControl.h"

#define CLEmojiViewHeight Emoji_Height * Emoji_line_count + Emoji_line * (Emoji_line_count -1) + 20

@interface CLEmojiInpuView ()<UIScrollViewDelegate,CLEmojiViewDelegate>
{
    StyledPageControl *pageControl;
}
@end
@implementation CLEmojiInpuView

- (id)initWithFrame:(CGRect)frame imgConfigName:(NSString*)pName delegate:(id)aDelegate
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, CLEmojiViewHeight)];
    if (self) {
        self.delegate = aDelegate;
        NSString *path = [[NSBundle mainBundle] pathForResource:pName ofType:@"plist"];
        NSArray *emojiArr = [NSArray arrayWithContentsOfFile:path];
        [self _initViews:emojiArr];
    }
    return self;
}

- (void)_initViews:(NSArray *)emojiArr{
    
    
    [[self viewWithTag:200000001] removeFromSuperview];
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    scrollView.tag = 200000001;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.canCancelContentTouches = NO;
    self.clipsToBounds = YES;
    scrollView.clipsToBounds = NO;
    
    NSInteger count = emojiArr.count;
    float numbers = Emoji_LINE_COUNT * Emoji_line_count;//每页表情数
    
    int page = ceilf(count / numbers);
    for (int i = 0; i < page; i++) {
        int len = numbers;
        int remaindCount = count % len;
        if (i == page - 1 && remaindCount != 0) {
            len = remaindCount;
        }
        NSArray *itemArr = [emojiArr subarrayWithRange:NSMakeRange(i*(int)numbers, len)];
        
        CLEmojiView *clemj = [[CLEmojiView alloc] initWithFrame:CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, CLEmojiViewHeight - 10)];
        clemj.delegate = self;
        [clemj updateEmojis:itemArr];
        [scrollView addSubview:clemj];
    }
    
    [scrollView setContentSize:CGSizeMake(self.frame.size.width * page, CLEmojiViewHeight)];
    
    [[self viewWithTag:200000002] removeFromSuperview];
    pageControl=[[StyledPageControl alloc] initWithFrame:CGRectZero];
    [pageControl setPageControlStyle:PageControlStyleStrokedCircle];
    pageControl.coreNormalColor = [UIColor blackColor];
    pageControl.strokeNormalColor = [UIColor blackColor];
    pageControl.strokeSelectedColor = [UIColor blackColor];
    pageControl.coreSelectedColor = [UIColor blackColor];
    
    pageControl.numberOfPages = page;
    pageControl.tag = 200000002;
    pageControl.currentPage = 0;
    pageControl.frame = CGRectMake(0,CLEmojiViewHeight - 10, self.frame.size.width, 10);
    
    pageControl.userInteractionEnabled = NO;
    [self addSubview:pageControl];
    
    self.backgroundColor = [UIColor whiteColor];
}

//==============================================================================
// CLLEmojiViewDelegate
//==============================================================================

#pragma mark - CLLEmojiViewDelegate
-(void)didTouchEmojiView:(CLEmojiView *)emojiView touchedEmojiName:(NSString *)name emojiIndexPath:(NSString *)idxPathString
{
    if ([self.delegate respondsToSelector:@selector(cLEmojiInpuView:didTouchimgName:imgIndexPath:)]) {
        [self.delegate cLEmojiInpuView:self didTouchimgName:name imgIndexPath:idxPathString];
    }
}

//==============================================================================
// UIScrollViewDelegate
//==============================================================================

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = sender.frame.size.width;
    int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    pageControl.currentPage=page;
    
}

@end
