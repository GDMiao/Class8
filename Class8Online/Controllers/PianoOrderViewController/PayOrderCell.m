//
//  PayOrderCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/27.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "PayOrderCell.h"



@implementation PayOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (PayOrderCell *)payOrderCellShared
{
    static PayOrderCell *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PayOrderCell alloc]init];
    });
    return sharedInstance;
}

-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PayOrderCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

- (CGFloat)updataPayInfoDictionary:(NSMutableDictionary *)dict
{
    height = 0;
    self.dict = dict;
    self.titleName.text = [self.dict objectForKey:@"mainName"];
    [self.titleName sizeToFit];
    self.titleName.left = 14;
    self.titleName.top = 10;
    
    self.subName.text = [self.dict objectForKey:@"subName"];
    [self.subName sizeToFit];
    self.subName.top = self.titleName.bottom + 1;
    self.subName.left = self.titleName.left;
    
    self.selectImge.image = [UIImage imageNamed:@"selectOff.png"];
    
    self.bottomLine.left = 0;
    self.bottomLine.top = self.subName.bottom + 8;
    
    self.selectImge.top = 15;
    self.selectImge.right = SCREENWIDTH - 12;
    
    height = self.bottomLine.bottom;
    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (!selected) {
        self.selectImge.image = [UIImage imageNamed:@"selectOff.png"];
//        self.selectImge setimge
    }else{
        self.selectImge.image = [UIImage imageNamed:@"selectOn.png"];
    }
//     Configure the view for the selected state
    selected = !selected;
}

@end
