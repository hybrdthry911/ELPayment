//
//  ELShippingAddress.m
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELShippingAddress.h"
#import <Parse/PFObject+Subclass.h>

@implementation ELShippingAddress
    @dynamic name, line1, line2, city, zipCode, state, country;
-(NSString *)addressString
{
    return [NSString stringWithFormat:@"%@\n%@%@\n%@, %@ %@",
            self.name,
            self.line1,
            self.line2.length?[NSString stringWithFormat:@"\n%@",self.line2]:@"",
            self.city,
            self.state,
            self.zipCode];
}
+(NSString *)parseClassName
{
    return @"ShippingAddress";
}
@end
