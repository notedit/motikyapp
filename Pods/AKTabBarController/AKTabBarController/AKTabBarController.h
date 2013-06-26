// AKTabBarController.h
//
// Copyright (c) 2012 Ali Karagoz (http://alikaragoz.net)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AKTabBarView.h"
#import "AKTabBar.h"
#import "AKTab.h"

@interface AKTabBarController : UIViewController <AKTabBarDelegate, UINavigationControllerDelegate>

// View Controllers handled by the tab bar controller.
@property (nonatomic, strong) NSMutableArray *viewControllers;

// Current active view controller
@property (nonatomic, strong) UIViewController *selectedViewController;

// Current active view controller index
@property (nonatomic, assign) NSInteger selectedIndex;

// This is the minimum height to display the title.
@property (nonatomic, assign) CGFloat minimumHeightToDisplayTitle;

// Used to show / hide the tabs title.
@property (nonatomic, assign) BOOL tabTitleIsHidden;

// Tabs icon colors.
@property (nonatomic, strong) NSArray *iconColors;

// Tabs icon shadow color
@property (nonatomic, strong) UIColor *iconShadowColor;

// Tabs icon shadow offset
@property (nonatomic) CGSize iconShadowOffset;

// Tabs selected icon colors.
@property (nonatomic, strong) NSArray *selectedIconColors;

// Tabs outer glow icon color
@property (nonatomic, strong) UIColor *selectedIconOuterGlowColor;

// Tabs selected colors.
@property (nonatomic, strong) NSArray *tabColors;

// Tabs selected colors.
@property (nonatomic, strong) NSArray *selectedTabColors;

// Tabs icon pre-rendered yes / no
@property (nonatomic, assign) BOOL tabIconPreRendered;

// Tabs icon glossy show / hide
@property (nonatomic, assign) BOOL iconGlossyIsHidden;

// Tab stroke Color
@property (nonatomic, strong) UIColor *tabStrokeColor;

// Tab inner stroke Color
@property (nonatomic, strong) UIColor *tabInnerStrokeColor;

// Tab top embos Color
@property (nonatomic, strong) UIColor *tabEdgeColor;

// Tab bar top embos Color. optional, default to tabEdgeColor
@property (nonatomic, strong) UIColor *topEdgeColor;

// Tab background image
@property (nonatomic, strong) NSString *backgroundImageName;

// Tab selected background image
@property (nonatomic, strong) NSString *selectedBackgroundImageName;

// Tab text color
@property (nonatomic, strong) UIColor *textColor;

// Tab selected text color
@property (nonatomic, strong) UIColor *selectedTextColor;

// Tab title font
@property (nonatomic, strong) UIFont *textFont;

// Initialization with a specific height.
- (id)initWithTabBarHeight:(NSUInteger)height;

// Hide / Show Methods
- (void)showTabBarAnimated:(BOOL)animated;
- (void)hideTabBarAnimated:(BOOL)animated;

// Refresh the Tab Bar
- (void)loadTabs;

@end