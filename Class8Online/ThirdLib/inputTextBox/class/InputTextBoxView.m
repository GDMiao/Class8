//
//  InputTextBoxView.m
//  InPutBoxView
//
//  Created by chuliangliang on 15-1-5.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
//由于时间紧迫 有可能不是非常完美 欢迎大家指正
//
//QQ: 949977202
//Email: chuliangliang300@sina.com


#import "InputTextBoxView.h"
#import "HPGrowingTextView.h"

#define VoiceButtonTag 7001 //语音
#define KeyButton_leftTag 7002 //键盘左

#define FaceButtonTag 7003 //表情
#define KeyButton_rightTag 7004 //键盘右

#define AddMoreButtonTag 7005 //更多
#define DelMoreButtonTag 7006 //移除

#define MoreViewHeight 160.0f //更多视图高度
#define FaceKeyViewHeight 160.0f //表情键盘高度

#define ToolBarHeight 50.0f  //工具栏高度

#define IS_IOS7   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )



#ifdef DEBUG
//#define VSLog(log, ...) NSLog(log, ## __VA_ARGS__)
#define VSLog(log, ...)
#else
#define VSLog(log, ...)
#endif

@interface UIView (ExtView)
@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

@end


@implementation UIView (ExtView)
// Retrieve and set the origin
- (CGPoint) origin
{
    return self.frame.origin;
}

- (void) setOrigin: (CGPoint) aPoint
{
    CGRect newframe = self.frame;
    newframe.origin = aPoint;
    self.frame = newframe;
}


// Retrieve and set the size
- (CGSize) size
{
    return self.frame.size;
}

- (void) setSize: (CGSize) aSize
{
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

// Query other frame locations
- (CGPoint) bottomRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint) bottomLeft
{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint) topRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}


// Retrieve and set height, width, top, bottom, left, right
- (CGFloat) height
{
    return self.frame.size.height;
}

- (void) setHeight: (CGFloat) newheight
{
    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat) width
{
    return self.frame.size.width;
}

- (void) setWidth: (CGFloat) newwidth
{
    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}

- (CGFloat) top
{
    return self.frame.origin.y;
}

- (void) setTop: (CGFloat) newtop
{
    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}

- (CGFloat) left
{
    return self.frame.origin.x;
}

- (void) setLeft: (CGFloat) newleft
{
    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}

- (CGFloat) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void) setBottom: (CGFloat) newbottom
{
    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat) right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void) setRight: (CGFloat) newright
{
    CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}


@end

typedef NS_ENUM(NSInteger, InsertStyle) {
    InsertStyle_SystemKey = 0,  /*系统键盘输入 默认*/
    InsertStyle_VoiceKey,       /*语音输入*/
    InsertStyle_FaceKey,        /*表情输入*/
    InsertStyle_MoreKey,        /*更多*/
    InsertStyle_HiddenAll,      /*收起输入控件*/
};

@interface InputTextBoxView () <HPGrowingTextViewDelegate,CLEmojiKeyBoradDelegate,CLEmojiInpuViewDelegate>
{
    float thisViewSupviewHeight;
    BOOL changeInpuSourceing; //正在切换输入源中
    BOOL hasHiddenAll; //是否可以全部隐藏
}
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) UIImageView *textImageView;


@property (nonatomic, strong) UIButton *voiceButton;      //语音
@property (nonatomic, strong) UIButton *keyButton_left;   //左侧键盘

@property (nonatomic, strong) UIButton *faceButton;       //表情
@property (nonatomic, strong) UIButton *keyButton_right;  //右侧键盘


@property (nonatomic, strong) UIButton *addButton;     //更多

@property (nonatomic, strong) UIImageView *toolBarBjImgView;
@property (nonatomic, strong) UIView *toolBarView;


//
@property (nonatomic, strong) UIView *faceInputView; //表情输入视图
@property (nonatomic, strong) UIView *smallfaceInputView; //小表情输入视图
@property (nonatomic, strong) UIView *moreInputView; //更多输入源视图
@property (nonatomic, strong) UIView *voiceInputView;//语音输入

@property (nonatomic, assign) InsertStyle insertStyle; //输入源模式
@property (nonatomic, assign) UIViewController *controlle_;

@property (nonatomic, assign) id<InputTextBoxViewDelegate>delegate;
@end


@implementation InputTextBoxView
@synthesize textView;
@synthesize textImageView;
@synthesize voiceButton;
@synthesize keyButton_left;
@synthesize faceButton;
@synthesize keyButton_right;
@synthesize addButton;
@synthesize toolBarBjImgView;
@synthesize toolBarView;
@synthesize faceInputView;
@synthesize smallfaceInputView;
@synthesize moreInputView;
@synthesize voiceInputView;

- (id)initWithDelegate:(id)aDelegate showAtController:(UIViewController *)controller
{
    self = [super initWithFrame:CGRectMake(0, controller.view.height - ToolBarHeight, controller.view.width, ToolBarHeight)];
    if (self) {
        self.delegate = aDelegate;
        self.controlle_ = controller;
        thisViewSupviewHeight = controller.view.height;
        [self _initView];

    }
    return self;
}

- (id)initWithDelegate:(id)aDelegate showAtView:(UIView *)aView
{
    self = [super initWithFrame:CGRectMake(0, aView.height - ToolBarHeight, aView.width, ToolBarHeight)];
    if (self) {
        self.delegate = aDelegate;
        self.controlle_ = nil;
        thisViewSupviewHeight = aView.height;
        [self _initView];
        
    }
    return self;
}


- (void)dealloc {
    self.delegate = nil;
    self.controlle_ = nil;
    self.smallfaceInputView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)_initView {
    hasHiddenAll = NO;
    self.isAutoChangeFrame = YES;
    self.hasShowKeyBorad = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    _insertStyle = InsertStyle_SystemKey;
    _insertStyle = InsertStyle_HiddenAll;
    
    toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, ToolBarHeight)];
    toolBarView.backgroundColor = [UIColor clearColor];
    toolBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:toolBarView];
    
    UIImage *img = [UIImage imageNamed:@"灌水tabbar"];
    img = [img stretchableImageWithLeftCapWidth:img.size.width / 2.0 topCapHeight:img.size.height / 2.0];
    toolBarBjImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, toolBarView.width, ToolBarHeight)];
    toolBarBjImgView.image = img;
    toolBarBjImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    toolBarBjImgView.userInteractionEnabled = YES;
    [toolBarView addSubview:toolBarBjImgView];
    
    float textViewWidth = toolBarView.width - 13;
    float textViewLeft = 13;
//////////////////////////////////////////////////////////////////////////////////////////////////
    //语音
    BOOL hasVoice = NO;
    if ([self.delegate respondsToSelector:@selector(InputTextBoxViewWithVoiceView:)]) {
        voiceInputView = [self.delegate InputTextBoxViewWithVoiceView:self];
        if (voiceInputView) {
            voiceInputView.hidden = YES;
            [toolBarView addSubview:voiceInputView];
            hasVoice = YES;
        }else {
            hasVoice = NO;
        }
    }
    
    if (hasVoice) {
        //语音
        textViewWidth = textViewWidth - 37 - 6;
        textViewLeft = 6 + 37 + 6;
        voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceButton.tag = VoiceButtonTag;
        voiceButton.hidden = NO;
        voiceButton.frame = CGRectMake(6, (toolBarView.height - 37 ) / 2.0, 37, 37);
        voiceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [voiceButton addTarget:self action:@selector(beginInput:) forControlEvents:UIControlEventTouchUpInside];
        [voiceButton setBackgroundImage:[UIImage imageNamed:@"灌水语音"] forState:UIControlStateNormal];
        [voiceButton setBackgroundImage:[UIImage imageNamed:@"灌水语音_highlight"] forState:UIControlStateSelected];
        [toolBarView addSubview:voiceButton];
        
        //键盘左侧
        keyButton_left = [UIButton buttonWithType:UIButtonTypeCustom];
        keyButton_left.tag = KeyButton_leftTag;
        keyButton_left.hidden = YES;
        keyButton_left.frame = CGRectMake(6, (toolBarView.height - 37 ) / 2.0, 37, 37);
        keyButton_left.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [keyButton_left addTarget:self action:@selector(beginInput:) forControlEvents:UIControlEventTouchUpInside];
        [keyButton_left setBackgroundImage:[UIImage imageNamed:@"灌水文字"] forState:UIControlStateNormal];
        [keyButton_left setBackgroundImage:[UIImage imageNamed:@"灌水文字_highlight"] forState:UIControlStateSelected];
        [toolBarView addSubview:keyButton_left];
    }
//////////////////////////////////////////////////////////////////////////////////////////////////
    //更多
    BOOL hasMore = NO;
    if ([self.delegate respondsToSelector:@selector(InputTextBoxViewWithMoreView:)]) {
        moreInputView = [self.delegate InputTextBoxViewWithMoreView:self];
        if (moreInputView) {
            moreInputView.top = self.height;
            moreInputView.hidden = YES;
            [self addSubview:moreInputView];

            hasMore = YES;
        }else {
            hasMore = NO;
        }
    }
    if (hasMore) {
        textViewWidth = textViewWidth - 38 - 6;
        addButton = [[UIButton alloc] initWithFrame:CGRectMake(toolBarView.width - 38 - 6, (toolBarView.height - 38 ) / 2.0, 38, 38)];
        addButton.tag = AddMoreButtonTag;
        addButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [addButton addTarget:self action:@selector(beginInput:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setBackgroundImage:[UIImage imageNamed:@"更多功能.png"] forState:UIControlStateNormal];
        [toolBarView addSubview:addButton];

    }
    
//////////////////////////////////////////////////////////////////////////////////////////////////
    
    //表情
    BOOL hasFace = NO;
    if ([self.delegate respondsToSelector:@selector(InputTextBoxViewWithFaceView:)]) {
        faceInputView = [self.delegate InputTextBoxViewWithFaceView:self];
        if (faceInputView) {
            faceInputView.top = self.height;
            faceInputView.hidden = YES;
            faceInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [self addSubview:faceInputView];

            hasFace = YES;
        }else {
            hasFace = NO;
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(InputTextBoxViewWithSmallFaceView:)]) {
            smallfaceInputView = [self.delegate InputTextBoxViewWithSmallFaceView:self];
            if (smallfaceInputView) {
                smallfaceInputView.top = self.height;
                smallfaceInputView.hidden = YES;
                smallfaceInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                [self addSubview:smallfaceInputView];
                
                hasFace = YES;
            }else {
                hasFace = NO;
            }
        }
    }
    if (hasFace) {
        
        textViewWidth = textViewWidth - 24 - 8-7;
        textViewLeft = 13;
        CGRect tmpRect = CGRectMake(toolBarView.width - 8 - 24, (toolBarView.height - 24 ) *0.5 , 24, 24);
       //表情
//        CGRect tmpRect = CGRectMake((hasMore?addButton.left - 38 - 6:toolBarView.width - 6 - 38), (toolBarView.height - 38 ) / 2.0, 38, 38);
//        textViewWidth = textViewWidth - 38 - 6;
        
        faceButton = [[UIButton alloc] initWithFrame:tmpRect];
        faceButton.hidden = NO;
        faceButton.tag = FaceButtonTag;
        faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [faceButton addTarget:self action:@selector(beginInput:) forControlEvents:UIControlEventTouchUpInside];
        [faceButton setBackgroundImage:[UIImage imageNamed:@"表情显示"] forState:UIControlStateNormal];
        [faceButton setBackgroundImage:[UIImage imageNamed:@"表情显示_highlight"] forState:UIControlStateSelected];
        [toolBarView addSubview:faceButton];
        
        //键盘右侧
        keyButton_right = [[UIButton alloc] initWithFrame:tmpRect];
        keyButton_right.hidden = YES;
        keyButton_right.tag = KeyButton_rightTag;
        keyButton_right.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [keyButton_right addTarget:self action:@selector(beginInput:) forControlEvents:UIControlEventTouchUpInside];
        [keyButton_right setBackgroundImage:[UIImage imageNamed:@"键盘"] forState:UIControlStateNormal];
        [keyButton_right setBackgroundImage:[UIImage imageNamed:@"键盘按下"] forState:UIControlStateSelected];
        [toolBarView addSubview:keyButton_right];
    }
    
    //输入框背景
    textImageView = [[UIImageView alloc] initWithFrame:CGRectMake(textViewLeft, (toolBarView.height - 34) / 2.0, textViewWidth, 34)];
    textImageView.userInteractionEnabled = YES;
    textImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    UIImage *imaget = [UIImage imageNamed:@"灌水输入框"];
    imaget = [imaget resizableImageWithCapInsets:UIEdgeInsetsMake(28, 28, 28, 28)];
    textImageView.image = imaget;
    [toolBarView addSubview:textImageView];
    
    //输入框
    textView = [[HPGrowingTextView alloc] initWithFrame:textImageView.frame];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 4;
    
    textView.returnKeyType = UIReturnKeySend; //just as an example
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor clearColor];
    textView.isScrollable = YES;
    textView.textViewScrollToTop = NO;
    [toolBarView addSubview:textView];
    
    if (voiceInputView) {
        voiceInputView.frame = textView.frame;
    }
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    textView.returnKeyType = returnKeyType;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor *)textColor {
    textView.textColor = textColor;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextFont:(UIFont *)textFont {
    textView.font = textFont;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    textView.placeholder =  placeholder;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hiddenAll
{
    if (hasHiddenAll && self.height > ToolBarHeight) {
        [self autoMovekeyBoard:0];
        self.insertStyle = InsertStyle_HiddenAll;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isEditing {
    if (self.insertStyle == InsertStyle_HiddenAll) {
        return NO;
    }
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark- HPGrowingTextViewDelegate

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    _insertStyle = InsertStyle_SystemKey;
    voiceButton.hidden = NO;
    keyButton_left.hidden = YES;
    
    faceButton.hidden = NO;
    keyButton_right.hidden = YES;
    
    addButton.tag = AddMoreButtonTag;

    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = toolBarView.frame;
    r.size.height -= diff;
    toolBarView.frame = r;
    
    CGRect sr = self.frame;
    sr.size.height -= diff;
    if (self.isAutoChangeFrame) {
        sr.origin.y += diff;
    }
    self.frame = sr;
    
    if ([self.delegate respondsToSelector:@selector(InputTextBoxViewChangedHeight:animateTime:)]) {
        [self.delegate InputTextBoxViewChangedHeight:self.height animateTime:0];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  
//    /*
//     * 获取当前输入的是 拼音 还是汉字 或者 其他语言
//     */
//    NSString *lang = @"";
//    if (IS_IOS7) {
//        lang =  growingTextView.textInputMode.primaryLanguage;// ios 7 键盘输入模式
//    }else {
//        //ios 6 及以下
//        lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
//    }
//    
//    if ([text isEqualToString:@"\n"]) {
//        //发送消息
//        [self sendText];
//        return  NO;
//    }
//    if ([lang isEqualToString:@"zh-Hans"]) {
//        UITextRange *selectedRange = [growingTextView MarkedTextRange];
//        //获取高亮部分
//        UITextPosition *position = [growingTextView positionFromPosition:selectedRange.start offset:0];
//        //
//        if (!position) {
//            VSLog(@"DeBug: inputTextBox:输入汉字");
//            if (text.length == 0 && range.location != textView.selectedRange.location && range.length == 1){
//                //删除
//                [self deleteInputText];
//                return NO;
//            }
//        }
//        //
//        else{
//            VSLog(@"DeBug: inputTextBox: 输入拼音");
//        }
//    }else {
//        //其他输入法
//        if ([text length] == 0 && range.location != textView.selectedRange.location && range.length == 1){
//            //删除
//            [self deleteInputText];
//            return NO;
//        }
//    }
    if ([text isEqualToString:@"\n"]) {
        //发送消息
        [self sendText];
        return  NO;
    }

    return YES;
}

- (void)sendText {
    BOOL hasSend = YES;
    if ([self.delegate respondsToSelector:@selector(hasSendText:)]) {
        hasSend = [self.delegate hasSendText:textView.text];
    }
    if (hasSend && [self.delegate respondsToSelector:@selector(sendContext:)]) {
        [self.delegate sendContext:textView.text];
        textView.text = @"";
    }
}

#pragma mark - 键盘通知
- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (!self.hasShowKeyBorad) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self autoMovekeyBoard:keyboardRect.size.height];
    
    if (faceInputView) {
        faceInputView.hidden = YES;
    }
    if (smallfaceInputView) {
        smallfaceInputView.hidden = YES;
    }
    if (voiceInputView) {
        voiceInputView.hidden = YES;
    }
    if (moreInputView) {
        moreInputView.hidden = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self autoMovekeyBoard:0];
}


- (void)showTextView:(BOOL)hasShow
{
    textView.hidden = !hasShow;
    textImageView.hidden = !hasShow;

    if (hasShow) {
        toolBarView.height = textView.top * 2 + textView.height;
    }else {
        toolBarView.height = ToolBarHeight;
        
    }
}

- (void)beginInput:(UIButton *)button {
    
    if (changeInpuSourceing) {
        return;
    }
    int buttonTag = (int)button.tag;
    switch (buttonTag) {
        case VoiceButtonTag: {
            VSLog(@"DeBug: inputTextBox: 语音");
            faceButton.hidden = NO;
            keyButton_right.hidden = YES;
            
            voiceButton.hidden = YES;
            keyButton_left.hidden = NO;
            addButton.tag = AddMoreButtonTag;
            
            [self showTextView:NO];
            
            self.insertStyle = InsertStyle_VoiceKey;
        }
            break;
        case KeyButton_leftTag: {
            VSLog(@"DeBug: inputTextBox: 键盘左");
            
            voiceButton.hidden = NO;
            keyButton_left.hidden = YES;
            addButton.tag = AddMoreButtonTag;
            
            [self showTextView:YES];
            
            self.insertStyle = InsertStyle_SystemKey;
        }
            break;
        case FaceButtonTag: {
            VSLog(@"DeBug: inputTextBox: 表情");
            keyButton_left.hidden = YES;
            voiceButton.hidden = NO;
            faceButton.hidden = YES;
            keyButton_right.hidden = NO;
            addButton.tag = AddMoreButtonTag;
            
            [self showTextView:YES];
            
            self.insertStyle = InsertStyle_FaceKey;
            
        }
            break;
        case KeyButton_rightTag: {
            VSLog(@"DeBug: inputTextBox: 键盘右");
            faceButton.hidden = NO;
            keyButton_right.hidden = YES;
            addButton.tag = AddMoreButtonTag;
            
            [self showTextView:YES];
            
            self.insertStyle = InsertStyle_SystemKey;
        }
            break;
        case AddMoreButtonTag: {
            VSLog(@"DeBug: inputTextBox: 添加");
            voiceButton.hidden = NO;
            keyButton_left.hidden = YES;
            
            faceButton.hidden = NO;
            keyButton_right.hidden = YES;
            
            addButton.tag = DelMoreButtonTag;
            
            [self showTextView:YES];
            
            self.insertStyle = InsertStyle_MoreKey;
        }
            break;
        case DelMoreButtonTag: {
            VSLog(@"DeBug: inputTextBox: 移除更多 显示系统键盘");
            voiceButton.hidden = NO;
            keyButton_left.hidden = YES;
            
            faceButton.hidden = NO;
            keyButton_right.hidden = YES;

            addButton.tag = AddMoreButtonTag;
            
            [self showTextView:YES];
            
            self.insertStyle = InsertStyle_SystemKey;
        }
            break;
        default:
            break;
    }

}

- (void)setInsertStyle:(InsertStyle )insertStyle {
    
    switch (_insertStyle) {
        case InsertStyle_SystemKey:
        {
            [textView resignFirstResponder];
        }
            break;
        case InsertStyle_FaceKey:
        {
            [self showFaceView:NO animation:YES];
        }
            break;
        case InsertStyle_VoiceKey:
        {
            [self showVoiceView:NO];
        }
            break;
        case InsertStyle_MoreKey:
        {
            [self showMoreView:NO animation:YES];
        }
            break;;
            
        default:
            break;
    }
    
    switch (insertStyle) {
        case InsertStyle_SystemKey:
        {
            [textView becomeFirstResponder];
        }
            break;
        case InsertStyle_FaceKey: {
            [self showFaceView:YES animation:YES];
        }
            break;
        case InsertStyle_VoiceKey: {
            [self showVoiceView:YES];
        }
            break;
        case InsertStyle_MoreKey: {
            [self showMoreView:YES animation:YES];
        }
            break;
            
        default:
            break;
    }
    
    _insertStyle = insertStyle;
}

//语音显示/隐藏
- (void)showVoiceView:(BOOL)show
{
    if (show) {
        [self autoMovekeyBoard:0];
        //显示视图
        voiceInputView.hidden = NO;
    }else{
        //隐藏视图
        voiceInputView.hidden  = YES;
    }

}
//表情显示/隐藏
- (void)showFaceView:(BOOL)show animation:(BOOL)animation
{

    changeInpuSourceing = YES;
    if (faceInputView) {
        if (show) {
            faceInputView.hidden = NO;
            [self autoMovekeyBoard:faceInputView.height];
            //显示视图
            if (animation) {
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^() {
                                     faceInputView.bottom = self.height;
                                 } completion:^(BOOL finished) {
                                     changeInpuSourceing = NO;
                                 }];
            }else{
                faceInputView.bottom = self.height;
            }
        }else{
            //隐藏视图
            if (animation) {
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^() {
                                     faceInputView.top = self.height;
                                     
                                 } completion:^(BOOL finished) {
                                     faceInputView.hidden = YES;
                                     changeInpuSourceing = NO;
                                 }];
            }else{
                faceInputView.top = self.height;
            }
        }
    }else if (smallfaceInputView) {
        //单组表情
        if (show) {
            smallfaceInputView.hidden = NO;
            [self autoMovekeyBoard:smallfaceInputView.height];
            //显示视图
            if (animation) {
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^() {
                                     smallfaceInputView.bottom = self.height;
                                 } completion:^(BOOL finished) {
                                     changeInpuSourceing = NO;
                                 }];
            }else{
                smallfaceInputView.bottom = self.height;
            }
        }else{
            //隐藏视图
            if (animation) {
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^() {
                                     smallfaceInputView.top = self.height;
                                     
                                 } completion:^(BOOL finished) {
                                     smallfaceInputView.hidden = YES;
                                     changeInpuSourceing = NO;
                                 }];
            }else{
                smallfaceInputView.top = self.height;
            }
        }

    }
}

//更多显示/隐藏
- (void)showMoreView:(BOOL)show animation:(BOOL)animation
{
    changeInpuSourceing = YES;
    if (show) {
        moreInputView.hidden = NO;
        [self autoMovekeyBoard:moreInputView.height];
        //显示视图
        if (animation) {
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^() {
                                 moreInputView.bottom = self.height;
                             } completion:^(BOOL finished) {
                                 changeInpuSourceing = NO;
                             }];
        }else{
            moreInputView.bottom = self.height;
        }
    }else{
        //隐藏视图
        if (animation) {
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^() {
                                 moreInputView.top = self.height;
                                 
                             } completion:^(BOOL finished) {
                                 moreInputView.hidden = YES;
                                 changeInpuSourceing = NO;
                             }];
        }else{
            moreInputView.top = self.height;
        }
    }

}

- (void)autoMovekeyBoard:(float)h {
    hasHiddenAll = (h>0)?YES:NO;
    self.height = toolBarView.height + h;
    
    if ([self.delegate respondsToSelector:@selector(InputTextBoxViewChangedHeight:animateTime:)]) {
        [self.delegate InputTextBoxViewChangedHeight:self.height animateTime:0.2];
    }
    
    if (self.isAutoChangeFrame) {        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        self.top = thisViewSupviewHeight - self.height;
        [UIView commitAnimations];
    }
}

#pragma mark - 删除表情
- (void)deleteInputText {
    if (faceInputView) {
        EmojiInputView *emojiView = (EmojiInputView *)faceInputView;
        [emojiView setBackPressTextView:textView];
    }
    
    if (smallfaceInputView) {
        EmojiInputView *emojiView = (EmojiInputView *)smallfaceInputView;
        [emojiView setBackPressTextView:textView];
    }
}

//==============================================================================
// EmojiInputViewDelegate
//==============================================================================

#pragma mark - EmojiInputViewDelegate
-(void)didTouchedEmoji:(NSString *)string
{
    if (faceInputView) {
        EmojiInputView *emojiView = (EmojiInputView *)faceInputView;
        [emojiView setEmojiTextView:textView emoji:string];
    }
    if (smallfaceInputView) {
        EmojiInputView *emojiView = (EmojiInputView *)smallfaceInputView;
        [emojiView setEmojiTextView:textView emoji:string];
    }

}
//点击删除
-(void)didTouchedDelete
{
    [self deleteInputText];
}

//点击发送
-(void)didTouchedSend
{
    [self sendText];
}

//==============================================================================
// RecordInputViewDelegate
//==============================================================================

#pragma  mark - RecordInputViewDelegate
- (void)recordInputView:(RecordInputView *)view recordFilePath:(NSString *)filePath fileTime:(int)time
{
    if ([self.delegate respondsToSelector:@selector(sendVoice:VoiceLength:)]) {
        [self.delegate sendVoice:filePath VoiceLength:time];
    }
}

//==============================================================================
// InputMoreViewDelegate
//==============================================================================

#pragma  mark - InputMoreViewDelegate
- (void) inputMoreView:(InputMoreView *)view didSelectInde:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(inputTextBoxDidselectMoreButtonAtIndex:)]) {
        [self.delegate inputTextBoxDidselectMoreButtonAtIndex:index];
    }
}


#pragma mark - 
#pragma mark - CLEmojiKeyBoradDelegate
- (void)didTouchimgName:(NSString *)nString imgIndexPath:(NSString *)indexpathString
{
//    CSLog(@"CLEmojiKeyBorad: 图片名: %@, indxpath : %@",nString,indexpathString);
    
    BOOL hasSend = YES;
    if ([self.delegate respondsToSelector:@selector(hasSendText:)]) {
        hasSend = [self.delegate hasSendText:nString];
    }
    if (hasSend && [self.delegate respondsToSelector:@selector(sendGifFace:indxPath:)]) {
        [self.delegate sendGifFace:nString indxPath:indexpathString];
    }
}


#pragma mark - 
#pragma mark - CLEmojiInpuViewDelegate
- (void)cLEmojiInpuView:(CLEmojiInpuView *)view didTouchimgName:(NSString *)nString imgIndexPath:(NSString *)indexpathString
{
    BOOL hasSend = YES;
    if ([self.delegate respondsToSelector:@selector(hasSendText:)]) {
        hasSend = [self.delegate hasSendText:nString];
    }
    if (hasSend && [self.delegate respondsToSelector:@selector(sendGifFace:indxPath:)]) {
        [self.delegate sendGifFace:nString indxPath:indexpathString];
    }
}

@end
