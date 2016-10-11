//
//  CameraViewController.h
//  Class8Camera
//
//  Created by chuliangliang on 15/7/18.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface CameraViewController : BasicViewController

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *statusView;

@property (weak, nonatomic) IBOutlet UIButton *micBtn;
@property (weak, nonatomic) IBOutlet UIButton *maskViewBtn;

@property (weak, nonatomic) IBOutlet UIButton *cameraStatusBtn;
@property (weak, nonatomic) IBOutlet UILabel *tItleLabel;

@property (assign, nonatomic) long long tid;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
- (IBAction)changeVideoSize:(UIButton *)sender;

- (IBAction)buttonActions:(UIButton *)sender;
@end
