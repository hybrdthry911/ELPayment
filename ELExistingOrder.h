//
//  ELExistingOrder.h
//  Fuel Logic
//
//  Created by Mike on 10/5/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Parse/Parse.h>

typedef void (^ELStringCompletionHandler)(NSString *string,NSError *error);
@class ELCard;
@class ELCustomer;
@interface ELExistingOrder : PFObject <PFSubclassing>
@property (strong, nonatomic) NSString *email, *stripeChargeIdentifier, *billingInformation, *status, *stripeCustomerId, *shippingCarrier, *trackingNumber, *notes;
 @property (strong, nonatomic) NSNumber *shipping, *orderNumber, *subTotal, *total, *amountRefunded, *discount, *tax;
 @property (strong, nonatomic) ELCustomer *stripeCustomer;
 @property (strong, nonatomic) ELCard *card;
 @property (strong, nonatomic) NSString *cardId;
 @property (strong, nonatomic) PFUser *customer;
 @property (readonly, nonatomic) PFRelation *lineItems;
 @property (strong, nonatomic) NSString *fingerprint;
 @property (strong, nonatomic) NSString *ipAddress;
+(void)nextOrderNumber:(PFIntegerResultBlock)handler;
-(void)emailCustomerTrackingFromOrder:(PFBooleanResultBlock)handler;
-(void)emailCustomerOrderConfirmation:(PFBooleanResultBlock)handler;
-(void)emailBusinessOrderConfirmation:(PFBooleanResultBlock)handler;
-(void)sendMessage:(NSString *)message toCustomerWithCompletion:(PFBooleanResultBlock)handler;
+(void)localIPAddress:(ELStringCompletionHandler)handler;
@end
