//
//  HHScrollView.m
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

//  Modified from NSScreencast

#import "HHScrollView.h"

@implementation HHScrollView

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!self.dragging) {
        [self.tapDelegate tapScrollView:self touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesMoved:touches withEvent:event];
    
    [self.tapDelegate tapScrollView:self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.tapDelegate tapScrollView:self  touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSLog(@"Touch on scroll view ended");
    if (!self.dragging) {
        [self.tapDelegate tapScrollView:self touchesEnded:touches withEvent:event];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}
@end
