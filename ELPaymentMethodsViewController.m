//
//  ELPaymentMethodsViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/2/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentMethodsViewController.h"
#import "ELUserManager.h"
#import "ELPaymentMethodEditViewController.h"
#import "Stripe+ApplePay.h"
#import "STPTestPaymentAuthorizationViewController.h"
@interface ELPaymentMethodsViewController()
 @property (strong, nonatomic) UIRefreshControl *refreshControl;
@end


@implementation ELPaymentMethodsViewController


#pragma mark - Table view data source
-(void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(customerDownloadComplete:) name:elNotificationCustomerDownloadComplete object:nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(pulledDown:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = ICON_BLUE;
    self.refreshControl = refreshControl;
}
-(IBAction)pulledDown:(id)sender
{
    [[ELUserManager sharedUserManager]fetchCustomer];
}
-(void)customerDownloadComplete:(NSNotification *)notification
{
    [self hideActivityView];
    [self.refreshControl endRefreshing];
    [self reload];
}
-(void)reload{
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[ELUserManager sharedUserManager]currentCustomer].cards.count+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = ICON_BLUE_SOLID;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.font =[UIFont fontWithName:MY_FONT_2 size:18];
    cell.detailTextLabel.textColor = ICON_BLUE_SOLID;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row<[[ELUserManager sharedUserManager]currentCustomer].cards.count) {
        

        ELCard *card = [[ELUserManager sharedUserManager]currentCustomer].cards[indexPath.row];
        if ([card.identifier isEqualToString:[[ELUserManager sharedUserManager]currentCustomer].defaultCardId]) cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@: Ending in %@ ",card.brand, card.last4];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Exp:%li/%li ",(unsigned long)card.expMonth,(unsigned long)card.expYear];
        // Configure the cell...r
    }
    else if(indexPath.row == [[ELUserManager sharedUserManager]currentCustomer].cards.count){
        cell.backgroundColor = ICON_BLUE_SOLID;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = @"Add New Payment Method ";
    }
    else{
        cell.backgroundColor = ICON_BLUE_SOLID;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = @"Add Apple Pay Card";
    }
    return cell;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
     return indexPath.row<[[ELUserManager sharedUserManager]currentCustomer].cards.count;
 }
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete)
     {
         ELCard *card = [[ELUserManager sharedUserManager]currentCustomer].cards[indexPath.row];
         [self showActivityView];
         [ELCard deleteCardId:card.identifier fromCustomerId:[[[ELUserManager sharedUserManager]currentCustomer]identifier] completionHandler:^(NSString *identifier, BOOL success, NSError *error) {
             [[ELUserManager sharedUserManager]fetchCustomer];
         }];
     }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>[[ELUserManager sharedUserManager]currentCustomer].cards.count)
    {
        [self showActivityView];
        if ([[ELUserManager sharedUserManager]passwordSessionActive])
        {
            PKPaymentRequest *paymentRequest = [ELStripe paymentRequestWithMerchantIdentifier:@"merchant.com.fuellogic.enoughlogic"];
            paymentRequest.requiredBillingAddressFields = PKAddressFieldAll;
            paymentRequest.requiredShippingAddressFields = PKAddressFieldAll;
            paymentRequest.currencyCode = @"USD";
            PKPaymentSummaryItem *item = [[PKPaymentSummaryItem alloc] init];
            item.amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];
            item.label = @"Add Payment method without Charge.";
            paymentRequest.paymentSummaryItems = @[item];
            
            UIViewController *paymentController;
            if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
#ifdef DEBUG
                paymentController = [[STPTestPaymentAuthorizationViewController alloc]
                                     initWithPaymentRequest:paymentRequest];
                [(STPTestPaymentAuthorizationViewController *)paymentController setDelegate:self];
#else
                paymentController = [[PKPaymentAuthorizationViewController alloc]
                                     initWithPaymentRequest:paymentRequest];
                [(PKPaymentAuthorizationViewController *)paymentController setDelegate:self];
#endif
                [[ViewController sharedViewController] presentViewController:paymentController animated:YES completion:nil];
            }
        }
        else
        {
            [[ELUserManager sharedUserManager]verifyPasswordWithComletion:^(BOOL verified, NSError *error) {
                UIViewController *paymentController;
                if (verified)
                {
                    PKPaymentRequest *paymentRequest =[ELStripe paymentRequestWithMerchantIdentifier:@"merchant.com.fuellogic.enoughlogic"];
                    paymentRequest.requiredBillingAddressFields = PKAddressFieldAll;
                    paymentRequest.requiredShippingAddressFields = PKAddressFieldAll;
                    paymentRequest.currencyCode = @"USD";
                    PKPaymentSummaryItem *item = [[PKPaymentSummaryItem alloc] init];
                    item.amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];
                    item.label = @"Add Payment method without Charge.";
                    paymentRequest.paymentSummaryItems = @[item];
                    if ([Stripe canSubmitPaymentRequest:paymentRequest])
                    {
                        
#ifdef DEBUG
                        paymentController = [[STPTestPaymentAuthorizationViewController alloc]
                                             initWithPaymentRequest:paymentRequest];
                        [(STPTestPaymentAuthorizationViewController *)paymentController setDelegate:self];
#else
                        paymentController = [[PKPaymentAuthorizationViewController alloc]
                                             initWithPaymentRequest:paymentRequest];
                        [(PKPaymentAuthorizationViewController *)paymentController setDelegate:self];
#endif
                        [[ViewController sharedViewController] presentViewController:paymentController animated:YES completion:nil];
                    }
                    
                }
                else [self hideActivityView];
            }];
        }
        return;
    }
    ELCard *card;
    if (indexPath.row<[[ELUserManager sharedUserManager]currentCustomer].cards.count) {
        card = [[ELUserManager sharedUserManager]currentCustomer].cards[indexPath.row];
    }
    
    if ([[ELUserManager sharedUserManager]passwordSessionActive])
    {
        ELPaymentMethodEditViewController *paymentMethodVC = [[ELPaymentMethodEditViewController alloc]init];
        paymentMethodVC.card = card;
        [self.navigationController pushViewController:paymentMethodVC animated:YES];
    }
    else
    {
        [[ELUserManager sharedUserManager]verifyPasswordWithComletion:^(BOOL verified, NSError *error) {
            if (verified) {
                ELPaymentMethodEditViewController *paymentMethodVC = [[ELPaymentMethodEditViewController alloc]init];
                paymentMethodVC.card = card;
                [self.navigationController pushViewController:paymentMethodVC animated:YES];
            }
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// ViewController.m

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self hideActivityView];
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion{
    
    [ELStripe createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
       [[[ELUserManager sharedUserManager]currentCustomer] addToken:token toStripeCustomerWithCompletion:^(ELCustomer *customer, ELCard *card, NSError *error) {
           if (!error) {
               UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
               [myAlert show];
               [self autoCloseAlertView:myAlert];
               [[ELUserManager sharedUserManager]fetchCustomer];
           }
           else{
               NSLog(@"error:%@",error);
               UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error Adding Apple Payment Method" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
               [myAlert show];
               [self autoCloseAlertView:myAlert];
           }
           [self hideActivityView];
#warning handle errors here
           completion(PKPaymentAuthorizationStatusSuccess);
       }];
    }];
}
@end
