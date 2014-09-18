

#import <UIKit/UIKit.h>
#import "UIThumbView.h"

@class ThumbsScrollView;
@protocol ThumbsScrollViewDelegate <NSObject>
@optional
-(int)numberOfThumbsInScrollView;

-(UIThumbView *)thumbViewForScrollView:(ThumbsScrollView *)thumbsView  index:(NSNumber *)index;

@end

 
@interface ThumbsScrollView : UIScrollView <ThumbsScrollViewDelegate>
@property (nonatomic,strong) NSMutableSet *cacheSet;

@property (nonatomic,assign) int numberOfThumb;

@property (nonatomic,assign) id<ThumbsScrollViewDelegate> controller;


-(id)dequeneReusedThumbView;
-(void)layoutSubviews;
-(CGFloat)bottomOffset;
@end





