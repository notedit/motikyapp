//
//  MOCommentListViewController.m
//  Motiky
//
//  Created by notedit on 4/30/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOCommentListViewController.h"
#import "SVPullToRefresh.h"
//#import "UIScrollView+SVInfiniteScrolling.h"
#import "MOClient.h"
#import "MOAuthEngine.h"
#import "UIImageView+WebCache.h"
#import "MOCommentCell.h"
#import "Post.h"
#import "Comment.h"

@interface MOCommentListViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    
    UIView  *touchCatcher;
    CGFloat  tableHeight;
    
    int  page;
    BOOL loaded;
    
    BOOL keyboardShow;
    UITapGestureRecognizer *tapGR;
}

@property(nonatomic,strong) NSMutableArray  *commentList;

@end

@implementation MOCommentListViewController

@synthesize post = _post;
@synthesize tableView = _tableView;
@synthesize commentTextField = _commentTextField;
@synthesize commentView = _commentView;



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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    __weak MOCommentListViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        
        [weakSelf loadComment];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreComment];
        
    }];
    
    loaded = NO;
    _commentList = [NSMutableArray array];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView triggerPullToRefresh];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    tableHeight = CGRectGetHeight(self.tableView.bounds);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentList ? self.commentList.count : 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"commentIdentifier";
    
    MOCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[MOCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    Comment *comment = self.commentList[indexPath.row];
    [cell setComment:comment];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    CGFloat height = [MOCommentCell heightOfComment:comment withTextConstrainedToWidth:183];
    
    return 52 - 16 + height;
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.commentTextField endEditing:YES];
}


#pragma mark - keyboard 


- (void)keyboardShown:(NSNotification *)notification
{
    
    /*
    if (tapGR  == nil) {

        tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
        tapGR.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGR];
    }
     
     */
    
    
//    CGRect newKeyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    NSTimeInterval animationDuration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    
//    CGPoint commentViewCenter = self.commentView.center;
//    commentViewCenter.y = self.view.frame.size.height - newKeyboardFrame.size.height - self.commentView.frame.size.height / 2.0;
//    
//       
//    [UIView animateWithDuration:animationDuration animations:^{
//        self.commentView.center = commentViewCenter;
//        
//    }];
//    
//    
//    CGRect tableFrame = self.tableView.frame;
//    
//    if (tableFrame.size.height == tableHeight) {
//        tableFrame.size.height = CGRectGetHeight(tableFrame) - 216.0f;
//        self.tableView.frame = tableFrame;
//    }

    
    
}

- (void)keyboardHidden:(NSNotification *)notification
{
    /*
    if (tapGR) {
        [self.view removeGestureRecognizer:tapGR];
        tapGR = nil;
    }
     */
    
    NSTimeInterval animationDuration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    CGPoint commentViewCenter = self.commentView.center;
    commentViewCenter.y = self.view.frame.size.height - self.commentView.frame.size.height/2.0;


    [UIView animateWithDuration:animationDuration  animations:^{
        self.commentView.center = commentViewCenter;
    }];

//    CGRect tableFrame = self.tableView.frame;
//    if(tableFrame.size.height != tableHeight){
//        tableFrame.size.height = tableHeight;
//        self.tableView.frame = tableFrame;
//    }

}


- (void)keyboardFrameChanged:(NSNotification *)notification
{

    
    CGRect newKeyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSTimeInterval animationDuration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGPoint commentViewCenter = self.commentView.center;
    commentViewCenter.y = self.view.frame.size.height - newKeyboardFrame.size.height - self.commentView.frame.size.height / 2.0;
    
    
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.commentView.center = commentViewCenter;
    }];
}


#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    NSUInteger currentLength = textField.text.length;
    currentLength += range.length;
    
    return (currentLength <= 140);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.text.length) {
        
        Comment *comment = [[Comment alloc] init];
        comment.author_id = [MOAuthEngine sharedAuthEngine].currentUser.id;
        comment.post_id = self.post.id;
        comment.user = [MOAuthEngine sharedAuthEngine].currentUser;
        comment.content = textField.text;
        
        [MOClient createComment:comment withContinuation:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    comment.user = [MOAuthEngine sharedAuthEngine].currentUser;
                    [_commentList insertObject:comment atIndex:0];
                    [_tableView reloadData];
                }
            });
        }];
        
        textField.text = @"";
    }
    
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}


#pragma mark - user action


-(void)loadComment
{
    [MOClient fetchPostComments:self.post.id page:1 withContinuation:^(BOOL success, int nextPage, NSArray *array) {
        if (success) {
            page = nextPage;
            _commentList = [NSMutableArray array];
            
            [_commentList addObjectsFromArray:array];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView.pullToRefreshView stopAnimating];
            if (success) {
                [_tableView reloadData];
            }
        });
    }];
}

-(void)loadMoreComment
{
    [MOClient fetchPostComments:self.post.id page:page ? page : 1 withContinuation:^(BOOL success, int nextPage, NSArray *array) {
        
        if (success) {
            page = nextPage;
            if (!_commentList) {
                _commentList = [NSMutableArray arrayWithArray:array];
            } else {
                [_commentList addObjectsFromArray:array];
            }
        }
        
         dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView.infiniteScrollingView stopAnimating];
            if (success) {
                [_tableView reloadData];
            }
        });
    }];
}

-(void)dismissKeyboard:(id)sender
{
    [self.commentTextField resignFirstResponder];
}


- (IBAction)addComment:(id)sender {
    if (self.commentTextField.text.length) {
        [self textFieldShouldReturn:self.commentTextField];
    } else {
        [self dismissKeyboard:self.commentTextField];
    }
}
@end



















