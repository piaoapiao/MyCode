

#import "ZYCameraManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageCVMatConverter.h"
#import "CIFaceOriention.h"
#import "GlobalData.h"

static ZYCameraManager *cameraManager;

@interface ZYCameraManager()<AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureVideoDataOutput *frameOutput;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIDetector *faceDetector;
@end

@implementation ZYCameraManager
@synthesize resizeImage;
@synthesize frameOutput = _frameOutput;
@synthesize context = _context;
@synthesize faceDetector = _faceDetector;

-(CIContext *)context {
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

+(id)cameraManager
{
    if(!cameraManager)
    {
        cameraManager = [[ZYCameraManager alloc] init];
    }
    return cameraManager;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [self setupSession];
        [self setUpVideoPreviewLayer];
        [self sessionRuning];
        NSDictionary *detectorOptions = [NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyLow ,CIDetectorAccuracy, nil];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    }
    return self;
}

- (void)setupSession
{
    // Set torch and flash mode to auto
	if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	if ([[self backFacingCamera] hasTorch]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeAuto]) {
				[[self backFacingCamera] setTorchMode:AVCaptureTorchModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	
    // Init the device inputs
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:nil];
    
    // Setup the still image file output
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [newStillImageOutput setOutputSettings:outputSettings];
    
    // Create session (use default AVCaptureSessionPresetHigh)
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    newCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.frameOutput = [[AVCaptureVideoDataOutput alloc]init];
    self.frameOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    self.frameOutput.alwaysDiscardsLateVideoFrames = YES;
    
    [self.frameOutput setSampleBufferDelegate:(id)self queue:dispatch_get_main_queue()];
    //[self.session addOutput:self.frameOutput];
    [self setFrameOutput:self.frameOutput];
    
    [newCaptureSession addOutput:self.frameOutput];
    // Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    if ([newCaptureSession canAddOutput:newStillImageOutput]) {
        [newCaptureSession addOutput:newStillImageOutput];
    }
    
    [self setStillImageOutput:newStillImageOutput];
    [self setVideoInput:newVideoInput];
    [self setSession:newCaptureSession];

}

-(void)setUpVideoPreviewLayer
{
        self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self session]];
        [self.captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        self.faceLayer = [[CALayer alloc] init];
        UIImage *image = [UIImage imageNamed:@"face.png"];
        self.faceLayer.contents = (id)image.CGImage;
   
        [self.captureVideoPreviewLayer addSublayer:self.faceLayer];
}

-(void)sessionRuning
{
    [self.session startRunning];
}

-(void)sessionStopRuning
{
    [self.session stopRunning];
}

#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
    [GlobalData shareData].isFrontCamera=YES;
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    [GlobalData shareData].isFrontCamera=NO;
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Toggle between the front and back camera, if both are present.
- (void)toggleCamera
{
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[self.videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        
        if (newVideoInput != nil) {
            [[self session] beginConfiguration];
            [[self session] removeInput:[self videoInput]];
            if ([[self session] canAddInput:newVideoInput]) {
                [[self session] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [[self session] addInput:[self videoInput]];
            }
            [[self session] commitConfiguration];
        }
    }
}


-(AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}
-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage  = [[CIImage alloc]initWithCVPixelBuffer:pb options:(__bridge  NSDictionary*)attachments];
    if (attachments) {
        CFRelease(attachments);
    }
     NSArray *features = [self.faceDetector featuresInImage:ciImage
                                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6]
                                                                                       forKey:CIDetectorImageOrientation]];
    if ([features count]==0) {
        self.faceLayer.hidden=YES;
    }else {
        self.faceLayer.hidden=NO;
    }
  
    for (CIFaceFeature *face in features) {
       
        CGRect faceRect = [face bounds];
        CGFloat temp = faceRect.size.width;
		faceRect.size.width = faceRect.size.height;
		faceRect.size.height = temp;
		temp = faceRect.origin.x;
        faceRect.origin.y=ciImage.extent.size.height-faceRect.size.height-faceRect.origin.y;
        faceRect.origin.x = faceRect.origin.y;
        faceRect.origin.y = temp;
        CGFloat widthScaleBy = self.captureVideoPreviewLayer.bounds.size.width / ciImage.extent.size.height;
		CGFloat heightScaleBy =self.captureVideoPreviewLayer.bounds.size.height / ciImage.extent.size.width;
        faceRect.origin.x*=widthScaleBy;
        faceRect.origin.y *=heightScaleBy;
        faceRect.size.width*=widthScaleBy;
        faceRect.size.height*=heightScaleBy;
        self.faceLayer.frame=faceRect;
    
        
    }

}

-(void)captureStillImage
{
    AVCaptureConnection *stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef  imageDataSampleBuffer, NSError *error) {
															 if (imageDataSampleBuffer != NULL) {
																 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];

                                                                 if([[self.videoInput device] position] == AVCaptureDevicePositionFront)
                                                                 {
                                                                     image = [image rotateInRadians:-3.14/2];
                                                                     
                                                                     image = [UIImage imageWithCGImage:[image CGImage]
                                                                                                 scale:1.0
                                                                                           orientation: UIImageOrientationUp];
                                                                     image = [image horizontalFlip];
                                                                     resizeImage=[UIImageCVMatConverter scaleAndRotateImageFrontCamera:image];
                                                                 }
                                                                 else {
                                                                   resizeImage=[UIImageCVMatConverter scaleAndRotateImageBackCamera:image];
                                                                 }
                                                                 self.captureImage =resizeImage;
                                                                 //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
															  }
													 [self sessionStopRuning];
															 if ([[self delegate] respondsToSelector:@selector(captureStillImage:)]){
																 [[self delegate] captureStillImage:self];
                                                             }
                                                         }];
    
}


@end
