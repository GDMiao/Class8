//
//  SignOutViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/6/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "SignOutViewController.h"

@interface SignOutViewController ()
{
    UITapGestureRecognizer *tapGuesture;
}
@property (assign, nonatomic)int scoreNum;
@end

@implementation SignOutViewController
@synthesize scoreNum;
- (void)dealloc {
    self.textView = nil;
    self.buttonsView = nil;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    
    scoreNum = 3;
    [self.titleView setTitleText:@"签退并评价" withTitleStyle:CTitleStyle_OnlyRight];
    
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.cornerRadius = 5;
    
    
    self.buttonsView.width = self.allContentView.width;
    
    self.textView.top = self.buttonsView.bottom + 16;
    
    tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.allContentView addGestureRecognizer:tapGuesture];
    
    float x = 10;
    CGSize bSize = CGSizeMake(25, 25);
    for (int i = 0; i < 5; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, 0, bSize.width, bSize.height);
        x = x + bSize.width + 5;
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d分",i+1]] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d分",i+1]] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"原始"] forState:UIControlStateNormal];
        if (i + 1 <= scoreNum) {
            button.selected = YES;
        }else {
            button.selected = NO;
        }
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonsAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView addSubview:button];
        
    
    }
    
}

- (void)tapAction {
    [self.textView resignFirstResponder];    
}
- (void)rightClicked:(TitleView *)view {
    CSLog(@"提交评价");
    
    NSString *contentText = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (contentText.length <= 0) {
        [Utils showToast:@"评论内容不可以为空"];
        return;
    }
    [self.textView resignFirstResponder];
    if (self.callBack) {
        self.callBack (scoreNum,contentText);
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)buttonsAction:(UIButton *)button {
    scoreNum = button.tag - 100 + 1;
    NSArray *subButton = [self.buttonsView subviews];
    for (UIButton *btn in subButton) {
        btn.selected = btn.tag <= button.tag;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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
