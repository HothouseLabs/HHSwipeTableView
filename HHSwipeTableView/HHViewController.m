//
//  MasterViewController.m
//  SwipeToRevealCell
//
//  Created by Yuk Lai Suen on 3/27/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#import "HHViewController.h"
#import "HHSwipeTableViewCell.h"
#import "HHSwipeTableView.h"
#import "HHSwipeButton.h"

@interface HHViewController ()
@property (nonatomic, strong) NSMutableArray* cellContent;
@end

@implementation HHViewController

- (id)init
{
    self = [super init];
    if (self) {
        HHSwipeTableView* tableView = [[HHSwipeTableView alloc] initWithFrame:self.view.bounds
                                                                style:UITableViewStylePlain];
        tableView.swipeDelegate = self;
        [tableView registerClass:[HHSwipeTableViewCell class] forCellReuseIdentifier:@"Cell"];
        self.tableView = tableView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(reloadTable:)];
    if (!self.cellContent) {
        [self loadTestMessages];
    }
}

- (void)reloadTable:(id)sender
{
    [self.tableView reloadData];
}

- (void)loadTestMessages
{
    self.cellContent = [NSMutableArray array];
    for (NSUInteger i = 0; i < 50; i++) {
        [self.cellContent addObject:[NSString stringWithFormat:@"Content %lu", (unsigned long)i]];
    }
    
    // Call reload table repetitively to test for resilience of the table view cell states
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            NSLog(@"<============  reload data ==============>");
            usleep(1000000); // Adjust this value to test resilience
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            break;
        }
    });
}

#pragma mark - Table View
- (NSArray *)swipeTableView:(HHSwipeTableView*)swipeTableView buttonsInState:(HHSwipeTableViewCellState)state forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (state == HHSwipeTableViewCellState_Left) {
        HHSwipeButton* button1 = [HHSwipeButton new];
        [button1 setTitle:@"No Op" forState:UIControlStateNormal];
        [button1 setBackgroundColor:[UIColor greenColor]];
        
        HHSwipeButton* button2 = [HHSwipeButton new];
        [button2 setTitle:@"..." forState:UIControlStateNormal];
        [button2 setBackgroundColor:[UIColor purpleColor]];
        
        return @[button1, button2];
    } else {
        HHSwipeButton* button1 = [HHSwipeButton new];
        [button1 setTitle:@"Delete" forState:UIControlStateNormal];
        [button1 setBackgroundColor:[UIColor redColor]];
        
        return @[button1];
    }
}

- (CGFloat)swipeTableViewButtonWidth:(HHSwipeTableView*)swipeTableView
{
    return 80;
}

- (void)swipeTableView:(HHSwipeTableView *)swipeTableView didTapButtonAtIndex:(NSUInteger)index inState:(HHSwipeTableViewCellState)state forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (state == HHSwipeTableViewCellState_Left) {
        if (index == 0) {
            NSLog(@"No op, return");
            HHSwipeTableViewCell *cell = (HHSwipeTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell setSwipeState:HHSwipeTableViewCellState_Center animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You pressed"
                                                            message:@"..."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            alert.tag = indexPath.row;
            [alert show];
        }
    } else {
        [self.cellContent removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 50;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellContent.count;
}

- (UITableViewCell *) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HHSwipeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                            forIndexPath:indexPath];
    cell.swipeId = @(indexPath.row);
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"Selected %@", indexPath);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
    HHSwipeTableViewCell *cell = (HHSwipeTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSwipeState:HHSwipeTableViewCellState_Center animated:YES];
}
@end
