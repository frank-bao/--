//
//  CameraImageHelper.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "CameraImageHelper.h"
#import <ImageIO/ImageIO.h>

@implementation CameraImageHelper

- (void) initialize
{
    //1.创建会话层
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    //2.创建、配置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
#if 1
    int flags = NSKeyValueObservingOptionNew; //监听自动对焦
    [device addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
#endif

	NSError *error;
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!captureInput)
	{
		NSLog(@"Error: %@", error);
		return;
	}
    [self.session addInput:captureInput];
    
    
    //3.创建、配置输出       
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.captureOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
    
    if ([self.session canAddOutput:self.captureOutput]) {
		[self.session addOutput:self.captureOutput];
	}
}

- (id) init
{
	if (self = [super init])
    {
        [self initialize];
    }
	return self;
}


//对焦回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        BOOL adjustingFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        NSLog(@"Is adjusting focus? %@", adjustingFocus ? @"YES" : @"NO" );
        NSLog(@"Change dictionary: %@", change);
        if (self.delegate) {
            [self.delegate foucusStatus:adjustingFocus];
        }
    }
}


-(void) embedPreviewInView: (UIView *) aView {
    if (!self.session) return;
    //设置取景
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.frame = aView.bounds;
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [aView.layer addSublayer: self.preview];
}

- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!self.preview) {
        return;
    }
     [CATransaction begin];
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.g_orientation = UIImageOrientationUp;
        self.preview.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        
    }else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        self.g_orientation = UIImageOrientationDown;
        self.preview.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        
    }else if (interfaceOrientation == UIDeviceOrientationPortrait){
        self.g_orientation = UIImageOrientationRight;
        self.preview.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        
    }else if (interfaceOrientation == UIDeviceOrientationPortraitUpsideDown){
        self.g_orientation = UIImageOrientationLeft;
        self.preview.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    [CATransaction commit];
}

-(void)giveImg2Delegate
{
    [self.delegate didFinishedCapture:self.image];
}

-(void)Captureimage
{
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }

    //get UIImage
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
//         CFDictionaryRef exifAttachments =
//         CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
//         if (exifAttachments) {
//             // Do something with the attachments.
//         }
         
         CMGetAttachment(imageSampleBuffer,kCGImagePropertyExifDictionary, NULL);
         
         if (imageSampleBuffer) {
             // Continue as appropriate.
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             
             CMRemoveAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary);
             
             self.imageData = imageData;
             
             UIImage *t_image = [UIImage imageWithData:imageData];
             self.image = [[UIImage alloc]initWithCGImage:t_image.CGImage scale:1.0 orientation:self.g_orientation];
             
             [self giveImg2Delegate];
         }
         
     }];
}

- (void) dealloc
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device removeObserver:self forKeyPath:@"adjustingFocus"];

	self.session = nil;
	self.image = nil;
}

#pragma mark Class Interface


- (void) startRunning
{
	[[self session] startRunning];	
}

- (void) stopRunning
{
	[[self session] stopRunning];
}

-(void)CaptureStillImage
{
    [self  Captureimage];
}


@end
