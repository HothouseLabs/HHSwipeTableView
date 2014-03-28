//
//  HHSwipeTableCell.h
//  SwipeToRevealCell
//
//  Created by Yuk Lai Suen on 3/27/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HHScrollView, HHTapGestureRecognizer;

static NSString* HHSwipeTableViewCellDidOpenNotification = @"HHSwipeTableViewCellDidOpenNotification";
static NSString* HHSwipeTableViewCellNeedsToCloseNotification = @"HHSwipeTableViewCellNeedsToCloseNotification";

typedef NS_ENUM(NSUInteger, HHSwipeTableViewCellState) {
    HHSwipeTableViewCellState_None,
    HHSwipeTableViewCellState_Left,
    HHSwipeTableViewCellState_Center,
    HHSwipeTableViewCellState_Right,
};

@interface HHSwipeTableViewCell : UITableViewCell
@property (nonatomic, weak, readonly) UITableView * tableView;
@property (nonatomic, strong, readonly) UIScrollView * scrollView;
@property (nonatomic, strong, readonly) UIView * scrollContentView;
@property (nonatomic, strong) id swipeId; // This helps the table view to identify the swipe state of the object so on reloadData the correct state can be recovered
@property (nonatomic, assign) HHSwipeTableViewCellState swipeState;
@property (nonatomic, strong, readonly) HHTapGestureRecognizer *singleTapGestureRecognizer;

- (void)setSwipeState:(HHSwipeTableViewCellState)swipeState animated:(BOOL)animated;
@end
