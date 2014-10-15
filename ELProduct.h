//
//  ELProduct.h
//  Fuel Logic
//
//  Created by Mike on 6/19/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Parse/Parse.h>
@class ELCategory;

@interface ELProduct : PFObject <PFSubclassing>
 @property (strong, nonatomic) NSNumber *additionalInformationRequired;
 @property (strong, nonatomic) NSString *additionalInformationNote;
@property (nonatomic, retain) NSDate * backorderDueInDate;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSNumber * couponPrice;
@property (nonatomic, retain) NSString * descriptor;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * quantityInStock;
@property (nonatomic, retain) NSNumber * isHidden;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSNumber * longestBoxDimension;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * parseId;
@property (nonatomic, retain) NSNumber * listPrice;
@property (nonatomic, retain) NSNumber * salePrice;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) NSNumber * taxable;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * girth;
@property (nonatomic, retain) ELCategory *productType;

@property (nonatomic, readonly) PFRelation *categories;
@property (nonatomic, readonly) PFRelation *compatibleProducts;
@property (nonatomic, readonly) PFRelation *nonCompatibleProducts;
@property (nonatomic, retain) PFFile *mainPhoto;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, readonly) PFRelation *similarProducts;
@property (nonatomic, readonly) PFRelation *specifications;

@end
