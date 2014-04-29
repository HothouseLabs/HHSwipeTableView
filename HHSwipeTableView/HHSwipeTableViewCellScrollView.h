//
//  HHSwipeTableViewCellScrollView.h
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 4/29/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHSwipeTableViewCellScrollView : UIScrollView
@property (nonatomic, assign) CGFloat horizontalSwipeAngleInRadians;
@property (nonatomic, strong) UIView *scrollContentView;
@end
