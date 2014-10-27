//
//  ELShippingMethodViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELTableViewController.h"
@class ELShippingAddress;
@class ELOrder;
@class STPToken;
@class STPCard;
@interface ELShippingMethodViewController : ELTableViewController
 @property (strong, nonatomic) ELOrder *order;
 @property (strong, nonatomic) STPToken *token;
 @property (strong, nonatomic) STPCard *card;
 @property (strong, nonatomic) ELShippingAddress *shippingAddress;
@end
