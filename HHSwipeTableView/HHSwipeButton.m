//
//  HHSwipeButton.m
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import "HHSwipeButton.h"

@interface HHSwipeButton()
@property (nonatomic, assign) HHSwipeTableViewCellState swipeState;
@property (nonatomic, assign) NSUInteger indexInContainer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end


@implementation HHSwipeButton
- (id)init
{
    self = [super init];
    if (self) {
        _tapGestureRecognizer = [UITapGestureRecognizer new];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        _tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    if (_image) {
        [self.imageView removeFromSuperview];
    }
    _image = image;
    
    if (image) {
        self.imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:self.imageView];
    }
}

- (void)setTitle:(NSString *)title
{
    if (_title) {
        [self.titleLabel removeFromSuperview];
    }
    _title = title;
    
    if (title) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:self.titleLabel];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.imageView.frame = CGRectMake((CGRectGetWidth(frame) - CGRectGetWidth(self.imageView.frame)) / 2,
                                      (CGRectGetHeight(frame) - CGRectGetHeight(self.imageView.frame)) / 2,
                                      CGRectGetWidth(self.imageView.frame),
                                      CGRectGetHeight(self.imageView.frame));
    
    CGRect titleFrame = [self.title boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(frame)) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
    titleFrame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(titleFrame)) / 2;
    titleFrame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(titleFrame)) / 2;
    self.titleLabel.frame = titleFrame;
}

@end

