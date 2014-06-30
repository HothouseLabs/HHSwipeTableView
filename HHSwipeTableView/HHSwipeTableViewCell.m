//
//  HHSwipeTableCell.m
//  SwipeToRevealCell
//
//  Created by Yuk Lai Suen on 3/27/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import "HHSwipeTableViewCell.h"
#import "HHSwipeTableView.h"
#import "HHSwipeTableViewCellScrollView.h"
#import "HHTapGestureRecognizer.h"
#import "HHSwipeButton.h"
#import "HHLog.h"

@interface HHSwipeButton(Private)
@property (nonatomic, assign) HHSwipeTableViewCellState swipeState;
@property (nonatomic, assign) NSUInteger indexInContainer;
@end

@interface HHSwipeTableView (Private)
@property (nonatomic, strong) NSMutableDictionary* swipeStates;
@end

@interface HHSwipeTableViewCell () <UIScrollViewDelegate>
// @property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) HHSwipeTableView * swipeTableView;
@property (nonatomic, strong) NSArray* buttonsOnLeft;
@property (nonatomic, strong) NSArray* buttonsOnRight;
@property (nonatomic, assign) CGFloat buttonWidth;

@property (nonatomic, assign, readonly) NSUInteger numberOfButtonsOnLeft;
@property (nonatomic, assign, readonly) NSUInteger numberOfButtonsOnRight;
@property (nonatomic, strong) HHSwipeTableViewCellScrollView * scrollView;
@property (nonatomic, strong) UIView * scrollContentView;
@property (nonatomic, strong) UIView * rightButtonContainerView;
@property (nonatomic, strong) UIView * leftButtonContainerView;
@property (nonatomic, strong) UIButton * moreButton;
@property (nonatomic, strong) UIButton * deleteButton;
@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) HHTapGestureRecognizer * singleTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGestureRecognizer;

@end

@implementation HHSwipeTableViewCell

- (NSUInteger)numberOfButtonsOnLeft
{
    return self.buttonsOnLeft.count;
}

- (NSUInteger)numberOfButtonsOnRight
{
    return self.buttonsOnRight.count;
}

- (CGFloat)contentOffsetXForLeft
{
    return 0;
}

- (CGFloat)contentOffsetXForCenter
{
    return [self contentOffsetXForLeft] + self.buttonWidth * [self numberOfButtonsOnLeft];
}

- (CGFloat)contentOffsetXForRight
{
    return [self contentOffsetXForCenter] + self.buttonWidth * [self numberOfButtonsOnRight];
}

- (void)setContentOffsetXForState:(HHSwipeTableViewCellState)swipeState
{
    switch (swipeState) {
        case HHSwipeTableViewCellState_Left:
            if (self.scrollView.contentOffset.x != [self contentOffsetXForLeft]) {
                self.scrollView.contentOffset = CGPointMake([self contentOffsetXForLeft], 0);
            }
            break;
        case HHSwipeTableViewCellState_Center:
            if (self.scrollView.contentOffset.x != [self contentOffsetXForCenter]) {
                self.scrollView.contentOffset = CGPointMake([self contentOffsetXForCenter], 0);
            }
            break;
        case HHSwipeTableViewCellState_Right:
            if (self.scrollView.contentOffset.x != [self contentOffsetXForRight]) {
                self.scrollView.contentOffset = CGPointMake([self contentOffsetXForRight], 0);
            }
            break;
        default:
            NSAssert(NO, @"Invalid swipe state: %u", swipeState);
            break;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.scrollView = [HHSwipeTableViewCellScrollView new];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = YES;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.scrollsToTop = NO;
        
        [self.contentView addSubview:self.scrollView];
        
        self.scrollContentView = [UIView new];
        
        self.scrollView.scrollContentView = self.scrollContentView;
        [self.scrollView addSubview:self.scrollContentView];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onOpen:)
                                                     name: HHSwipeTableViewCellDidOpenNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onClose:)
                                                     name: HHSwipeTableViewCellNeedsToCloseNotification
                                                   object: nil];
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressController:)];
        _longPressGestureRecognizer.delegate = self;
        [_scrollContentView addGestureRecognizer:_longPressGestureRecognizer];
        
        _singleTapGestureRecognizer = [[HHTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTapGestureRecognizer.delegate = self;
        [_scrollContentView addGestureRecognizer:_singleTapGestureRecognizer];
        //  For tap to be a tap long press has to fail.
        [_singleTapGestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
        
        [_scrollContentView setUserInteractionEnabled:YES];
        _swipeState = HHSwipeTableViewCellState_Center;
        
        // Note: workaround for iOS7. If this is not set the cell's separator mysteriously disappear
        // and scrollContentView and some other views turns transparent.
        // Subclasses can overwrite this behavior
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)dealloc
{
    self.singleTapGestureRecognizer.delegate = nil;
    self.longPressGestureRecognizer.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    
    if ([tableView isKindOfClass:[HHSwipeTableView class]]) {
        _swipeTableView = (HHSwipeTableView *)tableView;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.singleTapGestureRecognizer) {
        if (otherGestureRecognizer == self.tableView.panGestureRecognizer) {
            return YES;
        } else if (otherGestureRecognizer == self.scrollView.panGestureRecognizer) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (otherGestureRecognizer == self.scrollView.panGestureRecognizer ||
        otherGestureRecognizer == self.singleTapGestureRecognizer) {
        NSMutableArray *allButtons = [NSMutableArray array];
        if (self.buttonsOnLeft) {
            [allButtons addObjectsFromArray:self.buttonsOnLeft];
        }
        
        if (self.buttonsOnRight) {
            [allButtons addObjectsFromArray:self.buttonsOnRight];
        }
        
        for (HHSwipeButton *button in allButtons) {
            if (gestureRecognizer == button.tapGestureRecognizer) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)onOpen:(NSNotification*)notification
{
    if (![[notification.object swipeId] isEqual:self.swipeId]) {
        if (self.swipeState != HHSwipeTableViewCellState_Center) {
            [self setSwipeState:HHSwipeTableViewCellState_Center animated:YES];
        }
    }
}

- (void)onClose:(NSNotification*)notification
{
    [self setSwipeState:HHSwipeTableViewCellState_Center animated:YES];
}

- (void)setSwipeState:(HHSwipeTableViewCellState)swipeState
{
    if (_swipeState == swipeState) {
        return;
    }
    
    HHTrace(@"Swipe from state: %u to state: %u", _swipeState, swipeState);
    
    _swipeState = swipeState;
    if (self.swipeId) {
        self.swipeTableView.swipeStates[self.swipeId] = @(swipeState);
    }
}

- (void)setSwipeState:(HHSwipeTableViewCellState)swipeState animated:(BOOL)animated
{
    HHTrace(@"Animate swipe from state: %u to state: %u", _swipeState, swipeState);
    
    if (!animated) {
        [self setContentOffsetXForState:swipeState];
        self.swipeState = swipeState;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self setContentOffsetXForState:swipeState];
                             self.swipeState = swipeState;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    });
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.leftButtonContainerView removeFromSuperview];
    [self.rightButtonContainerView removeFromSuperview];self.leftButtonContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.rightButtonContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Inserting the button container views as siblings of the scroll view
    // will prevent the tap events on the button being disabled.
    // See setButtonFrameWithContentOffsetX on adjusting the button position
    // for an illustion of the swipe.
    [self.scrollView insertSubview:self.leftButtonContainerView belowSubview:self.scrollContentView];
    
    [self.scrollView insertSubview:self.rightButtonContainerView belowSubview:self.scrollContentView];
    
    self.contentView.frame = self.bounds;
    self.scrollView.frame = self.contentView.frame;
    self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width + [self contentOffsetXForRight], self.scrollView.frame.size.height);
    self.scrollContentView.frame = CGRectMake([self contentOffsetXForCenter], 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    CGFloat buttonHeight = self.frame.size.height; // use the cell height as the button width and height
    [self.buttonsOnLeft enumerateObjectsUsingBlock:^(HHSwipeButton *button, NSUInteger idx, BOOL* stop) {
        NSAssert([button isKindOfClass:[HHSwipeButton class]], @"Button should be of class HHSwipeButton");
        
        button.frame = CGRectMake(idx * self.buttonWidth, 0, self.buttonWidth, buttonHeight);
        button.indexInContainer = idx;
        button.swipeState = HHSwipeTableViewCellState_Left;
        [button.tapGestureRecognizer addTarget:self action:@selector(buttonPressed:)];
        button.tapGestureRecognizer.delegate = self;
        [self.leftButtonContainerView addSubview:button];
    }];
    
    self.leftButtonContainerView.frame = CGRectMake(0, 0, self.buttonsOnLeft.count * self.buttonWidth, buttonHeight);
    
    [self.buttonsOnRight enumerateObjectsUsingBlock:^(HHSwipeButton *button, NSUInteger idx, BOOL* stop) {
        NSAssert([button isKindOfClass:[HHSwipeButton class]], @"Button should be of class HHSwipeButton");
        
        button.frame = CGRectMake(idx * self.buttonWidth, 0, self.buttonWidth, buttonHeight);
        button.indexInContainer = idx;
        button.swipeState = HHSwipeTableViewCellState_Right;
        [button.tapGestureRecognizer addTarget:self action:@selector(buttonPressed:)];
        button.tapGestureRecognizer.delegate = self;
        [self.rightButtonContainerView addSubview:button];
    }];
    
    self.rightButtonContainerView.frame = CGRectMake(self.frame.size.width - self.buttonsOnRight.count * self.buttonWidth, 0, self.buttonsOnRight.count * self.buttonWidth, buttonHeight);
    
    if (self.swipeId) {
        HHSwipeTableViewCellState swipeState = [self.swipeTableView.swipeStates[self.swipeId] unsignedIntegerValue];
        if (swipeState == HHSwipeTableViewCellState_None) {
            [self setSwipeState:HHSwipeTableViewCellState_Center animated:NO];
        } else {
            [self setSwipeState:swipeState animated:NO];
        }
        
    } else {
        [self setSwipeState:HHSwipeTableViewCellState_Center animated:NO];
    }
    
    [self setButtonFrameWithContentOffsetX:self.scrollView.contentOffset.x];
}

- (void)buttonPressed:(UITapGestureRecognizer *)tapGestureRecognizer
{
    HHSwipeButton *button = (HHSwipeButton *)tapGestureRecognizer.view;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    if (indexPath != nil) { // this can happen if the cell is no longer visible by the time we get here (rare)
        [self.swipeTableView.swipeDelegate swipeTableView:self.swipeTableView didTapButton:button atIndex:button.indexInContainer inState:button.swipeState forRowAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)setButtonFrameWithContentOffsetX:(CGFloat)x
{
    // Hide the opposite buttons to remove defect while bouncing, and also when the length of left/right buttons overlap
    if (x < [self contentOffsetXForCenter]) {
        self.leftButtonContainerView.hidden = NO;
        self.rightButtonContainerView.hidden = YES;
    } else if (x > [self contentOffsetXForCenter]) {
        self.leftButtonContainerView.hidden = YES;
        self.rightButtonContainerView.hidden = NO;
    }
    
    CGRect leftFrame = self.leftButtonContainerView.frame;
    leftFrame.origin.x = self.scrollContentView.frame.origin.x - leftFrame.size.width + x;
    HHTrace(@"Left frame: %f", leftFrame.origin.x);
    self.leftButtonContainerView.frame = leftFrame;
    
    CGRect rightFrame = self.rightButtonContainerView.frame;
    rightFrame.origin.x = self.scrollContentView.frame.size.width - rightFrame.size.width + x;
    HHTrace(@"Right frame: %f", rightFrame.origin.x);
    self.rightButtonContainerView.frame = rightFrame;
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (scrollView != self.scrollView) {
        return;
    }
    
    HHTrace(@"currentState: %u, scrollViewDidScroll: scrollView.contentOffset: %f", self.swipeState, scrollView.contentOffset.x);
    
    [self setHighlighted:NO animated:NO];
    [self setSelected:NO animated:NO];
    
    [self setButtonFrameWithContentOffsetX:scrollView.contentOffset.x];
    
    if (scrollView.isTracking) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HHSwipeTableViewCellDidOpenNotification object:self];
    }
    // Prevent pan gesture to go over the current intended end state
    CGPoint contentOffset = scrollView.contentOffset;
    
    if (self.swipeState == HHSwipeTableViewCellState_Right && (contentOffset.x < [self contentOffsetXForCenter])) {
        contentOffset.x = [self contentOffsetXForCenter];
    } else if (self.swipeState == HHSwipeTableViewCellState_Left && contentOffset.x > [self contentOffsetXForCenter]) {
        contentOffset.x = [self contentOffsetXForCenter];
    }

    scrollView.contentOffset = contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView*)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint*)targetContentOffset
{
    if (scrollView != self.scrollView) {
        return;
    }
    
    HHTrace(@"currentState: %u, scrollView.contentOffset: %f, velocity: %f, targetContentOffset: %f", self.swipeState, scrollView.contentOffset.x, velocity.x, targetContentOffset->x);

    switch (self.swipeState) {
        case HHSwipeTableViewCellState_Left:
        {
            if (targetContentOffset->x >= [self contentOffsetXForCenter] ||
                (velocity.x == 0 && targetContentOffset->x <= [self contentOffsetXForCenter])) {
                targetContentOffset->x = [self contentOffsetXForCenter];
                self.swipeState = HHSwipeTableViewCellState_Center;
            } else {
                targetContentOffset->x = [self contentOffsetXForLeft];
            }
            break;
        }
        case HHSwipeTableViewCellState_Center:
        {
            if ((targetContentOffset->x < [self contentOffsetXForCenter]) ||
                (velocity.x == 0 && targetContentOffset->x < [self contentOffsetXForCenter])) {
                targetContentOffset->x = [self contentOffsetXForLeft];
                self.swipeState = HHSwipeTableViewCellState_Left;
            } else if ((targetContentOffset->x > [self contentOffsetXForCenter]) ||
                       (velocity.x == 0 && targetContentOffset->x > [self contentOffsetXForCenter])) {
                targetContentOffset->x = [self contentOffsetXForRight];
                self.swipeState = HHSwipeTableViewCellState_Right;
            } else {
                targetContentOffset->x = [self contentOffsetXForCenter];
                self.swipeState = HHSwipeTableViewCellState_Center;
            }
            break;
        }
        case HHSwipeTableViewCellState_Right:
        {
            if ((targetContentOffset->x < [self contentOffsetXForRight]) ||
                (velocity.x == 0 && targetContentOffset->x >= [self contentOffsetXForCenter])) {
                targetContentOffset->x = [self contentOffsetXForCenter];
                self.swipeState = HHSwipeTableViewCellState_Center;
            } else {
                targetContentOffset->x = [self contentOffsetXForRight];
            }
            break;
        }
        default:
            NSAssert(NO, @"Current statue is not supported: %u", self.swipeState);
            break;
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        HHTrace(@"Setting highlighted...");
        if (self.swipeState == HHSwipeTableViewCellState_Center) {
            [self setHighlighted:YES animated:NO];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        
        HHTrace(@"Setting normal...");
        [self setHighlighted:NO animated:NO];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (self.swipeState != HHSwipeTableViewCellState_Center) {
            [self setSwipeState:HHSwipeTableViewCellState_Center animated:YES];
            return;
        }
        
        HHTrace(@"did select....");
        NSIndexPath* indexPath = [self.tableView indexPathForCell:self];
        [self setHighlighted:NO animated:NO];
        
        BOOL newSelectState = !self.isSelected;
        if (newSelectState) {
            if ([self.tableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
                [self.tableView.delegate tableView:self.tableView willSelectRowAtIndexPath:indexPath];
            }
        } else {
            if ([self.tableView.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
                [self.tableView.delegate tableView:self.tableView willDeselectRowAtIndexPath:indexPath];
            }
        }
        
        self.selected = newSelectState;
        
        if (newSelectState) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            }
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            if ([self.tableView.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
                [self.tableView.delegate tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void) longPressController: (UILongPressGestureRecognizer*)gesture
{
    //  TODO: Now react to long press.
}

@end
