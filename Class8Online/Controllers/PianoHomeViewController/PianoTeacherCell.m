//
//  PianoTeacherCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "PianoTeacherCell.h"

@interface PianoTeacherCell ()

@property (weak, nonatomic) IBOutlet UIImageView *teaImg;
@property (weak, nonatomic) IBOutlet UILabel *nameStr;
@property (weak, nonatomic) IBOutlet UIImageView *medalsImg;
@property (weak, nonatomic) IBOutlet UILabel *organizationStr;
@property (weak, nonatomic) IBOutlet UILabel *scoreStr;
@property (weak, nonatomic) IBOutlet UIImageView *logoImg;
@property (weak, nonatomic) IBOutlet UILabel *courseNumStr;

@end

@implementation PianoTeacherCell

+ (PianoTeacherCell *)sharTeacell
{
    static PianoTeacherCell *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PianoTeacherCell alloc]init];
    });
    return sharedInstance;


}

-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PianoTeacherCell" owner:self options:nil];
    self = [nib lastObject];
    
    if (self) {
    }
    return self;
}

- (CGFloat)setTeaCellContent:(NSString *)title sectionView:(BOOL)isShow
{
    height = 0;
    self.left = 0;self.top = 0;
    if (isShow == YES) {
        self.sectionView.left = 0;
        self.sectionView.top = 0;
        self.sectionView.hidden = NO;
        
        self.teaImg.left = 20;
        self.teaImg.top = self.sectionView.bottom + 10;
        
        self.nameStr.text = title;
        [self.nameStr sizeToFit];
//        self.nameStr.backgroundColor = [UIColor redColor];
        self.nameStr.left = self.teaImg.right + 10;
        self.nameStr.top = self.teaImg.top + 10;
        
        
        self.medalsImg.left = self.nameStr.right + 10;
        self.medalsImg.top = self.nameStr.top;
        
        self.organizationStr.left = self.nameStr.left;
        self.organizationStr.top = self.nameStr.bottom + 10;
        
        self.logoImg.left = self.organizationStr.right + 10;
        self.logoImg.top = self.organizationStr.top;
        
        self.scoreStr.left = self.organizationStr.left;
        self.scoreStr.top = self.organizationStr.bottom+ 10;
        
        self.courseNumStr.left = self.scoreStr.right + 10;
        self.courseNumStr.top = self.scoreStr.top;
        
        height = self.teaImg.bottom + 10;
    }else
    {
        self.sectionView.hidden = YES;
        
        self.teaImg.left = 20;
        self.teaImg.top = 10;
        
        self.nameStr.text = title;
        [self.nameStr sizeToFit];
        //        self.nameStr.backgroundColor = [UIColor redColor];
        self.nameStr.left = self.teaImg.right + 10;
        self.nameStr.top = self.teaImg.top + 10;
        
        
        self.medalsImg.left = self.nameStr.right + 10;
        self.medalsImg.top = self.nameStr.top;
        
        self.organizationStr.left = self.nameStr.left;
        self.organizationStr.top = self.nameStr.bottom + 10;
        
        self.logoImg.left = self.organizationStr.right + 10;
        self.logoImg.top = self.organizationStr.top;
        
        self.scoreStr.left = self.organizationStr.left;
        self.scoreStr.top = self.organizationStr.bottom+ 10;
        
        self.courseNumStr.left = self.scoreStr.right + 10;
        self.courseNumStr.top = self.scoreStr.top;
        
        height = self.teaImg.bottom + 10;
    }
//    CSLog(@"%f",height);
    return height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
