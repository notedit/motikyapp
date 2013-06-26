//
//  MOPlayer.h
//  Motiky
//
//  Created by notedit on 5/9/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface MOPlayer : AVPlayer

+(MOPlayer *)sharedPlayer;

@end
