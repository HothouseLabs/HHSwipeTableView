//
//  HHTapGestureRecognizer.m
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "HHTapGestureRecognizer.h"

@implementation HHTapGestureRecognizer

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (self.state == UIGestureRecognizerStateBegan) {
        self.state = UIGestureRecognizerStateEnded;
    }
}
@end
