//
//  MOScrollView.h
//  Motiky
//
//  Created by notedit on 4/11/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *ScrollEnableControlNotification;

@interface MOScrollView : UIScrollView{
    UIPageControl           *_statusBarPageControl;
}

@end
