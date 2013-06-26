//
//  MOPlayer.m
//  Motiky
//
//  Created by notedit on 5/9/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOPlayer.h"

@implementation MOPlayer

+(MOPlayer*)sharedPlayer
{
    static MOPlayer *_player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _player = [[MOPlayer alloc] init];
    });
    
    return _player;
}

@end
