//
//  HHSwipeTableView.m
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import "HHSwipeTableView.h"
#import "HHSwipeTableViewCell.h"
#import "HHSwipeTableViewCellScrollView.h"

@interface HHSwipeTableViewCell (Private)
@property (nonatomic, weak) HHSwipeTableView * tableView;
@property (nonatomic, strong) NSArray* buttonsOnLeft;
@property (nonatomic, strong) NSArray* buttonsOnRight;
@property (nonatomic, assign) CGFloat buttonWidth;
@end

@interface HHSwipeTableView ()
@property (nonatomic, strong) NSMutableDictionary* swipeStates;
@end

@implementation HHSwipeTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        _swipeStates = [NSMutableDictionary dictionary];
        _swipeEnabled = YES;
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    if (self.isTracking) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HHSwipeTableViewCellNeedsToCloseNotification object:self];
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString*)identifier
{
    NSAssert(NO, @"Not supported currently. Use dequeueReusableCellWithIdentifier:forIndexPath");
    return nil;
}

- (id)dequeueReusableCellWithIdentifier:(NSString*)identifier forIndexPath:(NSIndexPath*)indexPath
{
    HHSwipeTableViewCell* cell = (HHSwipeTableViewCell*)[super dequeueReusableCellWithIdentifier:identifier];
    if (![cell isKindOfClass:[HHSwipeTableViewCell class]]) {
        return cell;
    }
    
    cell.tableView = self;
    
    cell.buttonsOnLeft = [self.swipeDelegate swipeTableView:self buttonsInState:HHSwipeTableViewCellState_Left forRowAtIndexPath:indexPath];
    cell.buttonsOnRight = [self.swipeDelegate swipeTableView:self buttonsInState:HHSwipeTableViewCellState_Right forRowAtIndexPath:indexPath];
    cell.buttonWidth = [self.swipeDelegate swipeTableViewButtonWidth:self];
    cell.scrollView.scrollEnabled = self.swipeEnabled;
    return cell;
}

- (void)resetVisibleCellsAnimated:(BOOL)animated
{
    NSArray *visibleCells = [self visibleCells];
    for (UITableViewCell *cell in visibleCells) {
        if (![cell isKindOfClass:[HHSwipeTableViewCell class]]) {
            continue;
        }
        
        HHSwipeTableViewCell *swipeCell = (HHSwipeTableViewCell *)cell;
        [swipeCell setSwipeState:HHSwipeTableViewCellState_Center animated:animated];
    }
}

- (HHSwipeButton *)buttonAtIndex:(NSUInteger)index inState:(HHSwipeTableViewCellState)state forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    if (!cell) {
        return nil; // Cell is not visible
    }
    
    if (![cell isKindOfClass:[HHSwipeTableViewCell class]]) {
        return nil; // There is no button
    }
    
    HHSwipeTableViewCell *swipeCell = (HHSwipeTableViewCell *)cell;
    if (state == HHSwipeTableViewCellState_Left) {
        if (index >= swipeCell.buttonsOnLeft.count) {
            return nil;
        }
        
        return swipeCell.buttonsOnLeft[index];
    } else if (state == HHSwipeTableViewCellState_Right) {
        if (index >= swipeCell.buttonsOnRight.count) {
            return nil;
        }
        
        return swipeCell.buttonsOnRight[index];
    } else {
        return nil;
    }
}

- (void)setSwipeEnabled:(BOOL)swipeEnabled
{
    _swipeEnabled = swipeEnabled;

    NSArray *visibleCells = [self visibleCells];
    for (UITableViewCell *cell in visibleCells) {
        if (![cell isKindOfClass:[HHSwipeTableViewCell class]]) {
            continue;
        }
        
        HHSwipeTableViewCell *swipeCell = (HHSwipeTableViewCell *)cell;
        swipeCell.scrollView.scrollEnabled = swipeEnabled;
    }

}

@end
