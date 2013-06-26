//
//  MOMovieEngine.m
//  Motiky
//
//  Created by notedit on 5/10/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOMovieEngine.h"
#import <CoreMedia/CMBufferQueue.h>

#define NUM_AUDIO_BUFFERS 3

@interface MOMovieEngine ()
{
    BOOL audioEncodingIsFinished, videoEncodingIsFinished;
    CVOpenGLESTextureCacheRef coreVideoTextureCache;
    AVAssetReader *reader;
    CMTime previousFrameTime;
    CFAbsoluteTime previousActualFrameTime;
    
    CMBufferQueueRef previewBufferQueue;
    
    dispatch_queue_t movieQueue;
    
    
    AudioStreamBasicDescription audioDesc;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef audioBuffers[ NUM_AUDIO_BUFFERS ];
}

@end

@implementation MOMovieEngine
{
    
}

@synthesize url = _url;
@synthesize asset = _asset;
@synthesize playAtActualSpeed = _playAtActualSpeed;
@synthesize delegate = _delegate;


-(id) initWithURL:(NSURL *)url
{
    if (!(self = [super init])) {
        return nil;
    }
    
    self.url = url;
    self.asset = nil;
    
    [self setup];
    return self;
}


-(id)initWithAsset:(AVAsset *)asset
{
    if (!(self = [super init])) {
        return nil;
    }
    
    self.url = nil;
    self.asset = asset;
    
    return self;
}

-(BOOL)setup
{
    movieQueue = dispatch_queue_create("www.motiky.com.movieWrite", DISPATCH_QUEUE_SERIAL);
    OSStatus err = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
    if (err) {
        return NO;
    }
    
    
}

-(void)setupAudioFormat
{
    //LOGFUNC_ENTRY;
    audioDesc.mSampleRate = 44100.00;
    audioDesc.mFormatID = kAudioFormatLinearPCM;
    audioDesc.mFormatFlags = kAudioFormatFlagsCanonical;
    audioDesc.mChannelsPerFrame = 2;
	audioDesc.mFramesPerPacket = 1;
	audioDesc.mBitsPerChannel = 16;
	audioDesc.mBytesPerPacket = 4;
	audioDesc.mBytesPerFrame = 4;
}

-(void)cleanupAudioQueue
{
    
    if ( audioQueue != NULL )
    {
        AudioQueueDispose( audioQueue, true );
    }
    audioQueue = NULL;
}

-(void)makeAudioQueue
{
    
}

-(void)start
{
    if (self.url == nil) {
        return;
    }
    
    previousFrameTime = kCMTimeZero;
    previousActualFrameTime = CFAbsoluteTimeGetCurrent();
    
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:self.url options:inputOptions];
    
    MOMovieEngine __block *blockSelf = self;
    
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
        if (!tracksStatus == AVKeyValueStatusLoaded)
        {
            return;
        }
        blockSelf.asset = inputAsset;
        [blockSelf processAsset];
        //blockSelf = nil;
    }];
}

-(void)processAsset
{
    __unsafe_unretained MOMovieEngine *weakSelf = self;
    NSError *error = nil;
    
    reader = [AVAssetReader assetReaderWithAsset:self.asset error:&error];
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    [outputSettings setObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]  forKey: (NSString*)kCVPixelBufferPixelFormatTypeKey];
    
    // todo  set alwaysCopiesSampleData to NO on iOS 5.0 for faster video decoding
    AVAssetReaderTrackOutput *readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:outputSettings];
    [reader addOutput:readerVideoTrackOutput];
    
    NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    
    AVAssetTrack* audioTrack = [audioTracks objectAtIndex:0];
    AVAssetReaderTrackOutput *readerAudioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    [reader addOutput:readerAudioTrackOutput];
    
    if ([reader startReading] == 0) {
        NSLog(@"Error reading from file at URL: %@", weakSelf.url);
        return;
    }
    
    while (reader.status == AVAssetReaderStatusReading) {
        [weakSelf readNextVideoFrameFromOutput:readerVideoTrackOutput];
        
        if (!audioEncodingIsFinished)
        {
            [weakSelf readNextAudioSampleFromOutput:readerAudioTrackOutput];
        }

    }
    
    if (reader.status == AVAssetWriterStatusCompleted) {
        [weakSelf stop];
        if ([self.delegate respondsToSelector:@selector(didCompletePlayingMovie)]) {
            [self.delegate didCompletePlayingMovie];
        }
    }

}


- (void)readNextVideoFrameFromOutput:(AVAssetReaderTrackOutput *)readerVideoTrackOutput
{
    
    if (reader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef sampleBufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
        if (sampleBufferRef) {
            if (_playAtActualSpeed) {
                
                CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef);
                CMTime differenceFromLastFrame = CMTimeSubtract(currentSampleTime, previousFrameTime);
                CFAbsoluteTime currentActualTime = CFAbsoluteTimeGetCurrent();
                
                CGFloat frameTimeDifference = CMTimeGetSeconds(differenceFromLastFrame);
                CGFloat actualTimeDifference = currentActualTime - previousActualFrameTime;
                
                if (frameTimeDifference > actualTimeDifference)
                {
                    usleep(1000000.0 * (frameTimeDifference - actualTimeDifference));
                }
                
                previousFrameTime = currentSampleTime;
                previousActualFrameTime = CFAbsoluteTimeGetCurrent();
            }
            
            // todo
            
            OSStatus err = CMBufferQueueEnqueue(previewBufferQueue, sampleBufferRef);
            
            if (!err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(previewBufferQueue);
                    if (sbuf) {
                        CVImageBufferRef pixBuf = CMSampleBufferGetImageBuffer(sbuf);
                        [self.delegate pixelBufferReadyForDisplay:pixBuf];
                        CFRelease(sbuf);
                    }
                });
            }
            
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        } else {
            
            videoEncodingIsFinished = YES;
            [self stop];
        }
        
        
    }
    
    
}

-(void)readNextAudioSampleFromOutput:(AVAssetReaderTrackOutput *)readerAudioTrackOutput
{
    
    if (audioEncodingIsFinished)
    {
        return;
    }
    
    CMSampleBufferRef audioSampleBufferRef = [readerAudioTrackOutput copyNextSampleBuffer];
    
    if (audioSampleBufferRef) {
        
    }
}














@end













