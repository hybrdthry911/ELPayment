//
//  ELPumpTableViewCell.h
//  Fuel Logic
//
//  Created by Mike on 6/11/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface ELPumpTableViewCell : UITableViewCell
 @property (strong, nonatomic) UIButton *addRemoveIcon;
 @property (strong, nonatomic) PFImageView *thumbnail;
 @property (strong, nonatomic) UIButton *cartIcon;
-(void)showCart:(BOOL)on;
-(void)hideAddRemoveIcon;
-(void)showAddIcon;
-(void)showRemoveIcon;
-(void)showThumbnail;
@end
