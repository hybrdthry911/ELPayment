//
//  ELShippingSelectViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELShippingSelectViewController.h"
#import "ELPaymentHeader.h"
@interface ELShippingSelectViewController ()

@end

@implementation ELShippingSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) {
        ELPaymentShippingViewController *vc = [ELPaymentShippingViewController new];
        vc.order = self.order;
        vc.token = self.token;
        vc.card = self.card;
        [self.navigationController pushViewController:vc animated:YES];
    }
    // Do any additional setup after loading the view.
}
#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.objects.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShippingAddressCell";
    static NSString *NewShippingAddressCellIdentifier = @"NewShippingAddressCell";
    
    if (indexPath.row >= self.objects.count)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewShippingAddressCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NewShippingAddressCellIdentifier];
            cell.backgroundColor = ICON_BLUE_SOLID;
            cell.textLabel.font = [UIFont fontWithName:MY_FONT_1 size:18];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        cell.textLabel.text = @"New Shipping Address";
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = ICON_BLUE_SOLID;
            cell.detailTextLabel.textColor = ICON_BLUE_SOLID;
            cell.textLabel.font = [UIFont fontWithName:MY_FONT_1 size:16];
            cell.detailTextLabel.font = [UIFont fontWithName:MY_FONT_1 size:13];
        }
        ELShippingAddress *address = self.objects[indexPath.row];
        cell.textLabel.text = address.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ %@, %@ %@",address.line1, address.line2.length?[NSString stringWithFormat:@"%@, ",address.line2]:@"", address.city, address.state, address.zipCode];
        // Configure the cell...
        
        return cell;
        
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row < self.objects.count){
        ELShippingAddress *address = self.objects[indexPath.row];
        self.order.shipToState = address.state;
        self.order.zipCode = address.zipCode;
        ELShippingMethodViewController *vc = [ELShippingMethodViewController new];
        vc.order = self.order;
        vc.token = self.token;
        vc.card = self.card;
        vc.shippingAddress = self.objects[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        ELPaymentShippingViewController *vc = [ELPaymentShippingViewController new];
        vc.order = self.order;
        vc.token = self.token;
        vc.card = self.card;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(PFQuery *)queryForTable
{
    if ([PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) return nil;
    return [[[[ELUserManager sharedUserManager]currentUser] relationForKey:@"shippingAddresses"]query];
}
@end









