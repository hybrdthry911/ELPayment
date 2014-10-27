//
//  ELShippingSelectViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Parse/Parse.h>
@class ELOrder;
@class STPToken;
@class ELCard;
@interface ELShippingSelectViewController : PFQueryTableViewController
 @property (strong, nonatomic) ELOrder *order;
 @property (strong, nonatomic) STPToken *token;
 @property (strong, nonatomic) ELCard *card;
@end
