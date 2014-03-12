//
//  CameraImageHelper.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol AVHelperDelegate;

@interface CameraImageHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
}
@property (strong) AVCaptureSession *session;
@property (strong) AVCaptureStillImageOutput *captureOutput;
@property (strong) UIImage *image;
@property (nonatomic,strong) NSData *imageData;
@property UIImageOrientation g_orientation;
@property (weak) AVCaptureVideoPreviewLayer *preview;
@property (weak) id<AVHelperDelegate>delegate;

- (void) startRunning;
- (void) stopRunning;

-(void)setDelegate:(id<AVHelperDelegate>)_delegate;
-(void)CaptureStillImage;
- (void)embedPreviewInView: (UIView *) aView;
- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

@protocol AVHelperDelegate <NSObject>

-(void)didFinishedCapture:(UIImage*)_img;
-(void)foucusStatus:(BOOL)isadjusting;
@end
