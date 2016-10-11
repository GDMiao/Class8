//
//  ScoreModel.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

@interface CommentsModel : JSONModel
@property (assign, nonatomic) long long commentID,                  /*评论ID*/
owerUid,                                                            /*评论者uid*/
classID,                                                            /*课ID*/
courseID;                                                           /*课程ID*/
@property (strong, nonatomic) NSString *owerName,                   /*评论发表者*/
*owerAvatar,                                                        /*评论者头像*/
*contenTxt,                                                         /*评论内容*/
*dateString;                                                        /*评论时间*/
@property (assign, nonatomic) CGFloat score;                        /*评分*/
@end

@interface CommentList : JSONModel
@property (strong, nonatomic) NSMutableArray *list;                 /*评论列表*/
@property (assign, nonatomic) BOOL hasMore;                         /*是否有更多评论*/
- (void)addList:(CommentList *)list;
@end