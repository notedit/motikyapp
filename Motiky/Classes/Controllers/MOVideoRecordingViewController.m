//
//  MOVideoRecordingViewController.m
//  Motiky
//
//  Created by notedit on 4/3/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

/*
 
 1,录制完成后  生成预览图
 2,把scrollView 放入view中
 3,动画滑入的方式 显示fieldText  publishButton  循环播放视频
 */

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MOVideoRecordingViewController.h"
#import "MOVideoUploadViewController.h"
#import "CameraEngine.h"
#import "Utils.h"
#import "MOClient.h"
#import "MOAuthEngine.h"
#import "MODefines.h"
#import "MOUploadManager.h"
#import "TWStatus.h"

@interface MOVideoRecordingViewController () <UIActionSheetDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    NSTimer *timer;
    NSURL *currentVideoURL;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    
    UIBackgroundTaskIdentifier backgroundRecordingID;
    
    CameraEngine *cameraEngine;
    
    float   duration;
    
    BOOL isRecording;
    BOOL isRecorded; // 是否已经完成录制
    BOOL isCanSave;  // 是否已经达到两秒可以保存了
    BOOL isUpload;
    
    NSURL *videoURL;
    NSURL *thumbnailURL;
    
    BOOL keyboardVisible;
    BOOL reRecord;
    
    
    MOViewPreviewView *previewView;
    
    
    
    //UITextField *_focusedControl;
    
}

@property(strong,nonatomic) UIImage *previewImage;
@property(strong,nonatomic) UIImageView *previewImageView;
@property (strong,nonatomic) MPMoviePlayerViewController *playerViewController;

@property(strong,nonatomic) MOShadowButton *backButton;
@property(strong,nonatomic) UIButton *sinaWeiboButton;

@end

@implementation MOVideoRecordingViewController


@synthesize cameraView = _cameraView;
@synthesize pProcess = _pProcess;
@synthesize okAndSaveButton = _okAndSaveButton;
@synthesize playerViewController = _playerViewController;
@synthesize videoCaption = _videoCaption;
@synthesize videoPublishButton = _videoPublishButton;
@synthesize dismissRecordingButton = _dismissRecordingButton;
@synthesize scrollView = _scrollView;

@synthesize backButton = _backButton;
@synthesize sinaWeiboButton = _sinaWeiboButton;

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
    
    [self startup];
    
    //self.navigationController.navigationBarHidden = YES;
    //self.tabBarController.tabBar.hidden = YES;
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
       
}

- (void)startup
{
    
    cameraEngine = [[CameraEngine alloc] init];
    [cameraEngine startup];
    cameraEngine.delegate = self;
    
    
    previewLayer = [cameraEngine getPreviewLayer];
    
    [previewLayer removeFromSuperlayer];
    
    previewLayer.frame = CGRectMake(0, 0, 320, 320);
    
    [self.cameraView.layer addSublayer:previewLayer];
    
    //UIImage *progressImage = [UIImage imageNamed:@"full.png"];
    //UIImage *trackImage = [UIImage imageNamed:@"progressbar.png"];
    
    UIImage *fill = [[UIImage imageNamed:@"cam-prgs"]
                     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [_progress setTrackImage:nil];
    [_progress setProgressImage:fill];
    
    _progress.progress = 0.0;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _okAndSaveButton = [[MOShadowButton alloc] initWithFrame:CGRectMake(134, 486, 53, 52)];
    _okAndSaveButton.enabled = NO;
    _okAndSaveButton.userInteractionEnabled = NO;
    _okAndSaveButton.alpha = 0.5;
    
    [_okAndSaveButton setImage:[UIImage imageNamed:@"cam-icon-done"] forState:UIControlStateNormal];
    [_okAndSaveButton setImage:[UIImage imageNamed:@"cam-icon-done"] forState:UIControlStateHighlighted];
    
    [_okAndSaveButton addTarget:self action:@selector(okAndSave:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_okAndSaveButton];
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                             target:self
                                           selector:@selector(updateProcess)
                                           userInfo:nil
                                            repeats:YES];
    
    NSLog(@"viewwill Appear %@", NSStringFromCGRect(self.cameraView.frame));
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //self.okAndSaveButton.frame = CGRectMake(20, 486, 280, 52);
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(MPMoviePlayerViewController *)playerViewController
{
    if (!_playerViewController) {
        
        _playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[cameraEngine finalURL]];
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


- (void)movieFinishedCallback:(NSNotification *)aNotification {
    MPMoviePlayerController *player = [aNotification object];
    [player play];
    NSLog(@"I got a movie finish notification");
}




-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma user funcation


- (void) updateProcess
{
    if (!isRecording) {
        return;
    }
    
    duration = duration + 0.05;
    _progress.progress = duration / 6.0;
    NSLog(@"the process is %f",duration);
    
    
    if (duration >= 2.0 && !isCanSave) {
        
        isCanSave = YES;
       _okAndSaveButton.alpha = 1.0;
        
        _okAndSaveButton.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _okAndSaveButton.userInteractionEnabled = YES;
        _okAndSaveButton.enabled = YES;
        
        [UIView animateWithDuration:0.15 animations:^{
            CGRect frame = CGRectMake(20, _okAndSaveButton.frame.origin.y, 280, _okAndSaveButton.frame.size.height);
            _okAndSaveButton.frame = frame;
        }];
        
    }
    
    if (duration >= 6.0 && !isRecorded) {
        isRecorded = YES;
        [timer invalidate];
        [self finishRecord:YES];
        
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
        
    if (isRecorded) {
        return;
    }
    
    
    if (![cameraEngine isCapturing]) {
        [cameraEngine startCapture];
    } else {
        [cameraEngine resumeCapture];
    }
    
    isRecording = YES;
        
    NSLog(@"touch started...");
        
    

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (isRecorded) {
        return;
    }
    
    [cameraEngine pauseCapture];
    isRecording = NO;
    
    NSLog(@"touch ended");
    

}


- (IBAction)videoPublish:(id)sender {
    
    [self videoPublishWithVideoURL:videoURL picURL:thumbnailURL title:self.videoCaption.text];
}

- (IBAction)dismissRecording:(id)sender {
    
    if (isRecorded || isCanSave) {
        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"嗯 取消" destructiveButtonTitle:@"坚决的放弃" otherButtonTitles:nil, nil];
        
        [as showInView:self.view];
    } else {
        
        [self dismissViewControllerAnimated:YES completion:^{
            // todo 
        }];
        
    }
}

- (IBAction)okAndSave:(id)sender {
    
    isRecorded = YES;
    [self finishRecord:NO];
   
    
}

- (void)finishRecord:(BOOL)fullTime
{
    self.view.userInteractionEnabled = NO;
    [cameraEngine stopCapture];
    
    
    
    // generate thumbnailImage
    
    videoURL = [cameraEngine finalURL];
    
    MOVideoUploadViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MOVideoUploadViewController"];
    
    vc.videoURL = videoURL;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    /*
    thumbnailURL = [NSURL fileURLWithPath:
                  [NSString stringWithFormat:@"%@%f.jpg", NSTemporaryDirectory(),
                   [[NSDate date] timeIntervalSince1970]]];
    
    self.previewImage = [self.playerViewController.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionExact];
    
    NSData *thumbnailImageData = UIImageJPEGRepresentation(self.previewImage, 0.8);
    
    [thumbnailImageData writeToURL:thumbnailURL atomically:YES];
    
    self.previewImageView = [[UIImageView alloc] initWithImage:self.previewImage];
    
    
    // 准备生成需要用到的新的view
    
    [self setupControlView];
    
    // remove 一些view
    
    [previewLayer removeFromSuperlayer];
    [self.okAndSaveButton removeFromSuperview];
    [self.progress removeFromSuperview];
    [self.dismissRecordingButton removeFromSuperview];
    [self.cameraView removeFromSuperview];
    
    [self.view addSubview:_controlView];
    
    
    [self.view addSubview:self.previewImageView];
    self.previewImageView.frame = self.cameraView.frame;
    //self.previewImageView.frame = self.cameraView.frame;
    
    
    CGRect captionViewFrame = CGRectMake(20, 345, 280, 106);
    CGRect backButtonFrame = CGRectMake(8, 489, 56, 44);
    CGRect sinaShareButtonFrame = CGRectMake(73, 489, 60, 44);
    CGRect videoPublishButtonFrame = CGRectMake(160, 486, 140, 50);
    
    
    [UIView animateWithDuration:.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.previewImageView.frame = CGRectMake(0, 0, 320, 310);
        //self.previewImageView.alpha = 0.8;
        self.videoCaption.frame = CGRectMake(20, 335, 280,116);
        
        self.backButton.frame = backButtonFrame;
        self.sinaWeiboButton.frame = CGRectMake(83, 489, 60, 44);
        self.videoPublishButton.frame = CGRectMake(170, 486, 130, 50);
        
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.1f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.previewImageView.frame = CGRectMake(0, 0, 320, 320);
            self.videoCaption.frame = captionViewFrame;
            self.sinaWeiboButton.frame = sinaShareButtonFrame;
            self.videoPublishButton.frame =  videoPublishButtonFrame;
            
        } completion:^(BOOL finished) {
            
            [self.scrollView addSubview:self.playerViewController.view];
            self.playerViewController.view.frame = self.previewImageView.frame;
            self.playerViewController.view.alpha = 0.8;
            self.previewImageView.hidden = YES;
            [self.playerViewController.moviePlayer play];
            
        }];
    }];
    
    //[self.navigationController pushViewController:uVC animated:NO];
    
    self.view.userInteractionEnabled = YES;
     
     */
        
}


-(void)setupControlView
{
    
    _videoCaption = [[MOTextView alloc] initWithFrame:CGRectMake(20, 100, 280, 36)];
    _videoCaption.backgroundColor = [UIColor colorWithRed:90/255.0 green:95/255.0 blue:107/255.0 alpha:1];
    _videoCaption.placeholder = @"描述...";
    _videoCaption.layer.cornerRadius = 5;
    _videoCaption.clipsToBounds = YES;
    
    _videoPublishButton = [[MOShadowButton alloc] initWithFrame:_okAndSaveButton.frame];
    _videoPublishButton.titleLabel.text = @"发布";
    
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(-50, 169, 56, 44);
    [_backButton setImage:[UIImage imageNamed:@"cam-icon-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backToRecord:) forControlEvents:UIControlEventTouchUpInside];
    
    _sinaWeiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sinaWeiboButton.frame = CGRectMake(0, 169, 60, 44);
    [_sinaWeiboButton setImage:[UIImage imageNamed:@"cam-icon-weibo-on"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(triggleSinaShare:) forControlEvents:UIControlEventTouchUpInside];
    
    _controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 320, 320, self.view.frame.size.height - 320)];
    
    [_controlView addSubview:_videoCaption];
    [_controlView addSubview:_videoPublishButton];
    [_controlView addSubview:_backButton];
    [_controlView addSubview:_sinaWeiboButton];
}

-(IBAction)backToRecord:(id)sender
{


}


-(IBAction)triggleSinaShare:(id)sender
{


}


-(void)setupPublishButtonAndCaption
{
    _videoCaption = [[MOTextView alloc] initWithFrame:CGRectMake(0, 500, 290, 70)];
    _videoCaption.backgroundColor = [UIColor colorWithRed:90/255.0 green:95/255.0 blue:107/255.0 alpha:1];
    _videoCaption.placeholder = @"描述...";
    _videoCaption.layer.cornerRadius = 5;
    _videoCaption.clipsToBounds = YES;
    
    _videoPublishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _videoPublishButton.frame = CGRectMake(0, 560, 290, 50);
    [_videoPublishButton setImage:[UIImage imageNamed:@"publish_button.png"] forState:UIControlStateNormal];
    [_videoPublishButton addTarget:self action:@selector(videoPublish:) forControlEvents:UIControlEventTouchUpInside];
}


- (void) videoPublishWithVideoURL:(NSURL *)vvideoURL  picURL:(NSURL*)picURL title:(NSString*) title
{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:[vvideoURL path]]) {
        return;
    }
    
    // 把用户id title 图片路径 视频路径 保存 用于续传
    
    NSDictionary *uploadTask = @{@"userId":[MOAuthEngine sharedAuthEngine].currentUser.id,
                                 @"title":title,
                                 @"picURL":[picURL path],
                                 @"videoURL":[vvideoURL path]};
    
    [[MOUploadManager sharedManager] addUpload:uploadTask];
    
    
    NSDictionary* extraParams = @{@"title":title};
    
    
    [MOClient publishPostWithVideoURL:videoURL picURL:thumbnailURL userid:[MOAuthEngine sharedAuthEngine].currentUser.id
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
    
    [self dismissViewControllerAnimated:YES completion:^{
        [TWStatus showLoadingWithStatus:@"正在发布..."];
    }];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded) {
        return;
    }
    
    if (keyboardVisible) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrameInWindow;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindow];
    
    // the keyboard frame is specified in window-level coordinates. this calculates the frame as if it were a subview of our view, making it a sibling of the scroll view
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrameInWindow fromView:nil];
    
    CGRect scrollViewKeyboardIntersection = CGRectIntersection(_scrollView.frame, keyboardFrameInView);
    UIEdgeInsets newContentInsets = UIEdgeInsetsMake(0, 0, scrollViewKeyboardIntersection.size.height, 0);
    
    // this is an old animation method, but the only one that retains compaitiblity between parameters (duration, curve) and the values contained in the userInfo-Dictionary.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    _scrollView.contentInset = newContentInsets;
    _scrollView.scrollIndicatorInsets = newContentInsets;
    
    /*
     * Depending on visual layout, _focusedControl should either be the input field (UITextField,..) or another element
     * that should be visible, e.g. a purchase button below an amount text field
     * it makes sense to set _focusedControl in delegates like -textFieldShouldBeginEditing: if you have multiple input fields
     */
    if (self.videoCaption) {
        CGRect controlFrameInScrollView = [_scrollView convertRect:self.videoCaption.bounds fromView:self.videoCaption]; // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
        controlFrameInScrollView = CGRectInset(controlFrameInScrollView, 0, -10); // replace 10 with any nice visual offset between control and keyboard or control and top of the scroll view.
        
        CGFloat controlVisualOffsetToTopOfScrollview = controlFrameInScrollView.origin.y - _scrollView.contentOffset.y;
        CGFloat controlVisualBottom = controlVisualOffsetToTopOfScrollview + controlFrameInScrollView.size.height;
        
        // this is the visible part of the scroll view that is not hidden by the keyboard
        CGFloat scrollViewVisibleHeight = _scrollView.frame.size.height - scrollViewKeyboardIntersection.size.height;
        
        if (controlVisualBottom > scrollViewVisibleHeight) { // check if the keyboard will hide the control in question
            // scroll up until the control is in place
            CGPoint newContentOffset = _scrollView.contentOffset;
            newContentOffset.y += (controlVisualBottom - scrollViewVisibleHeight);
            
            // make sure we don't set an impossible offset caused by the "nice visual offset"
            // if a control is at the bottom of the scroll view, it will end up just above the keyboard to eliminate scrolling inconsistencies
            newContentOffset.y = MIN(newContentOffset.y, _scrollView.contentSize.height - scrollViewVisibleHeight);
            
            [_scrollView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        } else if (controlFrameInScrollView.origin.y < _scrollView.contentOffset.y) {
            // if the control is not fully visible, make it so (useful if the user taps on a partially visible input field
            CGPoint newContentOffset = _scrollView.contentOffset;
            newContentOffset.y = controlFrameInScrollView.origin.y;
            
            [_scrollView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        }
    }
    
    [UIView commitAnimations];
    
    keyboardVisible = YES;
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardDidHide:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded) {
        return;
    }
    
    if (!keyboardVisible) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    // undo all that keyboardWillShow-magic
    // the scroll view will adjust its contentOffset apropriately
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}




# pragma delegate

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
	[textField becomeFirstResponder];
   	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}



- (void)readyToStart:(CameraEngine *)aCameraEngine
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]){
        backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        
        }];
    }


}


- (void)readyToFinish:(CameraEngine *)aCameraEngine
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        backgroundRecordingID = UIBackgroundTaskInvalid;
        
    }

}


-(void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
    // Don't make OpenGLES calls while in the background.
	if ( [UIApplication sharedApplication].applicationState != UIApplicationStateBackground )
		[previewView displayPixelBuffer:pixelBuffer];
}


@end
