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

@interface ELCustomerOrderTableViewController()

 @property BOOL fetchComplete;

@end

@implementation ELCustomerOrderTableViewController

#pragma mark - Table view data source

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Orders";
    self.view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.85];
}
-(void)objectsDidLoad:(NSError *)error
{
    self.fetchComplete = YES;
    [super objectsDidLoad:error];
    if (!self.objects.count) {
        [self.tableView reloadData];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.objects.count?self.objects.count:1;
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
    if (self.fetchComplete && self.objects.count) {
        // Configure the cell...
        PFObject *order = self.objects[indexPath.row];
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-YYYY"];
        cell.textLabel.text = [NSString stringWithFormat:@"Order#:%@  (%@)",order[@"orderNumber"], [dateFormat stringFromDate:order.createdAt]];
    }
    else if(self.fetchComplete && !self.objects.count) cell.textLabel.text = @"No Orders Found";
    else cell.textLabel.text = @"";
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.objects.count) {
        ELExistingOrderViewController *vc = [[ELExistingOrderViewController alloc]initWithStyle:UITableViewStylePlain];
        vc.order = self.objects[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    }
}

-(PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:@"Order"];
    [query orderByDescending:@"orderNumber"];
    return query;
}
@end
