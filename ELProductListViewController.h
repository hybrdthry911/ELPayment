//
//  ELProductListViewController.h
//  Fuel Logic
//
//  Created by Mike on 6/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELViewController.h"
#import "ELCategory.h"
#import "ELOrder.h"
@interface ELProductListViewController : ELViewController <UITableViewDataSource, UITableViewDelegate>
 @property (strong, nonatomic) ELCategory *category;
 @property (strong, nonatomic) ELOrder *order;
-(void)reload;
@end
