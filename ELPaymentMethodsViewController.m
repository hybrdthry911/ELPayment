//
//  ELPaymentMethodsViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/2/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentHeader.h"
#define AUTH_AMOUNT_IN_CENTS [NSNumber numberWithInt:50]
@interface ELPaymentMethodsViewController()
 @property (strong, nonatomic) UIRefreshControl *refreshControl;
 @property BOOL paymentRequestInProcess;
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
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@: Ending in %@ ",card.brand, card.dynamicLast4?card.dynamicLast4:card.last4];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Exp:%li/%li ",(unsigned long)card.expMonth,(unsigned long)card.expYear];
        // Configure the cell...r
    }
    else if(indexPath.row == [[ELUserManager sharedUserManager]currentCustomer].cards.count){
        cell.backgroundColor = ICON_BLUE_SOLID;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = @"Add New Credit/Debit Card";
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
         [self showActivityView];
         ELCard *card = [[ELUserManager sharedUserManager]currentCustomer].cards[indexPath.row];

         PFQuery *processingQuery = [ELExistingOrder query];
         [processingQuery whereKey:@"stripeCardId" equalTo:card.identifier];
         [processingQuery whereKey:@"status" equalTo:@"Processing"];
         
         PFQuery *backorderedQuery = [ELExistingOrder query];
         [backorderedQuery whereKey:@"stripeCardId" equalTo:card.identifier];
         [backorderedQuery whereKey:@"status" equalTo:@"Backordered"];
         PFQuery *query = [PFQuery orQueryWithSubqueries:@[processingQuery,backorderedQuery]];
         [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
             if (!number)
             {
                 [ELCard deleteCardId:card.identifier fromCustomerId:[[[ELUserManager sharedUserManager]currentCustomer]identifier] completionHandler:^(NSString *identifier, BOOL success, NSError *error) {
                     [[ELUserManager sharedUserManager]fetchCustomer];
                 }];
             }
             else{
                 UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Order is pending against this card. Try again after order ships." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                 [myAlert show];
                 [self hideActivityView];
             }
         }];

     }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row>[[ELUserManager sharedUserManager]currentCustomer].cards.count)
    {
        [self showActivityView];
        [[ELUserManager sharedUserManager]checkForSessionActiveThen:^(BOOL verified, NSError *error) {
            if (verified) [self presentApplePayAuthorization];
            else [self hideActivityView];
            
        }];
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
}


+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}
-(void)presentApplePayAuthorization
{
    PKPaymentRequest *paymentRequest = [ELStripe paymentRequest];
    paymentRequest.requiredBillingAddressFields = PKAddressFieldAll;
    //    paymentRequest.requiredShippingAddressFields = PKAddressFieldAll;
    paymentRequest.currencyCode = @"USD";
    
    PKPaymentSummaryItem *item = [[PKPaymentSummaryItem alloc] init];
    item.amount = [NSDecimalNumber decimalNumberWithString:
                   [NSString stringWithFormat:@"%.2f",[AUTH_AMOUNT_IN_CENTS floatValue]/100]
                   ];
    item.label = @"Temporary Authorization";
    
    paymentRequest.paymentSummaryItems = @[item];
    
    if ([Stripe canSubmitPaymentRequest:paymentRequest])
    {
        PKPaymentAuthorizationViewController *paymentController = [[PKPaymentAuthorizationViewController alloc]
                                                                   initWithPaymentRequest:paymentRequest];
        paymentController.delegate = self;
        UIViewController *topController = [ELPaymentMethodsViewController topMostController];
        [topController presentViewController:paymentController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
        [self hideActivityView];
    }
    
    
}
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    self.paymentRequestInProcess = YES;
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    if (!self.paymentRequestInProcess) [self hideActivityView];
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    
    [ELStripe createTokenWithPayment:payment completion:^(STPToken *token, NSError *error)
    {
        if (token && !error)
        {
            [[[ELUserManager sharedUserManager]currentCustomer] addToken:token toStripeCustomerWithCompletion:^(ELCustomer *customer, ELCard *card, NSError *error)
            {
                if (!error)
                {
                    ELCharge *charge = [ELCharge charge];
                    charge.amountInCents = AUTH_AMOUNT_IN_CENTS;
                    charge.customer = customer;
                    charge.customerID = customer.identifier;
                    charge.currency = @"USD";
                    charge.capture = NO;
                    charge.token = token;
                    [ELCharge createCharge:charge completion:^(ELCharge *charge, NSError *error)
                    {
                        if (charge && !error)
                        {
                            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                            [myAlert show];
                            [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
                            ELRefund *refund = [ELRefund new];
                            refund.charge = charge;
                            refund.chargeID = charge.identifier;
                            [refund createRefundCompletionHandler:^(ELRefund *refund, NSError *error) {
                                self.paymentRequestInProcess = NO;
                            }];
                            [[ELUserManager sharedUserManager]fetchCustomer];
                        }
                        else{
                            NSLog(@"error:%@",error);
                            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Creating charge failed" message:nil delegate:nil cancelButtonTitle:@"Close"  otherButtonTitles:nil];
                            [myAlert show];
                            [self hideActivityView];
                        }
                        self.paymentRequestInProcess = NO;

                        
//                            completion(PKPaymentAuthorizationStatusSuccess);
                    }];
                    

                }
                else{
                    UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Adding payment to customer failed" message:@"Close" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                    [myAlert show];
                    self.paymentRequestInProcess = NO;
                    [self hideActivityView];
                }
            }];
  
        }
        else{
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error creating Token" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [myAlert show];
            self.paymentRequestInProcess = NO;
            [self hideActivityView];
        }
    }];
}
@end
