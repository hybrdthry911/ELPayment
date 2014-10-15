//
//  ELOrder.h
//  Fuel Logic
//
//  Created by Mike on 5/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stripe.h"
#import <Parse/Parse.h>
#import "ELLineItem.h"
@class ELCustomer;
@class ELLineItem;
@class Product;
@class STPCharge;
typedef enum
{
   elOrderStatusNotReadyForCharge, elOrderStatusReadyToCharge, elOrderStatusAttemptingCharge, elOrderStatusChargeUnsuccessful, elOrderStatusChargeSucceeded,elOrderStatusComplete
}ELOrderStatus;

typedef void (^elOrderCompletionBlock)(ELOrderStatus orderStatus, NSError* error);
@interface ELOrder : NSObject <UIAlertViewDelegate>
@property int shippingCalcErrorCount;
 @property (strong, nonatomic) NSMutableArray *lineItemsArray;
 @property (strong, nonatomic) NSString *zipCode;
 @property (strong, nonatomic) NSString *parseID;
 @property (strong, nonatomic) NSNumber *subTotal, *shipping, *total, *tax, *discounts, *totalNumberOfItems;
 @property (strong, nonatomic) ELCustomer *customer;
 @property (strong, nonatomic) ELCard *card;
 @property (strong, nonatomic) PFUser *user;
 @property (strong, nonatomic) ELCharge *charge;
 @property (strong, nonatomic) NSString *cheapestShipmentCarrier;
 @property (strong, nonatomic) PFObject *pfObjectRepresentation;
 @property (strong, nonatomic) NSArray *shippingRates;
 @property ELOrderStatus orderStatus;
-(void)emptyCart;
-(void)clearOrder;
-(void)attempToAddProductToOrder:(ELProduct *)product quantity:(int)quantity;
-(void)processOrderForPayment:(elOrderCompletionBlock)handler;
-(BOOL)calculateShippingAsync:(elOrderCompletionBlock)handler;
@end
