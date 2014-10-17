//
//  ELExistingOrder.m
//  Fuel Logic
//
//  Created by Mike on 10/5/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELExistingOrder.h"
#import <Parse/PFObject+Subclass.h>

@interface ELExistingOrder()


@end


@implementation ELExistingOrder

@dynamic email, stripeChargeIdentifier, billingInformation, status, stripeCustomerId, shippingCarrier, trackingNumber, shipping, orderNumber, subTotal, total, amountRefunded, discount, tax, customer, lineItems, notes, cardId;
 @synthesize stripeCustomer = _stripeCustomer;
 @synthesize card = _card;

+(NSString *)parseClassName
{
    return @"Order";
}
-(void)emailCustomerOrderConfirmation
{
    [PFCloud callFunctionInBackground:@"emailCustomerInvoiceFromOrder" withParameters:@{@"objectId":self.objectId} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error:%@",error);
        }
    }];
}
-(void)emailBusinessOrderConfirmation
{
    [PFCloud callFunctionInBackground:@"emailBusinessInvoiceFromOrder" withParameters:@{@"objectId":self.objectId} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error:%@",error);
        }
    }];
}
-(void)emailCustomerTrackingFromOrder
{
    [PFCloud callFunctionInBackground:@"emailCustomerTrackingFromOrder" withParameters:@{@"objectId":self.objectId} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error:%@",error);
        }
    }];    
}
+(void)nextOrderNumber:(PFIntegerResultBlock)handler{
    [PFCloud callFunctionInBackground:@"nextOrderNumber" withParameters:@{} block:^(id object, NSError *error) {
        handler([object intValue],error);
    }];
}
@end
