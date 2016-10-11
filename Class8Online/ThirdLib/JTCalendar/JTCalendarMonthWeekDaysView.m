//
//  JTCalendarMonthWeekDaysView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarMonthWeekDaysView.h"
#define WeekViewTopline  112
#define WeekViewBottomline  113
#define WeekViewBjImg 114

@interface JTCalendarMonthWeekDaysView ()
{
    UIView *weekContentView;
}
@end

@implementation JTCalendarMonthWeekDaysView

static NSArray *cacheDaysOfWeeks;

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
    bjImgView.tag = WeekViewBjImg;
    bjImgView.backgroundColor = [UIColor colorWithWhite:245/255.0 alpha:1];
    [self addSubview:bjImgView];
    
    weekContentView = [[UIView alloc] initWithFrame:self.bounds];
    weekContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    weekContentView.backgroundColor = [UIColor clearColor];
    [self addSubview:weekContentView];
    
    
//    UIView *topLine = [[UIView alloc] initWithFrame:CGRectZero];
//    topLine.backgroundColor = [UIColor colorWithWhite:233/255.0 alpha:1];
//    topLine.tag = WeekViewTopline;
//    [self addSubview:topLine];

    
    UIImage *lineimg = [UIImage imageNamed:@"分隔线"];
    lineimg = [lineimg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectZero];
    bottomLine.image = lineimg;
    bottomLine.tag = WeekViewBottomline;
    [self addSubview:bottomLine];

    
    for(NSString *day in [self daysOfWeek]){
        UILabel *view = [UILabel new];
        
        view.font = self.calendarManager.calendarAppearance.weekDayTextFont;
        view.textColor = self.calendarManager.calendarAppearance.weekDayTextColor;
        
        view.textAlignment = NSTextAlignmentCenter;
        view.text = day;
        
//        [self addSubview:view];
        [weekContentView addSubview:view];
    }
}

- (NSArray *)daysOfWeek
{
    if(cacheDaysOfWeeks){
        return cacheDaysOfWeeks;
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSMutableArray *days = nil;
    
    switch(self.calendarManager.calendarAppearance.weekDayFormat) {
        case JTCalendarWeekDayFormatSingle:
            days = [[dateFormatter veryShortStandaloneWeekdaySymbols] mutableCopy];
            break;
    case JTCalendarWeekDayFormatShort:
            days = [[dateFormatter shortStandaloneWeekdaySymbols] mutableCopy];
            break;
    case JTCalendarWeekDayFormatFull:
            days = [[dateFormatter standaloneWeekdaySymbols] mutableCopy];
            break;
    }
    
    for(NSInteger i = 0; i < days.count; ++i){
        NSString *day = days[i];
        [days replaceObjectAtIndex:i withObject:[day uppercaseString]];
    }
    
    // Redorder days for be conform to calendar
    {
        NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;
        NSUInteger firstWeekday = (calendar.firstWeekday + 6) % 7; // Sunday == 1, Saturday == 7
        
        for(int i = 0; i < firstWeekday; ++i){
            id day = [days firstObject];
            [days removeObjectAtIndex:0];
            [days addObject:day];
        }
    }
    
    cacheDaysOfWeeks = days;
    return cacheDaysOfWeeks;
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
    
    // No need to call [super layoutSubviews]

#pragma mark -
#pragma mark - 上下分割线及背景图片分割线
    UIImageView *botLine = (UIImageView *)[self viewWithTag:WeekViewBottomline];
    botLine.frame = CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5);
    
    UIImageView *bjImgView = (UIImageView *)[self viewWithTag:WeekViewBjImg];
    bjImgView.frame = self.bounds;
    
}

+ (void)beforeReloadAppearance
{
    cacheDaysOfWeeks = nil;
}

- (void)reloadAppearance
{
    for(int i = 0; i < weekContentView.subviews.count; ++i){
        UILabel *view = [weekContentView.subviews objectAtIndex:i];
        
        view.font = self.calendarManager.calendarAppearance.weekDayTextFont;
        view.textColor = self.calendarManager.calendarAppearance.weekDayTextColor;
        
        view.text = [[self daysOfWeek] objectAtIndex:i];
    }
}

@end
