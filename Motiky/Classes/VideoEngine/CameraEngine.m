//
//  CameraEngine.m
//  Motiky
//
//  Created by notedit on 4/3/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "CameraEngine.h"
#import "AssetsLibrary/ALAssetsLibrary.h"
#import <CoreMedia/CMBufferQueue.h>


@interface CameraEngine  () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureSession* _session;
    AVCaptureVideoPreviewLayer* _preview;
    dispatch_queue_t _captureQueue;
    AVCaptureConnection* _audioConnection;
    AVCaptureConnection* _videoConnection;
    CMBufferQueueRef previewBufferQueue;
    
    AVAssetWriter* _writer;
    AVAssetWriterInput* _videoInput;
    AVAssetWriterInput* _audioInput;
    AVAssetWriterInputPixelBufferAdaptor* _writerPixelBufferInput;
    
    BOOL _isCapturing;
    BOOL _isPaused;
    BOOL _discont;
    int _currentFile;
    CMTime _timeOffset;
    CMTime _lastVideo;
    CMTime _lastAudio;
    CMTime startTime;
    
    NSURL *finalURL;
    BOOL wasAudioReadyToRecord;
    BOOL wasVideoReadyToRecord;
    
    CMTime previousFrameTime;
    CMTime pausingTimeDiff,previousFrameTimeWhilePausing;
    
}
@end


@implementation CameraEngine

@synthesize isCapturing = _isCapturing;
@synthesize isPaused = _isPaused;
@synthesize finalURL = finalURL;

- (id)init
{
    if (self = [super init]) {
        
        _isPaused = NO;
        _isCapturing = NO;
        startTime = kCMTimeInvalid;
        previousFrameTime = kCMTimeIndefinite;
        
    }
    return self;
    
}


- (void)resetVideoName
{
    finalURL = [NSURL fileURLWithPath:
                [NSString stringWithFormat:@"%@%f.mp4", NSTemporaryDirectory(),
                 [[NSDate date] timeIntervalSince1970]]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [finalURL path];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
		if (!success)
			[self showError:error];
    }
}


- (void)startup
{
    [self resetVideoName];
    _writer = [[AVAssetWriter alloc] initWithURL:finalURL fileType:AVFileTypeQuickTimeMovie error:nil];
    _writer.shouldOptimizeForNetworkUse = YES;
    
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureDevice* mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput* micinput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:nil];
    if ([_session canAddInput:micinput]) {
        [_session addInput:micinput];
    }
    
    AVCaptureDevice* backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    
    OSStatus err = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
    
    if (err)
		[self showError:[NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]];
    
    _captureQueue = dispatch_queue_create("com.motiky.www.capture", DISPATCH_QUEUE_SERIAL);
    
    AVCaptureAudioDataOutput* audioout = [[AVCaptureAudioDataOutput alloc] init];
    dispatch_queue_t audioOutQueue = dispatch_queue_create("audioout.queue", DISPATCH_QUEUE_SERIAL);
    [audioout setSampleBufferDelegate:self queue:audioOutQueue];
    [_session addOutput:audioout];
    _audioConnection = [audioout connectionWithMediaType:AVMediaTypeAudio];
    
    
    AVCaptureVideoDataOutput* videoout = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t videoOutQueue = dispatch_queue_create("videoout.queue", DISPATCH_QUEUE_SERIAL);
    [videoout setAlwaysDiscardsLateVideoFrames:YES];
	[videoout setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [videoout setSampleBufferDelegate:self queue:videoOutQueue];
    if ([_session canAddOutput:videoout]) {
        [_session addOutput:videoout];
    }
    _videoConnection = [videoout connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation = UIInterfaceOrientationPortrait;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session startRunning];
    });
    
    //
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
}

- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription
{
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
											  [NSNumber numberWithFloat:currentASBD->mSampleRate], AVSampleRateKey,
											  [NSNumber numberWithInt:64000], AVEncoderBitRatePerChannelKey,
											  [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame], AVNumberOfChannelsKey, nil];
    if ([_writer canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
        _audioInput.expectsMediaDataInRealTime = YES;
        if ([_writer canAddInput:_audioInput]) {
            [_writer addInput:_audioInput];
            
        } else {
            NSLog(@"can not add audio input");
            return NO;
        }
        
    }
    return YES;
}


-(BOOL)setupAssetWriterVideoInput
{
    
    NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  AVVideoCodecH264, AVVideoCodecKey,
											  [NSNumber numberWithInteger:640], AVVideoWidthKey,
											  [NSNumber numberWithInteger:640], AVVideoHeightKey,
											  [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithInteger:256*1024],AVVideoAverageBitRateKey,
											   [NSNumber numberWithInteger:100], AVVideoMaxKeyFrameIntervalKey,
											   nil], AVVideoCompressionPropertiesKey,
											  nil];
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                                           [NSNumber numberWithInt:640], kCVPixelBufferWidthKey,
                                                           [NSNumber numberWithInt:640], kCVPixelBufferHeightKey,
                                                           nil];
    
    if ([_writer canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        //_videoInput.expectsMediaDataInRealTime = YES;
        
        _writerPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        
        if ([_writer canAddInput:_videoInput]) {
            [_writer addInput:_videoInput];
            
        } else {
            NSLog(@"can not add video input");
            return NO;
        }
        return YES;
    }
    return YES;
    
}

- (void)pauseSession
{
    if (_session.isRunning) {
        [_session stopRunning];
    }
}

- (void)resumeSession
{
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

- (void)showError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}



- (void) startCapture
{
    
    if (!self.isCapturing)
    {
        NSLog(@"starting capture");
        
        // create the encoder once we have the audio params
        self.isPaused = NO;
        _discont = NO;
        _timeOffset = CMTimeMake(0, 0);
        self.isCapturing = YES;
        pausingTimeDiff = kCMTimeInvalid;
        startTime = kCMTimeInvalid;
        
        [self.delegate readyToStart:self];
    }
    
}

- (void) stopCapture
{
    
    if (self.isCapturing)
    {
        
        // serialize with audio and video capture
        
        self.isCapturing = NO;
        dispatch_async(_captureQueue, ^{
            
            [_writer finishWritingWithCompletionHandler:^{
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeVideoAtPathToSavedPhotosAlbum:finalURL completionBlock:^(NSURL *assetURL, NSError *error){
                    NSLog(@"save completed");
                    //[[NSFileManager defaultManager] removeItemAtPath:[currentURL path] error:nil];
                }];
            }];
            _writer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate readyToFinish:self];
            });
            
        });
    }
}

- (void) pauseCapture
{
    
    //if (self.isCapturing)
    //{
    NSLog(@"Pausing capture");
    self.isPaused = YES;
    _discont = YES;
    //}
    
}

- (void) resumeCapture
{
    
    //if (self.isPaused)
    //{
    NSLog(@"Resuming capture");
    self.isPaused = NO;
    //}
    
}




- (void)processAudioBuffer:(CMSampleBufferRef)sampleBuffer;
{
    if (!self.isCapturing) {
        return;
    }
    if (self.isPaused) {
        return;
    }
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
    
    if (!wasAudioReadyToRecord) {
        CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
        wasAudioReadyToRecord = [self setupAssetWriterAudioInput:fmt];
    }
    
    if (!(wasAudioReadyToRecord && wasVideoReadyToRecord)) {
        return;
    }
    
    if (CMTIME_IS_INVALID(startTime)) {
        [_writer startWriting];
        [_writer startSessionAtSourceTime:currentSampleTime];
        startTime = currentSampleTime;
    }
    
    if (!_audioInput.readyForMoreMediaData){
        NSLog(@"have to drop an audio frame");
        return;
    }
    if([_audioInput appendSampleBuffer:sampleBuffer]){
        NSLog(@"audio ***********");
    }
    
}

- (void)processVideoBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (!self.isCapturing) {
        return;
    }
    
    
    if (!wasVideoReadyToRecord) {
        wasVideoReadyToRecord = [self setupAssetWriterVideoInput];
    }
    
    if (!(wasAudioReadyToRecord && wasAudioReadyToRecord)) {
        return;
    }
    
    CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    if (self.isPaused) {
        if (CMTIME_IS_INVALID(previousFrameTimeWhilePausing)) {
            if (CMTIME_IS_INVALID(pausingTimeDiff)) {
                pausingTimeDiff = kCMTimeZero;
            }
            
            previousFrameTimeWhilePausing = pts;
        }
        
        pausingTimeDiff = CMTimeAdd(pausingTimeDiff, CMTimeSubtract(pts, previousFrameTimeWhilePausing));
        previousFrameTimeWhilePausing = pts;
        return;
    } else {
        if (CMTIME_IS_VALID(previousFrameTimeWhilePausing)) {
            previousFrameTimeWhilePausing = kCMTimeInvalid;
        }
        if (CMTIME_IS_VALID(pausingTimeDiff)) {
            pts = CMTimeSubtract(pts, pausingTimeDiff);
        }
    }
    
    
    if (CMTIME_IS_INVALID(startTime)) {
        [_writer startWriting];
        [_writer startSessionAtSourceTime:pts];
        startTime = pts;
    }
    
    if (!_videoInput.readyForMoreMediaData) {
        NSLog(@"have to drop a video frame");
        return;
    }
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if (![_writerPixelBufferInput appendPixelBuffer:pixelBuffer withPresentationTime:pts]) {
        NSLog(@"Problem append pixel buffer at time %lld",pts.value);
        NSLog(@"%@",_writer.error);
    } else {
        NSLog(@"video ===============");
        
    }
    
    previousFrameTime = pts;
    
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    /*
    if ( connection == _videoConnection ) {
       		
		// Enqueue it for preview.  This is a shallow queue, so if image processing is taking too long,
		// we'll drop this frame for preview (this keeps preview latency low).
		OSStatus err = CMBufferQueueEnqueue(previewBufferQueue, sampleBuffer);
		if ( !err ) {
			dispatch_async(dispatch_get_main_queue(), ^{
				CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(previewBufferQueue);
				if (sbuf) {
					CVImageBufferRef pixBuf = CMSampleBufferGetImageBuffer(sbuf);
					[self.delegate pixelBufferReadyForDisplay:pixBuf];
					CFRelease(sbuf);
				}
			});
		}
	}
     
     */
    
    CFRetain(sampleBuffer);
    dispatch_async(_captureQueue, ^{
        
        if (connection == _audioConnection) {
            [self processAudioBuffer:sampleBuffer];
        } else if(connection == _videoConnection){
            [self processVideoBuffer:sampleBuffer];
        }
        
        CFRelease(sampleBuffer);
    });
    
        
    
}

- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer isVidel:(BOOL)bVideo
{
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        if (_writer.status == AVAssetWriterStatusUnknown) {
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            if ([_writer startWriting]) {
                [_writer startSessionAtSourceTime:pts];
            }
        }
        
        
        if (_writer.status == AVAssetWriterStatusWriting) {
            if (bVideo) {
                if (_videoInput.readyForMoreMediaData) {
                    [_videoInput appendSampleBuffer:sampleBuffer];
                }
                NSLog(@"video =====================");
            } else {
                if (_audioInput.readyForMoreMediaData) {
                    [_audioInput appendSampleBuffer:sampleBuffer];
                }
                NSLog(@"audio *********************");
            }
        }
        
        
        
    }
}

- (void) shutdown
{
    NSLog(@"shutting down server");
    if (_session)
    {
        [_session stopRunning];
        _session = nil;
    }
    dispatch_async(_captureQueue, ^{
        [_writer finishWritingWithCompletionHandler:^{
            NSLog(@"finish write");
        }];
    });
    
}

- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [fileURL path];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
		if (!success)
			[self showError:error];
    }
}

- (AVCaptureVideoPreviewLayer*) getPreviewLayer
{
    return _preview;
}

@end
