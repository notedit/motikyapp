//
//  MOVideoRecordingViewController.h
//  Motiky
//
//  Created by notedit on 4/3/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraEngine.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MOViewPreviewView.h"
#import "MOProgressView.h"
#import "MOTextView.h"
#import "MOShadowButton.h"

@interface MOVideoRecordingViewController : UIViewController <CameraEngineDelegate>

@property (strong, nonatomic)  UIScrollView *scrollView;

//@property (strong, nonatomic) IBOutlet UITextField *videoCaption;
@property (strong, nonatomic)  UIButton *videoPublishButton;


@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;

@property (strong, nonatomic)  MOTextView *videoCaption;
@property (strong, nonatomic)  MOShadowButton *okAndSaveButton;
@property (strong, nonatomic)  MOProgressView *pProcess;
@property (strong, nonatomic)  UIView  *controlView;

@property (strong, nonatomic) IBOutlet UIButton *dismissRecordingButton;


- (IBAction)videoPublish:(id)sender;

- (IBAction)dismissRecording:(id)sender;

- (IBAction)okAndSave:(id)sender;

@end
