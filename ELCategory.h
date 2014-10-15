//
//  ELCategory.h
//  Fuel Logic
//
//  Created by Mike on 6/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Parse/Parse.h>

@interface ELCategory : PFObject <PFSubclassing>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) ELCategory *parent;
@property (nonatomic, readonly) PFRelation *products;
@property (retain) PFRelation *children;

@end
