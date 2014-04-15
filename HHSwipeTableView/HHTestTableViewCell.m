//
//  HHTestTableViewCell.m
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 4/15/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import "HHTestTableViewCell.h"

@implementation HHTestTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[UILabel alloc] init];
        [self.scrollContentView addSubview:self.label];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.label.text = @"Reused";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = self.contentView.frame;
    self.label.backgroundColor = [UIColor orangeColor];
}

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

