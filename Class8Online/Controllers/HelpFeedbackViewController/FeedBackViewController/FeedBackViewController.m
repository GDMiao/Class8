//
//  FeedBackViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/21.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "FeedBackViewController.h"
#include "CNetworkManager.h"

#define kMaxLength 300
@interface FeedBackViewController ()<UITextViewDelegate>

@end

@implementation FeedBackViewController

-(void)dealloc{
    self.feedTextView = nil;
    self.haveInput = nil;
    self.currentWords = nil;
    self.totalWords = nil;
    self.words = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:@"反馈" withTitleStyle:CTitleStyle_LeftAndRight];
    [self.titleView setRightButonText:@"提交"];
    self.allContentView.frame = CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 64);
    
    [self _initFeedBackViewContent];
 
}

- (void)leftClicked:(TitleView *)view
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightClicked:(TitleView *)view
{
    if (self.feedTextView.text.length <= 0) {
        [Utils showToast:@"反馈内容不可以为空"];
        return;
    }
    CSLog(@"反馈以提交");
    [CNETWORKMANAGER feedBack:self.feedTextView.text withUserID:[UserAccount shareInstance].loginUser.uid];
    [self showHUDSuccess:@"反馈成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_initFeedBackViewContent
{
    self.feedTextView.top = 15;
    self.feedTextView.left = 15;
    self.feedTextView.width = SCREENWIDTH - 2 * self.feedTextView.left;
    self.feedTextView.height = 173;
    self.feedTextView.delegate = self;


    self.placeholderL.left = self.feedTextView.left + 5;
    self.placeholderL.top = self.feedTextView.top + 6;
    self.placeholderL.width = self.feedTextView.width - 2 * self.placeholderL.left;
    [self.placeholderL sizeToFit];

    self.words.right = self.allContentView.right - 16;
    self.words.top = self.feedTextView.bottom + 9;

    
    self.totalWords.right = self.words.left;
    self.totalWords.top = self.words.top;

    
    self.currentWords.right = self.totalWords.left ;
    self.currentWords.top = self.totalWords.top;
    self.currentWords.width = 30;

    
    self.haveInput.right = self.currentWords.left;
    self.haveInput.top = self.currentWords.top;
    
 
    
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    /*
     * 获取当前输入的是 拼音 还是汉字 或者 其他语言
     */
    NSString *lang = @"";
    if (IS_IOS7) {
        lang =  textView.textInputMode.primaryLanguage;// ios 7 键盘输入模式
    }else {
        //ios 6 及以下
        lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    }
    
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = textView.markedTextRange;
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        //
        if (!position) {
            CSLog(@"输入汉字");
            [self editTextVIew:textView];
        }
        //
        else{
            CSLog(@"输入拼音");
        }
    }else {
        //其他输入法
        CSLog(@"其他输入法");
        [self editTextVIew:textView];
    }
    
    
}

- (void)editTextVIew:(UITextView *)textView
{
    NSInteger number = [textView.text length];
    if (textView.text.length== 0) {
        self.placeholderL.hidden = NO;
    }else{
        self.placeholderL.hidden = YES;
    }
    if (number > 300) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"字符个数不能大于300" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:300];
        number = 300;
        
    }
    self.currentWords.text = [NSString stringWithFormat:@"%d",number];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
