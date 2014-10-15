//
//  ELCustomerOrderTableViewController.m
//  Fuel Logic
//
//  Created by Mike on 9/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELCustomerOrderTableViewController.h"
#import "ELUserManager.h"
#import "ELPumpTableViewCell.h"
#import "ELExistingOrderViewController.h"
@implementation ELCustomerOrderTableViewController

#pragma mark - Table view data source

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Orders";
    self.view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.85];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ELPumpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ELPumpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [UIColor clearColor];
    }
    // Configure the cell...
    PFObject *order = self.objects[indexPath.row];

    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-YYYY"];
    cell.textLabel.text = [NSString stringWithFormat:@"Order#:%@  (%@)",order[@"orderNumber"], [dateFormat stringFromDate:order.createdAt]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELExistingOrderViewController *vc = [[ELExistingOrderViewController alloc]initWithStyle:UITableViewStylePlain];
    vc.order = self.objects[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:@"Order"];
    [query whereKey:@"customer" equalTo:[[ELUserManager sharedUserManager]currentUser]];
    [query orderByDescending:@"orderNumber"];
    return query;
}
@end
