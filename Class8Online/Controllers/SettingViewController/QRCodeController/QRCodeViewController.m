//
//  QRCodeViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/4/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImg;
@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleView setTitleText:@"课吧二维码" withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.backgroundColor = MakeColor(0x19, 0x76, 0xd2);
    // Do any additional setup after loading the view from its nib.
    
    
    self.qrCodeImg.left = (self.allContentView.width - self.qrCodeImg.width) * 0.5;
    self.qrCodeImg.top = (self.allContentView.height - self.qrCodeImg.height) * 0.5;
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
