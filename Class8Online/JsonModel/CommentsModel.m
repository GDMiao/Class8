//
//  ScoreModel.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CommentsModel.h"

@implementation CommentsModel
- (void)dealloc
{
    self.owerName = nil;
    self.contenTxt = nil;
    self.owerAvatar = nil;
    self.dateString = nil;
}


-(void)parse:(NSDictionary *)json
{
    self.commentID = [json longForKey:@"id"];
    self.classID = [json longForKey:@"classid"];
    self.courseID = [json longForKey:@"courseid"];
    self.owerUid = [json longForKey:@"uid"];
    
    self.owerName = [json stringForKey:@"nickName"];
    self.contenTxt = [json stringForKey:@"content"];
    self.dateString = [json stringForKey:@"createTime"];
    self.owerAvatar = [json stringForKey:@"avatarUrl"];
    
    self.score = [json floatForKey:@"score"];
}
@end


const int commentOnePageCount = 5;
@implementation CommentList

- (void)dealloc
{
    self.list = nil;
}

- (void)parse:(NSDictionary *)json
{
    NSDictionary *resultDic = [json objectForKey:@"result"];
    NSArray *commentList = [resultDic  arrayForKey:@"list"];
    NSMutableArray *tmpCommentList = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in commentList) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        CommentsModel *tmpComment = [[CommentsModel alloc] initWithJSON:dic];
        [tmpCommentList addObject:tmpComment];
    }
    self.list = tmpCommentList;
    if (self.list.count < commentOnePageCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
}


- (void)addList:(CommentList *)list
{
    if (list.list.count > 0) {
        [self.list addObjectsFromArray:list.list];
    }
    self.hasMore = list.hasMore;
}

@end