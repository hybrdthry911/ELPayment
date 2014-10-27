//
//  ApplePayTableViewCell.m
//  Fuel Logic
//
//  Created by Mike on 10/25/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ApplePayTableViewCell.h"

@interface ApplePayTableViewCell()
@end


@implementation ApplePayTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = ICON_BLUE_SOLID;
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

@end
