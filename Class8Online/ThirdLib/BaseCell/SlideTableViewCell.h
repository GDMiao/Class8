

#import <UIKit/UIKit.h>

@protocol SlideTableViewCellDelegate <NSObject>

@optional
-(void)didCellWillHide:(id)aSender;
-(void)didCellHided:(id)aSender;
-(void)didCellWillShow:(id)aSender;
-(void)didCellShowed:(id)aSender;
-(void)didCellClickedDeleteButton:(id)aSender;
-(void)didCellClickedMoreButton:(id)aSender;
@end

@interface SlideTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>
{
    CGFloat startLocation;
    BOOL    hideMenuView;
}



@property (strong, nonatomic) IBOutlet UIView *moveContentView;

@property (nonatomic,assign) id<SlideTableViewCellDelegate> delegate;
@property (nonatomic, strong) UIPanGestureRecognizer *vPanGesture;
-(void)hideMenuView:(BOOL)aHide Animated:(BOOL)aAnimate;
-(void)addControl;
@end
