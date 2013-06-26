//
//  MOPullRefreshView.h
//  Motiky
//
//  Created by notedit on 4/18/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    MOPullRefreshStatePulling = 0,
    MOPullRefreshStateNormal,
    MOPullRefreshStateLoading
} MOPullRefreshState;


@protocol MOPullRefreshViewDelegate;

@interface MOPullRefreshView : UIView

@property (nonatomic) CGFloat insetTop;
@property (nonatomic,weak) id<MOPullRefreshViewDelegate> delegate;

- (void)startRefresh;
- (void)refreshLastUpdatedDate;

//bind with parent scroll view

- (void)pullRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pullRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)pullRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end


@protocol MOPullRefreshViewDelegate <NSObject>

- (void)pullRefreshViewDidTriggerRefresh:(MOPullRefreshView *)refreshView;
- (BOOL)pullRefreshViewDataSourceIsLoading:(MOPullRefreshView *)refreshView;

@optional

- (NSDate*)pullRefreshViewDataSourceLastUpdated:(MOPullRefreshView *)refreshView;

@end