//
//  MOVideoUploadViewController.h
//  Motiky
//
//  Created by notedit on 4/3/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "QiniuUploadDelegate.h"
#import "QiniuResumableUploader.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface MOVideoUploadViewController : UIViewController
{
    QiniuResumableUploader *_resumableUploader;
    NSTimeInterval _uploadStartTime;
    NSString *_key;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancleUploadButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *publishButton;

- (IBAction)canclePublish:(id)sender;
- (IBAction)publish:(id)sender;


@property (strong,nonatomic) NSURL*  videoURL;
@property (strong,nonatomic) NSURL*  picURL;

@property (strong,nonatomic) MPMoviePlayerViewController *playerViewController;


@end
