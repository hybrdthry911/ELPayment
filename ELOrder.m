//
//  ELOrder.m
//  Fuel Logic
//
//  Created by Mike on 5/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#include "ELPaymentHeader.h"
#import "Postmaster.h"
#import "Shipment.h"
#import "RateResult.h"
#import "ELViewController.h"
#define USPS_ACCOUNT_ID @"305ENOUG1715"
#define USPS_ORIGIN_ZIP @"01013"
#define USPS_BASE_URL @"http://production.shippingapis.com/ShippingAPI.dll"
#define USPS_MAX_ATTEMPTS 10
@interface ELOrder()
 @property (strong, nonatomic) PFUser *currentUser;
 @property BOOL shippingCalcInProgress;
 @property (strong, nonatomic) NSString *originZipCode;
 @property (strong, nonatomic) NSString *zipCodeInProgress;
@end

@implementation ELOrder

 @synthesize orderStatus = _orderStatus;
 @synthesize lineItemsArray = _lineItemsArray;
 @synthesize totalNumberOfItems = _totalNumberOfItems;
-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.shipping = @0;
        self.tax = @0;
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            self.shippingBuffer = config[@"shippingBuffer"];
            self.originZipCode = config[@"shipFromZipCode"];
            self.shipFromState = config[@"shipFromState"];
            self.taxRate = config[@"taxRate"];
        }];
        self.shippingCalcInProgress = NO;
        self.orderStatus = elOrderStatusNotReadyForCharge;
        [self customerDownloadComplete:nil];
        self.card = self.customer.defaultCard;

    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(customerDownloadComplete:) name:elNotificationCustomerDownloadComplete object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orderChanged:) name:@"orderChanged" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedOut:) name:elNotificationLogoutSucceeded object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addProductToOrder:) name:@"addProductToOrder" object:nil];
    return self;
}
-(void)clearOrder
{
    self.shipping = @0;
    self.tax = @0;
    self.total = @0;
    self.shippingRates = nil;
    self.lineItemsArray = [NSMutableArray array];
    self.zipCode = nil;
    self.orderStatus = elOrderStatusNotReadyForCharge;
    self.shippingCalcInProgress = NO;
    self.charge = nil;
    self.shippingCarrier = nil;
    self.pfObjectRepresentation = nil;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"orderChanged" object:self];
}
-(void)setZipCode:(NSString *)zipCode{
    _zipCode = zipCode;
    self.shippingCarrier = nil;
    self.shippingRates = nil;
    self.shipping = @0;
}
-(void)orderChanged:(NSNotification *)notification
{
    self.shipping = nil;
    self.shippingCarrier = nil;
}
-(void)userLoggedOut:(NSNotification *)notification
{
    self.currentUser = nil;
    self.customer = nil;
}
-(void)customerDownloadComplete:(NSNotification *)notification
{
    self.currentUser = [[ELUserManager sharedUserManager]currentUser];
    self.customer = [[ELUserManager sharedUserManager]currentCustomer];
}

-(NSNumber *)totalNumberOfItems
{
    int number = 0;
    for (ELLineItem *lineItem in self.lineItemsArray) {
        number+= lineItem.quantity.intValue;
    }
    return [NSNumber numberWithInt:number];
}
-(BOOL)calculateShippingAsync:(elOrderCompletionBlock)handler{

    if (self.shippingCalcInProgress) {
        //returns no to let requestor know calculation is already in progress
        return NO;
    }
    if (!self.card && !self.zipCode){
        return NO;
    }
    self.shipping = nil;
    self.shippingRates = nil;
    self.shippingCalcInProgress = YES;
    
    RateQueryMessage *message = [[RateQueryMessage alloc]init];
    message.fromZip = self.originZipCode;
    message.weight = self.weight;
    message.toZip = self.zipCode?self.zipCode:self.card.addressZip;
    self.zipCodeInProgress = self.zipCode.copy;
    [ELShipment ratesInBackground:message completionHandler:^(RateResult *result, NSError *error)
     {
        if (!error) {
            if (result.rates.count)
            {
                for (Rate *rate in result.rates) {
                    rate.charge = [NSString stringWithFormat:@"%.2f",floorf((rate.charge.intValue / 100.0 * (self.shippingBuffer.floatValue + 1)*100+.5))/100];
                }
                
                self.shippingRates = [result.rates sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    
                    Rate *rate1 = obj1;
                    Rate *rate2 = obj2;
                    if ( rate1.charge.floatValue < rate2.charge.floatValue ) {
                        return (NSComparisonResult)NSOrderedAscending;
                    } else if ( rate1.charge.floatValue > rate2.charge.floatValue ) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                }];
                Rate *rate = self.shippingRates[0];
                self.shipping = @(rate.charge.floatValue);
                self.shippingCarrier = [rate.carrier uppercaseString];
                self.shippingCalcInProgress = NO;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"shippingCalculated" object:self];
                if (![self.zipCode isEqualToString:self.zipCodeInProgress])
                {
                    [self calculateShippingAsync:handler];
                }
                else handler(self.orderStatus,error);
            }
            else handler(self.orderStatus, errorFromELErrorType(elErrorCodeNoShipping));
        }
        else handler(self.orderStatus, errorFromELErrorType(elErrorCodeNoShipping));
         self.shippingCalcInProgress = NO;
    }];
    return YES;
}
-(void)setShippingRate:(Rate *)rate
{
    self.shipping = @(rate.charge.floatValue);
    self.shippingCarrier = [rate.carrier uppercaseString];
}
-(NSArray *)shippingMethods
{
    NSMutableArray *array = [NSMutableArray new];
    for (Rate *rate in self.shippingRates) {
        PKShippingMethod *shippingMethod = [PKShippingMethod new];
        shippingMethod.label = [rate.carrier uppercaseString];
        shippingMethod.amount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",floorf((rate.charge.intValue / 100.0 * (self.shippingBuffer.floatValue + 1)*100+.5))]];
        shippingMethod.detail = rate.service;
        [array addObject:shippingMethod];
    }
    return array;
}
-(NSNumber *)weight
{
    float weight = 0;
    for (ELLineItem *lineItem in self.lineItemsArray) {
        weight += lineItem.weight.floatValue;
    }
    return @(weight);
}
-(NSNumber *)tax
{
    if ([self.shipFromState isEqualToString:self.shipToState]) return [NSNumber numberWithFloat:self.subTotal.floatValue * (self.taxRate.floatValue/100)];
    
    return @0;
}
-(ELLineItem *)doesOrderContainProduct:(ELProduct *)product
{
    for (ELLineItem *lineItem in self.lineItemsArray ) {
        if ([lineItem.product.sku isEqualToString:product.sku]) {
            return lineItem;
        }
    }
    return nil;
}
-(void)emptyCart
{
    self.lineItemsArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"orderChanged" object:self];
}
-(void)addProductToOrder:(NSNotification *)notification
{
    [self attempToAddProductToOrder:notification.object quantity:1];
}
-(void)attempToAddProductToOrder:(ELProduct *)product quantity:(int)quantity
{
    
    if (self.orderStatus == elOrderStatusChargeSucceeded || self.orderStatus == elOrderStatusComplete) [self clearOrder];
    self.shipping = nil;
    self.shippingCarrier = nil;
    if (!product.sku || quantity == 0 || !product.salePrice || product.salePrice.doubleValue <= 0) {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Can't add pump to cart. If you need help with this product/order please call E-Nough Logic at 413-206-9184" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Call",nil];
        myAlert.delegate = self;
        [myAlert show];
        return;
    }
    else if(product.quantityInStock.intValue <= 0 && product.quantityInStock)
    {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Product out of stock. Please call E-Nough Logic at 413-206-9184 to backorder." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Call",nil];
        myAlert.delegate = self;
        [myAlert show];
        return;
    }
    else if(product.additionalInformationRequired && product.additionalInformationRequired.boolValue)
    {
        ELProductAlertView *myAlert = [[ELProductAlertView alloc]initWithTitle:@"Additional Information Required" message:product.additionalInformationNote delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        myAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        myAlert.product = product;
        myAlert.quantity = quantity;
        myAlert.delegate = self;
        [myAlert show];
        return;
    }
    [self addProductToOrder:product quantity:quantity];
   
}
-(ELLineItem *)addProductToOrder:(ELProduct *)product quantity:(int)quantity
{
    ELLineItem *lineItem = [self doesOrderContainProduct:product];
    
    if (!lineItem) lineItem = [[ELLineItem alloc]initWithProduct:product];
    else lineItem.quantity = [NSNumber numberWithInt:lineItem.quantity.intValue + quantity];
    if (![self.lineItemsArray containsObject:lineItem])
    {
        [self.lineItemsArray addObject:lineItem];
    }
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[self.lineItemsArray sortedArrayUsingComparator:^NSComparisonResult(ELLineItem *p1, ELLineItem *p2){
        return [p1.product.brand compare:p2.product.brand] == NSOrderedSame ? [p1.product.model compare:p2.product.model]:[p1.product.brand compare:p2.product.brand];
    }]];
    
    self.lineItemsArray = sortedArray;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"orderChanged" object:self];
    
    UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Added to cart" message:[NSString stringWithFormat:@"Added %@ %@ to your Shopping Kart",product.brand,product.model] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1.5];
    [myAlert show];
    return lineItem;
}
-(void)autoCloseAlertView:(UIAlertView*)alert{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[ELProductAlertView class]]) {
        ELProductAlertView *alert = (ELProductAlertView *)alertView;
        ELLineItem *lineItem = [self addProductToOrder:alert.product quantity:alert.quantity];
        UITextField *textField = [alertView textFieldAtIndex:0];
        lineItem.additionalInformation = textField.text;
    }
    else if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:4132069184"]];
    }
    
}
-(void)addLineItemToOrder:(ELLineItem *)lineItem
{
    ELProduct *product = lineItem.product;
    NSNumber *quantity = lineItem.quantity;
    if (self.orderStatus == elOrderStatusChargeSucceeded || self.orderStatus == elOrderStatusComplete) {
        return;
    }
    self.shipping = nil;
    self.shippingCarrier = nil;
    if (!product.sku || quantity == 0 || !product.salePrice || product.salePrice.doubleValue <= 0) {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Can't add pump to cart. If you need help with this product/order please call E-Nough Logic at 413-206-9184" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Call",nil];
        myAlert.delegate = self;
        [myAlert show];
        return;
    }
    
    ELLineItem *existingLineItem =[self doesOrderContainProduct:lineItem.product];
    if (existingLineItem) existingLineItem.quantity = [NSNumber numberWithInt:lineItem.quantity.intValue+existingLineItem.quantity.intValue];
    else     [self.lineItemsArray addObject:lineItem];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"orderChanged" object:self];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[self.lineItemsArray sortedArrayUsingComparator:^NSComparisonResult(ELLineItem *p1, ELLineItem *p2){
        return [p1.product.brand compare:p1.product.brand] == NSOrderedSame ? [p1.product.model compare:p1.product.model]:[p1.product.brand compare:p1.product.brand];
    }]];
    
    self.lineItemsArray = sortedArray;
    
    
}
-(NSMutableArray *)lineItemsArray
{
    if (!_lineItemsArray) self.lineItemsArray = [NSMutableArray array];
    return _lineItemsArray;
}
-(void)setLineItemsArray:(NSMutableArray *)lineItemsArray
{
    _lineItemsArray = lineItemsArray;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"orderChanged" object:self];
}
-(NSNumber *)total
{
    float total = self.subTotal.floatValue;
    total+=self.tax.floatValue;
    total+=self.shipping.floatValue;
    total-=self.discounts.floatValue;
    return [NSNumber numberWithFloat:total];
}
-(NSNumber *)subTotal
{
    float subTotal = 0;
    for (ELLineItem *lineItem in self.lineItemsArray)
    {
        subTotal+=lineItem.subTotal.floatValue;
    }
    return [NSNumber numberWithFloat:subTotal];
}
-(void)checkOrderStatusAsReadyToChargeWithError:(NSError **)error
{
    NSError *nextError;
    
    if (self.orderStatus == elOrderStatusChargeSucceeded || self.orderStatus == elOrderStatusComplete) {
        *error = errorFromELErrorType(elErrorCodeChargeAlreadyProcessed);
        return;
    }
    //checks if the order stats has not been set. If it hasn't it checks the parameters to see if the order status is ready to charge.
    if (self.total.floatValue > 50 &&
        self.charge &&
        [self.charge validForProcessingWithError:&nextError] &&
        [[ELUserManager sharedUserManager]currentUser] &&
        _orderStatus == elOrderStatusNotReadyForCharge &&
        self.shipping) self.orderStatus = elOrderStatusReadyToCharge;
    else
    {
        if (self.total.floatValue < 50) nextError = errorFromELErrorType(elErrorCodeChargeInvalidAmount);
        else if(!self.charge) nextError = errorFromELErrorType(elErrorCodeNotReadyToChargeGeneral);
        else if(![[ELUserManager sharedUserManager]currentUser]) nextError = errorFromELErrorType(elErrorCodeNotReadyToChargeGeneral);
        else if(!self.shipping) nextError = errorFromELErrorType(elErrorCodeNoShipping);
        else{
            NSLog(@"next:%@",nextError);
        }
        self.orderStatus = elOrderStatusNotReadyForCharge;
    }
    if (nextError) *error = nextError;
    
}
-(void)setCustomer:(ELCustomer *)customer
{
    _customer = customer;
}
-(ELOrderStatus)orderStatus
{
    //check order status again to ensure order is still ready to charge.
    return _orderStatus;
}
-(void)setOrderStatus:(ELOrderStatus)orderStatus
{
    switch (orderStatus) {
        case elOrderStatusChargeSucceeded:
            [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationOrderStatusChargeSucceeded object:self];
            break;
        case elOrderStatusComplete:
            [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationOrderStatusComplete object:self];
            break;
            
        default:
            break;
    }
    _orderStatus = orderStatus;
}
-(void)processOrderForPayment:(elOrderCompletionBlock)handler
{
    
    self.charge = [ELCharge charge];
    self.charge.amountInCents = [NSNumber numberWithInt:self.total.floatValue*100.0];
    self.charge.customer = self.customer;
    self.charge.card = self.card;
    self.charge.currency = @"usd";
    self.charge.receiptEmail = self.customer.email;
    self.charge.descriptor = self.customer.phoneNumber;
    //checks if order is ready to charge, if order is already successfully payed it will not let payment go through, if there is an error status will be unsuccessful, and must be resolves before further processing.
    NSError *error;
    [self checkOrderStatusAsReadyToChargeWithError:&error];
    if (error) {
        handler(self.orderStatus,error);
        return;
    }
    
    if (self.orderStatus == elOrderStatusReadyToCharge)
    {
        self.orderStatus = elOrderStatusAttemptingCharge;
        //prepare the self.charge for payment, charge should already have a token attached, it will return an error is it doesn't
        [self.charge createChargeWithCompletion:^(ELCharge *charge, NSError *error) {
            
            if (error || !charge)
            {
                self.orderStatus = elOrderStatusChargeUnsuccessful;
                handler(self.orderStatus, error);
            }
            else
            {
                self.charge = charge;
                self.orderStatus = elOrderStatusChargeSucceeded;
                [self saveAsPFObject:^(PFObject *orderObject, NSError *error)
                {
                    if (error || !orderObject)
                    {
                        handler(self.orderStatus,error);
                    }
                    else
                    {
                        self.orderStatus = elOrderStatusComplete;
                        [ELCustomer retrieveCustomerWithID:self.customer.identifier completion:^(ELCustomer *customer, NSError *error) {
                            if (customer && !error) self.customer = customer;
                            else NSLog(@"%@",error);
                        }];
                        PFUser *currentUser = [[ELUserManager sharedUserManager]currentUser];
                        if (currentUser && self.customer.identifier && self.customer.email)
                        {
                            currentUser[@"stripeID"] = self.customer.identifier;
                            currentUser[@"lastPurchaseEmail"] = self.customer.email;
                            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!succeeded || error) {
                                    NSLog(@"Error Saving current user during orderprocessing%@",error);
                                }
                            }];
                        }
                        [self.pfObjectRepresentation emailCustomerOrderConfirmation:nil];
                        [self.pfObjectRepresentation emailBusinessOrderConfirmation:nil];
                        handler(self.orderStatus, error);
                    }
                }];
            }
        }];
    }
    else
    {
        handler(self.orderStatus,errorFromELErrorType(elErrorCodeNotReadyToChargeGeneral));
    }
}

-(void)saveAsPFObject:(elPFObjectSaveCompletionHandler)handler
{
    [PFObject saveAllInBackground:self.lineItemsArray block:^(BOOL succeeded, NSError *error)
    {
        if (!succeeded || error) {
            for (ELLineItem *lineItem in self.lineItemsArray) {
                [lineItem saveEventually];
            }
        }


        self.pfObjectRepresentation = [ELExistingOrder object];
        self.pfObjectRepresentation.total = @(self.charge.amountInCents.integerValue/100.0);
        self.pfObjectRepresentation.billingInformation = [[self.card billingAddress] stringByAppendingFormat:@"\n%@\n%@",self.customer.email,
                                              self.customer.descriptor];
        self.pfObjectRepresentation.shippingInformation = self.shippingAddress.addressString;
        self.pfObjectRepresentation.customer = [[ELUserManager sharedUserManager]currentUser];
        if (self.subTotal) self.pfObjectRepresentation.subTotal = self.subTotal;
        if (self.tax)        self.pfObjectRepresentation.tax = self.tax;
        if (self.shipping)        self.pfObjectRepresentation.shipping = self.shipping;
        self.pfObjectRepresentation.email = self.customer.email;
        self.pfObjectRepresentation.stripeCustomerId = self.customer.identifier;
        self.pfObjectRepresentation.stripeChargeIdentifier = self.charge.identifier;
        self.pfObjectRepresentation.stripeCardId = self.charge.card.identifier;
        self.pfObjectRepresentation.status = @"Processing";
        self.pfObjectRepresentation.shippingCarrier = self.shippingCarrier;
        self.pfObjectRepresentation.cardId = self.card.identifier;
        self.pfObjectRepresentation.fingerprint = self.card.fingerprint;
        self.pfObjectRepresentation.phoneNumber = self.customer.descriptor;
        [ELExistingOrder localIPAddress:^(NSString *string, NSError *error) {
            if (string) self.pfObjectRepresentation.ipAddress = string;
            for (ELLineItem *lineItemPFObjects in self.lineItemsArray) {
                [self.pfObjectRepresentation.lineItems addObject:lineItemPFObjects];
            }
            [ELExistingOrder nextOrderNumber:^(int number, NSError *error)
            {
                self.pfObjectRepresentation.orderNumber = error? @(-1) : [NSNumber numberWithInt:number];
                [self.pfObjectRepresentation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (error)
                    {
                        [self.pfObjectRepresentation saveEventually];
                        handler(self.pfObjectRepresentation,error);
                        return;
                    }
                    self.charge.descriptor = self.pfObjectRepresentation.objectId;
                    handler(self.pfObjectRepresentation,error);
                }];
                
                //if shipping address doesn't exist add it.
                PFRelation *shippingAddressRelation = [[ELUserManager sharedUserManager]currentUser][@"shippingAddresses"];
                [shippingAddressRelation.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    BOOL found = NO;
                    for (ELShippingAddress *address in objects) {
                        if ([address.addressString isEqualToString:self.shippingAddress.addressString]) {
                            found = YES;
                        }
                    }
                    if (!found) {
                        [self.shippingAddress saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            
                            if (error) [self.shippingAddress saveEventually:^(BOOL succeeded, NSError *error) {
                                PFRelation *relation = [[ELUserManager sharedUserManager]currentUser][@"shippingAddresses"];
                                [relation addObject:self.shippingAddress];
                                [[[ELUserManager sharedUserManager]currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (error) {
                                        [[[ELUserManager sharedUserManager]currentUser] saveEventually];
                                    }
                                }];
                            }];
                            else
                            {
                                PFRelation *relation = [[ELUserManager sharedUserManager]currentUser][@"shippingAddresses"];
                                [relation addObject:self.shippingAddress];
                                [[[ELUserManager sharedUserManager]currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (error) {
                                        [[[ELUserManager sharedUserManager]currentUser] saveEventually];
                                    }
                                }];
                            }
                            
                        }];
                    }
                }];
            }];
        }];
    }];
}
-(NSString *)parseID
{
    return self.pfObjectRepresentation.objectId;
}
@end