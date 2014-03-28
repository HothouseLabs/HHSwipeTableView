//
//  HHSwipeTableCell.m
//  SwipeToRevealCell
//
//  Created by Yuk Lai Suen on 3/27/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import "HHSwipeTableViewCell.h"
#import "HHSwipeTableView.h"
//#import "HHScrollView.h"
#import "HHTapGestureRecognizer.h"
#import "HHSwipeButton.h"

@interface HHSwipeButton(Private)
@property (nonatomic, assign) HHSwipeTableViewCellState swipeState;
@property (nonatomic, assign) NSUInteger indexInContainer;
@end

@interface HHSwipeTableView (Private)
@property (nonatomic, strong) NSMutableDictionary* swipeStates;
@end

@interface HHSwipeTableViewCell () <UIScrollViewDelegate>
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) HHSwipeTableView * swipeTableView;
@property (nonatomic, strong) NSArray* buttonsOnLeft;
@property (nonatomic, strong) NSArray* buttonsOnRight;
@property (nonatomic, assign) CGFloat buttonWidth;

@property (nonatomic, assign, readonly) NSUInteger numberOfButtonsOnLeft;
@property (nonatomic, assign, readonly) NSUInteger numberOfButtonsOnRight;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIView * scrollContentView;
@property (nonatomic, strong) UIView * rightButtonContainerView;
@property (nonatomic, strong) UIView * leftButtonContainerView;
@property (nonatomic, strong) UIButton * moreButton;
@property (nonatomic, strong) UIButton * deleteButton;
@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) HHTapGestureRecognizer *singleTapGestureRecognizer;
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
            self.scrollView.contentOffset = CGPointMake([self contentOffsetXForLeft], 0);
            break;
        case HHSwipeTableViewCellState_Center:
            self.scrollView.contentOffset = CGPointMake([self contentOffsetXForCenter], 0);
            break;
        case HHSwipeTableViewCellState_Right:
            self.scrollView.contentOffset = CGPointMake([self contentOffsetXForRight], 0);
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
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.delegate = self;
        
        [self.contentView addSubview:self.scrollView];
        
        self.scrollContentView = [[UIView alloc] init];
        
        [self.scrollView addSubview:self.scrollContentView];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onOpen:)
                                                     name: HHSwipeTableViewCellDidOpenNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onClose:)
                                                     name: HHSwipeTableViewCellNeedsToCloseNotification
                                                   object: nil];
        
        _singleTapGestureRecognizer = [[HHTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [_singleTapGestureRecognizer requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
        [_scrollContentView addGestureRecognizer:_singleTapGestureRecognizer];
        [_scrollContentView setUserInteractionEnabled:YES];
        _swipeState = HHSwipeTableViewCellState_Center;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    if ([tableView isKindOfClass:[HHSwipeTableView class]]) {
        _swipeTableView = (HHSwipeTableView *)tableView;
    }
}

- (void)onOpen:(NSNotification*)notification
{
    if (notification.object != self) {
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
    
    NSLog(@"Swipe from state: %u to state: %u", _swipeState, swipeState);
    
    _swipeState = swipeState;
    if (self.swipeId) {
        self.swipeTableView.swipeStates[self.swipeId] = @(swipeState);
    }
}

- (void)setSwipeState:(HHSwipeTableViewCellState)swipeState animated:(BOOL)animated
{
    NSLog(@"Animate swipe from state: %u to state: %u", _swipeState, swipeState);
    
    if (!animated) {
        [self setContentOffsetXForState:swipeState];
        self.swipeState = swipeState;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self setContentOffsetXForState:swipeState];
                         }
                         completion:^(BOOL finished) {
                             self.swipeState = swipeState;
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
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.leftButtonContainerView addSubview:button];
    }];
    
    self.leftButtonContainerView.frame = CGRectMake(0, 0, self.buttonsOnLeft.count * self.buttonWidth, buttonHeight);
    
    [self.buttonsOnRight enumerateObjectsUsingBlock:^(HHSwipeButton *button, NSUInteger idx, BOOL* stop) {
        NSAssert([button isKindOfClass:[HHSwipeButton class]], @"Button should be of class HHSwipeButton");
        
        button.frame = CGRectMake(idx * self.buttonWidth, 0, self.buttonWidth, buttonHeight);
        button.indexInContainer = idx;
        button.swipeState = HHSwipeTableViewCellState_Right;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)buttonPressed:(id)sender
{
    HHSwipeButton *button = (HHSwipeButton *)sender;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    [self.swipeTableView.swipeDelegate swipeTableView:self.swipeTableView didTapButtonAtIndex:button.indexInContainer inState:button.swipeState forRowAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate
- (void)setButtonFrameWithContentOffsetX:(CGFloat)x
{
    CGRect leftFrame = self.leftButtonContainerView.frame;
    leftFrame.origin.x = self.scrollContentView.frame.origin.x - leftFrame.size.width + x;
    NSLog(@"Left frame: %f", leftFrame.origin.x);
    self.leftButtonContainerView.frame = leftFrame;
    
    CGRect rightFrame = self.rightButtonContainerView.frame;
    rightFrame.origin.x = self.scrollContentView.frame.size.width - rightFrame.size.width + x;
    NSLog(@"Right frame: %f", rightFrame.origin.x);
    self.rightButtonContainerView.frame = rightFrame;
}


- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    NSLog(@"currentState: %u, scrollViewDidScroll: scrollView.contentOffset: %f", self.swipeState, scrollView.contentOffset.x);
    
    [self setHighlighted:NO animated:NO];
    [self setSelected:NO animated:NO];
    
    [self setButtonFrameWithContentOffsetX:scrollView.contentOffset.x];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HHSwipeTableViewCellDidOpenNotification object:self];
    
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
              targetContentOffset:(inout CGPoint*)targetContentOffset {
    NSLog(@"currentState: %u, scrollViewWillEndDragging: scrollView.contentOffset: %f, velocity: %f, targetContentOffset: %f", self.swipeState, scrollView.contentOffset.x, velocity.x, targetContentOffset->x);
    switch (self.swipeState) {
        case HHSwipeTableViewCellState_Left:
        {
            if (targetContentOffset->x > [self contentOffsetXForCenter] ||
                (velocity.x == 0 && targetContentOffset->x <= [self contentOffsetXForCenter])) {
                targetContentOffset->x = [self contentOffsetXForCenter];
                self.swipeState = HHSwipeTableViewCellState_Center;
            } else {
                targetContentOffset->x = 0;
            }
            break;
        }
        case HHSwipeTableViewCellState_Center:
        {
            if ((targetContentOffset->x < [self contentOffsetXForCenter]) ||
                (velocity.x == 0 && targetContentOffset->x < [self contentOffsetXForCenter])) {
                targetContentOffset->x = 0;
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
        NSLog(@"Setting highlighted...");
        if (self.swipeState == HHSwipeTableViewCellState_Center) {
            [self setHighlighted:YES animated:NO];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        
        NSLog(@"Setting normal...");
        [self setHighlighted:NO animated:NO];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (self.swipeState != HHSwipeTableViewCellState_Center) {
            [self setSwipeState:HHSwipeTableViewCellState_Center animated:YES];
            return;
        }
        
        NSLog(@"did select....");
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

// For testing
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    if (highlighted) {
        self.scrollContentView.backgroundColor = [UIColor redColor];
    } else {
        self.scrollContentView.backgroundColor = [UIColor yellowColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.scrollContentView.backgroundColor = [UIColor blueColor];
    } else {
        self.scrollContentView.backgroundColor = [UIColor yellowColor];
    }
}
@end
