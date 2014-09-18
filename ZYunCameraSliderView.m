

#import "ZYunCameraSliderView.h"

@interface ZYunCameraSliderView ()
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@end


@implementation ZYunCameraSliderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_backGroud.png"]];
        
        UILabel *leftLbl = [[UILabel alloc] initWithFrame:CGRectMake(85, 20, 40, 40)];
        leftLbl.font = [UIFont systemFontOfSize:10];
        leftLbl.textAlignment = UITextAlignmentCenter;
        leftLbl.backgroundColor = [UIColor clearColor];
        leftLbl.text =  ZYNSLocal(@"face",nil);
        [self addSubview:leftLbl];
        
        UILabel *rightLbl = [[UILabel alloc] initWithFrame:CGRectMake(194, 20, 40, 40)];
        rightLbl.font = [UIFont systemFontOfSize:10];
        rightLbl.textAlignment = UITextAlignmentCenter;        
        rightLbl.backgroundColor = [UIColor clearColor];
        rightLbl.text = ZYNSLocal(@"template",nil);
        [self addSubview:rightLbl];
        
        
        self.thumbBtn.frame = CGRectMake(26, 6, 48, 48);
        self.slider.frame =  CGRectMake(70, 0, 180, 50);
        
        self.settingBtn.frame = CGRectMake(246, 6, 48, 48);
        self.selectState = SELECT_CENTER;
        
        NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"Effect"
                                                              ofType:@"aif"];
        if (musicPath) {
            NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL
                                                                 error:nil];
        }

    }
    return self;
}



-(UIButton *)thumbBtn
{
    if(!_thumbBtn)
    {
        _thumbBtn = [[UIButton alloc] init];
        [_thumbBtn addTarget:self action:@selector(goToAlbum) forControlEvents:UIControlEventTouchUpInside];
        [_thumbBtn setBackgroundImage:[UIImage imageNamed:@"album_Btn.png"]
                               forState:UIControlStateNormal];
        [self addSubview:_thumbBtn];
    }
    return _thumbBtn;
}

-(void)goToAlbum
{
    if(_delegate && [_delegate respondsToSelector:@selector(gotoAlbum)])
    {
        [_delegate gotoAlbum];
    }
}

-(ZYSlider *)slider
{
    if(!_slider)
    {
        _slider = [[ZYSlider alloc] initWithFrame:CGRectMake(100, 0, 120, 50)];
        [_slider addTarget:self action:@selector(dragging) forControlEvents: UIControlEventTouchDown ];
        [_slider addTarget:self action:@selector(drain) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(drain) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:_slider];
    }
    return _slider;
}

-(void)dragging
{
    self.slider.isDragging = YES;
    NSLog(@"dragging");

    if( SELECT_CENTER ==  self.selectState)
    {
        
        [self.slider setThumbImage:[UIImage imageNamed:@"canmeraview_camerabtn_normal_light.png"] forState:UIControlStateNormal];

    }
    else 
    {
        [self.slider setThumbImage:[UIImage imageNamed:@"cameraview_camera_effct_light.png"] forState:UIControlStateNormal];    
    }
}

-(void)drain
{
    NSLog(@"drain Value:%f",self.slider.value);
    
    [self.slider setThumbImage:[UIImage imageNamed:@"canmeraview_camerabtn_normal_light.png"] forState:UIControlStateNormal];
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
    
    self.slider.isDragging  = NO;
    if(self.slider.value ==0 ||self.slider.value == 1)
    {
        [self.audioPlayer play];
    }
    
    if(self.slider.value ==0 )
    {

        [self.audioPlayer play];
        self.selectState = SELECT_LEFT;
        [self selectLeft];
    }
    
    if(self.slider.value ==1 )
    {
        [self.audioPlayer play];        
        self.selectState = SELECT_RIGHT;
        [self selectRight];
    }

    if(0.4<self.slider.value  && self.slider.value  <0.6 && self.selectState == SELECT_CENTER)
    {
        [self takePhoto];
    }
    
    if(0.4<self.slider.value  && self.slider.value  <0.6   && self.selectState != SELECT_CENTER)
    {
        [self.audioPlayer play];        
        self.selectState = SELECT_CENTER;
        [self selectCenter];
    }


    self.slider.value = 0.5;
    NSLog(@"drain");
    
}

-(void)takePhoto
{
    if(_delegate && [_delegate respondsToSelector:@selector(takePhoto)])
    {
        [_delegate takePhoto];
    }
}

-(void)selectLeft
{
    
     [self.slider setThumbImage:[UIImage imageNamed:@"cameraview_camera_effct_light.png"] forState:UIControlStateNormal];
    if(_delegate && [_delegate respondsToSelector:@selector(selectLeft)])
    {
        [_delegate selectLeft];
    }
}
//canmeraview_camerabtn_normal_light@2x.png
-(void)selectCenter
{
    [self.slider setThumbImage:[UIImage imageNamed:@"canmeraview_camerabtn_normal.png"] forState:UIControlStateNormal];    
    if(_delegate && [_delegate respondsToSelector:@selector(selectCenter)])
    {
        [_delegate selectCenter];
    }
}

-(void)selectRight
{
    [self.slider setThumbImage:[UIImage imageNamed:@"cameraview_camera_effct_light.png"] forState:UIControlStateNormal];
    if(_delegate && [_delegate respondsToSelector:@selector(selectRight)])
    {
        [_delegate selectRight];
    }
}

-(UIButton *)settingBtn
{
    if(!_settingBtn)
    {
        _settingBtn = [[UIButton alloc] init];
        [_settingBtn addTarget:self action:@selector(goToSetting) forControlEvents:UIControlEventTouchUpInside];
        [_settingBtn setBackgroundImage:[UIImage imageNamed:@"setting_Btn.png"]
                               forState:UIControlStateNormal];
        [self addSubview:_settingBtn];
    }
    return _settingBtn;
}

-(void)goToSetting
{
    if(_delegate && [_delegate respondsToSelector:@selector(goToSetting)])
    {
        [_delegate goToSetting];
    }
}



@end
