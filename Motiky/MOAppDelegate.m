//
//  MOAppDelegate.m
//  Motiky
//
//  Created by notedit on 2/15/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOAppDelegate.h"
#import "MOClient.h"
#import "MOAuthEngine.h"

@implementation MOAppDelegate

@synthesize window = _window;

+ (MOAppDelegate *)sharedAppDelegate {
    return (MOAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"Navigation-Bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] forBarMetrics:UIBarMetricsDefault];
    
	[[UITabBar appearance] setBackgroundImage:[[UIImage imageNamed:@"Tab-Bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
    
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage imageNamed:@"tab-prs"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
    
    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, 0)];
    
    // add track    
    
    // Override point for customization after application launch.
      
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MOClient sharedClient];
    
    });
    
    return YES;
}


- (void) applyStylesheet {
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[[MOAuthEngine sharedAuthEngine] sinaWeibo] handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[[MOAuthEngine sharedAuthEngine] sinaWeibo] handleOpenURL:url];
}

@end
