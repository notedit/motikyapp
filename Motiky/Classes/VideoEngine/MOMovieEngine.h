//
//  MOMovieEngine.h
//  Motiky
//
//  Created by notedit on 5/10/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MOMovieEngineDelegate <NSObject>

-(void)didCompletePlayingMovie;

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;

@end


@interface MOMovieEngine : NSObject

@property (readwrite,retain)AVAsset *asset;
@property (readwrite,retain)NSURL   *url;

@property(readwrite, nonatomic) BOOL playAtActualSpeed;

@property (readwrite, nonatomic, assign) id <MOMovieEngineDelegate>delegate;


- (id)initWithAsset:(AVAsset *)asset;
- (id)initWithURL:(NSURL *)url;
- (void)textureCacheSetup;


- (void)readNextVideoFrameFromOutput:(AVAssetReaderTrackOutput *)readerVideoTrackOutput;
- (void)readNextAudioSampleFromOutput:(AVAssetReaderTrackOutput *)readerAudioTrackOutput;
- (void)processMovieFrame:(CMSampleBufferRef)movieSampleBuffer;
- (void)start;
- (void)pause;
- (void)play;
- (void)stop;


@end
