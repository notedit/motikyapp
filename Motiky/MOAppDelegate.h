//
//  MOAppDelegate.h
//  Motiky
//
//  Created by notedit on 2/15/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(MOAppDelegate *) sharedAppDelegate;

- (void) applyStylesheet;

@end
