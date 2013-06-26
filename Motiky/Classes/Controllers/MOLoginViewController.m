//
//  MOLoginViewController.m
//  Motiky
//
//  Created by notedit on 3/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOLoginViewController.h"
#import "MOAuthEngine.h"
#import "MOClient.h"
#import "MODefines.h"
#import "User.h"

@interface MOLoginViewController ()

@end

@implementation MOLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL authValid = [[MOAuthEngine sharedAuthEngine] isValid];
    
    if (authValid) {
        [self performSegueWithIdentifier:@"alreadyLoginedSegue" sender:self];
    } 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    SLLog(@"%@",[keyWindow subviews]);
    
    SLLog(@"print the auth %@",[MOAuthEngine sharedAuthEngine]);
    
    [[MOAuthEngine sharedAuthEngine] logInWithContinuation:^(BOOL success, NSError *error) {
        if (success) {
            SLLog(@"yes we success");
            SLLog(@"yes we update user info");
            [[MOAuthEngine sharedAuthEngine] getWeiboUserInfo:[[MOAuthEngine sharedAuthEngine] sinaWeiboID] withContinuation:^(NSDictionary *info) {
                
                
            }];
            [self performSegueWithIdentifier:@"loginThenGotoSegue" sender:self];
            
        } else if (error.code != 21330) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"can not login" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}


# pragma mark -  prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
