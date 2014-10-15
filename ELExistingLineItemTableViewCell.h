//
//  ELExistingLineItemTableViewCell.h
//  Fuel Logic
//
//  Created by Mike on 10/5/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELLineItem.h"
@interface ELExistingLineItemTableViewCell : UITableViewCell
 @property (strong, nonatomic) ELLineItem *lineItem;
@end
