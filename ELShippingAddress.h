//
//  ELShippingAddress.h
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Parse/Parse.h>

@interface ELShippingAddress : PFObject <PFSubclassing>
 @property (strong, nonatomic) NSString *name, *line1, *line2, *city, *zipCode, *country, *state;
-(NSString *)addressString;
@end
