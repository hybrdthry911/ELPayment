//
//  ELPaymentSummaryViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELTableViewController.h"
@class ELOrder;
@class STPToken;
@class ELCard;
@class ELShippingAddress;
@interface ELPaymentSummaryViewController : ELTableViewController
 @property (strong, nonatomic) ELOrder *order;
 @property (strong, nonatomic) STPToken *token;
 @property (strong, nonatomic) ELCard *card;
 @property (strong, nonatomic) ELShippingAddress *shippingAddress;
@end
