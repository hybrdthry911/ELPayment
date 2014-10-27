//
//  ELOrderViewController.h
//  Fuel Logic
//
//  Created by Mike on 6/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELOrder.h"
#import "ELPaymentViewController.h"
#import "ELLineItemTableViewCell.h"
@interface ELOrderViewController : ELViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
 @property (strong, nonatomic) ELOrder *order;
-(void)collapseViews;
@end
