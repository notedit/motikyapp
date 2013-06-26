//
//  MOSegue.m
//  Motiky
//
//  Created by notedit on 2/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOSegue.h"



@implementation MOSegue


- (void)perform
{
    NSLog(@"Performing Segue %@",self.identifier);
    [[self sourceViewController]  presentViewController:[self destinationViewController] animated:YES completion:^{
        
    }];

}

@end


@implementation MONonAnimatedSegue

- (id) initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        
    }
    
    return self;

}

- (void)perform
{
    NSLog(@"Performing Segue %@",self.identifier);    
    [[self sourceViewController]  presentViewController:[self destinationViewController] animated:NO completion:^{
        
    }];
}

@end
