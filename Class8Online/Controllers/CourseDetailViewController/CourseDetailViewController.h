//
//  CourseDetailViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/5/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "CourseInfoView.h"
#import "HFBrowserView.h"

@interface CourseDetailViewController : BasicViewController
@property (weak, nonatomic) IBOutlet CourseInfoView *courseInfoView;
@property (nonatomic,strong) HFBrowserView *browserView;
- (id)initWithCourseid:(long long)courseID;
@end
