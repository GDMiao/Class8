//
//  ChatImageView.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/31.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "ChatImageView.h"
#import "UIImageView+WebCache.h"
#import "ChatImageDownUtils.h"

@implementation ChatImageView

- (void)setImageWithUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage
{
    __weak ChatImageView *wself = self;
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholderImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            ChatImageView *sself = wself;
            if ([[ChatImageDownUtils shareChatImag] hasReLoadImagWithUrl:imageURL]) {
                [sself setImageWithUrl:url placeholderImage:placeholderImage];
                
            }
        }
    }];

}
@end
