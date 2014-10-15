//
//  UILabel+addOns.m
//  Fuel Logic
//
//  Created by Mike on 6/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "UILabel+addOns.h"

@implementation UILabel (addOns)
-(void)makeMine{
    self.textColor = ICON_BLUE_SOLID;
    self.backgroundColor = [UIColor clearColor];
    self.font = [UIFont fontWithName:MY_FONT_1 size:16];
}
-(void)makeMine2{
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = ICON_BLUE_SOLID;
    self.font = [UIFont fontWithName:MY_FONT_1 size:16];
}
@end
