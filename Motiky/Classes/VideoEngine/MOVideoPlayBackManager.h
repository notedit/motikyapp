//
//  MOVideoPlayBackManager.h
//  Motiky
//
//  Created by notedit on 4/25/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 - Keep track of which Post is playing
 - Indicate to TableViewCell if it's Post is playing or not
 - Update TableViewCell state
 */


@class Post;
@class MOVideoPlayCell;

typedef void(^MOPlaybackManagerDelegateBlock)(Post *post);

@interface MOVideoPlayBackManager : NSObject

@property(nonatomic,strong,readonly) Post *currentPlayingPost;
@property(nonatomic,readonly) BOOL isPlaying;

// callback blocks for play/pause/stop

@property(nonatomic,weak) MOVideoPlayCell *lastPlayingCell;

-(void)deregisterCell:(MOVideoPlayCell *)cell;
-(void)registerCell:(MOVideoPlayCell *)cell forPost:(Post *)post;

-(void)playPost:(Post *)post sender:(MOVideoPlayCell*)cell;
-(void)pausePost:(Post *)post sender:(MOVideoPlayCell*)cell;
-(void)stopPost:(Post *)post sender:(MOVideoPlayCell*)cell;

-(BOOL)isPlayingPost:(Post*)post;

-(void)cleanupPlayBackManager;

@end
