//
//  ELProductAlertView.h
//  Fuel Logic
//
//  Created by Mike on 8/6/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELProduct.h"
@interface ELProductAlertView : UIAlertView
 @property (strong, nonatomic) ELProduct *product;
@property int quantity;
@end
