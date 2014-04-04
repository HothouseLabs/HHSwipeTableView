//
//  HHSwipeButton.h
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSwipeTableViewCell.h"

@interface HHSwipeButton : UIView
@property (nonatomic, assign, readonly) HHSwipeTableViewCellState swipeState; // left or right button
@property (nonatomic, assign, readonly) NSUInteger indexInContainer; // index of the button in either the left or right container
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@end
