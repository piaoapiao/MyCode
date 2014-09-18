

#import <UIKit/UIKit.h>
#import "ZYSlider.h"
#import <AudioToolbox/AudioToolbox.h> 
#import <AVFoundation/AVFoundation.h>

typedef enum
{
    SELECT_LEFT,
    SELECT_RIGHT,
    SELECT_CENTER
}SelctState;

@protocol SliderViewDelegate <NSObject>
-(void)gotoAlbum;
-(void)goToSetting;

-(void)selectLeft;
-(void)selectCenter;
-(void)selectRight;
-(void)takePhoto;

@end


@interface ZYunCameraSliderView : UIView
{
    SystemSoundID soundID; 
}
@property (nonatomic,strong) UIButton *thumbBtn;
@property (nonatomic,strong) ZYSlider *slider;
@property (nonatomic,strong) UIButton *settingBtn;
@property (nonatomic,assign) id<SliderViewDelegate> delegate;
@property (nonatomic,assign) SelctState selectState;


@end


