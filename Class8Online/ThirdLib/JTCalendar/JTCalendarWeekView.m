//
//  JTCalendarWeekView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarWeekView.h"

#import "JTCalendarDayView.h"

#define WeekViewbjImgTag 2000
#define WeekViewBottomLineTag 2001
@interface JTCalendarWeekView (){
    NSArray *daysViews;
    UIView *weekContentView;
};

@end

@implementation JTCalendarWeekView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    
//    UIImage *bjImg = [UIImage imageNamed:@""];
//    bjImg = [bjImg resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    UIImageView *bjImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    bjImgView.image = bjImg;
    bjImgView.tag = WeekViewbjImgTag;
    bjImgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bjImgView];

    
    weekContentView = [[UIView alloc] initWithFrame:self.bounds];
    weekContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    weekContentView.backgroundColor = [UIColor clearColor];
    [self addSubview:weekContentView];

    
//    UIImage *lineimg = [UIImage imageNamed:@"分隔线"];
//    lineimg = [lineimg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
//    UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectZero];
//    bottomLine.image = lineimg;
//    bottomLine.tag = WeekViewBottomLineTag;
//    [self addSubview:bottomLine];

    
    NSMutableArray *views = [NSMutableArray new];
    
    for(int i = 0; i < 7; ++i){
        UIView *view = [JTCalendarDayView new];
        view.tag = i + 1;
        [views addObject:view];
//        [self addSubview:view];
        [weekContentView addSubview:view];
    }
    
    daysViews = views;
}

- (void)layoutSubviews
{

    weekContentView.frame = self.bounds;
    
    
    CGFloat x = 0;
    CGFloat width = self.frame.size.width / 7.;
    CGFloat height = self.frame.size.height;
    
    if(self.calendarManager.calendarAppearance.readFromRightToLeft){
        for(UIView *view in [[weekContentView.subviews reverseObjectEnumerator] allObjects]){
            view.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(view.frame);
        }
    }
    else{
        for(UIView *view in weekContentView.subviews){
            view.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(view.frame);
        }
    }
    
//    UIImageView *botLine = (UIImageView *)[self viewWithTag:WeekViewBottomLineTag];
//    botLine.frame = CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5);
    
    UIImageView *bjImgView = (UIImageView *)[self viewWithTag:WeekViewbjImgTag];
    bjImgView.frame = self.bounds;

    
    [super layoutSubviews];
}

- (void)setBeginningOfWeek:(NSDate *)date
{
    NSDate *currentDate = date;
    
    NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;
    
    for(JTCalendarDayView *view in daysViews){
        if(!self.calendarManager.calendarAppearance.isWeekMode){
            NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:currentDate];
            NSInteger monthIndex = comps.month;
                        
            [view setIsOtherMonth:monthIndex != self.currentMonthIndex];
        }
        else{
            [view setIsOtherMonth:NO];
        }
        
        [view setDate:currentDate];
        
        NSDateComponents *dayComponent = [NSDateComponents new];
        dayComponent.day = 1;
        
        currentDate = [calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
    }
}

#pragma mark - JTCalendarManager

- (void)setCalendarManager:(JTCalendar *)calendarManager
{
    self->_calendarManager = calendarManager;
    for(JTCalendarDayView *view in daysViews){
        [view setCalendarManager:calendarManager];
    }
}

- (void)reloadData
{
    for(JTCalendarDayView *view in daysViews){
        [view reloadData];
    }
}

- (void)reloadAppearance
{
    for(JTCalendarDayView *view in daysViews){
        [view reloadAppearance];
    }
}

@end
