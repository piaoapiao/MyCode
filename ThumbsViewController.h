

#import <UIKit/UIKit.h>
#import "ThumbsScrollView.h"
#import "BaseCustomNavBarViewController.h"

@protocol SelectPhoteDelegate <NSObject>

-(void)selectedPhoto:(UIImage *)image;

@end
 
@interface ThumbsViewController: BaseCustomNavBarViewController <ThumbsScrollViewDelegate>
@property (nonatomic,strong) ThumbsScrollView *thumbsScrollView;
@property (nonatomic,assign) id<SelectPhoteDelegate> delegate;
@end
