//
//  ELExistingOrderViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/5/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELTableViewController.h"
#import "ELExistingOrder.h"

typedef enum{
    elExistingOrderIndexDate,elExistingOrderIndexStatus,elExistingOrderIndexLineItems,elExistingOrderIndexSubTotal,elExistingOrderIndexShipping,elExistingOrderIndexTax,elExistingOrderIndexTotal, elExistingOrderIndexRefundAmount,elExistingOrderIndexCC,elExistingOrderIndexTracking,elExistingOrderIndexBillingInformation,elExistingOrderIndexShippingInformation, elExistingOrderIndexLogin, elExistingOrderIndexDefault
}elExistingOrderIndex;


@interface ELExistingOrderViewController : ELTableViewController
 @property (strong, nonatomic) ELExistingOrder *order;
 @property BOOL popToRootWhenBackButtonPressed;
@end
