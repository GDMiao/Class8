//
//  StudentListView.m
//  Class8Online
//
//  Created by chuliangliang on 15/8/3.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "StudentListView.h"
#import "StudentListCell.h"
#import "LiveViewController.h"

@interface StudentListView ()<UITableViewDataSource,UITableViewDelegate,UserChatViewBgDelegate>
{
    CGFloat ListWidth;
    CGRect userChatViewRect;
    dispatch_queue_t studentListQueue;
    dispatch_queue_t studentListRefeshQueue;
    long long currentUid;
    BOOL didShowUserChatView;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableListData;
@property (nonatomic, strong) UIView *uchatViewSuperView;   //显示聊天的父视图
@end;

@implementation StudentListView
- (id)initWithFrame:(CGRect)frame uCHatViewShowAtViewController:(UIViewController *)vc
{
    self = [super initWithFrame:frame];
    if (self) {
        LiveViewController *liveVC = (LiveViewController *)vc;
        self.uchatViewSuperView = liveVC.allContentView;
        userChatViewRect = liveVC.bottomView.frame;
        [self _initSubViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame uCHatViewShowAtView:(UIView *)v
{
    self = [super initWithFrame:frame];
    if (self) {
        self.uchatViewSuperView = v;
        [self _initSubViews];
    }
    return self;
}

- (void)dealloc {
    self.tableView = nil;
    self.uchatViewSuperView = nil;
    self.uChatbgView = nil;
    if (studentListQueue) {
        studentListQueue = nil;
    }
    if (studentListRefeshQueue) {
        studentListRefeshQueue = nil;
    }
    self.uCountBlock = nil;
}
- (void)_initSubViews {
    currentUid = -1;
    studentListQueue = dispatch_queue_create("studentData.queue", DISPATCH_QUEUE_SERIAL);
    studentListRefeshQueue = dispatch_queue_create("studentRefrechData.queue", DISPATCH_QUEUE_SERIAL);
    ListWidth = self.width;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.delegate = self;
    self.tableView.backgroundView = nil;
    self.tableView.dataSource = self;
    if (IS_IOS8) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }else if (IS_IOS7) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    [self addSubview:self.tableView];
    userAllCount = 0;
    self.tableListData = [[NSMutableArray alloc] init];
    [self.tableListData addObject:[UserAccount shareInstance].loginUser];
    [self refreshTableView];
    
    [self _initUserChatView];
}

- (void)_initUserChatView {
    
    self.uChatbgView = [[UserChatBgView alloc] initWithFrame:self.uchatViewSuperView.bounds uChatShowRect:userChatViewRect];
    self.uChatbgView.delegate = self;
    self.uChatbgView.backgroundColor = [UIColor clearColor];
    self.uChatbgView.hidden = YES;
    didShowUserChatView = self.uChatbgView.hidden;
    [self.uchatViewSuperView addSubview:self.uChatbgView];
    
}


- (void)initTableData:(NSDictionary *)userDic
{
    __block NSDictionary *uDic = userDic;
    __weak StudentListView *wself = self;
    dispatch_async(studentListQueue, ^{
        StudentListView *sself = wself;
        [sself.tableListData removeAllObjects];
        [sself.tableListData addObject:[UserAccount shareInstance].loginUser];
        NSArray *arr = [uDic allValues];
        for (User *u in arr) {
            if (u.authority == UserAuthorityType_TEACHER || u.uid == sself.teaUID) {
                u.authority = UserAuthorityType_TEACHER;
                [sself.tableListData insertObject:u atIndex:0];
            }else {
                [sself.tableListData addObject:u];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [sself refreshTableView];
        });
    });
}

- (void)insertUser:(User *)user
{
    __block User *u = user;
    __weak StudentListView *wself= self;
    dispatch_async(studentListQueue, ^{
        StudentListView *sself = wself;
        
        BOOL hasUser = NO;
        for (User *tmpUser in sself.tableListData) {
            if (tmpUser.uid == u.uid) {
                hasUser = YES;
                break;
            }
        }
        if (!hasUser) {
            if (u.authority == UserAuthorityType_TEACHER || u.uid == sself.teaUID) {
                u.authority = UserAuthorityType_TEACHER;
                [sself.tableListData insertObject:u atIndex:0];
            }else {
                [sself.tableListData addObject:u];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [sself refreshTableView];
        });
        
    });
}

- (void)delUser:(long long)uid
{

    __weak StudentListView *wself = self;
    dispatch_async(studentListQueue, ^{
        StudentListView *sself = wself;
        for (User *u in sself.tableListData) {
            if (u.uid == uid) {
                [sself.tableListData removeObject:u];
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [sself refreshTableView];
        });
    });
}

/**
 * 多线处理完数据后回到主线程刷新UI
 **/
- (void)refreshTableView {
    if (self.tableListData.count > 0) {
        self.tableView.tableFooterView = nil;
    }else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,ListWidth, 20)];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = CSLocalizedString(@"live_VC_stulist_not_user");
        self.tableView.tableFooterView = label;
    }
    [self.tableView reloadData];
 
    if (self.uCountBlock) {
        userAllCount = self.tableListData.count;
        self.uCountBlock(MAX(0, userAllCount));
    }
}
/**
 * 显示/隐藏 个人聊天
 **/
- (void)deviceOrientation:(BOOL)down
{

    if (down) {
        //竖屏
        self.uChatbgView.hidden = didShowUserChatView;
        ClassRoomLog(@"StudentListView==> (竖屏)当前单聊显示状态:%@",didShowUserChatView?@"隐藏":@"显示");
    }else{
        //横屏
        didShowUserChatView = self.uChatbgView.hidden;
        self.uChatbgView.hidden = YES;
        ClassRoomLog(@"StudentListView==> (横屏)记录单聊显示状态:%@",didShowUserChatView?@"隐藏":@"显示");
    }
}

#pragma mark- 
#pragma mark- UITableViewDataSource/UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableListData.count;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return  [[StudentListCell shareStudentCell] setCellContent:[self getUserData:indexPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idtifier = @"cell-StudentListCell";
    StudentListCell *cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"StudentListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:idtifier];
        cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    }
    cell.courseid = self.courseid;
    cell.classid = self.classid;
    cell.cellAllWidth = ListWidth;
    [cell setCellContent:[self getUserData:indexPath]];
    return cell;

}


- (User *)getUserData:(NSIndexPath *)indexPath {
    User *user= nil;
    user = [self.tableListData objectAtIndex:indexPath.row];
    return user;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    User *u = [self getUserData:indexPath];
    if (u.uid == [UserAccount shareInstance].uid) {
        return;
    }
    u.hasUnReadMsg = NO;
    currentUid = u.uid;
    [self refreshTableView];
    CSLog(@"StudentListView==> 点击用户名: %@, uid:%lld",u.realname,u.uid);
    self.uChatbgView.classID = self.classid;
    self.uChatbgView.otherUid = u.uid;
    [self.uChatbgView updateTitltText:[NSString stringWithFormat:@"%@%@%@",
                                       CSLocalizedString(@"live_VC_stulist_user_chat1"),
                                       u.realname,
                                       CSLocalizedString(@"live_VC_stulist_user_chat2")]];
    [self.uChatbgView showUserChatView];
}


#pragma mark - 
#pragma mark - UserChatViewBgDelegate
- (void)userChatBgViewAddNewChat:(long long)uid
{
    CSLog(@"StudentListView==>新增私聊UID: %lld",uid);
    __weak StudentListView *wself = self;
    dispatch_async(studentListQueue, ^{
        StudentListView *sself = wself;
        int teaIndex = -1;
        int newChatIndex = -1;
        for (int i = 0; i < sself.tableListData.count; i ++) {
            User *u = [sself.tableListData objectAtIndex:i];
            if ((u.uid == sself.teaUID || u.authority == UserAuthorityType_TEACHER) && currentUid != uid) {
                if (uid == self.teaUID) {
                    u.hasUnReadMsg = YES;
                }
                teaIndex = i;
            }else if (uid == u.uid && currentUid != uid) {
                newChatIndex = i;
                u.hasUnReadMsg = YES;
            }
        }
        if (newChatIndex != -1) {
            teaIndex = MAX(0, teaIndex);
            teaIndex = MIN(teaIndex+1, sself.tableListData.count -1);
            [sself.tableListData exchangeObjectAtIndex:newChatIndex withObjectAtIndex:teaIndex];
        }
    dispatch_async(dispatch_get_main_queue(), ^{
            [sself refreshTableView];
        });
    });
    
}

- (void)userChatBgViewWillDisMiss
{
    currentUid = -1;
}
@end
