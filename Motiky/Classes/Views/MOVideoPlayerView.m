//
//  MOVideoPlayerView.m
//  Motiky
//
//  Created by notedit on 4/5/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOVideoPlayerView.h"

@interface MOVideoPlayerView()
{
    BOOL isStarted;
    BOOL isPlaying;
}

@property(nonatomic, strong, readwrite) UILabel* loadingStateLabel;
@property(nonatomic, strong, readwrite) UIView* placeholderView;
@property(nonatomic, strong, readwrite) UIImageView* placeholderImageView;
@property(nonatomic, strong, readwrite) MPMoviePlayerController* moviePlayerController;
@property(nonatomic, copy, readwrite) NSURL* videoURL;


@end

@implementation MOVideoPlayerView


- (id) initWithFrame:(CGRect)frame placeholderImage:(UIImage *)placeholderImage videoURL:(NSURL *)videoURL
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoURL = videoURL;
        [self initVideoPlayerPlaceholderViewWithFrame:frame placeholderImage:placeholderImage];
        [self addSubview:_placeholderView];
        
        [self initMoviePlayerControllerWithFrame:frame videoURL:videoURL];
    }
    return self;
}

- (void)initVideoPlayerPlaceholderViewWithFrame:(CGRect)frame
                               placeholderImage:(UIImage*)placeholderImage{
    CGRect placeholderViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _placeholderView = [[UIView alloc] initWithFrame:placeholderViewFrame];
    
    CGRect placeholderImageViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _placeholderImageView = [[UIImageView alloc] initWithFrame:placeholderImageViewFrame];
    _placeholderImageView.image = placeholderImage;
    [_placeholderView addSubview:_placeholderImageView];
    
    
    CGSize loadingStateLabelSize = CGSizeMake(CGRectGetWidth(placeholderImageViewFrame), 20.0f);
    CGRect loadingStateFrame = CGRectMake(CGRectGetMinX(placeholderImageViewFrame), (frame.size.height - loadingStateLabelSize.height) / 2, loadingStateLabelSize.width, loadingStateLabelSize.height);
    self.loadingStateLabel = [[UILabel alloc] initWithFrame:loadingStateFrame];
    self.loadingStateLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)initMoviePlayerControllerWithFrame:(CGRect)frame videoURL:(NSURL*)videoURL {
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    self.moviePlayerController.view.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
    self.moviePlayerController.view.center = self.center;
    
    self.moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
    self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
    self.moviePlayerController.scalingMode = MPMovieScalingModeNone;
    self.moviePlayerController.repeatMode = MPMovieRepeatModeOne;
}

- (void)dealloc {
    [self cleanupMoviePlayerControllerInstance];
    self.moviePlayerController = nil;
}

- (void)cleanupMoviePlayerControllerInstance {
    [self stopVideo];
    [self.moviePlayerController.view removeFromSuperview];
    
}


#pragma mark - video actions

- (void)setupTapGestureRecognizer
{
    UITapGestureRecognizer *singleOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleOne:)];
    singleOne.numberOfTouchesRequired = 1;
    singleOne.numberOfTapsRequired = 1;
    
    [self.moviePlayerController.view addGestureRecognizer:singleOne];
}

-(void)singleOne:(UITapGestureRecognizer *)sender
{
    if (!isStarted) {
        return;
    }
    if (isPlaying) {
        [self pauseVideo];
    } else {
        [self playVideo];
    }
}

- (void)startPlay
{
    self.moviePlayerController.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.moviePlayerController.view];
    
    [self playVideo];
    isStarted = YES;
}

- (void)playVideo {
    [self registerForNotificationsFromMoviePlayer:self.moviePlayerController];
    [self.moviePlayerController play];
    isPlaying = YES;
}

- (void)pauseVideo {
    [self.moviePlayerController pause];
    isPlaying = NO;
}

- (void)stopVideo {
    [self.moviePlayerController stop];
    [self deregisterForNotificationsFromMoviePlayer:self.moviePlayerController];
    isStarted = NO;
    isPlaying = NO;
}

#pragma mark - autorotation

-(void)registerForNotificationsFromMoviePlayer:(MPMoviePlayerController*)moviePlayer {
    if (nil == moviePlayer) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notification_moviePlayerLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notification_moviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_moviePlayerDidFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    
}

-(void)deregisterForNotificationsFromMoviePlayer:(MPMoviePlayerController*)moviePlayer {
    if (nil == moviePlayer) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
}

- (void)notification_moviePlayerDidFinished:(NSNotification*)notification {
    
    MPMoviePlayerController *player = [notification object];
    [player play];
    NSLog(@"I got a movie finish notification and play again");
}

- (void)notification_moviePlayerLoadStateDidChange:(NSNotification*)notification {
    MPMoviePlayerController* moviePlayer = notification.object;
    MPMovieLoadState loadState = moviePlayer.loadState;
    
    BOOL isMoviePlayable = (loadState == (MPMovieLoadStatePlaythroughOK|MPMovieLoadStatePlayable));
    NSString* moviePlayerLoadStateText = [self labelTextForMoviePlayerLoadState:loadState];
    if (isMoviePlayable) {
        [self.loadingStateLabel removeFromSuperview];
    }
    
    
}

- (void)notification_moviePlayerPlaybackStateDidChange:(NSNotification*)notification {
    MPMoviePlayerController* moviePlayer = notification.object;
    MPMoviePlaybackState playbackState = moviePlayer.playbackState;
    MPMovieLoadState loadState = moviePlayer.loadState;
    
    BOOL isMoviePlayable = (loadState == (MPMovieLoadStatePlaythroughOK|MPMovieLoadStatePlayable));
    if (NO == isMoviePlayable && (playbackState == MPMoviePlaybackStatePlaying)) {
        [self addSubview:self.loadingStateLabel];
    }
}

- (NSString*)labelTextForMoviePlayerLoadState:(MPMovieLoadState)loadState {
    return @"loading";
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
