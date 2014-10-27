//
//  ELPaymentSummaryViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentSummaryViewController.h"
#import "ELPaymentHeader.h"

typedef enum{
    elOrderSummaryIndexPay = elExistingOrderIndexDefault,
    elOrderSummaryIndexDefault
}elOrderSummaryIndex;
@interface ELPaymentSummaryViewController ()
 @property (strong, nonatomic) UIAlertView *paymentErrorAlertView;
@end

@implementation ELPaymentSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Order Summary";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    // Do any additional setup after loading the view.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return elOrderSummaryIndexDefault;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case elExistingOrderIndexLineItems:
            return self.order.lineItemsArray.count;
        case elExistingOrderIndexSubTotal:
        case elExistingOrderIndexShipping:
        case elExistingOrderIndexTax:
        case elExistingOrderIndexTotal:
        case elExistingOrderIndexBillingInformation:
        case elExistingOrderIndexShippingInformation:
        case elOrderSummaryIndexPay:
            return 1;
        default:
            return 0;
            break;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case elExistingOrderIndexLineItems:
        case elExistingOrderIndexBillingInformation:
        case elExistingOrderIndexShippingInformation:
        case elOrderSummaryIndexPay:
            return 20;
            break;
        default:
            return 0;
            break;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == elExistingOrderIndexBillingInformation)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
        [label makeMine2];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Billing Information:";
        return label;
    }
    
    if (section == elExistingOrderIndexShippingInformation)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
        [label makeMine2];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Shipping Information:";
        return label;
    }
    if (section == elOrderSummaryIndexPay) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];\
        view.backgroundColor = [UIColor whiteColor];
        return view;
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case elExistingOrderIndexLineItems:
        {
            CGFloat height = [[self.order.lineItemsArray[indexPath.row] productName]
                              sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                              constrainedToSize:CGSizeMake(self.tableView.bounds.size.width/2-10, 500)].height+10;
            CGFloat additionalHeight = [[self.order.lineItemsArray[indexPath.row] additionalInformation]
                                        sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                                        constrainedToSize:CGSizeMake(self.tableView.bounds.size.width/2-10, 500)].height+10;
            return [self.order.lineItemsArray[indexPath.row] additionalInformation]? height+additionalHeight:height;
        }
        case elExistingOrderIndexBillingInformation:
        {
            return [[ELCard billingAddressFromSTPCard:self.card?self.card:self.token.card]
                    sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                    constrainedToSize:CGSizeMake(self.tableView.bounds.size.width/2-10, 500)].height+10;
        }
        case elExistingOrderIndexShippingInformation:
        {
            return [self.shippingAddress.addressString
                    sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                    constrainedToSize:CGSizeMake(self.tableView.bounds.size.width/2-10, 500)].height+10;
        }
        case elExistingOrderIndexStatus:
        case elExistingOrderIndexCC:
            return 40;
        case elOrderSummaryIndexPay:
            return 50;
        default:
            return 30;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case elExistingOrderIndexLineItems:
        {
            static NSString *lineItemCellIdentifier = @"LineItemCell";
            ELExistingLineItemTableViewCell *lineItemCell = [tableView dequeueReusableCellWithIdentifier:lineItemCellIdentifier];
            if (!lineItemCell) {
                lineItemCell = [[ELExistingLineItemTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lineItemCellIdentifier];
            }
            lineItemCell.lineItem = self.order.lineItemsArray[indexPath.row];
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

        case elExistingOrderIndexBillingInformation:
        {
            static NSString *billingIdentifier = @"BillingInformationCell";
            cell = [tableView dequeueReusableCellWithIdentifier:billingIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:billingIdentifier];
                cell.textLabel.textColor = ICON_BLUE_SOLID;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.numberOfLines = 0;
            }
            cell.textLabel.text = self.card?[self.card billingAddress]:[ELCard billingAddressFromSTPCard:self.token.card];
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
            cell.textLabel.text = [self.shippingAddress addressString];
        }
            break;
        case elOrderSummaryIndexPay:
        {
            static NSString *payCellIdentifier = @"payCell";
            cell = [tableView dequeueReusableCellWithIdentifier:payCellIdentifier];
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:payCellIdentifier];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.numberOfLines = 1;
                cell.backgroundColor = ICON_BLUE_SOLID;
                cell.textLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.numberOfLines = 0;
            }
            cell.textLabel.text = @"Place Order";
        }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == elOrderSummaryIndexPay) {
        [self showActivityView];
        if (![[ELUserManager sharedUserManager]currentCustomer]) {
            [self chargeNewCustomer];
        }
        else{
            [self chargeExistingCustomer];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
-(void)chargeNewCustomer
{
    ELCustomer *customer = [ELCustomer customer];
    customer.email = self.order.email;
    customer.descriptor = self.order.phoneNumber;
    customer.currency = @"USD";
    [customer createWithCompletion:^(ELCustomer *customer, NSError *error) {
        if (!error) {
            [[ELUserManager sharedUserManager]currentUser][@"stripeID"] = customer.identifier;
            [[[ELUserManager sharedUserManager]currentUser] saveEventually];
            [[ELUserManager sharedUserManager] fetchCustomerCompletion:^(ELCustomer *customer, NSError *error) {
                [self chargeExistingCustomer];
            }];
        }
        else [self handlePaymentError:error];
    }];
    
}
-(void)chargeExistingCustomer{
    self.order.customer = [[ELUserManager sharedUserManager]currentCustomer];
    if (self.token)
    {
        [[[ELUserManager sharedUserManager]currentCustomer] addCard:self.token completion:^(ELCard *card, NSError *error) {
            
            if (!error)
            {
                self.order.customer = [[ELUserManager sharedUserManager]currentCustomer];
                self.order.card = card;
                [self processOrder];
            }
            else [self handlePaymentError:error];
        }];
    }
    else{
        self.order.card = self.card;
        [self processOrder];
    }
}
-(void)processOrder
{
    self.order.shippingAddress = self.shippingAddress;
    [self.order processOrderForPayment:^(ELOrderStatus orderStatus, NSError *error) {
        if (!error) [self handlePaymentSuccess];
        else [self handlePaymentError:error];
    }];
}
-(void)handlePaymentSuccess{
    [self hideActivityView];
    UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Order Processed" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [myAlert show];
    [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
    ELExistingOrderViewController *vc = [ELExistingOrderViewController new];
    vc.order = self.order.pfObjectRepresentation;
    vc.popToRootWhenBackButtonPressed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)handlePaymentError:(NSError *)error
{
    [self hideActivityView];
    self.paymentErrorAlertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    switch (error.code) {
            
        case elErrorCodeCardDeclinedCVC:
            self.paymentErrorAlertView.title = @"Declined";
            self.paymentErrorAlertView.message = @"CVC Rejected";
            break;
        case elErrorCodeCardDeclinedExpired:
            self.paymentErrorAlertView.title = @"Declined";
            self.paymentErrorAlertView.message = @"Expired Credit Card";
            break;
        case elErrorCodeCardDeclinedLine1:
            self.paymentErrorAlertView.title = @"Declined";
            self.paymentErrorAlertView.message = @"Address Rejected";
            break;
        case elErrorCodeCardDeclinedLine1Zip:
            self.paymentErrorAlertView.title = @"Declined";
            self.paymentErrorAlertView.message = @"Address Rejected";
            break;
        case elErrorCodeCardDeclinedNoMessage:
            self.paymentErrorAlertView.title = @"Declined";
            self.paymentErrorAlertView.message = @"Declined";
            break;
        case elErrorCodeVerificationRequired:
            self.paymentErrorAlertView.title = @"Error";
            self.paymentErrorAlertView.message = @"Verification Required";
            break;
        default:
            self.paymentErrorAlertView.title = @"Error";
            self.paymentErrorAlertView.message = @"Error processing payment please try again later.";
            break;
    }
    [self.paymentErrorAlertView show];
}
@end
