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

@class ELCard;
@class ELCharge;
@class ELCustomer;
@class ELLineItem;
@class Product;
@class STPCharge;
@class ELExistingOrder;
@class ELShippingAddress;
@class Rate;
typedef enum
{
   elOrderStatusNotReadyForCharge, elOrderStatusReadyToCharge, elOrderStatusAttemptingCharge, elOrderStatusChargeUnsuccessful, elOrderStatusChargeSucceeded,elOrderStatusComplete
}ELOrderStatus;

typedef void (^elOrderCompletionBlock)(ELOrderStatus orderStatus, NSError* error);
@interface ELOrder : NSObject <UIAlertViewDelegate>
@property int shippingCalcErrorCount;
 @property (strong, nonatomic) NSMutableArray *lineItemsArray;
 @property (strong, nonatomic) NSString *email, *phoneNumber;
 @property (strong, nonatomic) NSNumber *shippingBuffer, *taxRate;
 @property (strong, nonatomic) NSString *zipCode;
 @property (strong, nonatomic) NSString *parseID;
 @property (strong, nonatomic) NSString *shipFromState, *shipToState;
 @property (strong, nonatomic) NSNumber *subTotal, *shipping, *total, *tax, *discounts, *totalNumberOfItems;
 @property (strong, nonatomic) ELCustomer *customer;
 @property (strong, nonatomic) ELCard *card;
 @property (strong, nonatomic) PFUser *user;
 @property (strong, nonatomic) ELCharge *charge;
 @property (strong, nonatomic) NSString *shippingCarrier;
 @property (strong, nonatomic) ELShippingAddress *shippingAddress;
 @property (strong, nonatomic) ELExistingOrder *pfObjectRepresentation;
 @property (strong, nonatomic) NSArray *shippingRates, *shippingMethods;
 @property ELOrderStatus orderStatus;
-(void)emptyCart;
-(void)clearOrder;
-(void)attempToAddProductToOrder:(ELProduct *)product quantity:(int)quantity;
-(void)setShippingRate:(Rate *)rate;
-(void)processOrderForPayment:(elOrderCompletionBlock)handler;
-(BOOL)calculateShippingAsync:(elOrderCompletionBlock)handler;
@end
