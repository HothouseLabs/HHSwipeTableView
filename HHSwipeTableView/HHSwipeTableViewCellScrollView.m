//
//  HHSwipeTableViewCellScrollView.m
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 4/29/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import "HHSwipeTableViewCellScrollView.h"
#import "HHTrace.h"

// Define at 15 degrees above or below a horizontal line
#define DEFAULT_SWIPE_ANGLE_ALLOWED M_PI / 12

@implementation HHSwipeTableViewCellScrollView
- (id)init
{
    self = [super init];
    if (self) {
        self.horizontalSwipeAngleInRadians = DEFAULT_SWIPE_ANGLE_ALLOWED;
    }
    return self;
}

// Customize the angle in which the swipe should be detected in the swipe speed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self.scrollContentView];
        HHTrace(@"Velocity: %f, %f", velocity.x, velocity.y);
        if (velocity.x != 0 && velocity.y != 0) {
            // Take absolute
            CGFloat angle = atan(fabs(velocity.y) / fabs(velocity.x));
            HHTrace(@"Angle: %f", angle);
            return angle < self.horizontalSwipeAngleInRadians;
        }
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end
