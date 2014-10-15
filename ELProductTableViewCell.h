//
//  ELProductTableViewCell.h
//  Fuel Logic
//
//  Created by Mike on 6/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ELProduct.h"
@interface ELProductTableViewCell : UITableViewCell
 @property (strong, nonatomic) ELProduct *product;
@property (strong, nonatomic) UIButton *addRemoveIcon;
@property (strong, nonatomic) PFImageView *thumbnail;
@property (strong, nonatomic) UIButton *cartIcon;
 @property (strong, nonatomic) UILabel *brandLabel, *modelLabel, *priceLabel, *skuLabel;

-(void)showCart:(BOOL)on;
-(void)hideAddRemoveIcon;
-(void)showAddIcon;
-(void)showRemoveIcon;
@end
