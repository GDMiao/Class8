//
//  PayOrderViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/12.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "PayOrderViewController.h"
#import "KGModal.h"
#import "PayOrderCell.h"
#import "WXApiManager.h"
#import "WXPayMannager.h"
#import "ZFBPayMannager.h"
#import "OrderModel.h"
#import "CommitModel.h"
const int totalRequestCount = 1;                            //初始化数据需要的全部请求个数
@interface PayOrderViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isAllocData;               //是否初始化加载数据
    int didLoadRequestCount;        //已经成功返回数据的请求个数
    NSString *cName,*cPrice,*cOrderID;
}

@property (nonatomic, assign) NSInteger buttonTag;

@property (strong, nonatomic) IBOutlet UIView *payPopView;
@property (weak, nonatomic) IBOutlet UILabel *qsrPwd;
@property (weak, nonatomic) IBOutlet UIButton *backBt;
@property (weak, nonatomic) IBOutlet UIImageView *payline;
@property (weak, nonatomic) IBOutlet UILabel *payNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableViewDatas;

@property (assign, nonatomic) long long userid,coursid,classid;
@property (strong, nonatomic) OrderModel *ordermodel;
@property (strong, nonatomic) CommitModel *commitmodel;
@end

@implementation PayOrderViewController

+ (PayOrderViewController *)PaySharSingleton
{
    static PayOrderViewController *payshared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        payshared = [[PayOrderViewController alloc]init];
    });
    return payshared;
}

- (void)dealloc
{
    [self resetHttp];
    self.view1 = nil;
    self.orderNumL = nil;
    self.courseNameL = nil;
    self.coursePrice = nil;
    self.orderLine = nil;
    self.orderIdStr = nil;

    self.view3 = nil;
    self.qrPaybt = nil;
    
    self.tableViewDatas = nil;
    self.ordermodel = nil;
    self.commitmodel = nil;
}

#pragma mark -
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

- (id)initCommitOderInfoWitUerID:(long long)uid courseID:(long long)coursid classId:(long long)classid
{
    if (self == [super initWithNibName:nil bundle:nil]) {
        //
        self.userid = uid;
        self.coursid = coursid;
        self.classid = classid;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.titleView setTitleText:@"支付订单" withTitleStyle:CTitleStyle_OnlyBack];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.bounces = NO;
    self.tableView.frame = CGRectMake(0, self.view1.bottom + 10, self.allContentView.width, 100);
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    [self _initPayInfoDictionary]; // 初始化tableview 数据
    [self updataCommitOderInfo];
//    [self payOrderUI];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShow:) name:KGModalWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShow:) name:KGModalDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHide:) name:KGModalWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHide:) name:KGModalDidHideNotification object:nil];
}

//////////////////////
- (void)updataCommitOderInfo
{
    [self resetHttp];
    isAllocData = YES;
    didLoadRequestCount = 0;
    [http_ getPianoCommitOrderWithUid:self.userid Courseid:self.coursid Classid:self.classid jsonResPonseDelegate:self];

//    [http_ getPianopayOrderWithUid:self.userid OrderIDStr:self.orderIdStr jsonResPonseDelegate:self];
    
    [self showHUD:nil];
}

- (void)updatapayOrderInfo:(NSString *)orderID
{
    [self resetHttp];
    isAllocData = YES;
    didLoadRequestCount = 0;
//    [http_ getPianoCommitOrderWithUid:self.userid Courseid:self.coursid Classid:self.classid jsonResPonseDelegate:self];
    
    [http_ getPianopayOrderWithUid:self.userid OrderIDStr:orderID jsonResPonseDelegate:self];
    
    [self showHUD:nil];
}

#pragma mark-
#pragma mark- HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"payOrder"].location != NSNotFound) {
        OrderModel *order = [[OrderModel alloc]initCommitOrderInfoWithJson:[request responseJSON]];
        if (order.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount ++;
                self.ordermodel = order;
                [self payOrderUI];
            }
            
        }else{
            if (isAllocData) {
                [self hiddenHUD];
            }
            [Utils showToast:@"未知错误"];
        }
    }
    
    else if ([urlString rangeOfString:@"commitOrder"].location != NSNotFound) {
        CommitModel *order = [[CommitModel alloc]initCommitOrderInfoWithJson:[request responseJSON]];
        if (order.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount ++;
                self.commitmodel = order;
                cName = self.commitmodel.courseName;
                cPrice = self.commitmodel.totalPrice;
                cOrderID = self.commitmodel.orderID;
                [self updatapayOrderInfo:self.commitmodel.orderID];
                
            }
            
        }else{
            if (isAllocData) {
                [self hiddenHUD];
            }
            [self updatapayOrderInfo:[PayOrderViewController PaySharSingleton].payOrders];
//            [Utils showToast:@"未知错误"];
        }
    }

    if (isAllocData && didLoadRequestCount == totalRequestCount) {
        //初始化数据成功 刷新UI
        [self hiddenHUD];
        isAllocData = NO;
        
    }else if (didLoadRequestCount == totalRequestCount) {
        //获取下一页数据之后 刷新UI
        
    }else if (isAllocData){
        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    didLoadRequestCount = 2;
    if (didLoadRequestCount == totalRequestCount) {
        //请求出错
        [self hiddenHUD];
        [Utils showToast:@"未知错误"];
    }
}
//////////////////////






- (void)_initPayInfoDictionary
{
   
    NSDictionary *item1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"微信支付",@"mainName",@"推荐安装微信5.0以上版本的用户使用",@"subName", nil];

     NSDictionary *item2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"支付宝支付",@"mainName",@"推荐有支付宝账号的使用",@"subName", nil];
    self.tableViewDatas = [NSMutableArray arrayWithObjects:item1,item2, nil];
}

#pragma mark__
#pragma mark__UITableViewDataSource__
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewDatas.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *payCell = @"payCell";
    PayOrderCell *Cell = [tableView dequeueReusableCellWithIdentifier:payCell];
    if (!Cell) {
        UINib *nib = [UINib nibWithNibName:@"PayOrderCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:payCell];
        Cell = [tableView dequeueReusableCellWithIdentifier:payCell];
    }
    [Cell updataPayInfoDictionary:self.tableViewDatas[indexPath.row]];
    return Cell;
}
#pragma mark__
#pragma mark__UITableViewDelegate__
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    PayOrderCell *cellshared = [PayOrderCell payOrderCellShared];
    if (indexPath.row == 0) {
        self.qrPaybt.tag = 50 + indexPath.row;
    }
    else{
        self.qrPaybt.tag = 50 + indexPath.row;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}



#pragma mark__微信支付__
-(void)Weixinpay{
    CSLog(@"开启微信支付");
    [PayOrderViewController PaySharSingleton].payMethodCode = 0;
    NSString *res = [WXPayMannager WXJumpToPay:self.ordermodel];
    
    if( ![@"" isEqual:res] ){
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"支付失败" message:res delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alter show];
        
    }
 
}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}

- (void)AliPay
{
    [self alert:@"敬请期待" msg:@"支付宝还在路上。。。"];
//    CSLog(@"支付宝支付");
//    [PayOrderViewController PaySharSingleton].payMethodCode = 1;
//    ZFBPayMannager * alipay = [[ZFBPayMannager alloc]init];
//    [alipay ZFBJumpToPay:self.ordermodel];
}


// 支付订单UI
- (void)payOrderUI
{
    self.view1.left = 0;
    self.view1.top = 0;
    self.commitmodel.orderID;
    if(self.commitmodel.orderID){
        [PayOrderViewController PaySharSingleton].payOrders = self.commitmodel.orderID;
        self.orderNumL.text = [NSString stringWithFormat:@"订单号:%@",cOrderID];
        
    }else{
        self.orderNumL.text = [NSString stringWithFormat:@"订单号:%@",[PayOrderViewController PaySharSingleton].payOrders ];
    }
    
    [self.orderNumL sizeToFit];
    self.orderNumL.left = 10;
    self.orderNumL.top = 14;
    
    self.orderLine.left = self.orderNumL.left;
    self.orderLine.top = self.orderNumL.bottom + 13;
    self.orderLine.width = self.allContentView.width - 2*self.orderLine.left;
    
    self.commitmodel.courseName;
    if (self.commitmodel.courseName) {
        [PayOrderViewController PaySharSingleton].payCourseName = self.commitmodel.courseName;
        self.courseNameL.text = cName;
    }else{
        self.courseNameL.text = [PayOrderViewController PaySharSingleton].payCourseName;
    }
    
    [self.courseNameL sizeToFit];
    self.courseNameL.left = self.orderLine.left;
    self.courseNameL.top = self.orderLine.bottom + 12;
    
    self.commitmodel.totalPrice;
    if (self.commitmodel.totalPrice) {
         [PayOrderViewController PaySharSingleton].payPrices = self.commitmodel.totalPrice;
        self.coursePrice.text = [NSString stringWithFormat:@"￥%@",cPrice];
    }else{
        self.coursePrice.text = [NSString stringWithFormat:@"￥%@", [PayOrderViewController PaySharSingleton].payPrices];
    }
    [self.coursePrice sizeToFit];
    self.coursePrice.left = self.courseNameL.left;
    self.coursePrice.top = self.courseNameL.bottom + 12;
    

    
    self.view3.left = 0;
    self.view3.top = self.allContentView.height - 50;
    self.view3.width = self.allContentView.width;
    self.qrPaybt.left = 12;
    self.qrPaybt.top = 5;
    self.qrPaybt.backgroundColor = MakeColor(0x23, 0x95, 0x199);
    self.qrPaybt.layer.cornerRadius = 5.0f;
    self.qrPaybt.width = self.allContentView.width - 2*self.qrPaybt.left;
    [self.qrPaybt addTarget:self action:@selector(qrPayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

// 支付 按钮事件
#pragma mark-—— 支付Action
- (void)qrPayButtonAction:(UIButton *)button
{
//    CSLog(@"选择的是%ld",self.buttonTag);
    if (!self.qrPaybt.tag) {
        [Utils showToast:@"请选择支付方式，谢谢！"];
        return;
    }
    switch (self.qrPaybt.tag) {
        case 49:{
//            [self locoalPayPassWordPopView]; // 本地支付 会被 商店拒绝
        }
            break;
        case 50:{
            CSLog(@"微信支付,选择的是%ld",(long)self.qrPaybt);
            [self Weixinpay];
        }
            break;
        case 51:{
            CSLog(@"支付宝支付,选择的是%ld",(long)self.qrPaybt);
            [self AliPay];
        }
            break;
        case 52:{
//            CSLog(@"银行卡支付,选择的是%ld",(long)self.buttonTag);
        }
            break;
        default:
            break;
    }
//    NSString *resultStr = [NSString stringWithFormat:@"%ld",(long)self.buttonTag];
//    self.payresulBlock(resultStr);


}

- (void)locoalPayPassWordPopView
{
    
    self.payPopView.frame = CGRectMake(0, 0, 280, 250);
    
    self.qsrPwd.text = @"请输入支付密码";
    [self.qsrPwd sizeToFit];
    self.qsrPwd.top = 15;
    self.qsrPwd.left = self.payPopView.width/2 - self.qsrPwd.width/2;
    
    self.backBt.right = self.payPopView.width - 12;
    self.backBt.top = 10;
    
    self.payline.left = 20;
    self.payline.top = self.qsrPwd.bottom + 10;
    self.payline.width = self.payPopView.width - 2*self.payline.left;
    
    self.payNumLabel.text = @"￥1000";
    [self.payNumLabel sizeToFit];
    self.payNumLabel.top = self.payline.bottom + 25;
    self.payNumLabel.left = self.payPopView.width/2 - self.payNumLabel.width/2;
    
    self.balanceLabel.text = @"账户余额:￥200元";
    [self.balanceLabel sizeToFit];
    self.balanceLabel.top = self.payNumLabel.bottom + 20;
    self.balanceLabel.left = self.payPopView.width/2 - self.balanceLabel.width/2;
    
    self.pwdTextField.left = self.payline.left;
    self.pwdTextField.top = self.balanceLabel.bottom + 15;
    self.pwdTextField.width = self.payPopView.width - 2*self.pwdTextField.left;
   
    [self.pwdTextField setBorderStyle:UITextBorderStyleLine];
    self.pwdTextField.layer.borderWidth = 1.0;
    self.pwdTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.payPopView.height = self.pwdTextField.bottom + 30;
    
    [self.backBt addTarget:self action:@selector(changeCloseButtonType:) forControlEvents:UIControlEventTouchUpInside];
    
    //    [[KGModal sharedInstance] setCloseButtonLocation:KGModalCloseButtonLocationRight];
    [[KGModal sharedInstance] showWithContentView:self.payPopView andAnimated:YES];
    [KGModal sharedInstance].closeButtonType = KGModalCloseButtonTypeNone;
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
}

- (void)willShow:(NSNotification *)notification{
    CSLog(@"will show");
}

- (void)didShow:(NSNotification *)notification{
    CSLog(@"did show");
}

- (void)willHide:(NSNotification *)notification{
    CSLog(@"will hide");
}

- (void)didHide:(NSNotification *)notification{
    CSLog(@"did hide");
}
- (void)changeCloseButtonType:(id)sender{
    UIButton *button = (UIButton *)sender;
    KGModal *modal = [KGModal sharedInstance];
    [modal hideAnimated:YES];
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
