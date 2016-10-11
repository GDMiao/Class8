//
//  MyCalendarViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "JTCalendar.h"
#import "TimePickerView.h"
@interface MyCalendarViewController : BasicViewController<UIScrollViewDelegate, JTCalendarDataSource>

@property (strong, nonatomic) JTCalendar *calendar;

@property (strong, nonatomic) JTCalendarMenuView *calendarMenuView;
@property (strong, nonatomic) JTCalendarContentView *calendarContentView;

@property (strong, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UIButton *pickerButton;
@property (strong, nonatomic) TimePickerView *myPickerView;


//@property (strong, nonatomic) UIButton *pickerBut;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
