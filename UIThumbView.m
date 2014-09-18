

#import "UIThumbView.h"

@implementation UIThumbView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

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

-(UIImageView *)thumbView
{
    if(!_thumbView)
    {
        _thumbView = [[UIImageView alloc] init];
        _thumbView.layer.borderWidth = 1;
        _thumbView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _thumbView.userInteractionEnabled = YES;
        [self addSubview:_thumbView];
    }
    return _thumbView;
}

-(void)setImage:(UIImage *)image
{
    self.thumbView.image = image;
    _image = image;
}


-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.thumbView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.selectBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height); 
    
}

-(UIButton *)selectBtn
{
    if(!_selectBtn)
    {
        _selectBtn = [[UIButton alloc] init];
        [_selectBtn addTarget:self action:@selector(selectWhich:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectBtn];
    }
     return  _selectBtn;
}

-(void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    self.selectBtn.tag = tag;
}

-(void)selectWhich:(UIButton *)sender
{
    NSLog(@"select:%d",[sender tag]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectImage" object:[NSNumber numberWithInt:sender.tag]];
    
    
}
@end
