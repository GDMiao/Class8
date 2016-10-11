//
//  SchNoticeDetailViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "SchNoticeDetailViewController.h"
#import "SchoolNoticeModel.h"
@interface SchNoticeDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *creattimeL;
@property (weak, nonatomic) IBOutlet UITextView *noticeText;


@end

@implementation SchNoticeDetailViewController

- (void)dealloc
{
    self.titleL = nil;
    self.creattimeL = nil;
    self.noticeText = nil;
    self.noticeModel = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:@"公告详情" withTitleStyle:CTitleStyle_OnlyBack];
    
    self.allContentView.frame = CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 64);
    
    [self _initNoticeDetailContentView:self.noticeModel];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)_initNoticeDetailContentView:(SchoolNoticeModel *)model
{
//    self.titleL.text = @"实打实的的司法文书的发生返回结果就会快乐可;离开出口sdfghjjh  h哈哈哈和环境不那么美好会计本科北京根据公开的";
    self.titleL.text = model.title;
    [self.titleL sizeToFit];

    self.titleL.top = 25;
    self.titleL.left = 19;
    self.titleL.width = self.allContentView.width - 2*self.titleL.left;

    
    self.creattimeL.text = model.createTime;
    self.creattimeL.top = self.titleL.bottom + 10;
    self.creattimeL.left = 19;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:17],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    NSString *string = [NSString stringWithFormat:@"    %@",model.contentTxt];
    self.noticeText.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];

    [self.noticeText sizeToFit];
    self.noticeText.top = self.creattimeL.bottom + 23;
    self.noticeText.left = 27;
    self.noticeText.width = self.allContentView.width - self.noticeText.left*2;

    
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
