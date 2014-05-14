//
//  HHSwipeTableView.h
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSwipeTableViewCell.h"
@class HHSwipeTableView;
@class HHSwipeButton;

@protocol HHSwipeTableViewDelegate <UITableViewDelegate>
- (NSArray *)swipeTableView:(HHSwipeTableView *)swipeTableView buttonsInState:(HHSwipeTableViewCellState)state forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)swipeTableViewButtonWidth:(HHSwipeTableView *)swipeTableView;
- (void)swipeTableView:(HHSwipeTableView *)swipeTableView didTapButton:(HHSwipeButton *)button atIndex:(NSUInteger)index inState:(HHSwipeTableViewCellState)state forRowAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface HHSwipeTableView : UITableView
@property (nonatomic, weak) id<HHSwipeTableViewDelegate> swipeDelegate;
- (void)resetVisibleCellsAnimated:(BOOL)animated;
- (HHSwipeButton *)buttonAtIndex:(NSUInteger)index inState:(HHSwipeTableViewCellState)state forRowAtIndexPath:(NSIndexPath *)indexPath;
@end
