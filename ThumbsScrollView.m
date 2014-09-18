

#import "ThumbsScrollView.h"


@interface ThumbsScrollView()

@property (nonatomic,assign) float pading;

@property (nonatomic,assign) int lineNum;

@property (nonatomic,assign) int rowNum;

@property (nonatomic,assign) float thumbWidth;

@end

@implementation ThumbsScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pading = 10;
        self.lineNum = 3;
        self.scrollEnabled = YES;
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"big_backGround.png"]];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(CGFloat)bottomOffset
{
    int photoNum = [[ZYAlbumData shareAlbumData] numberOfPhoto];
    
    CGFloat yoffset = ceilf(photoNum/3.0)*(self.pading + self.thumbWidth) + self.pading -self.frame.size.height;
    
    return yoffset;
}


-(void)layoutSubviews
{
    NSLog(@"call layoutSubviews");
//    if(![self.cacheSet anyObject])
//    {
//        [self queneReusedImageView];
//    }
    
    if(_controller && [_controller respondsToSelector:@selector(numberOfThumbsInScrollView)])
    {
        self.numberOfThumb = [_controller numberOfThumbsInScrollView];
    }
    CGRect visionBounds = self.bounds;
    
    int topRow = floorf(CGRectGetMinY(visionBounds)/(self.thumbWidth + 10));
    
    topRow = MAX(0, topRow);
    
    
    int bottomRow = ceilf(CGRectGetMaxY(visionBounds)/(self.thumbWidth + 10));
    
    
    float rowNumber = self.lineNum;
    
    int totalRow = ceilf([[ZYAlbumData shareAlbumData] numberOfPhoto]/rowNumber);
    
    self.contentSize = CGSizeMake(320,totalRow*(self.thumbWidth + self.pading) + self.pading);
    
    //去除看不到的UIImageView
    
   
    for(UIView *item in self.subviews)
    {
        if([item isKindOfClass:[UIThumbView class]])
        {
            CGRect temp =   CGRectIntersection(item.frame, visionBounds);
            
            if( CGRectIsNull(temp))
            {
                [self.cacheSet addObject:item];
                [item removeFromSuperview];
            }
        }
        else
        {
            //盛大bug
            NSLog(@"item:%@",item);
            NSLog(@"item:%@",item);
        }

    }
    
    // layout thumbView
    
    int firstIndex = topRow*self.lineNum;
    
    int lastIndex =  MIN([[ZYAlbumData shareAlbumData] numberOfPhoto], bottomRow*self.lineNum);
    
    for(int i = firstIndex;i<lastIndex;i++)
    {
        if(![self isExistImageView:i])
        {
        
            UIThumbView *thumbView = [self.controller thumbViewForScrollView:self index:[NSNumber numberWithInt:i]];
            
            int row = i/self.lineNum;
            
            int line = i%(self.lineNum);
            
            thumbView.frame = CGRectMake(line*(_thumbWidth + _pading) + _pading, row*(_thumbWidth + _pading) + _pading, self.thumbWidth, self.thumbWidth);
            
            if([thumbView isKindOfClass:[UIImageView class]])
            {
                NSLog(@"thumbView:%@",thumbView);
            }
            [self addSubview:thumbView];
        }
    }
    

    
}

-(BOOL)isExistImageView:(int) tag
{
    for(UIImageView *item in self.subviews)
    {
        if([item tag]  == tag && [item isKindOfClass:[UIThumbView class]])
        {
            item.image = [[ZYAlbumData shareAlbumData] thumbImageAtIndex:tag];
            return YES;
        }
    }
    return NO;
}




-(id)dequeneReusedThumbView
{
    UIThumbView *thumb = [self.cacheSet anyObject];
    if(thumb)
    {
        [self.cacheSet removeObject:thumb];
    }
    return thumb;
}


-(NSMutableSet *)cacheSet
{
    if(!_cacheSet)
    {
        _cacheSet = [[NSMutableSet alloc] init];
    }
    return _cacheSet;
}

-(float)thumbWidth
{
    _thumbWidth = (320-self.pading)/self.lineNum -self.pading;
    return _thumbWidth;
}


@end
