//
//  MOModelController.m
//  Motiky
//
//  Created by notedit on 4/2/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOModelController.h"

#import "MOFeedsViewController.h"
#import "MOExploreViewController.h"

@interface MOModelController()
@property (readonly,strong,nonatomic) NSArray *pageData;
@end

@implementation MOModelController

- (id)init
{
    self = [super init];
    if (self) {
        _pageData = @[@"MOFeedsViewController",@"MOExploreViewController"];
        
    }
    return self;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    UIViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:self.pageData[index]];
    return dataViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController

{
    if ([viewController isKindOfClass:[MOFeedsViewController class]]) {
        return nil;
    }
    
    if ([viewController isKindOfClass:[MOExploreViewController class]]) {
        return [self viewControllerAtIndex:0 storyboard:viewController.storyboard];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[MOFeedsViewController class]]) {
        return [self viewControllerAtIndex:1 storyboard:viewController.storyboard];
    }
    
    if ([viewController isKindOfClass:[MOExploreViewController class]]) {
        return nil;
    }
    return nil;

}

@end
