//
//  VideoRecord.m
//  CAP
//
//  Created by chuliangliang on 15/7/2.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "VideoRecord.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CameraSlider.h"

#define MAX_PINCH_SCALE_NUM   6.f
#define MIN_PINCH_SCALE_NUM   1.f

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface VideoRecord ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureSession* _avCaptureSession;
    AVCaptureDevice *avCaptureDevice;
    BOOL firstFrame;	//是否为第一帧

    dispatch_queue_t videoCoverQueue;
    CameraSlider *cameraSlider;
    
    UIImageView *leftIcon;
    UIImageView *rightIcon;
    
    
//    int videoCount;
//    NSMutableData *videoData;

}
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic, retain) AVCaptureSession *avCaptureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer* previewLayer;
@property (retain, nonatomic) UIImageView *focusCursor; //聚焦光标
@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;
@property (nonatomic, strong) AVCaptureVideoDataOutput *avCaptureVideoDataOutput;
@property (assign, nonatomic) AVCaptureVideoOrientation videoPortaint; //视频方向 默认竖屏


@end

@implementation VideoRecord
@synthesize previewLayer;
@synthesize videoInput;
@synthesize avCaptureVideoDataOutput;
@synthesize videoPortaint;
- (void)dealloc {
    self.delegate = nil;
    self.videoPreview = nil;
    self.pullAwayAndNearlyPinch = nil;
    
}

-(id)init
{
    if(self = [super init])
    {
//        videoCount = 0;
        
        firstFrame = YES;
        self.producerFps = 10;
        _scaleNum = 1.f;
        _preScaleNum = 1.f;

        videoCoverQueue = dispatch_queue_create("my queque", DISPATCH_QUEUE_SERIAL); //串行队列进先出
        
        self.focusCursor = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 90)];
        self.focusCursor.image = [UIImage imageNamed:@"touch_focus"];
        self.focusCursor.alpha = 0;
        self.hasCameraPullAwayAndNearly = YES;
        self.hasFocusCursorWithTap = YES;
    }
    return self;
}

#pragma mark -
#pragma mark VideoCapture <获取摄像头>
- (AVCaptureDevice *)getFrontCameraWithPosition:(AVCaptureDevicePosition )position
{
    //获取前置摄像头设备
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras)
    {
        if (device.position == position)
            return device;
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
}


- (void)setp
{
    
    videoPortaint = [[UIDevice currentDevice] orientation];
    //打开摄像设备，并开始捕抓图像
    if(self->avCaptureDevice || self.avCaptureSession)
    {
        
        CLVideoLog(@"Already capturing");
        return;
    }
    
    if((self->avCaptureDevice = [self getFrontCameraWithPosition:AVCaptureDevicePositionFront]) == nil)
    {
        CLVideoLog(@"Failed to get valide capture device");
        
        return;
    }
    
    if ( YES == [avCaptureDevice lockForConfiguration:NULL] )
    {
        CLVideoLog(@"producerFps: %d",self.producerFps);
        [avCaptureDevice setActiveVideoMinFrameDuration:CMTimeMake(1,self.producerFps)];
        [avCaptureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1,self.producerFps)];
        [avCaptureDevice unlockForConfiguration];
    }
    CLVideoLog(@"FPS: %d",self.producerFps);

    NSError *error = nil;
    videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self->avCaptureDevice error:&error];
    if (!videoInput)
    {
        CLVideoLog(@"Failed to get video input");
        self->avCaptureDevice = nil;
        return;
    }

    
    
    self.avCaptureSession = [[AVCaptureSession alloc] init];
    self.avCaptureSession.sessionPreset = AVCaptureSessionPreset352x288;//AVCaptureSessionPreset640x480//AVCaptureSessionPreset352x288
    [self.avCaptureSession addInput:videoInput];
    
    
    avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                              /*[NSNumber numberWithInt:240], (id)kCVPixelBufferWidthKey,*/
                              /*[NSNumber numberWithInt:320], (id)kCVPixelBufferHeightKey,*/
                              nil];
    avCaptureVideoDataOutput.videoSettings = settings;
    dispatch_queue_t queue = dispatch_queue_create("videoCaptureQueque", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [self.avCaptureSession addOutput:avCaptureVideoDataOutput];
    
    if (self.videoPreview) {
        self.videoPreview.clipsToBounds = YES;
        previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.avCaptureSession];
        previewLayer.frame = self.videoPreview.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//AVLayerVideoGravityResizeAspect; //AVLayerVideoGravityResizeAspectFill
        [self.videoPreview.layer addSublayer: previewLayer];
        
        [self.videoPreview addSubview:self.focusCursor];
    }
    
    self->firstFrame = YES;
    
    //视频方向
    [self.avCaptureSession beginConfiguration];
    [self updateVideoPortait];
    [self.avCaptureSession commitConfiguration];
    self.capTureFlashOn = NO;
    _swichCaptureBack = YES;

}
/**
 *更新摄像头刷新频率及图像方向
 **/
- (void)updateVideoPortait
{
    AVCaptureConnection *videoConnection = NULL;
    
    for ( AVCaptureConnection *connection in [avCaptureVideoDataOutput connections] )
    {
        for ( AVCaptureInputPort *port in [connection inputPorts] )
        {
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                    connection.videoMinFrameDuration = CMTimeMake(1,self.producerFps);
            }
        }
    }
    if([videoConnection isVideoOrientationSupported]) // **Here it is, its always false**
    {
        [videoConnection setVideoOrientation:videoPortaint];
//        [videoConnection setVideoOrientation:videoPortaint];
    }
}

/**
 * 外部调用 用来更新摄像头方向信息
 **/
- (void)refreshCameraDevicePortait
{
    videoPortaint = [[UIDevice currentDevice] orientation];
    [self.avCaptureSession beginConfiguration];
    [self updateVideoPortait];
    [self.avCaptureSession commitConfiguration];

}
//修改输出设备的分辨率
- (void)changeSessionPreset:(VideoSize)sessionPreset
{
    NSString *sessionString = AVCaptureSessionPreset352x288;
    switch (sessionPreset) {
        case VideoSize_288_352:
        {
            sessionString = AVCaptureSessionPreset352x288;
        }
            break;
        case VideoSize_480_640:
        {
            sessionString = AVCaptureSessionPreset640x480;
        }
            break;
        case VideoSize_720_1280:
        {
            sessionString = AVCaptureSessionPreset1280x720;
        }
            break;
        default:
            break;
    }
    [self.avCaptureSession beginConfiguration];
    self.avCaptureSession.sessionPreset = sessionString;
    [self updateVideoPortait];
    [self.avCaptureSession commitConfiguration];
}

//视频采集
- (void)startVideoCapture
{
    if (!self.avCaptureSession) {
        [self setp];
        [self addGenstureRecognizer];
        if (IS_IOS7) {
            [self addPinchGestureAtView:self.videoPreview];
        }
    }
    [self.avCaptureSession startRunning];
    CLVideoLog(@"Video capture started");
}

- (void)stopVideoCapture;
{
    //停止摄像头捕抓
    if(self.avCaptureSession){
        [self.avCaptureSession stopRunning];
        self.avCaptureSession = nil;
        CLVideoLog(@"Video capture stopped");
    }
    self->avCaptureDevice = nil;
    //移除视频预览view 所有字视图
    [self.videoPreview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView *)obj removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    static UInt8 * pTempBuf  = NULL;
    /*
    // 保存图像
    UIImage *img = [self imageFromSamplePlanerPixelBuffer:sampleBuffer];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString * imgName = [NSString stringWithFormat:@"视频图片%@.jpg",dateString];
    
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *jpgPath = [docsDir stringByAppendingPathComponent:imgName];
    if ([UIImageJPEGRepresentation(img, 1.0) writeToFile:jpgPath atomically:YES]) {
        CSLog(@"图片保存成功..................................................");
    }*/
    
    if ([connection.output isKindOfClass:[AVCaptureVideoDataOutput class]]) {
        // 视频图像
        //取出图像数据
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        /*Lock the buffer*/
        if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess)
        {
            //视频图像数据
            UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,0);
            size_t width = CVPixelBufferGetWidth(pixelBuffer);
            size_t height = CVPixelBufferGetHeight(pixelBuffer);
//            OSType vType = CVPixelBufferGetPixelFormatType(pixelBuffer);
            size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);
//            size_t bytePerHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer,0);
            if(bytesPerRow != width)
            {
                
                if(pTempBuf == NULL)
                {
                    pTempBuf = (UInt8 *)malloc(width * height *3);
                }
                if(pTempBuf)
                {
                    int nSrcStep = bytesPerRow;
                    int nDestStep = width;
                    UInt8 * pYDest = pTempBuf;
                    UInt8 * pYSrc = bufferPtr;
                    
                    UInt8 * pUVDest = pTempBuf + width * height ;
                    UInt8 * pUVSrc = bufferPtr + bytesPerRow * height;
//                    int nDiff = (bytesPerRow - width) ;
                    for(int i = 0;i<height;i++)
                    {
                        memcpy(pYDest,pYSrc,nDestStep);
                        pYDest += nDestStep;
                        pYSrc += nSrcStep;
                        if(i % 2 == 0)
                        {
                            memcpy(pUVDest,pUVSrc,nDestStep);
                            pUVDest += nDestStep ;
                            pUVSrc +=  nSrcStep ;
                        }
                        
                    }
                    bufferPtr = pTempBuf;
                }
            }

           /* if (!videoData) {
                videoData = [[NSMutableData alloc]init];
            }
            printf("\n*******video:%d\n\n\n\n",videoCount);
            if (videoCount < 300 && videoCount > 50) {
                UInt8 *pixeBuffer = bufferPtr;
                NSMutableData *writer1 = [[NSMutableData alloc] init];
                [writer1 appendBytes:pixeBuffer length:bytesPerRow*bytePerHeight*3/2];
                [videoData appendData:writer1];
            }else if (videoCount == 300){
                NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docsDir = [dirPaths objectAtIndex:0];
                NSString *savedPath = [docsDir stringByAppendingPathComponent:@"1400----"];
                BOOL savesuccess = [videoData writeToFile:savedPath atomically:YES];
                if (savesuccess) {
                    printf("OK---------------------------");
                }
            }
            videoCount ++;*/
            

            
            CLVideoLog(@"录制回调:(%zu,%zu)",width,height);
//             NV21 To YUV 不需要转换格式
//            UInt8 *pixeBuffer = NV21ToYUV420(bufferPtr, width, height);
            if ([self.delegate respondsToSelector:@selector(videoRecordRecVideo:videoWidth:videoHeight:)]) {
                [self.delegate videoRecordRecVideo:bufferPtr videoWidth:width videoHeight:height];
            }
            
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        }
        
    }else if ([connection.output isKindOfClass:[AVCaptureAudioDataOutput class]]) {
        
        
    }
}


/*
-(UIImage *) imageFromSamplePlanerPixelBuffer:(CMSampleBufferRef) sampleBuffer{
    
    @autoreleasepool {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get the number of bytes per row for the plane pixel buffer
        void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        
        // Get the number of bytes per row for the plane pixel buffer
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
        size_t bytePerHeight = CVPixelBufferGetHeightOfPlane(imageBuffer,0);
        // Get the pixel buffer width and height
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent gray color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        // Create a bitmap graphics context with the sample buffer data
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGImageAlphaNone);
        // Create a Quartz image from the pixel data in the bitmap graphics context
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Free up the context and color space
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        // Create an image object from the Quartz image
        UIImage *image = [UIImage imageWithCGImage:quartzImage];
        
        // Release the Quartz image
        CGImageRelease(quartzImage);
        
        return (image);
    }
}
*/

/*
// 弃用
UInt8* NV21ToYUV420(unsigned char *nv21, size_t nWidth, size_t nHeight)
{
    UInt8 *yuv;
    int j;
    unsigned char* dstY,*dstU, *dstV, *srcUV;
    size_t nSize = nWidth*nHeight;
    size_t nSizeU = nSize>>2;
    yuv = (unsigned char*)malloc(nWidth*nHeight*3/2);
    
    
    srcUV = nv21+nSize;
    dstY = yuv;
    dstU = yuv+nWidth*nHeight;
    dstV = dstU+nSizeU;
    
    memcpy(yuv, nv21, nWidth*nHeight);
    // Y is same
    for(j = 0; j<nSizeU; j++)
    {
        dstU[j] = srcUV[j*2];
        dstV[j] = srcUV[j*2+1];
    }
    
    return yuv;
}
*/


- (void)setCapTureFlashOn:(BOOL)capTureFlashOn {
    _capTureFlashOn = capTureFlashOn;
    [self switchCaptureFlash:capTureFlashOn];
}

- (void)setSwichCaptureBack:(BOOL)swichCaptureBack
{
    _swichCaptureBack = swichCaptureBack;
    [self changeCaptureDevice:swichCaptureBack];
}
/**
 * 摄像头拉近 每次拉近 0.03
 **/
- (void)setCameraAddNearly:(CGFloat)cameraAddNearly {
    _scaleNum += cameraAddNearly;
    if (_scaleNum < MIN_PINCH_SCALE_NUM) {
        _scaleNum = MIN_PINCH_SCALE_NUM;
    }
    else if (_scaleNum > MAX_PINCH_SCALE_NUM) {
        _scaleNum = MAX_PINCH_SCALE_NUM;
    }
    _cameraAddNearly = _scaleNum;

    [self doPinch];
}
/**
 * 摄像头拉远 每次拉远 0.03
 **/
- (void)setCameraPullAway:(CGFloat)cameraPullAway {
     _scaleNum -= cameraPullAway;
    if (_scaleNum < MIN_PINCH_SCALE_NUM) {
        _scaleNum = MIN_PINCH_SCALE_NUM;
    }
    else if (_scaleNum > MAX_PINCH_SCALE_NUM) {
        _scaleNum = MAX_PINCH_SCALE_NUM;
    }
    _cameraPullAway = _scaleNum;
    [self doPinch];
}

////////////////////////////////////////////////////////////////////////////////////
//=========================================
//TODO: 设置属性的通用方法
//=========================================
/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange
{
    AVCaptureDevice *captureDevice= [videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        CLVideoLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

//=========================================
//TODO: 开启关闭闪光灯
//=========================================
/**
 * 设置闪光灯模式 开启/关闭
 **/
-(void)switchCaptureFlash:(BOOL)On
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        AVCaptureFlashMode flashMode;
        AVCaptureTorchMode torchMode;
        if (!On) {
            //开启闪光灯
            flashMode = AVCaptureFlashModeOff;
            torchMode = AVCaptureTorchModeOff;

        }else {
            //关闭闪光灯
            flashMode = AVCaptureFlashModeOn;
            torchMode = AVCaptureTorchModeOn;
        }
        
        if ([captureDevice isTorchModeSupported:torchMode]) {
            [captureDevice setTorchMode:torchMode];
        }
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}


/**
 * 切换摄像头
 **/
- (void)changeCaptureDevice:(BOOL)back {
    CATransition *tran = [CATransition animation];
    tran.duration = 0.5f;
    tran.type = @"oglFlip";
    tran.subtype = kCATransitionFromRight;
//    [self.videoPreview exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.videoPreview.layer addAnimation:tran forKey:@"animation"];

    
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    
    if (back) {
        toChangePosition=AVCaptureDevicePositionBack;
    }else {
        toChangePosition=AVCaptureDevicePositionFront;
        _capTureFlashOn = NO;
    }
    toChangeDevice=[self getFrontCameraWithPosition:toChangePosition];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.avCaptureSession beginConfiguration];
    //移除原有输入对象
    [self.avCaptureSession removeInput:videoInput];
    //添加新的输入对象
    if ([self.avCaptureSession canAddInput:toChangeDeviceInput]) {
        [self.avCaptureSession addInput:toChangeDeviceInput];
        videoInput = toChangeDeviceInput;
    }
    [self updateVideoPortait];
    //提交会话配置
    [self.avCaptureSession commitConfiguration];
}

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    
    if (!self.tapGesture) {
        self.tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
        [self.videoPreview addGestureRecognizer:self.tapGesture];
    }
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
        
    CGPoint point= [tapGesture locationInView:self.videoPreview];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [previewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    
    [self.focusCursor stopAnimating];
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
//    self.focusCursor.alpha=1.0;
//    [UIView animateWithDuration:1.0 animations:^{
//        self.focusCursor.transform=CGAffineTransformIdentity;
//    } completion:^(BOOL finished) {
//        self.focusCursor.alpha=0;
//        
//    }];
    
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.focusCursor.alpha = 1.f;
        self.focusCursor.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.focusCursor.alpha = 0.f;
        } completion:nil];
    }];

}

/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}


//伸缩镜头的手势
- (void)addPinchGestureAtView:(UIView *)view {
    if (!self.pullAwayAndNearlyPinch) {
        self.pullAwayAndNearlyPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [view addGestureRecognizer:self.pullAwayAndNearlyPinch];
    }
    
    //竖向
    CGFloat height = 40;
    CGFloat width = self.videoPreview.bounds.size.width - 60;;
    cameraSlider = [[CameraSlider alloc] initWithFrame:CGRectMake((self.videoPreview.bounds.size.width - width ) * 0.5,self.videoPreview.bounds.size.height - height, width, height) direction:CameraSliderDirectionHorizonal];
    cameraSlider.alpha = 0.f;
    cameraSlider.minValue = MIN_PINCH_SCALE_NUM;
    cameraSlider.maxValue = MAX_PINCH_SCALE_NUM;
    
    [cameraSlider buildDidChangeValueBlock:^(CGFloat value) {
        [self pinchCameraViewWithScalNum:value];
    }];
    [cameraSlider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [self setSliderAlpha:isTouchEnd];
    }];
    
    
    leftIcon = [[UIImageView alloc] initWithFrame:CGRectMake(cameraSlider.left - 11,cameraSlider.top + (cameraSlider.height - 2) * 0.5, 9, 2)];
    leftIcon.image = [UIImage imageNamed:@"减"];
    
    rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(cameraSlider.right - 2,cameraSlider.top + (cameraSlider.height - 9) * 0.5, 9, 9)];
    rightIcon.image = [UIImage imageNamed:@"加"];
    
    leftIcon.alpha = 0.f;
    rightIcon.alpha = 0.f;

    [self.videoPreview addSubview:rightIcon];
    [self.videoPreview addSubview:leftIcon];
    [self.videoPreview addSubview:cameraSlider];
}

//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
        if (videoInput.device.activeFormat.videoMaxZoomFactor == MIN_PINCH_SCALE_NUM) {
        return;
    }
    [self pinchCameraView:gesture];
    if (cameraSlider) {
        if (cameraSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                cameraSlider.alpha = 1.f;
                leftIcon.alpha = 1.f;
                rightIcon.alpha = 1.f;
            }];
        }
        [cameraSlider setValue:_scaleNum shouldCallBack:NO];
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [self setSliderAlpha:YES];
        }
        else {
            [self setSliderAlpha:NO];
        }
    }
}

- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (cameraSlider) {
        cameraSlider.isSliding = !isTouchEnd;
        if (cameraSlider.alpha != 0.f && !cameraSlider.isSliding) {
            double delayInSeconds = 3.88;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (cameraSlider.alpha != 0.f && !cameraSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        cameraSlider.alpha = 0.f;
                        leftIcon.alpha = 0.f;
                        rightIcon.alpha = 0.f;
                    }];
                }
            });
        }
    }
}


/**
 *  拉近拉远镜头
 *
 *  @param scale 拉伸倍数
 */
- (void)pinchCameraViewWithScalNum:(CGFloat)scale {
    _scaleNum = scale;
    if (_scaleNum < MIN_PINCH_SCALE_NUM) {
        _scaleNum = MIN_PINCH_SCALE_NUM;
    }
    else if (_scaleNum > MAX_PINCH_SCALE_NUM) {
        _scaleNum = MAX_PINCH_SCALE_NUM;
    }
    [self doPinch];
    _preScaleNum = scale;
}

- (void)pinchCameraView:(UIPinchGestureRecognizer *)gesture {
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [gesture numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [gesture locationOfTouch:i inView:self.videoPreview];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if (![self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    if ( allTouchesAreOnThePreviewLayer ) {
        _scaleNum = _preScaleNum * gesture.scale;
        if (_scaleNum < MIN_PINCH_SCALE_NUM) {
            _scaleNum = MIN_PINCH_SCALE_NUM;
        }
        else if (_scaleNum > MAX_PINCH_SCALE_NUM) {
            _scaleNum = MAX_PINCH_SCALE_NUM;
        }
        [self doPinch];
    }
    
    if ([gesture state] == UIGestureRecognizerStateEnded ||
        [gesture state] == UIGestureRecognizerStateCancelled ||
        [gesture state] == UIGestureRecognizerStateFailed) {
        _preScaleNum = _scaleNum;
        CLVideoLog(@"final scale: %f", _scaleNum);
    }
}

- (void)doPinch {

    CGFloat maxZoom = MAX_PINCH_SCALE_NUM;
    if ([videoInput.device lockForConfiguration:nil])
    {
        maxZoom = videoInput.device.activeFormat.videoMaxZoomFactor;
        if (_scaleNum > maxZoom) {
            _scaleNum = maxZoom;
        }
//        [videoInput.device rampToVideoZoomFactor:maxZoom withRate:1];
        videoInput.device.videoZoomFactor = _scaleNum;
        [videoInput.device unlockForConfiguration];
    }

    
    
//    AVCaptureConnection *videoConnection = [self findVideoConnection];
//    CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;//videoScaleAndCropFactor这个属性取值范围是1.0-videoMaxScaleAndCropFactor。iOS5+才可以用
//    CLVideoLog(@"镜头拉伸:%f 镜头最大拉伸:%f",_scaleNum,maxScale);
//
//    if (_scaleNum > maxScale) {
//        _scaleNum = maxScale;
//    }
    
//    videoConnection.videoScaleAndCropFactor = _scaleNum;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(1+(_scaleNum-1)/maxZoom, 1+(_scaleNum-1)/maxZoom)];
    [CATransaction commit];
}

/**
 * 更新视频预览窗口的尺寸
 **/
- (void)updatevideoPreviewFrame:(CGRect )rect
{
    if (self.videoPreview && previewLayer) {
        previewLayer.frame = rect;
    }
    
}

/**
 * 禁用/启用 点击手势
 **/
- (void)setHasFocusCursorWithTap:(BOOL)hasFocusCursorWithTap {
    self.tapGesture.enabled = hasFocusCursorWithTap;
}

/**
 * 禁用/启用 伸缩镜头
 **/
- (void)setHasCameraPullAwayAndNearly:(BOOL)hasCameraPullAwayAndNearly
{
    self.pullAwayAndNearlyPinch.enabled = hasCameraPullAwayAndNearly;
}
@end
