//
//  MOVideoPlayerView.h
//  Motiky
//
//  Created by notedit on 4/5/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MOVideoPlayerView : UIView

@property(nonatomic, strong, readonly) UILabel* loadingStateLabel;
@property(nonatomic, strong, readonly) UIView* placeholderView;
@property(nonatomic, strong, readonly) UIImageView* placeholderImageView;
@property(nonatomic, strong, readwrite) UIImage* placeholderImage;
@property(nonatomic, strong, readonly) MPMoviePlayerController* moviePlayerController;


- (id)initWithFrame:(CGRect)frame
   placeholderImage:(UIImage*)placeholderImage
           videoURL:(NSURL*)videoURL;

- (void) startPlay;
- (void) pauseVideo;
- (void) playVideo;
- (void) stopVideo;

@end
