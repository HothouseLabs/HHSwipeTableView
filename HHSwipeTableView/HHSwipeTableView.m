//
//  HHSwipeTableView.m
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import "HHSwipeTableView.h"
#import "HHSwipeTableViewCell.h"

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
    return cell;
}
@end
