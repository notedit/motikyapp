//
//  MOVideoPlayCell.m
//  Motiky
//
//  Created by notedit on 4/19/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOVideoPlayCell.h"
#import "AFDownloadRequestOperation.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import "Post.h"
#import "Utils.h"

@interface MOVideoPlayCell()
{
    
    AFDownloadRequestOperation *downloadOperation;
    
    dispatch_queue_t asyncSetUpQueue;
    
    BOOL willStartePlay;
    BOOL isStartePlay;
    BOOL isClearnup;
    
    UITapGestureRecognizer *portraitTapGR;
}



-(void)removeMovieViewFromViewHierarchy;

@end

@implementation MOVideoPlayCell

@synthesize post = _post;
@synthesize indicator = _indicator;
@synthesize maskView = _maskView;
@synthesize moviePlayer = _moviePlayer;
//@synthesize playerView = _playerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self setupAsyncQueue];
    return self;
}

-(void)awakeFromNib
{
    self.indicator.hidesWhenStopped = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self setupAsyncQueue];
    
    
}

-(void)setupAsyncQueue
{
    asyncSetUpQueue = dispatch_queue_create("com.motiky.www.async.play", DISPATCH_QUEUE_SERIAL);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    
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
    
    [self.userLikeButton setImage:[UIImage imageNamed:@"like_btn_selected"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
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
    
    [self.userLikeButton setImage:[UIImage imageNamed:@"like_btn_selected"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    self.userLikeButton.selected = post.is_like;
    
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




#pragma video play


-(BOOL)isActive
{
    return willStartePlay || isStartePlay;
}


-(void) startPlay
{
    //self.indicator.hidden = NO;
    
    if ([self isActive]) {
        return;
    }
    
    //[self.indicator startAnimating];
    
    __weak MOVideoPlayCell *weakSelf = self;
    
    isStartePlay = isClearnup = NO;
    willStartePlay = YES;
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, asyncSetUpQueue, ^(void){
        [weakSelf prepareVideo];
    });
        
}

-(void) prepareVideo
{
    
    if (isClearnup) {
        return;
    }
    
    __weak MOVideoPlayCell *weakSelf = self;
    
    NSString *videoFilePath =[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),[weakSelf.post.video_url lastPathComponent]];
    //NSLog(@"the videoFilePath is %@",videoFilePath);
    //dispatch_async(dispatch_get_main_queue(), ^{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:videoFilePath]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:weakSelf.post.video_url]];
        //NSLog(@"post.video_url:%@",weakSelf.post.video_url);
        downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:videoFilePath shouldResume:NO];
        [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //dispatch_async(dispatch_get_main_queue(), ^{
            if ([fileManager fileExistsAtPath:videoFilePath]) {
                [weakSelf createAndPlayMovieForURL:[NSURL fileURLWithPath:videoFilePath] sourceType:MPMovieSourceTypeFile];
            }
            //});
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"the error is %@",error);
            NSLog(@"%@",operation.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.indicator stopAnimating];
                //weakSelf.indicator.hidden = YES;
            });
        }];
        [downloadOperation start];
        
    } else {
        
        [weakSelf createAndPlayMovieForURL:[NSURL fileURLWithPath:videoFilePath] sourceType:MPMovieSourceTypeFile];
    }



}



- (void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    if (isClearnup) {
        return;
    }
    
    __weak MOVideoPlayCell *weakSelf = self;

    
    //dispatch_async(dispatch_get_main_queue(), ^{
    
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        
        [weakSelf installMovieNotificationObservers];
        
        _moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayer.repeatMode = MPMovieRepeatModeOne;
        _moviePlayer.shouldAutoplay = YES;
        
        _moviePlayer.view.frame = weakSelf.backgroundImageView.frame;
        _moviePlayer.view.backgroundColor = [UIColor clearColor];
    } else {
        [weakSelf installMovieNotificationObservers];
        [_moviePlayer setContentURL:movieURL];
        _moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayer.repeatMode = MPMovieRepeatModeOne;
        _moviePlayer.shouldAutoplay = YES;
    }
    
    [_moviePlayer prepareToPlay];
    
}




- (void) setupMoviePlayerView
{
    [self.indicator stopAnimating];
    //MPMoviePlayerController *player = [self moviePlayer];
    //if (![self.moviePlayer.view isDescendantOfView:self]) {
        //self.moviePlayer.view.backgroundColor = [UIColor clearColor];

        [self addSubview:self.moviePlayer.view];
        //self.moviePlayer.view.alpha = 0.5;
        //self.maskView = self.moviePlayer.view;
        
        //[self bringSubviewToFront:self.maskView];
        
        //UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        //tapGestureRecognizer.numberOfTapsRequired = 1;
        //tapGestureRecognizer.numberOfTouchesRequired = 1;
        //[self.maskView removeGestureRecognizer:tapGestureRecognizer];
        //[self.maskView addGestureRecognizer:tapGestureRecognizer];
        //[self addSubview:self.maskView];
    //}

    
}


- (void)cleanupMoviePlayerView
{
    //[UIView animateWithDuration:.1f animations:^{
    //    self.moviePlayer.view.alpha = 0;
    //} completion:^(BOOL finished) {
    [self.moviePlayer.view removeFromSuperview];
    //}];
        //[self.maskView removeFromSuperview];
}

- (void)handleTap:(UITapGestureRecognizer*)tapGestureRecognizer;
{
   
    NSLog(@"tapGestureRecognizer");
    if (self.moviePlayer.currentPlaybackRate > 0) {
        [self.moviePlayer pause];
    } else {
        [self.moviePlayer play];
    }
    
}


// Notifies observers of a change in the prepared-to-play state of an objectconforming to the MPMediaPlayback protocol. 
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
	// Add an overlay view on top of the movie view
    [self performSelectorOnMainThread:@selector(setupMoviePlayerView) withObject:nil waitUntilDone:NO];
    //[self setupMoviePlayerView];
    //[self.indicator stopAnimating];
    //self.indicator.hidden = YES;
    
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
	MPMoviePlayerController *player = notification.object;
    
    switch ([reason integerValue])
	{
        case MPMovieFinishReasonPlaybackEnded:
            //[player stop];
            [player play];
			break;
		default:
			break;
	}
}


// Handle movie load state changes.
- (void)loadStateDidChange:(NSNotification *)notification
{
    if (isClearnup) {
        return;
    }
    
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;
    
	
	if (loadState & MPMovieLoadStatePlaythroughOK)
	{
        [self.indicator stopAnimating];

       //[self setupMoviePlayerView];
        ///[UIView animateWithDuration:.2f animations:^{
                        
        //} completion:^(BOOL finished) {
            if (isClearnup) {
                return;
            }
        
        
            [player play];
            isStartePlay = YES;
        
            //}];
        
        //[player play];
               
	}
	
}

// Register observers for the various movie object notifications. 
-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayer];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];
    
}


// Remove the movie notification observers from the movie object.
-(void)removeMovieNotificationHandlers
{
    MPMoviePlayerController *player = [self moviePlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
}


- (void) cleanupMoviePlayer
{
    
    isClearnup = YES;
    
    if (isStartePlay) {
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        //dispatch_async(dispatch_get_main_queue(), ^{
            //[self.moviePlayer stop];
        //});
        
        [self.indicator stopAnimating];
        [self cleanupMoviePlayerView];
        self.moviePlayer.initialPlaybackTime = 0;
        [self.moviePlayer pause];
        [self removeMovieNotificationHandlers];
        //[self setMoviePlayer:nil];
        
    }
    
    isStartePlay = willStartePlay = NO;
       //[downloadOperation cancel];
    
}

-(void)prepareForReuse
{
    isClearnup = isStartePlay = willStartePlay = NO;
}



@end
