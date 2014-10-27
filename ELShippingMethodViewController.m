//
//  ELShippingMethodViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELShippingMethodViewController.h"
#import "ELPaymentHeader.h"
@interface ELShippingMethodViewController ()
@end

@implementation ELShippingMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shippingCalculated:) name:@"shippingCalculated" object:nil];
    self.title = @"Shipping Methods";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (!self.order.shippingRates)
    {
        [self showActivityView];
        [self.order calculateShippingAsync:^(ELOrderStatus orderStatus, NSError *error) {
            
        }];
    }
    // Do any additional setup after loading the view.
}
-(void)shippingCalculated:(NSNotification *)notification
{
    [self hideActivityView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.order.shippingRates.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = ICON_BLUE_SOLID;
        cell.detailTextLabel.textColor = ICON_BLUE_SOLID;
        cell.textLabel.font = [UIFont fontWithName:MY_FONT_1 size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:MY_FONT_1 size:13];
    }
    
    Rate *rate =self.order.shippingRates[indexPath.row];
    if ([rate.carrier isEqualToString:self.order.shippingCarrier ]) cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.text = [NSString stringWithFormat:@"$%.2f - %@",rate.charge.floatValue,[rate.carrier uppercaseString]];
    cell.detailTextLabel.text = rate.service;
    // Configure the cell...
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.order setShippingRate:self.order.shippingRates[indexPath.row]];
    ELPaymentSummaryViewController *vc = [ELPaymentSummaryViewController new];
    vc.order = self.order;
    vc.token = self.token;
    vc.shippingAddress = self.shippingAddress;
    if([self.card isKindOfClass:[ELCard class]]) vc.card = (ELCard *)self.card;
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
