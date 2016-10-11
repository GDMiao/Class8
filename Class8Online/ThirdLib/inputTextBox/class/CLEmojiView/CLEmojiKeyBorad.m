//
//  CLEmojiKeyBorad.m
//  EmojiView
//
//  Created by chuliangliang on 15/5/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CLEmojiKeyBorad.h"
#import "HMSegmentedControl.h"
#import "HFBrowserView.h"
#import "CLEmojiInpuView.h"

#define DefaultSelectedIndex 0
#define ToolsViewHeight 40
@interface CLEmojiKeyBorad ()<HFBrowserViewSourceDelegate,HFBrowserViewDelegate,CLEmojiInpuViewDelegate>
@property (strong, nonatomic) NSArray *emojiList;
@property (strong, nonatomic) HMSegmentedControl *segmentControl;
@property (strong, nonatomic) HFBrowserView *browserView;
@end

@implementation CLEmojiKeyBorad

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 200 + ToolsViewHeight)];
    if (self) {
        self.delegate = aDelegate;
        [self _initViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initViews];
    }
    return self;
}

- (void)_initViews
{
    NSString *emojiListPath = [[NSBundle mainBundle] pathForResource:@"全部表情" ofType:@"plist"];
    self.emojiList = [NSArray arrayWithContentsOfFile:emojiListPath];
    
    self.segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"东方不败",@"狸"]];
    self.segmentControl.frame = CGRectMake(0, self.height- ToolsViewHeight, self.width, ToolsViewHeight);
    self.segmentControl.textColor = [UIColor blackColor];
    [self.segmentControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.segmentControl.selectedSegmentIndex = 0;
    [self addSubview:self.segmentControl];
    
    self.browserView = [[HFBrowserView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - ToolsViewHeight)];
    self.browserView.bounces = NO;
    self.browserView.scrollEnabled = YES;
    self.browserView.sourceDelegate = self;
    self.browserView.dragDelegate = self;
    self.browserView.clipsToBounds = NO;
    [self addSubview:self.browserView];
    [self.browserView setInitialPageIndex:DefaultSelectedIndex];

    [self.browserView reloadData];
}

#pragma mark - 
#pragma mark - HMSegmentedControl Action
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    CSLog(@"选择: %ld", (long)segmentedControl.selectedSegmentIndex);
    [self.browserView setInitialPageIndex:segmentedControl.selectedSegmentIndex animated:YES];
}


#pragma mark -
#pragma mark HFBrowserView Delegate
-(NSUInteger)numberOfPageInBrowserView:(HFBrowserView *)browser
{
    return self.emojiList.count;
}
-(UIView *)browserView:(HFBrowserView *)browser viewAtIndex:(NSUInteger)index
{
    NSString *name = @"";
    if (index == 0) {
        name = @"东方不败";
    }else if (index == 1) {
        name = @"狸";
    }
    CLEmojiInpuView *ein = [[CLEmojiInpuView alloc] initWithFrame:browser.bounds imgConfigName:name delegate:self];
    return ein;

}
-(void)browserViewlDidEndDecelerating:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex
{
    [self.segmentControl setSelectedSegmentIndex:pageIndex animated:YES];
    [self refreshCurrentView];
}


-(void)browserViewlDidEndScrollingAnimation:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex
{
    //显示第几个视图了
    [self refreshCurrentView];
    
}

- (void)refreshCurrentView {
    
    
}


- (void)cLEmojiInpuView:(CLEmojiInpuView *)view didTouchimgName:(NSString *)nString imgIndexPath:(NSString *)indexpathString
{
    if ([self.delegate respondsToSelector:@selector(didTouchimgName:imgIndexPath:)]) {
        [self.delegate didTouchimgName:nString imgIndexPath:indexpathString];;
    }
}
@end
