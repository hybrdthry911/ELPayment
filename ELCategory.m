//
//  ELCategory.m
//  Fuel Logic
//
//  Created by Mike on 6/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELCategory.h"
#import <Parse/PFObject+Subclass.h>

@implementation ELCategory


@dynamic name;
@dynamic parent;
@dynamic products;
@synthesize children = _children;
- (void)setChildren:(PFRelation *)children{
    _children = children;
}

- (PFRelation *)children{
    if(_children == nil) {
        _children = [self relationforKey:@"children"];
    }
    return _children;
}

+(NSString *)parseClassName
{
    return @"Category";
}
@end
