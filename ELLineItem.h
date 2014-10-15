//
//  ELLineItem.h
//  Fuel Logic
//
//  Created by Mike on 5/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import <Parse/Parse.h>
#import "ELProduct.h"
typedef void (^elPFObjectSaveCompletionHandler)(PFObject *object, NSError* error);
@interface ELLineItem : PFObject <PFSubclassing, UIAlertViewDelegate>
 @property (strong, nonatomic) ELProduct * product;
 @property (strong, nonatomic) NSNumber *quantity;
 @property (strong, nonatomic) NSNumber *subTotal;
 @property (strong, nonatomic) NSString *productName;
 @property (strong, nonatomic) NSString *sku;
 @property (strong, nonatomic) NSString *descriptor;
 @property (strong, nonatomic) NSNumber *weight;
 @property (strong, nonatomic) NSString *additionalInformation;
-(id)initWithProduct:(ELProduct *)product;
-(id)init;
@end
