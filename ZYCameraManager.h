

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GlobalData.h"
@class ZYCameraManager;
@protocol AVCamCaptureManagerDelegate <NSObject>
@optional
- (void)captureStillImage:(ZYCameraManager *)captureManager;
@end

@interface ZYCameraManager : NSObject
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,strong) CALayer *faceLayer ;

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) UIImage *captureImage;
@property (nonatomic,strong)  UIImage *resizeImage;;
@property (nonatomic,weak) id<AVCamCaptureManagerDelegate> delegate;

+(id)cameraManager;
-(void)toggleCamera;
-(void)captureStillImage;
-(void)sessionRuning;
-(void)sessionStopRuning;




@end
