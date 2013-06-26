//
//  MOVideoPlayer.h
//  Motiky
//
//  Created by notedit on 4/25/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import <AVFoundation/AVFoundation.h>

@protocol MOVideoPlayerDelegate;


@interface MOVideoPlayer : NSObject

-(void)prepareToPlayURL:(NSString*)url;
-(void)play;
-(void)pause;
-(void)stop;
-(void)close;

@property(nonatomic,readonly) BOOL isPlaying;
@property(nonatomic,retain)AVPlayer   *player;
@property(nonatomic,retain)AVPlayerItem *currentPlayerItem;
@property(nonatomic,weak) id<MOVideoPlayerDelegate> delegate;

@end


@protocol MOVideoPlayerDelegate <NSObject>

@optional
//stop animation setup preview && add tap
-(void)willStartToPlay:(MOVideoPlayer*)videoPlayer;
-(void)isStartToPlay:(MOVideoPlayer *)videoPlayer;
// clean up preview and remove tap
-(void)finishToPlay:(MOVideoPlayer *)videoPlayer;

@end
