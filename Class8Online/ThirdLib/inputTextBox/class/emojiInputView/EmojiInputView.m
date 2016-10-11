//
//  EmojiInputView.m
//  InPutBoxView
//
//  Created by chuliangliang on 15-1-6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
//由于时间紧迫 有可能不是非常完美 欢迎大家指正
//
//QQ: 949977202
//Email: chuliangliang300@sina.com

#import "EmojiInputView.h"
#import "StyledPageControl.h"
#import "CLLEmojiView.h"

#define CLLEmojiViewHeight 160.0f

//==============================================================================
// EmojiUtils
//==============================================================================

@interface EmojiUtils ()

@end

static EmojiUtils *sharedInstance = nil;
@implementation EmojiUtils
+(EmojiUtils *)shareEmojiUtils
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        NSBundle *bundle = [ NSBundle mainBundle ];
        
        NSString *filePath = [ bundle pathForResource:@"emojiDic" ofType:@"plist" ];
        sharedInstance.emojiDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        NSString *filePath2 = [ bundle pathForResource:@"emojiKeyArray" ofType:@"plist" ];
        sharedInstance.emojiKeys = [NSArray arrayWithContentsOfFile:filePath2];
    });
    return sharedInstance;
}
- (void)dealloc {
    self.emojiDic = nil;
    self.emojiKeys = nil;
}

@end


@interface EmojiInputView ()<CLLEmojiViewDelegate,UIScrollViewDelegate>
{
    float tY;
    BOOL hasShowed;
    StyledPageControl *pageControl;
}

@end


//==============================================================================
// EmojiInputView
//==============================================================================

@implementation EmojiInputView

- (id)initWithFrame:(CGRect)frame delegate:(id<EmojiInputViewDelegate>)aDelegate hasSendButton:(BOOL)aHasSendButton

{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, CLLEmojiViewHeight)];
    if (self) {
        self.delegate = aDelegate;
        NSDictionary *dic = [EmojiUtils shareEmojiUtils].emojiDic;
        NSArray *keys = [EmojiUtils shareEmojiUtils].emojiKeys;
        
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
        
        NSInteger count = keys.count;
        float numbers = 19.0;//每页表情数
        if (aHasSendButton) {
            numbers = 18.0;
        }
        int page = ceilf(count / numbers);
        for (int i = 0; i < page; i++) {
            int len = numbers;
            int remaindCount = count % len;
            if (i == page - 1 && remaindCount != 0) {
                len = remaindCount;
            }
            NSArray *keyItems = [keys subarrayWithRange:NSMakeRange(i*(int)numbers, len)];
            NSArray *valueItems = [dic objectsForKeys:keyItems notFoundMarker:@"无奈"];
            CLLEmojiView *emojiView = [[CLLEmojiView alloc] initWithFrame:CGRectMake(SCREENWIDTH * i + (SCREENWIDTH - 300) * 0.5, 10, 300, CLLEmojiViewHeight) symbolArray:keyItems emojiArray:valueItems hasSendButton:aHasSendButton];
            emojiView.delegate = self;
            [scrollView addSubview:emojiView];
        }
        
        [scrollView setContentSize:CGSizeMake(SCREENWIDTH * page, CLLEmojiViewHeight)];
        
        [[self viewWithTag:200000002] removeFromSuperview];
        pageControl=[[StyledPageControl alloc] initWithFrame:CGRectZero];
        [pageControl setPageControlStyle:PageControlStyleThumb];
        [pageControl setThumbImage:[UIImage imageNamed:@"表情点"]];
        [pageControl setSelectedThumbImage:[UIImage imageNamed:@"表情点_highlight"]];
        pageControl.numberOfPages = page;
        pageControl.tag = 200000002;
        pageControl.currentPage = 0;
        float pageControlWidth=page*10.0f+40.f;
        float pagecontrolHeight=5.0f;
        pageControl.frame = CGRectMake((SCREENWIDTH-pageControlWidth)*0.5,CLLEmojiViewHeight, pageControlWidth, pagecontrolHeight - 20);
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];
    }
    return self;
}

//==============================================================================
// CLLEmojiViewDelegate
//==============================================================================

#pragma mark - CLLEmojiViewDelegate
-(void)didTouchEmojiView:(CLLEmojiView *)emojiView touchedEmoji:(NSString *)string
{
    if ([self.delegate respondsToSelector:@selector(didTouchedEmoji:)]) {
        [self.delegate didTouchedEmoji:string];
    }
}
-(void)didTouchDeleteEmojiView:(CLLEmojiView *)emojiView
{
    if ([self.delegate respondsToSelector:@selector(didTouchedDelete)]) {
        [self.delegate didTouchedDelete];
    }
}
-(void)didTouchSendEmojiView:(CLLEmojiView *)emojiView
{
    if ([self.delegate respondsToSelector:@selector(didTouchedSend)]) {
        [self.delegate didTouchedSend];
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

//==============================================================================
// Method
//==============================================================================

-(NSString *)removeEmojiText:(NSString *)inputString
{
    NSString *string = nil;
    NSInteger stringLength = inputString.length;
    if (stringLength > 0) {
        if ([@"]" isEqualToString:[inputString substringFromIndex:stringLength-1]]) {
            if ([inputString rangeOfString:@"["].location == NSNotFound){
                string = [inputString substringToIndex:stringLength - 1];
            } else {
                NSString *tmeStr = [inputString substringFromIndex:[inputString rangeOfString:@"[" options:NSBackwardsSearch].location];
                if ([[EmojiUtils shareEmojiUtils].emojiDic objectForKey:tmeStr]) {
                    string = [inputString substringToIndex:[inputString rangeOfString:@"[" options:NSBackwardsSearch].location];;
                }else{
                    string = [inputString substringToIndex:stringLength - 1];
                }
            }
        } else {
            string = [inputString substringToIndex:stringLength - 1];
        }
    }
    if (!string) {
        string = @"";
    }
    return string;
}


-(BOOL)hasSuffixEmoji:(NSString *)inputString
{
    NSInteger stringLength = inputString.length;
    if (stringLength > 0) {
        return [@"]" isEqualToString:[inputString substringFromIndex:stringLength-1]];
    }
    return NO;
}
-(NSString *)setBackPressCustomTextViewWithText:(NSString *)text
{
    NSString *inputString = text;
    //删除文字 或 表情 返回 删除之后的文字
    return [self removeEmojiText:inputString];
}

//删除表情
-(void)setBackPressTextView:(HPGrowingTextView *)atextView
{
    NSString *inputString = atextView.text;
    if (!inputString) {
        inputString = @"";
    }
    NSRange selectRange = atextView.selectedRange;
    NSString *editStr = [inputString substringToIndex:selectRange.location];
    if (![self hasSuffixEmoji:editStr]) {
        [atextView deleteBackward];
        return;
    }
    NSString *noEditStr = [inputString substringFromIndex:selectRange.location];
    NSString *removeStr = [self setBackPressCustomTextViewWithText:editStr];
    atextView.text = [NSString stringWithFormat:@"%@%@",removeStr,noEditStr];
    NSString *nowStr = atextView.text;
    if (!nowStr) {
        nowStr = @"";
    }
    NSRange nowRange = [nowStr rangeOfString:removeStr];
    if (nowRange.location != NSNotFound) {
        selectRange.location = nowRange.length;
    }else{
        selectRange.location = 0;
    }
    atextView.selectedRange = selectRange;
    [atextView scrollRangeToVisible:selectRange];
    
}
//输入表情
-(void)setEmojiTextView:(HPGrowingTextView *)atextView emoji:(NSString *)emoji
{
    NSString *inputString = atextView.text;
    if (!inputString) {
        inputString = @"";
    }
    NSRange selectRange = atextView.selectedRange;
    NSString *editStr = [inputString substringToIndex:selectRange.location];
    NSString *noEditStr = [inputString substringFromIndex:selectRange.location];
    atextView.text = [NSString stringWithFormat:@"%@%@%@",editStr,emoji,noEditStr];
    selectRange.location = selectRange.location + emoji.length;
    atextView.selectedRange = selectRange;
    
    [atextView scrollRangeToVisible:selectRange];

}

@end
