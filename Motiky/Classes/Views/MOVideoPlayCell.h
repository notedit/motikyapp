//
//  MOVideoPlayCell.h
//  Motiky
//
//  Created by notedit on 4/19/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Post.h"
#import "MOVideoPlayBackManager.h"
#import "AVPlayerDemoPlaybackView.h"

@protocol MOVideoPlayCellDelegate;

typedef void(^MOTableViewActionBlock)(id sender);

@interface MOVideoPlayCell : UITableViewCell

@property (nonatomic,weak) Post *post;
//@property (nonatomic,weak) MOVideoPlayBackManager *playbackManager;

//@property (strong, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong,nonatomic) IBOutlet UIView *maskView;
@property (strong,nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) IBOutlet AVPlayerDemoPlaybackView *playerView;

@property (strong, nonatomic) IBOutlet UIImageView *userPhotoUrl;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *userLikeButton;
@property (strong, nonatomic) IBOutlet UIButton *userCommentButton;
@property (strong, nonatomic) IBOutlet UILabel *userLikeLabel;
@property (strong, nonatomic) IBOutlet UILabel *userCommentLabel;


@property (nonatomic,copy) MOTableViewActionBlock likeTouched;
@property (nonatomic,copy) MOTableViewActionBlock commentTouched;
@property (nonatomic,copy) MOTableViewActionBlock portraitTouched;

-(void) updateLike:(User*)user;
-(void) updateComment:(User*)user;


-(void) startPlay;
-(void) cleanupMoviePlayer;
-(BOOL) isActive;

@end


@protocol MOVideoPlayCellDelegate <NSObject>



@end

