//
//  CourseWithLessonsView.m
//  Class8Online
//
//  Created by chuliangliang on 15/5/14.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CourseWithLessonsView.h"
#import "CourseWithLessonCell.h"
#import "LessonsModel.h"

@interface CourseWithLessonsView ()<UITableViewDataSource,UITableViewDelegate>
{
}
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) LessonsList *lessonList;
@end

@implementation CourseWithLessonsView

- (void)dealloc {
    self.tableView = nil;
    self.lessonList = nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews {
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (IS_IOS7) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if (IS_IOS8) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    [self addSubview:self.tableView];

}
- (void)updateClassInfo:(LessonsList *)list
{
    self.lessonList = list;
    if (self.lessonList.list.count <= 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,self.width, 20)];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = CSLocalizedString(@"courseDetail_classView_no_class");
        self.tableView.tableFooterView = label;
    }else {
        self.tableView.tableFooterView = nil;
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.lessonList.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idtifier = @"cell-lessonsList";
    CourseWithLessonCell *cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"CourseWithLessonCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:idtifier];
        cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    }
    cell.teaName = self.teaName;
    cell.avatarURL = self.avatarURL;
    
    [cell setCellContentModel:[self.lessonList.list objectAtIndex:indexPath.row]];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[CourseWithLessonCell shareCourseWithLessonCell] setCellContentModel:[self.lessonList.list objectAtIndex:indexPath.row]];
}

@end
