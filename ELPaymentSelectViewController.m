//
//  ELPaymentSelectViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/25/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentSelectViewController.h"
#import "ELPaymentHeader.h"

typedef enum{
 elPaymentMethodSelectNew, elPaymentMethodSelectExisting, elPaymentMethodSelectApplePay, elPaymentMethodSelectDefault
}elPaymentMethodSelect;
@interface ELPaymentSelectViewController ()
 @property (strong, nonatomic) ELPickerView *creditCardPickerView;
 @property (strong, nonatomic) UIAlertView *paymentErrorAlertView;
@end

@implementation ELPaymentSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select Method";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.order.orderStatus != elOrderStatusNotReadyForCharge) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
- (void)showCreditCardPickerView{
    
    self.creditCardPickerView = [[ELPickerView alloc]init];
    self.creditCardPickerView.delegate = self;
    self.creditCardPickerView.elDelegate = self;
    self.creditCardPickerView.dataSource= self;
    [self.creditCardPickerView presentGlobally];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return elPaymentMethodSelectDefault;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    switch (section) {
        case elPaymentMethodSelectApplePay:
            return [PKPaymentAuthorizationViewController canMakePayments];
        case elPaymentMethodSelectExisting:
            return (!![[[[ELUserManager sharedUserManager]currentCustomer] cards]count] && ![PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]);
        default:
            return 1;
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = ICON_BLUE_SOLID;
    cell.textLabel.font = [UIFont fontWithName:MY_FONT_1 size:18];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case elPaymentMethodSelectExisting:
            cell.textLabel.text = @"Choose Existing Card";
            break;
        case elPaymentMethodSelectNew:
            cell.textLabel.text = @"Enter New Card Information";
            break;
        case elPaymentMethodSelectApplePay:
            cell.textLabel.text = @"Pay with Apple Pay";
            break;
        default:
            break;
    }
    
    // Configure the cell...
    return cell;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case elPaymentMethodSelectExisting:
        {
            [self showCreditCardPickerView];
        }
            break;
        case elPaymentMethodSelectNew:
        {
            ELPaymentBillingViewController *vc = [ELPaymentBillingViewController new];
            vc.order = self.order;
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        case elPaymentMethodSelectApplePay:
        {
            [self presentApplePay];
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark pickerview datasource/delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [[[[ELUserManager sharedUserManager]currentCustomer] cards]count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%@:xxxx%@",[[[ELUserManager sharedUserManager]currentCustomer].cards[row] brand],[[[ELUserManager sharedUserManager]currentCustomer].cards[row] last4]];
}
- (void)pickerView:(ELPickerView *)pickerView completedSelectionAtRow:(NSInteger)row{
    
    ELShippingSelectViewController *vc = [ELShippingSelectViewController new];
    vc.order = self.order;
    vc.card = [[ELUserManager sharedUserManager]currentCustomer].cards[row];
    [self.navigationController pushViewController:vc animated:YES];
    [pickerView removeFromSuperview];
}
- (void)pickerViewCancelled:(ELPickerView *)pickerView{
        [pickerView removeFromSuperview];
}



#pragma mark - PKPayment ViewController
- (void)presentApplePay
{
    self.order.zipCode = nil;
    PKPaymentRequest *paymentRequest = [ELStripe paymentRequest];
    paymentRequest.requiredBillingAddressFields = PKAddressFieldAll;
    paymentRequest.requiredShippingAddressFields = PKAddressFieldAll;
    paymentRequest.currencyCode = @"USD";
    paymentRequest.paymentSummaryItems = [self paymentSummaryArrayFromOrder];
    
    if ([Stripe canSubmitPaymentRequest:paymentRequest])
    {
        PKPaymentAuthorizationViewController *paymentController = [[PKPaymentAuthorizationViewController alloc]
                                                                   initWithPaymentRequest:paymentRequest];
        paymentController.delegate = self;
        UIViewController *topController = [ELViewController topMostController];
        [topController presentViewController:paymentController animated:YES completion:nil];
    }
    else
    {
        if (![PKPaymentAuthorizationViewController canMakePayments]) {
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error:" message:@"Apple Pay not capable on this device" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [myAlert show];
            [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
            [self hideActivityView];
        }
        else{
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error:" message:@"No compatible Apple Pay card found" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [myAlert show];
            [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
            [self hideActivityView];
        }
    }
}
- (NSArray *)paymentSummaryArrayFromOrder{
    PKPaymentSummaryItem *subTotalitem = [PKPaymentSummaryItem new];
    subTotalitem.amount = [NSDecimalNumber decimalNumberWithString:self.order.subTotal.stringValue?self.order.subTotal.stringValue:@"0.00"];
    subTotalitem.label = [NSString stringWithFormat:@"Subtotal"];
    
    PKPaymentSummaryItem *shippingItem = [PKPaymentSummaryItem new];
    shippingItem.amount = [NSDecimalNumber decimalNumberWithString:self.order.shipping.stringValue?self.order.shipping.stringValue:@"0.00"];
    shippingItem.label = [NSString stringWithFormat:@"Shipping"];
    
    PKPaymentSummaryItem *taxItem = [PKPaymentSummaryItem new];
    taxItem.amount = [NSDecimalNumber decimalNumberWithString:self.order.tax.stringValue?self.order.tax.stringValue:@"0.00"];
    taxItem.label = [NSString stringWithFormat:@"Tax"];
    
    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem new];
    totalItem.amount = [NSDecimalNumber decimalNumberWithString:self.order.total.stringValue];
    totalItem.label = [NSString stringWithFormat:@"Total"];
    
    return @[subTotalitem,shippingItem,taxItem,totalItem];
}
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingAddress:(ABRecordRef)address completion:(void (^)(PKPaymentAuthorizationStatus, NSArray *, NSArray *))completion{
    ABMultiValueRef addressValues = ABRecordCopyValue(address, kABPersonAddressProperty);
    if (ABMultiValueGetCount(addressValues) > 0)
    {
        CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(addressValues, 0);
        NSString *zip = CFDictionaryGetValue(dict, kABPersonAddressZIPKey);
        if (zip) {
            self.order.zipCode = zip;
            [self.order calculateShippingAsync:^(ELOrderStatus orderStatus, NSError *error) {
                completion(PKPaymentAuthorizationStatusSuccess,self.order.shippingMethods,[self paymentSummaryArrayFromOrder]);
            }];
        }
    }
}
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingMethod:(PKShippingMethod *)shippingMethod completion:(void (^)(PKPaymentAuthorizationStatus, NSArray *))completion{
    self.order.shipping = shippingMethod.amount;
    completion(PKPaymentAuthorizationStatusSuccess,[self paymentSummaryArrayFromOrder]);
}
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion{
    [self showActivityViewWithMessage:@"Procession Apple Pay Payment..."];
    if (![[ELUserManager sharedUserManager]currentCustomer])
    {
        ELCustomer *startingcustomer = [ELCustomer customer];
        startingcustomer.currency = @"usd";
        
        ABMultiValueRef emailAddresses = (ABMultiValueRef)ABRecordCopyValue(payment.shippingAddress, kABPersonEmailProperty);
        startingcustomer.email =  (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, 0);
        
        ABMultiValueRef phoneNumbers = (ABMultiValueRef)ABRecordCopyValue(payment.shippingAddress, kABPersonPhoneProperty);
        startingcustomer.descriptor =  (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        
        [ELCustomer createCustomer:startingcustomer completionHandler:^(ELCustomer *customer, NSError *error) {
            if (error)
            {
                [self handlePaymentError:error];
                [self hideActivityView];
            }
            else
            {
                self.order.customer = customer;
                [[ELUserManager sharedUserManager]currentUser][@"stripeID"] = customer.identifier;
                [[ELUserManager sharedUserManager]fetchCustomerCompletion:^(ELCustomer *customer, NSError *error) {
                    [self processApplePayment:payment completion:completion];
                }];
                
            }
        }];
    }
    else
    {
        [self processApplePayment:payment completion:completion];
    }
}
- (void)processApplePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion{
    [ELStripe createTokenWithPayment:payment completion:^(STPToken *token, NSError *error)
     {
         if (error || !token) NSLog(@"Error creating token:%@",error);
         else
         {
             if (![[ELUserManager sharedUserManager]currentCustomer]) {
                 
                 [self handlePaymentError:errorFromELErrorType(elErrorCodeInvalidCustomerInformation)];
                 completion(PKPaymentAuthorizationStatusFailure);
                 [self hideActivityView];
                 return;
             }
             [[[ELUserManager sharedUserManager]currentCustomer] addToken:token toStripeCustomerWithCompletion:^(ELCustomer *finalCustomer, ELCard *card, NSError *error) {
                 
                 if (error || !finalCustomer)
                 {
                     NSLog(@"Error:%@ \n Adding token:%@ \nTo Customer:%@",error,token,finalCustomer);
                     [self handlePaymentError:error];
                 }
                 else
                 {
                     
                     self.order.customer = finalCustomer;
                     self.order.card = card;
                     ELShippingAddress *address = [ELShippingAddress object];
                     ABMultiValueRef addressValues = ABRecordCopyValue(payment.shippingAddress, kABPersonAddressProperty);
                     if (ABMultiValueGetCount(addressValues) > 0)
                     {
                         CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(addressValues, 0);
                         NSString *name = (__bridge NSString *)(ABRecordCopyCompositeName(payment.billingAddress));
                         NSString *line1 = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
                         NSString *city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
                         NSString *state = CFDictionaryGetValue(dict, kABPersonAddressStateKey);
                         NSString *zip = CFDictionaryGetValue(dict, kABPersonAddressZIPKey);
                         NSString *country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
                         address.name = name;
                         address.line1 = line1;
                         address.city = city;
                         address.state = state;
                         address.zipCode = zip;
                         address.country = country;
                     }
                     self.order.shippingAddress = address;
                     ABMultiValueRef emailAddresses = (ABMultiValueRef)ABRecordCopyValue(payment.shippingAddress, kABPersonEmailProperty);
                     self.order.email =  (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, 0);
                     
                     ABMultiValueRef phoneNumbers = (ABMultiValueRef)ABRecordCopyValue(payment.shippingAddress, kABPersonPhoneProperty);
                     self.order.phoneNumber =  (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        
                     
                     [self.order processOrderForPayment:^(ELOrderStatus orderStatus, NSError *error) {
                         if (error)
                         {
                             [self handlePaymentError:error];
                             completion(PKPaymentAuthorizationStatusFailure);
                         }
                         if (orderStatus == elOrderStatusComplete)
                         {
                             [self handlePaymentSuccess];
                             completion(PKPaymentAuthorizationStatusSuccess);
                         }
                         else if(orderStatus == elOrderStatusChargeSucceeded)
                         {
                             NSLog(@"Order successfully charged, error saving to parse:%@",error);
                         }
                         else if(orderStatus == elOrderStatusChargeUnsuccessful)
                         {
                             completion(PKPaymentAuthorizationStatusFailure);
                         }
                     }];
                 }
             }];
         }
         
     }];
    
}
- (void)handlePaymentSuccess{
    [self hideActivityView];
    UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Order Processed" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [myAlert show];
    [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
    ELExistingOrderViewController *vc = [ELExistingOrderViewController new];
    vc.order = self.order.pfObjectRepresentation;
    vc.popToRootWhenBackButtonPressed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)handlePaymentError:(NSError *)error{
    [self hideActivityView];
    self.paymentErrorAlertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
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
