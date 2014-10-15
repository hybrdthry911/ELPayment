//
//  UITableViewCell+addOns.m
//  Fuel Logic
//
//  Created by Mike on 6/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "UITableViewCell+addOns.h"
#import "ELPaymentHeader.h"
@implementation UITableViewCell (addOns)
-(void)makeMine{
//    self.contentView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:.1];
    self.textLabel.textColor = ICON_BLUE_SOLID;
//    self.contentView.layer.borderColor = ICON_BLUE.CGColor;
   // self.contentView.layer.borderWidth = .5;
    
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.numberOfLines = 1;
    self.textLabel.font =[UIFont fontWithName:MY_FONT_1 size:20];
    
    self.detailTextLabel.textColor = ICON_BLUE_SOLID;
    self.detailTextLabel.font = [UIFont fontWithName:MY_FONT_2 size:16];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}
-(void)makeMine2{
    self.contentView.backgroundColor = ICON_BLUE_SOLID;
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.numberOfLines = 1;
    self.textLabel.font =[UIFont fontWithName:MY_FONT_1 size:18];
    
    self.detailTextLabel.textColor = [UIColor whiteColor];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}
@end
