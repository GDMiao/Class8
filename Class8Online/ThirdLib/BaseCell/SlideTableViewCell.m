
#import "SlideTableViewCell.h"

#define DELETE_BUTTON_WIDHT 98
#define MORE_BUTTON_WIDTH   0 //80
#define BOUNENCE            30
#define IconSize CGSizeMake(30, 34)
#define DeleteViewTag 1001
#define DeleteButtonTag 1002
@interface CustomButton : UIView
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;
- (id)initWithTitle:(NSString *)title iconImg:(NSString *)icon;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event;

@end

@implementation CustomButton
- (void)dealloc {
    self.label = nil;
    self.iconView= nil;
    self.button = nil;
}
- (id)initWithTitle:(NSString *)title iconImg:(NSString *)icon {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IconSize.width, IconSize.height)];
        self.iconView.userInteractionEnabled = YES;
        self.iconView.image = [UIImage imageNamed:icon];
        [self addSubview:self.iconView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.label.text = title;
        [self.label sizeToFit];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        [self addSubview:self.label];
        
    
        self.button.adjustsImageWhenHighlighted = NO;
        self.button.backgroundColor = [UIColor redColor];
        [self addSubview:self.button];
        
        self.backgroundColor = [UIColor colorWithRed:23/ 255.0 green:95/255.0 blue:199/255.0 alpha:1];
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    float totalWidth = self.iconView.width + self.label.width + 5;
    self.iconView.left = (self.width - totalWidth) *0.5;
    self.iconView.top = (self.height - self.iconView.height ) * 0.5;
    
    self.label.left = self.iconView.right + 5;
    self.label.top = (self.height - self.label.height) * 0.5;
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = self.bounds;

}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event
{
    [self.button addTarget:target action:action forControlEvents:event];
}

@end

@implementation SlideTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // Initialization code
        if (_moveContentView == nil) {
            _moveContentView = [[UIView alloc] init];
            _moveContentView.backgroundColor = [UIColor whiteColor];
        }
        [self.contentView addSubview:_moveContentView];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addControl];
        
    }
    return self;
}

-(void)dealloc{
    if (self.vPanGesture) {
        [self.contentView removeGestureRecognizer:self.vPanGesture];
        self.vPanGesture = nil;
    }
}

- (void)awakeFromNib
{
    // Initialization code
    [self addControl];
}

-(void)addControl{

    UIView *menuContetnView = [[UIView alloc] init];
    menuContetnView.hidden = YES;
    menuContetnView.tag = 100;
    
    UIButton *vDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [vDeleteButton setBackgroundColor:[UIColor clearColor]];
    [vDeleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [vDeleteButton setTag:DeleteButtonTag];
    
    
//    UIButton *vMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [vMoreButton setBackgroundColor:[UIColor lightGrayColor]];
//    [vMoreButton setTitle:@"更多" forState:UIControlStateNormal];
//    [vMoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [vMoreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [vMoreButton setTag:1002];
    
//    [menuContetnView addSubview:vDeleteButton];
//    [menuContetnView addSubview:vMoreButton];
    
    
    CustomButton *delButtonView = [[CustomButton alloc] initWithTitle:@"删除" iconImg:@"全部课件删除图标"];
    delButtonView.tag = DeleteViewTag;
//    [delButtonView addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [menuContetnView addSubview:delButtonView];
    [menuContetnView addSubview:vDeleteButton];
    
    [self.contentView insertSubview:menuContetnView atIndex:0];
    
    self.vPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.vPanGesture.delegate = self;
    [self.contentView addGestureRecognizer:self.vPanGesture];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CSLog(@"layoutSubviews:_moveContentView:%@",NSStringFromCGRect(self.contentView.frame));
    [_moveContentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    UIView *vMenuView = [self.contentView viewWithTag:100];
    vMenuView.frame =CGRectMake(self.frame.size.width - DELETE_BUTTON_WIDHT - MORE_BUTTON_WIDTH, 0, DELETE_BUTTON_WIDHT + MORE_BUTTON_WIDTH, self.frame.size.height);
    
//    UIView *vDeleteButton = [self.contentView viewWithTag:1001];
//    vDeleteButton.frame = CGRectMake(MORE_BUTTON_WIDTH, 0, DELETE_BUTTON_WIDHT, self.frame.size.height);
//    UIView *vMoreButton = [self.contentView viewWithTag:1002];
//    vMoreButton.frame = CGRectMake(0, 0, MORE_BUTTON_WIDTH, self.frame.size.height);
    
    //删除
    CustomButton *dBtnView = (CustomButton *)[vMenuView viewWithTag:DeleteViewTag];
    dBtnView.frame = CGRectMake(MORE_BUTTON_WIDTH, 0, DELETE_BUTTON_WIDHT, self.frame.size.height);
    
    UIButton *dbutton = (UIButton *)[vMenuView viewWithTag:DeleteButtonTag];
    dbutton.frame = CGRectMake(MORE_BUTTON_WIDTH, 0, DELETE_BUTTON_WIDHT, self.frame.size.height);

}

//此方法和下面的方法很重要,对ios 5SDK 设置不被Helighted
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // Configure the view for the selected state
    UIView *vMenuView = [self.contentView viewWithTag:100];
    if (vMenuView.hidden == YES) {
        [super setSelected:selected animated:animated];
        self.backgroundColor = [UIColor whiteColor];
    }
}
//此方法和上面的方法很重要，对ios 5SDK 设置不被Helighted
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    UIView *vMenuView = [self.contentView viewWithTag:100];
    if (vMenuView.hidden == YES) {
        [super setHighlighted:highlighted animated:animated];
    }
}

-(void)prepareForReuse{
    self.contentView.clipsToBounds = YES;
    [self hideMenuView:YES Animated:YES];
}


-(CGFloat)getMaxMenuWidth{
    return DELETE_BUTTON_WIDHT + MORE_BUTTON_WIDTH;
}

-(void)enableSubviewUserInteraction:(BOOL)aEnable{
    if (aEnable) {
        for (UIView *aSubView in self.contentView.subviews) {
            aSubView.userInteractionEnabled = YES;
        }
    }else{
        for (UIView *aSubView in self.contentView.subviews) {
            UIView *vDeleteButtonView = [self.contentView viewWithTag:100];
            if (aSubView != vDeleteButtonView) {
                aSubView.userInteractionEnabled = NO;
            }
        }
    }
}

-(void)hideMenuView:(BOOL)aHide Animated:(BOOL)aAnimate{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    CGRect vDestinaRect = CGRectZero;
    if (aHide) {
        vDestinaRect = self.contentView.frame;
        [self enableSubviewUserInteraction:YES];
    }else{
        vDestinaRect = CGRectMake(-[self getMaxMenuWidth], self.contentView.frame.origin.x, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self enableSubviewUserInteraction:NO];
    }
    
    CGFloat vDuration = aAnimate? 0.4 : 0.0;
    [UIView animateWithDuration:vDuration animations:^{
        _moveContentView.frame = vDestinaRect;
    } completion:^(BOOL finished) {
        if (aHide) {
            if ([_delegate respondsToSelector:@selector(didCellHided:)]) {
                [_delegate didCellHided:self];
            }
        }else{
            if ([_delegate respondsToSelector:@selector(didCellShowed:)]) {
                [_delegate didCellShowed:self];
            }
        }
        UIView *vMenuView = [self.contentView viewWithTag:100];
        vMenuView.hidden = aHide;
    }];
}


- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint vTranslationPoint = [gestureRecognizer translationInView:self.contentView];
        return fabs(vTranslationPoint.x) > fabs(vTranslationPoint.y);
    }
    return YES;
}

-(void)handlePan:(UIPanGestureRecognizer *)sender{

    if (sender.state == UIGestureRecognizerStateBegan) {
        startLocation = [sender locationInView:self.contentView].x;
        CGFloat direction = [sender velocityInView:self.contentView].x;
        if (direction < 0) {
            if ([_delegate respondsToSelector:@selector(didCellWillShow:)]) {
                [_delegate didCellWillShow:self];
            }
        }else{
            if ([_delegate respondsToSelector:@selector(didCellWillHide:)]) {
                [_delegate didCellWillHide:self];
            }
        }
    }else if (sender.state == UIGestureRecognizerStateChanged){
        CGFloat vCurrentLocation = [sender locationInView:self.contentView].x;
        CGFloat vDistance = vCurrentLocation - startLocation;
        startLocation = vCurrentLocation;

        CGRect vCurrentRect = _moveContentView.frame;
        CGFloat vOriginX = MAX(-[self getMaxMenuWidth] - BOUNENCE, vCurrentRect.origin.x + vDistance);
        vOriginX = MIN(0 + BOUNENCE, vOriginX);
        _moveContentView.frame = CGRectMake(vOriginX, vCurrentRect.origin.y, vCurrentRect.size.width, vCurrentRect.size.height);
        
        CGFloat direction = [sender velocityInView:self.contentView].x;
        CSLog(@"direction:%f",direction);
        CSLog(@"vOriginX:%f",vOriginX);
        if (direction < -40.0 || vOriginX <  - (0.5 * [self getMaxMenuWidth])) {
            hideMenuView = NO;
            UIView *vMenuView = [self.contentView viewWithTag:100];
            vMenuView.hidden = hideMenuView;
        }else if(direction > 20.0 || vOriginX >  - (0.5 * [self getMaxMenuWidth])){
            hideMenuView = YES;
        }
    }else if (sender.state == UIGestureRecognizerStateEnded){
        [self hideMenuView:hideMenuView Animated:YES];
    }
}


#pragma mark  点击更多
-(void)moreButtonClicked:(id)sender{
    if ([_delegate respondsToSelector:@selector(didCellClickedMoreButton:)]) {
        [_delegate didCellClickedMoreButton:self];
    }
}

#pragma mark 点击删除
-(void)deleteButtonClicked:(id)sender{
    [self.superview sendSubviewToBack:self];
    if ([_delegate respondsToSelector:@selector(didCellClickedDeleteButton:)]) {
        [_delegate didCellClickedDeleteButton:self];
    }
}

@end
