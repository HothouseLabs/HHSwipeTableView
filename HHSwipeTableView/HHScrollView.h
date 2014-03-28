//
//  HHScrollView.h
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

//  Modified from NSScreencast

#import <UIKit/UIKit.h>

@protocol HHScrollView;

@interface HHScrollView:UIScrollView

@property (nonatomic, weak) id<HHScrollView> tapDelegate;
@end

@protocol HHScrollView <UIScrollViewDelegate>
@optional

- (void)tapScrollView:(HHScrollView*)scrollView touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)tapScrollView:(HHScrollView*)scrollView touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)tapScrollView:(HHScrollView*)scrollView touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
@end