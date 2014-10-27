//
//  ELPaymentSelectViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/25/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELTableViewController.h"

@class ELOrder;

@interface ELPaymentSelectViewController : ELTableViewController <ELPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, PKPaymentAuthorizationViewControllerDelegate>
 @property (strong, nonatomic) ELOrder *order;
@end
