//
//  MORootPageViewController.m
//  Motiky
//
//  Created by notedit on 4/2/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MORootPageViewController.h"
#import "MOModelController.h"
#import "MOFeedsViewController.h"
#import "MOExploreViewController.h"

@interface MORootPageViewController ()
@property (readonly,strong,nonatomic) MOModelController *modelController;
@end

@implementation MORootPageViewController

@synthesize modelController = _modelController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.delegate = self;
    
    MOFeedsViewController *feedsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MOFeedsViewController"];
    NSArray *viewControllers = @[feedsViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    self.pageViewController.dataSource = self.modelController;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;
    
    [self.pageViewController didMoveToParentViewController:self];
    
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MOModelController *)modelController
{
    if (!_modelController) {
        _modelController = [[MOModelController alloc] init];
    }
    return _modelController;
}

@end
