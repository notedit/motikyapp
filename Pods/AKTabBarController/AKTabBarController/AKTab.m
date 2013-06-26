// AKTab.m
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

#import "AKTab.h"

// cross fade animation duration.
static const float kAnimationDuration = 0.15;

// Padding of the content
static const float kPadding = 4.0;

// Margin between the image and the title
static const float kMargin = 2.0;

// Margin at the top
static const float kTopMargin = 2.0;

@interface AKTab ()

// Permits the cross fade animation between the two images, duration in seconds.
- (void)animateContentWithDuration:(CFTimeInterval)duration;

@end

@implementation AKTab
{
    BOOL isTabIconPresent;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor clearColor];
        _titleIsHidden = NO;
        isTabIconPresent = NO;
    }
    return self;
}

#pragma mark - Touche handeling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self animateContentWithDuration:kAnimationDuration];
}

#pragma mark - Animation

- (void)animateContentWithDuration:(CFTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
    animation.duration = duration;
    [self.layer addAnimation:animation forKey:@"contents"];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // If the height of the container is too short, we do not display the title
    CGFloat offset = 1.0;
    
    if (_tabImageWithName) isTabIconPresent = YES;
    
    if (!_minimumHeightToDisplayTitle)
        _minimumHeightToDisplayTitle = _tabBarHeight - offset;
    
    BOOL displayTabTitle = (CGRectGetHeight(rect) + offset >= _minimumHeightToDisplayTitle) ? YES : NO;
    if (!isTabIconPresent) displayTabTitle = YES;
    if (_titleIsHidden) displayTabTitle = NO;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Container, basically centered in rect
    CGRect container = CGRectInset(rect, kPadding, kPadding);
    container.size.height -= kTopMargin;
    container.origin.y += kTopMargin;
    
    UIImage *image;
    CGRect imageRect = CGRectZero;
    CGFloat ratio = 0;
    
    if (isTabIconPresent)
    {
        // Tab's image
        image = [UIImage imageNamed:_tabImageWithName];
        
        // Getting the ratio for eventual scaling
        ratio = image.size.width / image.size.height;
        
        // Setting the imageContainer's size.
        imageRect.size = image.size;
    }
    
    // Title label
    UILabel *tabTitleLabel = [[UILabel alloc] init];
    tabTitleLabel.text = _tabTitle;
    tabTitleLabel.font = self.tabTitleFont ?: [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    CGSize labelSize = [tabTitleLabel.text sizeWithFont:tabTitleLabel.font forWidth:CGRectGetWidth(rect) lineBreakMode:NSLineBreakByTruncatingMiddle ];
    
    CGRect labelRect = CGRectZero;
    
    labelRect.size.height = (displayTabTitle) ? labelSize.height : 0;
    
    // Container of the image + label (when there is room)
    CGRect content = CGRectZero;
    content.size.width = CGRectGetWidth(container);
    
    // We determine the height based on the longest side of the image (when not square) , presence of the label and height of the container
    content.size.height = MIN(MAX(CGRectGetWidth(imageRect), CGRectGetHeight(imageRect)) + ((displayTabTitle) ? (kMargin + CGRectGetHeight(labelRect)) : 0), CGRectGetHeight(container));
    
    // Now we move the boxes
    content.origin.x = floorf(CGRectGetMidX(container) - CGRectGetWidth(content) / 2);
    content.origin.y = floorf(CGRectGetMidY(container) - CGRectGetHeight(content) / 2);
    
    labelRect.size.width = CGRectGetWidth(content);
    labelRect.origin.x = CGRectGetMinX(content);
    labelRect.origin.y = CGRectGetMaxY(content) - CGRectGetHeight(labelRect);
    
    if (!displayTabTitle)
        labelRect = CGRectZero;
    
    if (isTabIconPresent)
    {
        CGRect imageContainer = content;
        imageContainer.size.height = CGRectGetHeight(content) - ((displayTabTitle) ? (kMargin + CGRectGetHeight(labelRect)) : 0);
        
        // When the image is not square we have to make sure it will not go beyond the bonds of the container
        if (CGRectGetWidth(imageRect) >= CGRectGetHeight(imageRect)) {
            imageRect.size.width = MIN(CGRectGetHeight(imageRect), MIN(CGRectGetWidth(imageContainer), CGRectGetHeight(imageContainer)));
            imageRect.size.height = floorf(CGRectGetWidth(imageRect) / ratio);
        } else {
            imageRect.size.height = MIN(CGRectGetHeight(imageRect), MIN(CGRectGetWidth(imageContainer), CGRectGetHeight(imageContainer)));
            imageRect.size.width = floorf(CGRectGetHeight(imageRect) * ratio);
        }
        
        imageRect.origin.x = floorf(CGRectGetMidX(content) - CGRectGetWidth(imageRect) / 2);
        imageRect.origin.y = floorf(CGRectGetMidY(imageContainer) - CGRectGetHeight(imageRect) / 2);
    }
    
    CGFloat offsetY = rect.size.height - ((displayTabTitle) ? (kMargin + CGRectGetHeight(labelRect)) : 0) + kTopMargin;
    
    if (!self.selected) {
        
        // We draw the vertical lines for the border
        CGContextSaveGState(ctx);
        {
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetFillColorWithColor(ctx, _innerStrokeColor ? [_innerStrokeColor CGColor] : [[UIColor colorWithRed:.7f green:.7f blue:.7f alpha:.1f] CGColor]);
            CGContextFillRect(ctx, CGRectMake(0, kTopMargin, 1, rect.size.height - kTopMargin));
            CGContextFillRect(ctx, CGRectMake(rect.size.width - 1, 2, 1, rect.size.height - 2));
        }
        CGContextRestoreGState(ctx);
        
        if (isTabIconPresent)
        {
            if(self.tabIconPreRendered) {
                // Simply draw the pre-rendered image.
                CGContextSaveGState(ctx);
                {
                    CGContextTranslateCTM(ctx, 0.0, offsetY);
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextDrawImage(ctx, imageRect, image.CGImage);
                }
                CGContextRestoreGState(ctx);
            } else {
                // We draw the inner shadow which is just the image mask with an offset of 1 pixel
                CGContextSaveGState(ctx);
                {                
                    CGContextTranslateCTM(ctx, _tabIconShadowOffset.width, offsetY + _tabIconShadowOffset.height);
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextClipToMask(ctx, imageRect, image.CGImage);
                    CGContextSetFillColorWithColor(ctx, _tabIconShadowColor ? [_tabIconShadowColor CGColor] : [[UIColor colorWithRed:.0f green:.0f blue:.0f alpha:.8f] CGColor]);
                    CGContextFillRect(ctx, imageRect);
                }
                CGContextRestoreGState(ctx);
                
                // We draw the inner gradient
                CGContextSaveGState(ctx);
                {
                    CGContextTranslateCTM(ctx, 0, offsetY);
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextClipToMask(ctx, imageRect, image.CGImage);
                    
                    size_t num_locations = 2;
                    CGFloat locations[2] = {1.0, 0.0};
                    CGFloat components[8] = {0.353, 0.353, 0.353, 1.0, // Start color
                        0.612, 0.612, 0.612, 1.0};  // End color
                    
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                    CGGradientRef gradient = _tabIconColors ? CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)_tabIconColors, locations) : CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
                    
                    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, imageRect.origin.y + imageRect.size.height), CGPointMake(0, imageRect.origin.y), kCGGradientDrawsAfterEndLocation);
                    
                    CGColorSpaceRelease(colorSpace);
                    CGGradientRelease(gradient);
                }
                CGContextRestoreGState(ctx);
            }
        }
        
        if (displayTabTitle) {
            CGContextSaveGState(ctx);
            {
                UIColor *textColor = [UIColor colorWithRed:0.461 green:0.461 blue:0.461 alpha:1.0];
                CGContextSetFillColorWithColor(ctx, _textColor ? _textColor.CGColor : textColor.CGColor);
                [tabTitleLabel.text drawInRect:labelRect withFont:tabTitleLabel.font lineBreakMode:NSLineBreakByTruncatingMiddle  alignment:UITextAlignmentCenter];
            }
            CGContextRestoreGState(ctx);
        }
        
    } else if (self.selected) {
        
        // We fill the background with a noise pattern
        CGContextSaveGState(ctx);
        {
            [[UIColor colorWithPatternImage:[UIImage imageNamed:_selectedBackgroundImageName ? _selectedBackgroundImageName : @"AKTabBarController.bundle/noise-pattern"]] set];
            CGContextFillRect(ctx, rect);
            
            // We set the parameters of th gradient multiply blend
            size_t num_locations = 2;
            CGFloat locations[2] = {1.0, 0.0};
            CGFloat components[8] = {0.6, 0.6, 0.6, 1.0,  // Start color
                0.2, 0.2, 0.2, 0.4}; // End color
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = _tabSelectedColors ? CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)_tabSelectedColors, locations) : CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
            CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, kTopMargin), CGPointMake(0, rect.size.height - kTopMargin), kCGGradientDrawsAfterEndLocation);
            
            // top dark emboss
            CGContextSetBlendMode(ctx, kCGBlendModeNormal);
            UIColor *topEdgeColor = _topEdgeColor;
            if (!topEdgeColor) {
                _edgeColor ? _edgeColor : [UIColor colorWithRed:.1f green:.1f blue:.1f alpha:.8f];
            }
            CGContextSetFillColorWithColor(ctx, topEdgeColor.CGColor);
            CGContextFillRect(ctx, CGRectMake(0, 0, rect.size.width, 1));
            
            CGColorSpaceRelease(colorSpace);
            CGGradientRelease(gradient);
        }
        CGContextRestoreGState(ctx);
        
        // We draw the vertical lines for the border
        CGContextSaveGState(ctx);
        {
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetFillColorWithColor(ctx, _strokeColor ? [_strokeColor CGColor] : [[UIColor colorWithRed:.7f green:.7f blue:.7f alpha:.4f] CGColor]);
            CGContextFillRect(ctx, CGRectMake(0, 2, 1, rect.size.height - 2));
            CGContextFillRect(ctx, CGRectMake(rect.size.width - 1, 2, 1, rect.size.height - 2));
        }
        CGContextRestoreGState(ctx);
        
        if (isTabIconPresent)
        {
            if(self.tabIconPreRendered) {
                // Simply draw the pre-rendered image.
                CGContextSaveGState(ctx);
                {
                    CGContextTranslateCTM(ctx, 0.0, offsetY);
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextDrawImage(ctx, imageRect, image.CGImage);
                }
                CGContextRestoreGState(ctx);
            } else {
                // We draw the outer glow
                CGContextSaveGState(ctx);
                {
                    CGContextTranslateCTM(ctx, 0.0, offsetY);
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 10.0, _tabIconOuterGlowColorSelected ? [_tabIconOuterGlowColorSelected CGColor] : [UIColor colorWithRed:0.169 green:0.418 blue:0.547 alpha:1].CGColor);
                    CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
                    CGContextDrawImage(ctx, imageRect, image.CGImage);
                    
                }
                CGContextRestoreGState(ctx);
                
                // We draw the inner gradient
                CGContextSaveGState(ctx);
                {
                    CGContextTranslateCTM(ctx, 0, offsetY);
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextClipToMask(ctx, imageRect, image.CGImage);
                    
                    size_t num_locations = 2;
                    CGFloat locations[2] = {1.0, 0.2};
                    CGFloat components[8] = {0.082, 0.369, 0.663, 1.0, // Start color
                        0.537, 0.773, 0.988, 1.0};  // End color
                    
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                    CGGradientRef gradient = _tabIconColorsSelected ? CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)_tabIconColorsSelected, locations) : CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
                    
                    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, imageRect.origin.y + imageRect.size.height), CGPointMake(0, imageRect.origin.y), kCGGradientDrawsAfterEndLocation);
                    
                    CGColorSpaceRelease(colorSpace);
                    CGGradientRelease(gradient);
                }
                CGContextRestoreGState(ctx);
                
                
                // We draw the glossy effect over the image
                CGContextSaveGState(ctx);
                {
                    // Center of the circle + an offset to have the right angle no matter the size of the container
                    CGFloat posX = CGRectGetMinX(container) - CGRectGetHeight(container);
                    CGFloat posY = CGRectGetMinY(container) - CGRectGetHeight(container) * 2 - CGRectGetWidth(container);
                    
                    // Getting the icon center
                    CGFloat dX = CGRectGetMidX(imageRect) - posX;
                    CGFloat dY = CGRectGetMidY(imageRect) - posY;
                    
                    // Calculating the radius
                    CGFloat radius = sqrtf((dX * dX) + (dY * dY));
                    
                    // We draw the circular path
                    CGMutablePathRef glossPath = CGPathCreateMutable();
                    CGPathAddArc(glossPath, NULL, posX, posY, radius, M_PI, 0, YES);
                    CGPathCloseSubpath(glossPath);
                    CGContextAddPath(ctx, glossPath);
                    CGContextClip(ctx);
                    
                    // Clipping to the image path
                    CGContextTranslateCTM(ctx, 0, offsetY);
                    CGContextScaleCTM(ctx, 1.0, -1.0);
                    CGContextClipToMask(ctx, imageRect, image.CGImage);
                    
                    // Drawing the clipped gradient
                    size_t num_locations = 2;
                    CGFloat locations[2] = {1, 0};
                    CGFloat components[8] = {1.0, 1.0, 1.0, _glossyIsHidden ? 0 : 0.5, // Start color
                        1.0, 1.0, 1.0, _glossyIsHidden ? 0 : 0.15};  // End color
                    
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
                    CGContextDrawRadialGradient(ctx, gradient, CGPointMake(CGRectGetMinX(imageRect), CGRectGetMinY(imageRect)), 0, CGPointMake(CGRectGetMaxX(imageRect), CGRectGetMaxY(imageRect)), radius, kCGGradientDrawsBeforeStartLocation);
                    
                    CGColorSpaceRelease(colorSpace);
                    CGGradientRelease(gradient);
                    CGPathRelease(glossPath);
                }
                CGContextRestoreGState(ctx);
            }
        }
        
        if (displayTabTitle) {
            CGContextSaveGState(ctx);
            {
                UIColor *textColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.0];
                CGContextSetFillColorWithColor(ctx, _selectedTextColor ? _selectedTextColor.CGColor : textColor.CGColor);
                [tabTitleLabel.text drawInRect:labelRect withFont:tabTitleLabel.font lineBreakMode:NSLineBreakByTruncatingMiddle  alignment:UITextAlignmentCenter];
            }
            CGContextRestoreGState(ctx);
        }
        
    }
    
}
@end