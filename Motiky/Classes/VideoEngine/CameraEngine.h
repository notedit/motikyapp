//
//  CameraEngine.h
//  Motiky
//
//  Created by notedit on 4/3/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"

@class CameraEngine;
@protocol CameraEngineDelegate <NSObject>
@required
- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;
-(void)readyToStart:(CameraEngine *)aCameraEngine;
-(void)readyToFinish:(CameraEngine *)aCameraEngine;

@end


@interface CameraEngine : NSObject

- (void)startup;
- (void) shutdown;

- (void) startCapture;
- (void) pauseCapture;
- (void) stopCapture;
- (void) resumeCapture;

- (AVCaptureVideoPreviewLayer*) getPreviewLayer;


@property (nonatomic,weak) id<CameraEngineDelegate> delegate;
@property (atomic, readwrite) BOOL isCapturing;
@property (atomic, readwrite) BOOL isPaused;
@property (atomic, readwrite) NSURL *finalURL;

@end
