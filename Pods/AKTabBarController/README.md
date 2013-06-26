#AKTabBarController

AKTabBarController is an adaptive and customizable tab bar for iOS.

##Features
- Portrait and Landscape mode tab bar.
- Ability to set the height of the tab bar.
- Ability to hide the tab bar when pushed.
- Ability to set the minimum height of the tab bar to allow display the title.
- Ability to hide the title in the tabs.
- When the height of the tab bar is too small, the title is not displayed.
- Only one image is needed for both selected and unselected states (style is added via CoreGraphics).
- Icons are resized when needed and particularly in landscape mode.
- Animated state of the tabs with a nice cross fade animation.
- Support pre-rendered images (no glossy effect will be applied).
- Set a custom font for tab titles.

## Preview
###iPhone portrait
![iPhone portrait](https://github.com/alikaragoz/AKTabBarController/raw/master/Screenshots/iphone-portrait.png)

##Usage

###Installation
Add the dependency to your `Podfile`:

```ruby
platform :ios

pod 'AKTabBarController'
```

Run `pod install` to install the dependencies.

Next, import the header file wherever you want to use the tab bar controller:

```objc
#import "AKTabBarController.h"
```

### Creation and initialization of the tab bar
``` objective-c  
// Create and initialize the height of the tab bar to 50px.
_tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:50];

// Adding the view controllers to manage.
[_tabBarController setViewControllers:@[[[FirstViewController alloc] init], [[SecondViewController alloc] init], [[ThirdViewController alloc] init], [[FourthViewController alloc] init]]]];  
```

### Setting the title and image
(in each view controller)

``` objective-c
// Setting the image of the tab.
- (NSString *)tabImageName
{
	return @"myImage";
}

// Setting the title of the tab.
- (NSString *)tabTitle
{
	return @"Tab";
}
```

## Accessing the current AKTabViewController instance

``` objective-c
// Ensure to import AKTabController and the category for UIViewController
#import <AKTabBarController.h>
#import <AKTabBarController/UIViewController+AKTabBarController.h>

// It's now possible to access the current AKTabBarController instance.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.akTabBarController setTextColor:[UIColor redColor]];
}
```

**Note**: self.akTabBarController returns nil on devices running iOS < 5.0.

## Customization
### Setting the minimum height to display the title

``` objective-c  
[_tabBarController setMinimumHeightToDisplayTitle:50];
```

### Hide the tab title

``` objective-c  
[_tabBarController setTabTitleIsHidden:NO];
```
### Hide the tab bar when pushed in an UINavigationController
When pushing a viewcontroller in the viewControllers stack of an UINavigationController it is possible to hide the tab bar. It works exactely like the original UITabBarController:

``` objective-c
[viewController setHidesBottomBarWhenPushed:YES];
```
### Full customization example

``` objective-c
// Tab background Image
[_tabBarController setBackgroundImageName:@"noise-dark-gray.png"];
[_tabBarController setSelectedBackgroundImageName:@"noise-dark-blue.png"];

// Tabs top emboss Color
[_tabBarController setTabEdgeColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8]];

// Tabs colors settings
[_tabBarController setTabColors:@[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.0], [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]]]; // MAX 2 Colors
[_tabBarController setSelectedTabColors:@[[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0], [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0]]]; // MAX 2 Colors

// Tab stroke Color
[_tabBarController setTabStrokeColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];

// Icons color settings
[_tabBarController setIconColors:@[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1], [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]]]; // MAX 2 Colors
[_tabBarController setSelectedIconColors:@[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1], [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]]]; // MAX 2 Colors

// Text color
[_tabBarController setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
[_tabBarController setSelectedTextColor:[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0]];

// Text font
[_tabBarController setTextFont:[UIFont fontWithName:@"Chalkduster" size:14]];

// Hide / Show glossy effect on tab icons
[_tabBarController setIconGlossyIsHidden:YES];

// Enable / Disable pre-rendered image mode
[_tabBarController setTabIconPreRendered:YES];
```
###See below the result of the customization:  
![iPhone portrait](https://github.com/alikaragoz/AKTabBarController/raw/master/Screenshots/iphone-portrait-customized.png)

For further details see the Xcode example project.

##Requirements
- iOS >= 4.3
- ARC
- QuartzCore.framework

##Screenshots

###iPhone landscape
![iPhone landscape](https://github.com/alikaragoz/AKTabBarController/raw/master/Screenshots/iphone-landscape.png)

###iPad portrait
![iPhone portrait](https://github.com/alikaragoz/AKTabBarController/raw/master/Screenshots/ipad-portrait.png)

###iPad landscape
![iPad portrait](https://github.com/alikaragoz/AKTabBarController/raw/master/Screenshots/ipad-landscape.png)

##Credits
- Largely inspired by **Brian Collins**'s [BCTabBarController](https://github.com/briancollins/BCTabBarController) (for views imbrication).
- Icons used in the example project are designed by **Tomas Gajar** (@tomasgajar).

## Contact

Ali Karagoz

- http://github.com/alikaragoz
- http://twitter.com/alikaragoz

## License

AKTabBarController is available under the MIT license. See the LICENSE file for more info.
