//
//  EditUserInfoViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "EditUserInfoViewController.h"
#import "User.h"
#import <AVFoundation/AVFoundation.h>


@interface EditUserInfoViewController ()<UITextFieldDelegate,IBActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UITapGestureRecognizer *tapGesture;
}
//@property (assign, nonatomic) BOOL isOnlyNick;
@property (strong, nonatomic) NSString *userAvatar;
@property (strong, nonatomic) NSString *userNickName;
@property (assign, nonatomic) EditUserInfoStyle editStyle;
@end

@implementation EditUserInfoViewController
@synthesize editStyle;

- (id)initWithEditStyle:(EditUserInfoStyle)style
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        editStyle = style;
    }
    return self;
}

- (void)dealloc {
    self.nickNameTextField = nil;
    self.avatarButton = nil;
    self.doneButton = nil;
    self.scrollView = nil;
    self.nameDivece = nil;
    self.desLabel = nil;
    if (tapGesture) {
        [self.allContentView removeGestureRecognizer:tapGesture];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *textFieldPlaceholderString = @"";
    self.desLabel.hidden = YES;
    if (EditUserInfoStyle_NickAndAvatar == editStyle) {
        //编辑昵称+头像
        [self.titleView setTitleText:CSLocalizedString(@"editNick_VC_nav2_title") withTitleStyle:CTitleStyle_OnlyBack];
        self.avatarButton.hidden = NO;
        self.avatarButton.top = 30;
        self.nickNameTextField.top = self.avatarButton.bottom + 20;
        self.doneButton.top = self.nickNameTextField.bottom + 40;
        self.avatarButton.left = (self.allContentView.width - self.avatarButton.width) * 0.5;
        
        textFieldPlaceholderString = CSLocalizedString(@"editNick_VC_textField_placeholder");
    }else if (EditUserInfoStyle_OnlyNick == editStyle) {
        //只编辑昵称
        [self.titleView setTitleText:CSLocalizedString(@"editNick_VC_nav1_title") withTitleStyle:CTitleStyle_OnlyBack];
        self.avatarButton.hidden = YES;
        self.nickNameTextField.top = 30;
        self.doneButton.top = self.nickNameTextField.bottom + 40;
        
        textFieldPlaceholderString = CSLocalizedString(@"editNick_VC_textField_placeholder");
    }else if (EditUserInfoStyle_CameraDevName == editStyle) {
        //编辑摄像头设备名
        [self.titleView setTitleText:CSLocalizedString(@"editNick_VC_nav3_title") withTitleStyle:CTitleStyle_LeftAndRight];
        [self.titleView setleftButtonText:CSLocalizedString(@"editNick_VC_nav_leftBtnText")];
        [self.titleView setRightButonText:CSLocalizedString(@"editNick_VC_nav_rightBtnText")];

        UIButton *leftBtn = [self.titleView titleLeftButton];
        [leftBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [leftBtn setImage:nil forState:UIControlStateNormal];
        self.avatarButton.hidden = YES;
        self.nickNameTextField.top = 30;
        self.doneButton.hidden = YES;
        textFieldPlaceholderString = CSLocalizedString(@"editNick_VC_Camera_DevNameplacholder");
        
        self.desLabel.hidden = NO;
        self.desLabel.width = self.allContentView.width -20;
        self.desLabel.text = @"此名称方便多机位选择与连接,尽量去一个响亮而与众不同的名称!";
        [self.desLabel sizeToFit];
        self.desLabel.left = 20;
        self.desLabel.top = self.nickNameTextField.bottom + 10;
    }
        
    
    self.doneButton.left = (self.allContentView.width - self.doneButton.width) * 0.5;
    [self.doneButton setTitle:CSLocalizedString(@"editNick_VC_doneBtn_nomalTitle") forState:UIControlStateNormal];
    [self.doneButton setBackgroundImage:[UIImage imageNamed:@"更换"] forState:UIControlStateNormal];
    
    self.nickNameTextField.placeholder = textFieldPlaceholderString;
    UIView *emailLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, self.nickNameTextField.height)];
    emailLeftView.backgroundColor = [UIColor clearColor];
    self.nickNameTextField.leftView = emailLeftView;
    self.nickNameTextField.leftViewMode =  UITextFieldViewModeAlways;

    UIView *emailRightView = [[UIView alloc] initWithFrame:CGRectMake(0,0,30, self.nickNameTextField.height)];
    emailRightView.backgroundColor = [UIColor clearColor];
    UIButton *emRightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    emRightbtn.frame = CGRectMake((emailRightView.width - 16) * 0.5, (emailRightView.height - 16) * 0.5, 16, 16);
    [emRightbtn setImage:[UIImage imageNamed:@"清除文字"] forState:UIControlStateNormal];
    [emRightbtn addTarget:self action:@selector(clearEmail) forControlEvents:UIControlEventTouchUpInside];
    [emailRightView addSubview:emRightbtn];
    self.nickNameTextField.rightView = emailRightView;
    self.nickNameTextField.rightViewMode =  UITextFieldViewModeWhileEditing;

    
    UIImage *aVimg = nil;
    User *user = [UserAccount shareInstance].loginUser;
    if (user && EditUserInfoStyle_CameraDevName != editStyle) {
        self.userAvatar = user.avatar;
        self.userNickName = user.nickName;
        
        NSString *filePath = [[FILECACHEMANAGER getFileRootPathWithFileType:FileType_Img] stringByAppendingPathComponent:[NSString stringWithFormat:@"user_pic_%@.jpg", self.userAvatar]];
        aVimg = [UIImage imageWithContentsOfFile:filePath];

        self.nickNameTextField.text = user.nickName;
    }else {
        self.nickNameTextField.text = self.nameDivece;
    }
    aVimg = [Utils objectIsNull:aVimg]?[UIImage imageNamed:@"默认头像"] : aVimg;
    [self.avatarButton setImage:aVimg forState:UIControlStateNormal];
    self.avatarButton.layer.cornerRadius = self.avatarButton.width * 0.5;
    self.avatarButton.layer.masksToBounds = YES;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoradTagAction)];
    [self.allContentView addGestureRecognizer:tapGesture];
    
}

//只有在 editStyle == EditUserInfoStyle_CameraDevName 网络摄像头时 此方法调用
- (void)rightClicked:(TitleView *)view {
    [self doneAction:nil];
}

//点击手势隐藏键盘
- (void)hiddenKeyBoradTagAction {
    [self.nickNameTextField resignFirstResponder];

}

- (void)clearEmail {
    self.nickNameTextField.text = nil;
}
#pragma mark-
#pragma mark-  UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}
-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        return;
    }
    if (buttonIndex == 0) {
        //拍照
        [self showCamera];
    }else if (buttonIndex == 1) {
        //相册
        [self selectExistingPicture];
    }
}

- (IBAction)avatarAction:(UIButton *)sender {
    IBActionSheet *actionSheetView = [[IBActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:CSLocalizedString(@"editNick_VC_takePhoto_cancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:CSLocalizedString(@"editNick_VC_takePhoto"),
                                      CSLocalizedString(@"editNick_VC_photoslib"), nil];
    [actionSheetView showInView:self.view];
}
- (BOOL)checkUserInfo {
    
    if ([Utils objectIsNull:self.userAvatar]&& editStyle == EditUserInfoStyle_NickAndAvatar) {
        [Utils showToast:CSLocalizedString(@"editNick_VC_choose_avatar")];
        return NO;
    }
    NSString *userName = [self.nickNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.userNickName = userName;
    if (userName.length <= 0) {
        if (editStyle == EditUserInfoStyle_CameraDevName) {
            //手机摄像头
            [Utils showToast:CSLocalizedString(@"editNick_VC_camera_name_no")];
        }else {
            [Utils showToast:CSLocalizedString(@"editNick_VC_input_nick")];
        }
        return NO;
    }
    return YES;
}

- (IBAction)doneAction:(UIButton *)sender {
    [self.nickNameTextField resignFirstResponder];
    if (![self checkUserInfo]) {
        return;
    }
    
    if (EditUserInfoStyle_CameraDevName == editStyle) {
        [UserAccount shareInstance].deviceName = self.nickNameTextField.text;
        if (self.block) {
            self.block(self.userNickName);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else if (EditUserInfoStyle_OnlyNick == editStyle) {
        NSString *userName = [self.nickNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self showHUD:nil];
        [self resetHttp];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:userName forKey:@"usernickname"];
        [params setValue:[NSNumber numberWithLongLong:self.uid] forKey:@"userid"];
        [http_  updateUserInfoparams:params jsonResponseDelegate:self];

    }else {
        if (self.block) {
            self.block(self.userNickName);
        }
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

//=========================================
// 相册和相机
//=========================================
-(void)showCamera
{
    //判断是否有拍照功能
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if (IS_IOS7) {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];  //获取对摄像头的访问权限
            if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:CSLocalizedString(@"editNick_VC_not_takePhoto")
                                                               delegate:nil
                                                      cancelButtonTitle:CSLocalizedString(@"editNick_VC_takePhoto_alert_ok")
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        //模式窗体转化到图片选取界面
        UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
        imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;
        imagePickerController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        //将图片选取器呈现给用户
        [self presentViewController:imagePickerController animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:CSLocalizedString(@"editNick_VC_no_campare")
                              delegate:nil
                              cancelButtonTitle:CSLocalizedString(@"editNick_VC_takePhoto_cancel")
                              otherButtonTitles:nil];
        [alert show];
    }
}

//选取相册中的图片
- (void)selectExistingPicture
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker =[[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:CSLocalizedString(@"editNick_VC_not_photoslib")
                              message:CSLocalizedString(@"editNick_VC_no_photoslib")
                              delegate:nil
                              cancelButtonTitle:CSLocalizedString(@"editNick_VC_takePhoto_cancel")
                              otherButtonTitles:nil];
        [alert show];
    }
}

//相机代理实现的方法
#pragma mark -
#pragma mark UIImagePickerControllerDelegate
//当用户成功拍摄了照片，或从图片库中选取一张图片将会调用这个方法
//第一个参数返回创建的指针，第二个参数是用户所选image的实例
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSString *fileName = [self createFilename];
    NSString *filePath = [[FILECACHEMANAGER getFileRootPathWithFileType:FileType_Img] stringByAppendingPathComponent:[NSString stringWithFormat:@"user_pic_%@.jpg", fileName]];
    
    [UIImageJPEGRepresentation(image, 0.3) writeToFile:filePath atomically:YES];
    
    
    [self.avatarButton setImage:image forState:UIControlStateNormal];
    self.userAvatar = fileName;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self resetHttp];
    [http_ upLoadFile:filePath userid:[UserAccount shareInstance].uid jsonResponseDelegate:self];

}

//创建储存件名字
- (NSString *)createFilename {
    NSDate *date_ = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *timeFileName = [dateformater stringFromDate:date_];
    return timeFileName;
}


/**
 * http请求成功后的回调
 */
- (void)requestFinished:(ASIHTTPRequest *) request
{
    CSLog(@"返回值: %@",[request responseString]);
    if (editStyle == EditUserInfoStyle_OnlyNick) {
        [self hiddenHUD];
        NSString *urlString = [[request url] absoluteString];
        if ([urlString rangeOfString:@"mobileupdatepersonaldata"].location != NSNotFound) {
            JSONModel *rspModel = [[JSONModel alloc] initWithJSON:[request responseJSON]];
            if (rspModel.code_ == RepStatus_Success) {
                [Utils showToast:CSLocalizedString(@"editNick_VC_update_success")];
                if (self.block) {
                    NSString *userName = [self.nickNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    self.block(userName);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                [Utils showToast:CSLocalizedString(@"editNick_VC_update_faild")];
            }
        }
    }
}
/**
 * http请求失败后的回调
 */
- (void)requestFailed:(ASIHTTPRequest *) request
{
    [self hiddenHUD];
    if (editStyle == EditUserInfoStyle_OnlyNick) {
        [Utils showToast:CSLocalizedString(@"editNick_VC_update_faild")];
    }
}

@end
