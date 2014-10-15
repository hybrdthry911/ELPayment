//
//  ELProduct.m
//  Fuel Logic
//
//  Created by Mike on 6/19/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELProduct.h"
#import <Parse/PFObject+Subclass.h>

@implementation ELProduct

@dynamic additionalInformationRequired;
@dynamic additionalInformationNote;
@dynamic backorderDueInDate;
@dynamic brand;
@dynamic couponPrice;
@dynamic descriptor;
@dynamic height;
@dynamic quantityInStock;
@dynamic isHidden;
@dynamic length;
@dynamic model;
@dynamic notes;
@dynamic listPrice;
@dynamic salePrice;
@dynamic size;
@dynamic sku;
@dynamic taxable;
@dynamic weight;
@dynamic width;
@dynamic girth;
@dynamic compatibleProducts;
@dynamic nonCompatibleProducts;
@dynamic mainPhoto;
@dynamic photos;
@dynamic similarProducts;
@dynamic specifications;
@dynamic productType;


@synthesize categories = _categories;
@synthesize parseId = _parseId;
@synthesize longestBoxDimension = _longestBoxDimension;

- (void)setCategories:(PFRelation *)categories{
    _categories = categories;
}

- (PFRelation *)categories{
    if(_categories == nil) {
        _categories = [self relationForKey:@"categories"];
    }
    return _categories;
}
-(NSString *)parseId
{
    return _parseId?_parseId:self.objectId;
}
-(void)setParseId:(NSString *)parseId
{
    _parseId = parseId;
}
+(NSString *)parseClassName
{
    return @"Product";
}
@end
