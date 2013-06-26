//
//  MOVideoUploadViewController.m
//  Motiky
//
//  Created by notedit on 4/3/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//


/*
 0,设置两个视图的imageView
 1,首先设置这个页面的previewImageView
 2,视图load完毕后 previewImageView和下面的meta信息填写部分 动画
 3,
 */

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "MOVideoUploadViewController.h"
#import "QiniuAuthPolicy.h"

#import "MOClient.h"
#import "MOAuthEngine.h"

#import "MOFeedsViewController.h"
#import "MOTextView.h"
#import "MOUploadManager.h"

#import "TWStatus.h"

#define kAccessKey @"9wLPqikPvlXdOWkC4SKTPSHbLCWORMXtipkya0GZ"
#define kSecretKey @"hZCdW1Nih9i40dxo0kLG68GjT50JTXc3lz_reT_Y"
#define kBucketName @"motiky_test1"

@interface MOVideoUploadViewController () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    
    
    MOTextView  *captionView;
    UIView      *previewView;
    UIButton    *weiboShareButton;
    
}

@end

@implementation MOVideoUploadViewController

@synthesize picURL;
@synthesize videoURL;
@synthesize playerViewController = _playerViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(MPMoviePlayerViewController *)playerViewController
{
    if (!_playerViewController) {
        
      
        
        _playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:self.videoURL];
        _playerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        _playerViewController.moviePlayer.controlStyle = MPMovieControlStyleNone;
        _playerViewController.moviePlayer.scalingMode = MPMovieScalingModeNone;
        _playerViewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:[_playerViewController moviePlayer]];
    }
    return _playerViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //.playerViewController.view.frame = self.videoPreview.bounds;
    //[self.videoPreview addSubview:self.playerViewController.view];
    //[self.playerViewController.moviePlayer play];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(videoPlay) withObject:nil afterDelay:1.0f];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


#pragma mark -- tableview delegate


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80;
    } else if(indexPath.row == 1){
        return 320;
    } else if (indexPath.row == 2){
        return 60;
    }
    return 0;
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *captionIdentifier = @"captionCell";
    static NSString *previewIdentifier = @"previewCell";
    static NSString *weiboShareIdentifier = @"weiboShareCell";
    static NSString *Identifier = @"Cell";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        captionView = [[MOTextView alloc] initWithFrame:CGRectMake(20, 8, 280, 70)];
       
        captionView.placeholderColor = [UIColor blackColor];
        captionView.placeholder = @"表述...";
        
        captionView.layer.borderWidth = 2.0f;
        captionView.layer.borderColor = [[UIColor colorWithRed:35/255.0 green:181/255.0 blue:116/255.0 alpha:1] CGColor];
        captionView.layer.cornerRadius = 8.0f;
        captionView.tag = 10000;
        
        [cell.contentView addSubview:captionView];
    }
    
    if (indexPath.row == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        previewView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];
        
        previewView.layer.borderWidth = 2.0f;
        previewView.layer.borderColor = [[UIColor colorWithRed:35/255.0 green:181/255.0 blue:116/255.0 alpha:1] CGColor];
        previewView.layer.cornerRadius = 8.0f;
        
        previewView.clipsToBounds = YES;
        
        self.playerViewController.view.frame = previewView.bounds;
        
        [previewView addSubview:self.playerViewController.view];
        
        [cell.contentView addSubview:previewView];
        
    }
    
    if (indexPath.row == 2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        weiboShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [weiboShareButton setImage:[UIImage imageNamed:@"cam-icon-weibo-on"] forState:UIControlStateNormal];
        [weiboShareButton setImage:[UIImage imageNamed:@"cam-icon-weibo-on"] forState:UIControlStateSelected];
        
        weiboShareButton.frame = CGRectMake(15, 0, 50, 50);
        
        [cell.contentView addSubview:weiboShareButton];
        weiboShareButton.selected = YES;
        
    }
    
    return cell;
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark -- user action


-(void)videoPlay
{
    [self.playerViewController.moviePlayer play];
}

- (void)movieFinishedCallback:(NSNotification *)aNotification {
    MPMoviePlayerController *player = [aNotification object];
    [player play];
    NSLog(@"I got a movie finish notification");
}


- (IBAction)videoPublish:(id)sender {
    
    NSString *title = @"title";
    
    NSString *videoPath = [self.videoURL path];
    NSLog(@"the file path is:%@",videoPath);
    
    self.picURL = [NSURL fileURLWithPath:
                              [NSString stringWithFormat:@"%@%f.jpg", NSTemporaryDirectory(),
                               [[NSDate date] timeIntervalSince1970]]];
    
    UIImage *thumbnailImage = [_playerViewController.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.7);
    
    [thumbnailImageData writeToURL:self.picURL atomically:YES];
    
    [self videoPublishWithVideoURL:self.videoURL picURL:self.picURL title:title];
    
}

- (IBAction)dismissUploading:(id)sender {
    
    // userFeedsNavigationIdenty
    
    //MOFeedsViewController *feedsVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"userFeedsIdenty"];
    
    //[self presentViewController:feedsVC animated:YES completion:^{
        
    //}];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    /*
     
         
     MOLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MOLoginViewController"];
     
     UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
     [self presentViewController:nVC animated:NO completion:nil];
     
     }
     
     */
    
}





- (void) videoPublishWithVideoURL:(NSURL *)vvideoURL  picURL:(NSURL*)picURL title:(NSString*) title
{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:[vvideoURL path]]) {
        return;
    }
    
    
    
    NSDictionary* extraParams = @{
                                  @"title":title};

    [MOClient publishPostWithVideoURL:self.videoURL picURL:self.picURL userid:[MOAuthEngine sharedAuthEngine].currentUser.id
                          extraParams:extraParams
                         WithProgress:^(CGFloat progress) {
                             NSLog(@"the process is %f",progress);
                         }
                     withContinuation:^(BOOL success, NSError *error) {
                         if (success) {
                             NSLog(@"successfule upload ");
                             
                            
                             
                         } else {
                             NSString *message = [NSString stringWithFormat:@"failed uploading with error:%@",error];
                             NSLog(@"%@",message);
                         }
                         
                     }];
}



- (IBAction)canclePublish:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"嗯 取消" destructiveButtonTitle:@"无情的放弃" otherButtonTitles:nil, nil];
    
    [as showInView:self.view];
    
}

- (IBAction)publish:(id)sender {
    
    NSString *title = captionView.text.length > 0 ? captionView.text : @"测试";
    
    self.picURL = [NSURL fileURLWithPath:
                    [NSString stringWithFormat:@"%@%f.jpg", NSTemporaryDirectory(),
                     [[NSDate date] timeIntervalSince1970]]];
    
    UIImage *thumbnailImage = [self.playerViewController.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionExact];
    
    NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.8);
    
    [thumbnailImageData writeToURL:self.picURL atomically:YES];
    
    
    NSDictionary *uploadTask = @{@"userId":[MOAuthEngine sharedAuthEngine].currentUser.id,
                                 @"title":title,
                                 @"picURL":[self.picURL path],
                                 @"videoURL":[self.videoURL path]};
    
    [[MOUploadManager sharedManager] addUpload:uploadTask];
    
    
    NSDictionary* extraParams = @{@"title":title};
    
    
    [MOClient publishPostWithVideoURL:self.videoURL  picURL:self.picURL userid:[MOAuthEngine sharedAuthEngine].currentUser.id
                          extraParams:extraParams
                         WithProgress:^(CGFloat progress) {
                             NSLog(@"the process is %f",progress);
                         }
                     withContinuation:^(BOOL success, NSError *error) {
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             
                             if (success) {
                                 NSLog(@"successfule upload ");
                                 [TWStatus showStatus:@"发布成功"];
                                 [TWStatus dismissAfter:0.5];
                                 
                             } else {
                                 NSString *message = [NSString stringWithFormat:@"failed uploading with error:%@",error];
                                 NSLog(@"%@",message);
                                 [TWStatus dismiss];
                             }
                             
                         });
                         
                     }];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [TWStatus showLoadingWithStatus:@"正在发布..."];
    }];
    
}
@end
