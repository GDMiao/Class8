//
//  CLLEmojiView.m
//  InPutBoxView
//
//  Created by chuliangliang on 15-1-6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
//由于时间紧迫 有可能不是非常完美 欢迎大家指正
//
//QQ: 949977202
//Email: chuliangliang300@sina.com

#import "CLLEmojiView.h"
#define CLLEMOJIVIEW_COLUMNS 7
#define CLLEMOJIVIEW_SPACES  0.7
#define CLLEMOJIVIEW_KEYTOP_WIDTH 82
#define CLLEMOJIVIEW_KEYTOP_HEIGHT 111
#define CLLKEYTOP_SIZE 55
#define CLLEMOJI_SIZE 34
#define DeleteImageRect CGRectMake(179, 96, 44, 28)
#define NoSendDeleteImageRect CGRectMake(246, 96, 44, 28)
#define SendImageRect CGRectMake(237, 93, 55, 33)


//==============================================================================
// CLLEmojiViewLayer
//==============================================================================
@interface CLLEmojiViewLayer : CALayer {
@private
    CGImageRef _keytopImage;;
}
@property (nonatomic, retain) UIImage* emoji;
@end

@implementation CLLEmojiViewLayer
@synthesize emoji = _emoji;
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    _keytopImage = nil;
    _emoji = nil;
}

- (void)drawInContext:(CGContextRef)context
{
    //从后台返回需要重新获取图片,Fixes Bug
    _keytopImage = [[UIImage imageNamed:@"emoji_touch.png"] CGImage];
    
    UIGraphicsBeginImageContext(CGSizeMake(CLLEMOJIVIEW_KEYTOP_WIDTH, CLLEMOJIVIEW_KEYTOP_HEIGHT));
    CGContextTranslateCTM(context, 0.0, CLLEMOJIVIEW_KEYTOP_HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, CLLEMOJIVIEW_KEYTOP_WIDTH, CLLEMOJIVIEW_KEYTOP_HEIGHT), _keytopImage);
    UIGraphicsEndImageContext();
    
    //
    UIGraphicsBeginImageContext(CGSizeMake(CLLKEYTOP_SIZE, CLLKEYTOP_SIZE));
    CGContextDrawImage(context, CGRectMake((CLLEMOJIVIEW_KEYTOP_WIDTH - CLLKEYTOP_SIZE) / 2 , 45, CLLKEYTOP_SIZE, CLLKEYTOP_SIZE), [_emoji CGImage]);
    UIGraphicsEndImageContext();
}



@end

//==============================================================================
// CLLEmojiView
//==============================================================================

@interface CLLEmojiView() {
    NSArray *_emojiArray;
    NSArray *_symbolArray;
    
    NSInteger _touchedIndex;
    CLLEmojiViewLayer *_emojiPadLayer;
}
@end


@implementation CLLEmojiView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame symbolArray:(NSArray *)aSymbolArray emojiArray:(NSArray *)aEmojiArray hasSendButton:(BOOL)aHasSendButton
{
    self = [super initWithFrame:frame];
    if (self) {
        hasSendButton = aHasSendButton;
        NSMutableArray *tmparray = [NSMutableArray arrayWithCapacity:1];
        [aEmojiArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //
            UIImage *image = [UIImage imageNamed:obj];
            if (!image) {
                image = [UIImage imageNamed:@"emoji_0"];
            }
            [tmparray addObject:image];
        }];
        _emojiArray = [NSArray arrayWithArray:tmparray];
        
        _symbolArray = aSymbolArray;
        
        
        UIImage *deleteImage = [UIImage imageNamed:@"删除表情"];
        UIImage *deleteImageH = [UIImage imageNamed:@"删除表情_highlight"];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [deleteButton setImage:deleteImage forState:UIControlStateNormal];
        [deleteButton setImage:deleteImageH forState:UIControlStateHighlighted];
        [deleteButton addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        
        if (hasSendButton) {
            //删除
            deleteButton.frame = DeleteImageRect;
            //发送
            UIImage *sendImage = [UIImage imageNamed:@"确定表情"];
            UIImage *sendImageH = [UIImage imageNamed:@"确定表情_highlight"];
            UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
            sendButton.frame = SendImageRect;
            [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [sendButton setTitle:@"发送" forState:UIControlStateNormal];
            [sendButton setBackgroundImage:sendImage forState:UIControlStateNormal];
            [sendButton setBackgroundImage:sendImageH forState:UIControlStateHighlighted];
            [sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:sendButton];
        }else{
            //删除
            deleteButton.frame = NoSendDeleteImageRect;
        }
        
        //背景透明
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}
- (void)deleteButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(didTouchDeleteEmojiView:)]) {
        [self.delegate didTouchDeleteEmojiView:self];
    }
}
- (void)sendButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(didTouchSendEmojiView:)]) {
        [self.delegate didTouchSendEmojiView:self];
    }
}
- (void)dealloc
{
    _delegate = nil;
    _emojiArray = nil;
    _symbolArray = nil;
    _emojiPadLayer = nil;
}

- (void)drawRect:(CGRect)rect
{
    int index =0;
    for(UIImage *image in _emojiArray) {
        float originX = (self.bounds.size.width / CLLEMOJIVIEW_COLUMNS) * (index % CLLEMOJIVIEW_COLUMNS) + ((self.bounds.size.width / CLLEMOJIVIEW_COLUMNS) - CLLEMOJI_SIZE ) / 2;
        float originY = (index / CLLEMOJIVIEW_COLUMNS) * (self.bounds.size.width / CLLEMOJIVIEW_COLUMNS) + ((self.bounds.size.width / CLLEMOJIVIEW_COLUMNS) - CLLEMOJI_SIZE ) / 2;
        
        
        [image drawInRect:CGRectMake(originX, originY, CLLEMOJI_SIZE, CLLEMOJI_SIZE)];
        index++;
    }
    
}

#pragma mark -
#pragma mark Actions
- (NSUInteger)indexWithEvent:(UIEvent*)event
{
    UITouch* touch = [[event allTouches] anyObject];
    NSUInteger x = [touch locationInView:self].x / (self.bounds.size.width / CLLEMOJIVIEW_COLUMNS);
    NSUInteger y = [touch locationInView:self].y / (self.bounds.size.width / CLLEMOJIVIEW_COLUMNS);
    
    return x + (y * CLLEMOJIVIEW_COLUMNS);
}
-(BOOL)cotainDeleteButton:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    return CGRectContainsPoint(DeleteImageRect, touchPoint);
}
-(BOOL)cotainSendButton:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    return CGRectContainsPoint(SendImageRect, touchPoint);
}
- (void)updateWithIndex:(NSUInteger)index
{
    if(index < _emojiArray.count) {
        _touchedIndex = index;
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    if(index < _emojiArray.count) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self updateWithIndex:index];
        [CATransaction commit];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    //    _touchedIndex >=0 &&
    if (index != _touchedIndex && index < _emojiArray.count) {
        [self updateWithIndex:index];
    }else if (index >= _emojiArray.count){
        _touchedIndex = -1;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchedIndex >= 0) {
        if ([self.delegate respondsToSelector:@selector(didTouchEmojiView:touchedEmoji:)]) {
            [self.delegate didTouchEmojiView:self touchedEmoji:[_symbolArray objectAtIndex:_touchedIndex]];
        }
    }
    _touchedIndex = -1;
}

@end
