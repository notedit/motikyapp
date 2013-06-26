//
//  MOVideoPlayer+AVPlayer.m
//  Motiky
//
//  Created by notedit on 5/8/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOVideoPlayer+AVPlayer.h"


#import "MOVideoPlayCell.h"
#import "AFDownloadRequestOperation.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import "Post.h"
#import "MOPlayer.h"


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



@interface MOVideoPlayer_AVPlayer()
{
    BOOL isplaying;
    BOOL ispauseing;
    BOOL interrupted;
    
    id _notificationToken;
    
    dispatch_queue_t asyncSetUpQueue;
    
    AFDownloadRequestOperation *downloadOperation;
    
    UITapGestureRecognizer *portraitTapGR;
}

-(void)removeMovieViewFromViewHierarchy;

@end

@implementation MOVideoPlayer_AVPlayer

@synthesize post = _post;
@synthesize indicator = _indicator;
@synthesize maskView = _maskView;
@synthesize moviePlayer = _moviePlayer;
//@synthesize playerView = _playerView;
@synthesize playerView = _playerView;

@synthesize player = _player;
@synthesize currentPlayerItem = _currentPlayerItem;

@synthesize willStartePlay,isStartePlay,isClearnup;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTableCell];
    }
    return self;
}

-(void)awakeFromNib
{
    self.indicator.hidesWhenStopped = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self setupTableCell];
}

-(void)setupTableCell
{
    asyncSetUpQueue = dispatch_queue_create("com.motiky.www.async.play", DISPATCH_QUEUE_SERIAL);
    self.player = [[AVPlayer alloc] init];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:MOAVPlayerStatusObservationContext];
    
    [self addObserver:self forKeyPath:@"player.currentItem" options:NSKeyValueObservingOptionNew context:MOAVPlayerCurrentItemObservationContext];
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"item-btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    
    self.likeBackgroudImage.image = backgroundImage;
    self.commentBackgroundImage.image = backgroundImage;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



-(void)setPost:(Post *)post
{
    _post = post;
    
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:post.pic_small] placeholderImage:nil];
    [self.userPhotoUrl setImageWithURL:[NSURL URLWithString:post.user.photo_url] placeholderImage:nil];
    
    self.usernameLabel.text = post.user.username;
    self.videoTitleLabel.text = post.title;
    
    self.userLikeLabel.text = [NSString stringWithFormat:@"%d", post.like_count.intValue];
    self.userCommentLabel.text = [NSString stringWithFormat:@"%d",post.comment_count.intValue];
    
    //[self.userLikeButton setImage:[UIImage imageNamed:@"item-icon-like-false"] forState:UIControlStateNormal];
    //[self.userLikeButton setImage:[UIImage imageNamed:@"item-icon-like-true"] forState:UIControlStateSelected];
    
    static NSDateFormatter *dateFormatterMostRecent;
    static NSDateFormatter *dataFormatterSomewhatRecent;
    static NSDateFormatter *dateFormatterOld;
    
    
    @synchronized(self) {
        if (!dateFormatterMostRecent) {
            NSString *format;
            
            dateFormatterMostRecent = [[NSDateFormatter alloc] init];
            dateFormatterMostRecent.dateFormat = nil;
            dateFormatterMostRecent.timeStyle = NSDateFormatterShortStyle;
            dateFormatterMostRecent.dateStyle = NSDateFormatterShortStyle;
            //            dateFormatterMostRecent.doesRelativeDateFormatting = YES;
            
            dataFormatterSomewhatRecent = [[NSDateFormatter alloc] init];
            dataFormatterSomewhatRecent.dateFormat = @"E HH:mm";
            
            dateFormatterOld = [[NSDateFormatter alloc] init];
            dateFormatterOld.dateFormat = nil;
            
            dateFormatterOld.timeStyle = NSDateFormatterNoStyle;
            
            // have to set a date style before dateFormat will give you a string back
            [dateFormatterOld setDateStyle:NSDateFormatterLongStyle];
            
            // read out the format string
            format = [dateFormatterOld dateFormat];
            format = [format stringByReplacingOccurrencesOfString:@", y" withString:@""];
            format = [format stringByReplacingOccurrencesOfString:@"y, " withString:@""];
            format = [format stringByReplacingOccurrencesOfString:@"y," withString:@""];
            
            format = [format stringByReplacingOccurrencesOfString:@" y" withString:@""];
            format = [format stringByReplacingOccurrencesOfString:@"y " withString:@""];
            format = [format stringByReplacingOccurrencesOfString:@"y" withString:@""];
            format = [format stringByReplacingOccurrencesOfString:@"年" withString:@""];
            
            [dateFormatterOld setDateFormat:format];
            
        }
    }
    
    NSDateFormatter *dateFormatter = nil;
    
    NSDate *now = [NSDate date];
    
    NSLog(@"now is %@",now);
    NSLog(@"date_create %@",[post.date_create class]);
    
    NSDate *dateCreate = nil;
    if ([post.date_create isKindOfClass:[NSString class]]) {
        dateCreate = [[Post dateFormatter] dateFromString:(NSString*)post.date_create];
    } else {
        dateCreate = post.date_create;
    }
    
    NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:dateCreate];
    if ( timeDifference < 60 * 60 * 24 * 7.0) {
        if (timeDifference < 60 * 60 * 24 * 2.0) {
            dateFormatter = dateFormatterMostRecent;
            
        } else {
            
            dateFormatter = dataFormatterSomewhatRecent;
        }
    } else {
        dateFormatter = dateFormatterOld;
    }
    
    self.postDateLabel.text = [dateFormatter stringFromDate:dateCreate];
    
    //[self.userLikeButton setImage:[UIImage imageNamed:@"item-icon-like-true"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    self.userLikeButton.selected = post.is_like;
    NSLog(@"selected %c",post.is_like);
    
}


-(void)setUserLikeButton:(UIButton *)userLikeButton
{
    [_userLikeButton removeTarget:self action:@selector(likeButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    _userLikeButton = userLikeButton;
    [userLikeButton addTarget:self action:@selector(likeButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)setUserCommentButton:(UIButton *)userCommentButton
{
    [_userCommentButton removeTarget:self action:@selector(commentButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
    _userCommentButton = userCommentButton;
    [userCommentButton addTarget:self action:@selector(commentButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)setUserPhotoUrl:(UIImageView *)userPhotoUrl
{
    if (portraitTapGR) {
        [_userPhotoUrl removeGestureRecognizer:portraitTapGR];
    }
    _userPhotoUrl = userPhotoUrl;
    userPhotoUrl.userInteractionEnabled = YES;
    portraitTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(portraitTouchUp:)];
    [userPhotoUrl addGestureRecognizer:portraitTapGR];
}


-(void)likeButtonTouchUp:(id)sender
{
    if (self.likeTouched) {
        self.likeTouched(self);
    }
    self.userLikeButton.selected = NO == self.userLikeButton.selected;
    
}


-(void)commentButtonTouchUp:(id)sender
{
    if (self.commentTouched) {
        self.commentTouched(self);
    }
}


-(void)portraitTouchUp:(id)sender
{
    if (self.portraitTouched) {
        self.portraitTouched(self);
    }
}



-(void)updateLike:(User *)user
{
    
    self.userLikeLabel.text = [NSString stringWithFormat:@"%d", self.post.like_count.intValue];
    self.userLikeButton.selected = self.post.is_like;
    
}

-(void)updateComment:(User *)user
{
    self.userCommentLabel.text = [NSString stringWithFormat:@"%d",self.post.comment_count.intValue];;
}





-(BOOL)isActive
{
    return willStartePlay || isStartePlay;
}


-(void) startPlay
{
    
    if ([self isActive]) {
        return;
    }
    
    willStartePlay = YES;
    isStartePlay = isClearnup = NO;
    
    [self.indicator startAnimating];
    
    __weak MOVideoPlayer_AVPlayer *weakSelf = self;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime,asyncSetUpQueue, ^(void){
        
        
        NSString *videoFilePath =[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),[self.post.video_url lastPathComponent]];
        //NSLog(@"the videoFilePath is %@",videoFilePath);
                    
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:videoFilePath]) {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.post.video_url]];
                NSLog(@"post.video_url:%@",self.post.video_url);
                downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:videoFilePath shouldResume:NO];
                [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    
                    if ([fileManager fileExistsAtPath:videoFilePath]) {
                        [weakSelf createAndPlayMovieForURL:[NSURL fileURLWithPath:videoFilePath] sourceType:MPMovieSourceTypeFile];
                    }
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"the error is %@",error);
                    NSLog(@"%@",operation.description);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.indicator stopAnimating];
                
                    });
                }];
                [downloadOperation start];
            
            } else {
            
                [self createAndPlayMovieForURL:[NSURL fileURLWithPath:videoFilePath] sourceType:MPMovieSourceTypeFile];
            }

        
    });
    
}



-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:movieURL options:nil];
    NSArray *requestedKeys = [NSArray arrayWithObjects: kPlayableKey, nil];
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareToPlayAsset:asset withKeys:requestedKeys];
        //});
    
    }];
    
    
}


-(void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    
    
    if (isClearnup) {
        return;
    }
    
    if (!asset.playable) {
        return;
    }
    
    self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    
    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [[_player currentItem] seekToTime:kCMTimeZero];
    }];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        isStartePlay = YES;
        if (self.player.currentItem != self.currentPlayerItem) {
            [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
        }
        
    });
    
}



-(void)playerItemDidReachEnd:(NSNotification*)notication
{
    [self.player seekToTime:kCMTimeZero];
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    
    if (context == MOAVPlayerStatusObservationContext) {
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
            }
                
                break;
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"AVPlayerStatusReadyToPlay");
                if (!isClearnup) {
                    [self.player play];
                }
                
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
       
        
        [self.indicator stopAnimating];
        
        if (isClearnup) {
            return;
        }
       
        
        NSLog(@"CurrentItem change");
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if(newPlayerItem == (id)[NSNull null]){
            // newPlayeritem is null?
            //NSLog(@"newPlayerItem IS null");
            
        } else {
            
            
            //self.playerView.frame = self.backgroundImageView.frame;
            
            //[self addSubview:self.playerView];
            
            self.playerView.player = self.player;
            
            
        }
         
         
        
    }  else {
        
        [super observeValueForKeyPath:keyPath  ofObject:object change:change context:context];
    }
    
}



-(void)handleTap:(UITapGestureRecognizer*)tapGestureRecognizer;
{
    
    if (interrupted) {
        return;
    }
   // NSLog(@"tapGestureRecognizer");
    if (isplaying) {
        [self.moviePlayer pause];
    } else {
        [self.moviePlayer play];
    }
    
}

// Remove the movie notification observers from the movie object.
-(void)removeMovieNotificationHandlers
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(void) cleanupMoviePlayer
{
    
    isClearnup = YES;
    if (isStartePlay) {
        //[self.player seekToTime:kCMTimeZero];
        [self.indicator stopAnimating];
        dispatch_async(asyncSetUpQueue, ^{
            [self.player.currentItem seekToTime:kCMTimeZero];
            [self.player pause];
            //self.currentPlayerItem = nil;
            //dispatch_async(dispatch_get_main_queue(), ^{
            
            self.playerView.player = nil;
            //});
            //[self.playerView removeFromSuperview];
            [self removeMovieNotificationHandlers];
        });
        
       
    }
    
    isStartePlay = willStartePlay = NO;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    willStartePlay = isStartePlay = isClearnup = NO;
    //[self addSubview:self.playerView];
    
}



@end
