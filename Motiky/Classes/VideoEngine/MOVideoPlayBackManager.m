//
//  MOVideoPlayBackManager.m
//  Motiky
//
//  Created by notedit on 4/25/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOVideoPlayCell.h"
#import "Post.h"
#import "MOVideoPlayBackManager.h"
#import "MOVideoPlayer.h"
#import "AFDownloadRequestOperation.h"

@interface MOVideoPlayBackManager () <MOVideoPlayerDelegate>
{
    __weak __block MOVideoPlayCell *registedCell;
    MOVideoPlayer *videoPlayer;
    
    AFDownloadRequestOperation *downloadOperation;
    
}

@end

@implementation MOVideoPlayBackManager

static MOVideoPlayBackManager *currentManager = nil;

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)deregisterCell:(MOVideoPlayCell *)cell
{
    if (registedCell == cell) {
        NSLog(@"Deregistering cell %@",cell);
        registedCell = nil;
    }
}

- (void)registerCell:(MOVideoPlayCell *)cell forPost:(Post *)post
{
    if (cell == nil) {
        NSLog(@"nil cell being registered");
    }
    
    if (self.currentPlayingPost.id ==  post.id) {
        registedCell = cell;
    }
}


- (void)playPost:(Post *)post sender:(MOVideoPlayCell *)cell
{
    //NSLog(@"start play post: %@",post);
    
    @synchronized([self class]){
        if (currentManager && currentManager != self) {
            [currentManager stopPost:post sender:cell];
        }
        currentManager = self;
    }
    
    if (self.currentPlayingPost.id == post.id) {
        [videoPlayer play];
        return;
    }
    
    if (self.currentPlayingPost) {
        [self stopPost:self.currentPlayingPost sender:cell];
    }
    
    _currentPlayingPost = post;
    registedCell = cell;
    //[registedCell.indicator startAnimating];
    
    
    if (videoPlayer == nil) {
        videoPlayer = [[MOVideoPlayer alloc] init];
        videoPlayer.delegate = self;
    }
    
    //if (_playerQueue) {
    //_playerQueue = dispatch_queue_create("www.motiky.com.playerback", DISPATCH_QUEUE_PRIORITY_BACKGROUND);
    //}
    
    //double delayInSeconds = 0.5;
    //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [videoPlayer prepareToPlayURL:_currentPlayingPost.video_url];
    //});
        
    //});
    
    
    
}

-(void)stopPost:(Post *)post sender:(MOVideoPlayCell *)cell
{
    [videoPlayer close];
    //registedCell.playerView.player = nil;
    //[registedCell.playerView removeFromSuperview];
    
    
    registedCell.playerView.playerLayer.player = nil;
    
    registedCell = nil;
    _currentPlayingPost = nil;
    
    
}

-(void)pausePost:(Post *)post sender:(MOVideoPlayCell *)cell
{
    if (self.currentPlayingPost.id == post.id) {
        [videoPlayer pause];
        
    }
}

- (BOOL)isPlaying
{
    return videoPlayer.isPlaying;
}

- (BOOL)isPlayingPost:(Post *)post
{
    return videoPlayer.isPlaying && (self.currentPlayingPost.id == post.id);
}


-(void)cleanupPlayBackManager
{
    registedCell = nil;
    if (videoPlayer) {
        [videoPlayer close];
        videoPlayer = nil;
    }
}

#pragma mark - delegate



-(void)willStartToPlay:(MOVideoPlayer*)vvideoPlayer
{
    
    if (!registedCell) {
        NSLog(@"error:there is no registedCell");
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [registedCell.indicator startAnimating];
    });
    

    
    

}
-(void)isStartToPlay:(MOVideoPlayer *)vvideoPlayer
{
    if (!registedCell) {
        NSLog(@"error:there is no registedCell");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [registedCell.indicator stopAnimating];
        registedCell.playerView.playerLayer.hidden = NO;
        [registedCell.playerView.playerLayer setPlayer:vvideoPlayer.player];
        //[registedCell.playerView.layer addSublayer:registedCell.playerView.playerLayer];
        
       
    });
    //to do.

}
// clean up preview and remove tap
-(void)finishToPlay:(MOVideoPlayer *)vvideoPlayer
{
    if (!registedCell) {
        NSLog(@"error:there is no registedcell");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //registedCell.playerView.player = nil;
        [registedCell.playerView removeFromSuperview];
        [vvideoPlayer close];
    });
   
}

#pragma mark -- 



@end
