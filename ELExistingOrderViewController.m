//
//  ELExistingOrderViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/5/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentHeader.h"
#import "UINavigationController+addOns.h"
@interface ELExistingOrderViewController()
    @property (strong, nonatomic) NSArray *lineItems;
 @property (strong, nonatomic) UIBarButtonItem *loginButton;
@end


@implementation ELExistingOrderViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.95];
    self.tableView.separatorColor = [UIColor clearColor];
    if (!self.lineItems) [self showActivityView];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedIn:) name:elNotificationLoginSucceeded object:nil];
    if (self.popToRootWhenBackButtonPressed && [PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) {
        self.loginButton = [[UIBarButtonItem alloc]initWithTitle:@"Create Account" style:UIBarButtonItemStyleDone target:self action:@selector(handleLoginButtonPress:)];
        self.navigationItem.rightBarButtonItem = self.loginButton;
    }
}
-(IBAction)handleLoginButtonPress:(id)sender
{
    ELLoginViewController *vc = [ELLoginViewController new];
    vc.createOnly = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)userLoggedIn:(NSNotification *)notification
{
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)setOrder:(ELExistingOrder *)order
{
    _order = order;
    if (!_order.isDataAvailable) {
        [_order fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            self.title = [NSString stringWithFormat:@"Order Number:%@",self.order.orderNumber];
            PFQuery *query = self.order.lineItems.query;
            [query includeKey:@"product"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    self.lineItems = objects;
                    [self.tableView reloadData];
                    [self hideActivityView];
                }
            }];
            [ELCard retrieveCardWithId:self.order.cardId customerId:self.order.stripeCustomerId completionHandler:^(ELCard *card, NSError *error) {
                if (!error && card.identifier)
                {
                    self.order.card = card;
                    [self.tableView reloadData];
                }
            }];
        }];
    }
    else{
        self.title = [NSString stringWithFormat:@"Order Number:%@",self.order.orderNumber];
        PFQuery *query = self.order.lineItems.query;
        [query includeKey:@"product"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.lineItems = objects;
                [self.tableView reloadData];
                [self hideActivityView];
            }
        }];
        [ELCard retrieveCardWithId:self.order.cardId customerId:self.order.stripeCustomerId completionHandler:^(ELCard *card, NSError *error) {
            if (!error && card.identifier)
            {
                self.order.card = card;
                [self.tableView reloadData];
            }
        }];
        
    }
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case elExistingOrderIndexLineItems:
        case elExistingOrderIndexTracking:
        case elExistingOrderIndexShippingInformation:
        case elExistingOrderIndexBillingInformation:
            return 20;
            break;
        default:
            return 0;
            break;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == elExistingOrderIndexTracking)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 15)];
        [label makeMine2];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Tracking Information:";
        return label;
    }
    if (section == elExistingOrderIndexShippingInformation)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 15)];
        [label makeMine2];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Shipping Information:";
        return label;
    }
    if (section == elExistingOrderIndexBillingInformation) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 15)];
        [label makeMine2];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Billing Information:";
        return label;
    }
    
    if (section != elExistingOrderIndexLineItems) return nil;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
    
    UILabel *quantityLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 20)];
    view.backgroundColor = ICON_BLUE_SOLID;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = .5;
    quantityLabel.textAlignment = NSTextAlignmentLeft;
    quantityLabel.textColor = [UIColor whiteColor];
    quantityLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
    quantityLabel.text = @"Quantity";
    quantityLabel.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin);
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width-50, 20)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
    nameLabel.text = @"Product";
    nameLabel.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth);
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 20)];
    priceLabel.textAlignment = NSTextAlignmentRight;
    priceLabel.textColor = [UIColor whiteColor];
    priceLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
    priceLabel.text = @"Unit Price\t";
    priceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    
    [view addSubview:nameLabel];
    [view addSubview:quantityLabel];
    [view addSubview:priceLabel];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return elExistingOrderIndexDefault;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    switch (section) {
        case elExistingOrderIndexLineItems:
            return self.lineItems.count;
            break;
        case elExistingOrderIndexCC:
            return !!self.order.card;
        case elExistingOrderIndexRefundAmount:
            return (self.order.amountRefunded && self.order.amountRefunded.floatValue>0);
        default:
            return 1;
            break;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case elExistingOrderIndexLineItems:
        {
            CGFloat height = [[self.lineItems[indexPath.row] productName]
                              sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                              constrainedToSize:CGSizeMake(self.tableView.bounds.size.width/2-10, 500)].height+10;
            CGFloat additionalHeight = [[self.lineItems[indexPath.row] additionalInformation]
                                        sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                                        constrainedToSize:CGSizeMake(self.tableView.bounds.size.width/2-10, 500)].height+10;
            return [self.lineItems[indexPath.row] additionalInformation]? height+additionalHeight:height;
        }
            break;
        case elExistingOrderIndexShippingInformation:
        {
            return [self.order.shippingInformation
                    sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                    constrainedToSize:CGSizeMake(self.tableView.bounds.size.width/2-10, 500)].height+10;
        }
            break;
        case elExistingOrderIndexBillingInformation:
        {
            return [self.order.billingInformation
                    sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                    constrainedToSize:CGSizeMake(self.tableView.bounds.size.width/2-10, 500)].height+10;
        }
            break;
        case elExistingOrderIndexStatus:
        case elExistingOrderIndexCC:
            return 40;
            break;
        default:
            return 30;
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case elExistingOrderIndexDate:
        {
            static NSString *createdCellIdentifier = @"CreatedCell";
            cell = [tableView dequeueReusableCellWithIdentifier:createdCellIdentifier];
            if (!cell) {
                cell = [[ELPumpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:createdCellIdentifier];
                [cell shine];
            }
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
            [dateFormat setTimeStyle:NSDateFormatterNoStyle];
            cell.textLabel.text = [NSString stringWithFormat:@"Order Created:%@",[dateFormat stringFromDate:self.order.createdAt]];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            // Configure the cell...
        }
            break;
        case elExistingOrderIndexStatus:
        {
            static NSString *statusCellIdentifier = @"StatusCell";
            cell = [tableView dequeueReusableCellWithIdentifier:statusCellIdentifier];
            if (!cell) {
                cell = [[ELPumpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:statusCellIdentifier];
                [cell shine];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"Status:%@",self.order.status];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            // Configure the cell...
        }
            break;
        case elExistingOrderIndexLineItems:
        {
            static NSString *lineItemIdentifier = @"LineItemCell";
            ELExistingLineItemTableViewCell *lineItemCell = [tableView dequeueReusableCellWithIdentifier:lineItemIdentifier];
            if (!lineItemCell) {
                lineItemCell = [[ELExistingLineItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lineItemIdentifier];
            }
            lineItemCell.lineItem = self.lineItems[indexPath.row];
            lineItemCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell = lineItemCell;
        }
            break;
        case elExistingOrderIndexSubTotal:
        {
            static NSString *subtotalIdentifier = @"SubtotalCell";
            ELAmountTableViewCell *amountCell = [tableView dequeueReusableCellWithIdentifier:subtotalIdentifier];
            if (!amountCell) {
                amountCell = [[ELAmountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subtotalIdentifier];
            }
            amountCell.amountTypeLabel.text = @"Subtotal:";
            amountCell.amountLabel.text = [NSString stringWithFormat:@"$%.2f",self.order.subTotal.floatValue];
            cell = amountCell;
            // Configure the cell...
        }
            break;
        case elExistingOrderIndexShipping:
        {
            static NSString *shippingIdentifier = @"ShippingCell";
            ELAmountTableViewCell *amountCell = [tableView dequeueReusableCellWithIdentifier:shippingIdentifier];
            if (!amountCell) {
                amountCell = [[ELAmountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:shippingIdentifier];
            }
            amountCell.amountTypeLabel.text = @"Shipping:";
            amountCell.amountLabel.text = [NSString stringWithFormat:@"$%.2f",self.order.shipping.floatValue];
            cell = amountCell;
            // Configure the cell...
        }
            break;
        case elExistingOrderIndexTax:
        {
            static NSString *taxIdentifier = @"TaxCell";
            ELAmountTableViewCell *amountCell = [tableView dequeueReusableCellWithIdentifier:taxIdentifier];
            if (!amountCell) {
                amountCell = [[ELAmountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:taxIdentifier];
            }
            amountCell.amountTypeLabel.text = @"Tax:";
            amountCell.amountLabel.text = [NSString stringWithFormat:@"$%.2f",self.order.tax?self.order.tax.floatValue:0.0];
            cell = amountCell;
        }
            break;
        case elExistingOrderIndexTotal:
        {
            static NSString *totalIdentifier = @"TotalCell";
            ELAmountTableViewCell *amountCell = [tableView dequeueReusableCellWithIdentifier:totalIdentifier];
            if (!amountCell) {
                amountCell = [[ELAmountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:totalIdentifier];
            }
            amountCell.amountTypeLabel.text = @"Total:";
            amountCell.amountLabel.text = [NSString stringWithFormat:@"$%.2f",self.order.total.floatValue];
            cell = amountCell;
        }
            break;
        case elExistingOrderIndexRefundAmount:
        {
            static NSString *refundedIdentifier = @"RefundedCell";
            ELAmountTableViewCell *amountCell = [tableView dequeueReusableCellWithIdentifier:refundedIdentifier];
            if (!amountCell) {
                amountCell = [[ELAmountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:refundedIdentifier];
            }
            amountCell.amountTypeLabel.text = @"Refunded:";
            amountCell.amountLabel.text = [NSString stringWithFormat:@"$%.2f",self.order.amountRefunded.floatValue];
            cell = amountCell;
        }
            break;
        case elExistingOrderIndexCC:
        {
            static NSString *ccIdentifier = @"CCCell";
            ELAmountTableViewCell *amountCell = [tableView dequeueReusableCellWithIdentifier:ccIdentifier];
            if (!amountCell) {
                amountCell = [[ELAmountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ccIdentifier];
            }
            amountCell.amountTypeLabel.text = [NSString stringWithFormat:@"%@ Ending In:",self.order.card.brand];
            amountCell.amountLabel.text = [NSString stringWithFormat:@"%@",self.order.card.dynamicLast4?self.order.card.dynamicLast4:self.order.card.last4];
            cell = amountCell;
        }
            break;
            
        case elExistingOrderIndexTracking:
        {
            static NSString *trackingIdentifier = @"TrackingCell";
            cell = [tableView dequeueReusableCellWithIdentifier:trackingIdentifier];
            if (!cell) {
                cell = [[ELPumpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:trackingIdentifier];
            }
            cell.textLabel.text = self.order.trackingNumber?[NSString stringWithFormat:@"%@:%@ ",self.order.shippingCarrier, self.order.trackingNumber]:@"No Tracking Information";
            cell.accessoryType = self.order.trackingNumber?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
            break;
        case elExistingOrderIndexShippingInformation:
        {
            static NSString *shippingIdentifier = @"ShippingInformationCell";
            cell = [tableView dequeueReusableCellWithIdentifier:shippingIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:shippingIdentifier];
                cell.textLabel.textColor = ICON_BLUE_SOLID;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.numberOfLines = 0;
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@",self.order.shippingInformation];
        }
            break;
        case elExistingOrderIndexBillingInformation:
        {
            static NSString *BillingIdentifier = @"BillingInformationCell";
            cell = [tableView dequeueReusableCellWithIdentifier:BillingIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BillingIdentifier];
                cell.textLabel.textColor = ICON_BLUE_SOLID;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.numberOfLines = 0;
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@",self.order.billingInformation];
        }
            break;
        default:
            return nil;
            break;
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case elExistingOrderIndexLineItems:
        {
            ELProductViewController *vc = [[ELProductViewController alloc]init];
            vc.product = [self.lineItems[indexPath.row] product];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case elExistingOrderIndexTracking:
        {
            if (self.order.trackingNumber) {
                NSString *urlString;
                
                if ([self.order.shippingCarrier isEqualToString:@"UPS"]) urlString = [NSString stringWithFormat:@"http://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=%@",self.order.trackingNumber];
                else if ([self.order.shippingCarrier isEqualToString:@"FEDEX"]) urlString = [NSString stringWithFormat:@"http://www.fedex.com/Tracking?action=track&tracknumbers=%@",self.order.trackingNumber];
                else if ([self.order.shippingCarrier isEqualToString:@"USPS"]) urlString = [NSString stringWithFormat:@"https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=%@",self.order.trackingNumber];
                if (urlString)
                {
                    ELTrackingViewController *vc = [[ELTrackingViewController alloc]init];
                    vc.url = [NSURL URLWithString:urlString];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
-(BOOL)navigationShouldPopOnBackButton
{
    
    if (self.popToRootWhenBackButtonPressed) [self.navigationController popToRootViewControllerAnimated:YES];
    return YES;
}

@end
