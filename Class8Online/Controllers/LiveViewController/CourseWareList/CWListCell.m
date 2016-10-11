//
//  CWListCell.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CWListCell.h"
static CWListCell *sharedInstance = nil;
@implementation CWListCell


- (void)dealloc {
    self.cwIcon = nil;
    self.cwNameLabel = nil;
    self.cwRightBtn = nil;
    self.cwModel = nil;
    self.line = nil;
    
}

-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CWListCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

+ (CWListCell *)shareCWListCell
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[CWListCell alloc] init];
    });
    return sharedInstance;
}
- (CGFloat)cellHeight:(CWModel *)value
{
    [self setCourseWare:value];
    return cellHeight;
}




- (void)awakeFromNib {
    [self _initViews];
}


- (void)_initViews {
    self.cwRightBtn.adjustsImageWhenDisabled = NO;
    self.cwRightBtn.adjustsImageWhenHighlighted = NO;
    
    if (IS_IOS8) {
        [self setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }

    
    UIImage *lineImg = [UIImage imageNamed:@"分隔线"];
    lineImg = [lineImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.line.image = lineImg;

}


- (void)setCourseWare:(CWModel *)cwModel
{
    self.cwModel = cwModel;
    cellHeight = 0;
    
 
    self.cwIcon.top = 10;
    self.cwIcon.left = 35;
    UIImage *fileIocnImg = [UIImage imageNamed:[Utils getCourseWareIcon:self.cwModel.cwName]];
    self.cwIcon.image = fileIocnImg;

    self.cwNameLabel.text = self.cwModel.cwName;
    [self.cwNameLabel sizeToFit];
    self.cwNameLabel.left = self.cwIcon.right + 18;
    self.cwNameLabel.top = (self.cwIcon.height - self.cwNameLabel.height) * 0.5 + self.cwIcon.top;
    
    self.cwRightBtn.right = self.contentWidth - 10;
    self.cwRightBtn.top = self.cwIcon.top;
    self.cwRightBtn.height = self.cwIcon.height;
    self.cwRightBtn.width = 40;
    
    
    
    switch (self.cwModel.loadState) {
        case CWLoadState_Wait:
        {
            self.cwRightBtn.userInteractionEnabled = NO;
            [self.cwRightBtn setTitle:CSLocalizedString(@"live_VC_courseWare_wait") forState:UIControlStateNormal];
            [self.cwRightBtn setImage:nil forState:UIControlStateNormal];
        }
            break;
        case CWLoadState_Loading:
        {
            self.cwRightBtn.userInteractionEnabled = NO;
            [self.cwRightBtn setImage:nil forState:UIControlStateNormal];
            [self.cwRightBtn setTitle:[NSString stringWithFormat:@"%.1f%%",self.cwModel.progress * 100] forState:UIControlStateNormal];
        }
            break;
        case CWLoadState_Fail:
        {
            self.cwRightBtn.userInteractionEnabled = YES;
            [self.cwRightBtn setImage:nil forState:UIControlStateNormal];
            [self.cwRightBtn setTitle:CSLocalizedString(@"live_VC_courseWare_reload") forState:UIControlStateNormal];
        }
            break;
        case CWLoadState_Done:
        {
            self.cwRightBtn.userInteractionEnabled = NO;
            [self.cwRightBtn setImage:[UIImage imageNamed:@"文件保存"] forState:UIControlStateNormal];
                        [self.cwRightBtn setTitle:nil forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    
    
    self.cwNameLabel.width = self.cwRightBtn.left - self.cwNameLabel.left;
    
    cellHeight = self.cwIcon.bottom + 10;
    self.line.frame = CGRectMake(10, cellHeight- 0.5, self.contentWidth-20, 0.5);

}
@end
