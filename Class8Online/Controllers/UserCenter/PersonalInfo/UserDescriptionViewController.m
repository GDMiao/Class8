//
//  UserDescriptionViewController.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/7/20.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "UserDescriptionViewController.h"

@interface UserDescriptionViewController ()

@end

@implementation UserDescriptionViewController

- (void)dealloc
{
    self.descriptionCallBack = nil;
    self.oldDescriptionTxt = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.titleView setTitleText:CSLocalizedString(@"userdec_VC_nav_title") withTitleStyle:CTitleStyle_LeftAndRight];
    [self.titleView setRightButonText:CSLocalizedString(@"userdec_VC_nav_rightbtn_nomalTitle")];
    
    self.textView.left = 10;
    self.textView.width = SCREENWIDTH - 20;
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [[UIColor colorWithWhite:200/225.0 alpha:1] CGColor];
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.delegate = self;
    

    self.textView.text = [Utils objectIsNotNull:self.oldDescriptionTxt]?self.oldDescriptionTxt:@"";
    
    self.placeholderLabel.text = CSLocalizedString(@"userdec_VC_textView_placeholder");
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.hidden = self.textView.text.length > 0;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)rightClicked:(TitleView *)view
{
    [self.textView resignFirstResponder];
    if ([Utils objectIsNotNull:self.textView.text]) {
        [self showHUD:nil];
        [self resetHttp];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.textView.text forKey:@"userdesc"];
        [params setValue:[NSNumber numberWithLongLong:self.uid] forKey:@"userid"];
        [http_  updateUserInfoparams:params jsonResponseDelegate:self];
    }else{
        [Utils showToast:CSLocalizedString(@"userdec_VC_dec_not_null")];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self hiddenHUD];
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"mobileupdatepersonaldata"].location != NSNotFound) {
        JSONModel *respModel = [[JSONModel alloc] initWithJSON:[request responseJSON]];
        //更新用户信息
        if (respModel.code_ == RepStatus_Success) {
            //成功
            [Utils showToast:CSLocalizedString(@"userdec_VC_update_success")];
            if (self.descriptionCallBack) {
                self.descriptionCallBack(self.textView.text);
                [self.navigationController popViewControllerAnimated:YES];
            }else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else {
            [Utils showToast: CSLocalizedString(@"userdec_VC_update_faild")];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hiddenHUD];
    [Utils showToast: CSLocalizedString(@"userdec_VC_update_faild")];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
