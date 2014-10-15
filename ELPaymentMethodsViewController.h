//
//  ELPaymentMethodsViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/2/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELViewController.h"
#import "ELPumpTableViewCell.h"
#import "ELTableViewController.h"
#import <PassKit/PassKit.h>

@interface ELPaymentMethodsViewController : ELTableViewController <PKPaymentAuthorizationViewControllerDelegate>
@end
