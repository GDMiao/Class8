//
//  IMGCWView.m
//  Class8Online
//
//  Created by chuliangliang on 15/6/30.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "IMGCWView.h"
#import "FileCacheManager.h"
@implementation IMGCWView

/**
 * 更新内容
 **/
- (void)updateConten:(NSString *)imgName
{
    UIImage *image = [UIImage imageWithContentsOfFile:[[FILECACHEMANAGER getFileRootPathWithFileType:FileType_Img] stringByAppendingPathComponent:imgName]];
    self.layer.contents = (id)image.CGImage;
}

@end
