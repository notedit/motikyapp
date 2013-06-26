//
//  MOVideoPlayer.m
//  Motiky
//
//  Created by notedit on 4/25/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOVideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

#import "AFDownloadRequestOperation.h"

//#import "MOVideoPlayer+AVPlayer.h"

/* Asset keys */
NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey		= @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";


/* AVPlayer keys */
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";


NSString * const kCurrentActiveCell = @"currentActiveCell";


static void *MOAVPlayerRateObservationContext = &MOAVPlayerRateObservationContext;
static void *MOAVPlayerStatusObservationContext = &MOAVPlayerStatusObservationContext;
static void *MOAVPlayerCurrentItemObservationContext = &MOAVPlayerCurrentItemObservationContext;

static void *MOAVPlayerCurrenTableCellObservationContext = &MOAVPlayerCurrenTableCellObservationContext;


@interface MOVideoPlayer (){
    
    AFDownloadRequestOperation *downloadOperation;
    
    dispatch_queue_t  _playerQueue;
    
}

@end

@implementation MOVideoPlayer


@synthesize player = _player;
@synthesize currentPlayerItem = _currentPlayerItem;



- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    _playerQueue = dispatch_queue_create("wwww.motiky.com.playerqueue", DISPATCH_QUEUE_SERIAL);
    return self;
}


-(void)play
{
    [self.player play];
}

-(void)pause
{
    [self.player pause];
}


-(void)stop
{
    [self.player.currentItem seekToTime:kCMTimeZero];
}


-(void)close
{
    // todo
    
    //[self cleanupMoviePlayer];
    //[self.player.currentItem seekToTime:kCMTimeZero];
    [self removeMovieNotificationHandlers];
}

-(BOOL)isPlaying
{
    return self.player.rate > 0 ? YES:NO;
}


-(void)prepareToPlayURL:(NSString *)url
{
    
    [self.delegate willStartToPlay:self];
    
    __weak MOVideoPlayer *weakSelf = self;
    
    dispatch_async(_playerQueue, ^{
        //[self.player play];
    
    
    NSString *videoFilePath =[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),[url  lastPathComponent]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:videoFilePath]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSLog(@"post.video_url:%@",url);
        downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:videoFilePath shouldResume:NO];
        [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //dispatch_async(dispatch_get_main_queue(), ^{
            if ([fileManager fileExistsAtPath:videoFilePath]) {
                [weakSelf loadAssetForURL:[NSURL fileURLWithPath:videoFilePath]];
            }
            //});
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"the error is %@",error);
            NSLog(@"%@",operation.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.indicator stopAnimating];
                //weakSelf.indicator.hidden = YES;
            });
        }];
        [downloadOperation start];
        
    } else {
        
        [self loadAssetForURL:[NSURL fileURLWithPath:videoFilePath]];
    }
        
    });

    
}

-(void)loadAssetForURL:(NSURL*)videoURL
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSArray *requestedKeys = [NSArray arrayWithObjects: kPlayableKey, nil];
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareToPlayAsset:asset withKeys:requestedKeys];
        });
    }];

}


- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    
    for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			
			return;
		}
		/* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
	}
    
    if (!asset.playable) {
        return;
    }
    
    if (self.currentPlayerItem) {
        [self.currentPlayerItem removeObserver:self forKeyPath:kStatusKey context:MOAVPlayerStatusObservationContext];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayerItem];
    }
    
    
    self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.currentPlayerItem addObserver:self
                             forKeyPath:kStatusKey
                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                context:MOAVPlayerStatusObservationContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.currentPlayerItem];
    
    //dispatch_async(dispatch_queue_create("com.motiky.www.capture", DISPATCH_QUEUE_SERIAL), ^{
        
        
        if (!self.player) {
            self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
            
            
            [self.player addObserver:self
                          forKeyPath:kCurrentItemKey
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:MOAVPlayerCurrentItemObservationContext];
            
            
            
            /* Observe the AVPlayer "rate" property to update the scrubber control. */
            [self.player addObserver:self
                          forKeyPath:kRateKey
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:MOAVPlayerRateObservationContext];
            
            
        }
        
        if (self.player.currentItem != self.currentPlayerItem) {
            [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
            
        }
    
    //});
    
    

    
}

- (void)playerItemDidReachEnd:(NSNotification*)notication
{
    
    // repeat play
    dispatch_async(_playerQueue, ^{
        [self.player.currentItem seekToTime:kCMTimeZero];
        [self.player play];
    });


}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    
    
    /* AVPlayerItem "status" property value observer. */
    if (context == MOAVPlayerStatusObservationContext) {
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                //NSLog(@"AVPlayerStatusUnknown");
            }
                
                break;
            case AVPlayerStatusReadyToPlay:
            {
                //NSLog(@"AVPlayerStatusReadyToPlay");
                //[self.player play];
            }
                break;
            case AVPlayerStatusFailed:
            {
                //NSLog(@"AVPlayerStatusFailed");
            }
                break;
        }
    } else if (context == MOAVPlayerRateObservationContext) {
        
        //NSLog(@"MOAVPlayerRateObservationContext");
        
    } else if (context == MOAVPlayerCurrentItemObservationContext){
        
        // NSLog(@"CurrentItem change");
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if(newPlayerItem == (id)[NSNull null]){
            // newPlayeritem is null?
            //NSLog(@"newPlayerItem IS null");
            
        } else {
            
            
            //self.playerView.frame = self.backgroundImageView.frame;
            
            //[self addSubview:self.playerView];
            
            
            //double delayInSeconds = 0.2;
            //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            //dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //self.playerView.player = self.player;
                //[self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
                //dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate isStartToPlay:self];
            
                //dispatch_async(dispatch_queue_create("com.motiky.www.capture", DISPATCH_QUEUE_SERIAL), ^{
                    
                //});
            
                dispatch_async(_playerQueue, ^{
                    [self.player play];
                });
                //[self.player play];
                //});
                //
                //[self.indicator stopAnimating];
            //});
            
            
        }
        
    }  else {
        
        [super observeValueForKeyPath:keyPath  ofObject:object change:change context:context];
    }
    
}

-(void)removeMovieNotificationHandlers
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) cleanupMoviePlayer
{
    
   
    [self.player.currentItem seekToTime:kCMTimeZero];
    [self removeMovieNotificationHandlers];
    [self.delegate finishToPlay:self];
    //[self setMoviePlayer:nil];
    //[downloadOperation cancel];
    
}



@end
