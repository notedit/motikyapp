//
//  MOVideoPlayer+AVPlayer.h
//  Motiky
//
//  Created by notedit on 5/8/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//





#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Post.h"
#import "MOVideoPlayBackManager.h"

#import <AVFoundation/AVFoundation.h>

#import "AVPlayerDemoPlaybackView.h"



typedef void(^MOTableViewActionBlock)(id sender);


@protocol MOVideoPlayCellDelegate;


@interface MOVideoPlayer_AVPlayer : UITableViewCell

@property (nonatomic,weak) Post *post;
//@property (nonatomic,weak) MOVideoPlayBackManager *playbackManager;

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *currentPlayerItem;

//@property (strong, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong,nonatomic) IBOutlet UIView *maskView;
@property (strong,nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,retain) MPMoviePlayerController *moviePlayer;

@property (strong, nonatomic) IBOutlet AVPlayerDemoPlaybackView *playerView;
//@property (nonatomic,retain) AVPlayerDemoPlaybackView *playerView;
@property (strong, nonatomic) IBOutlet UIImageView *likeBackgroudImage;
@property (strong, nonatomic) IBOutlet UIImageView *commentBackgroundImage;

@property (strong, nonatomic) IBOutlet UIImageView *userPhotoUrl;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *userLikeButton;
@property (strong, nonatomic) IBOutlet UIButton *userCommentButton;
@property (strong, nonatomic) IBOutlet UILabel *userLikeLabel;
@property (strong, nonatomic) IBOutlet UILabel *userCommentLabel;

@property (nonatomic) BOOL willStartePlay;
@property (nonatomic) BOOL isStartePlay;
@property (nonatomic) BOOL isClearnup;

@property (nonatomic,copy) MOTableViewActionBlock likeTouched;
@property (nonatomic,copy) MOTableViewActionBlock commentTouched;
@property (nonatomic,copy) MOTableViewActionBlock portraitTouched;


-(void) updateLike:(User*)user;
-(void) updateComment:(User*)user;


-(void) startPlay;
-(void)cleanupMoviePlayer;

@end


@protocol MOVideoPlayCellDelegate <NSObject>



@end
