//
//  ELLineItem.m
//  Fuel Logic
//
//  Created by Mike on 5/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELLineItem.h"
#import "ELCategory.h"
#import <Parse/PFObject+Subclass.h>
@implementation ELLineItem
@dynamic additionalInformation;
@dynamic subTotal, productName, sku, descriptor;
 @synthesize weight = _weight;
 @synthesize product = _product;
 @synthesize quantity = _quantity;

+(NSString *)parseClassName
{
    return @"LineItem";
    
}
-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
-(NSNumber *)weight
{
    return @(self.quantity.intValue*self.product.weight.floatValue);
}
-(ELProduct *)product
{
    return [self objectForKey:@"product"];
}
-(void)setProduct:(ELProduct *)product
{
    [product fetchIfNeeded];
    _product = product;
    [self setObject:product forKey:@"product"];
    self.subTotal = [NSNumber numberWithFloat:self.quantity.floatValue * self.product.salePrice.floatValue ];
    self.sku = product.sku;
    
    if (product.descriptor)
    {
        self.descriptor = product.descriptor;
    }
    
    
    self.productName = [NSString stringWithFormat:@"%@ - %@", self.product.brand,self.product.model];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"orderChanged" object:self];
}

-(NSNumber *)quantity
{
    return [self objectForKey:@"quantity"];
}
-(void)setQuantity:(NSNumber *)quantity
{
    if (quantity.intValue >=100) return;
    [self setObject:quantity forKey:@"quantity"];
    self.subTotal = [NSNumber numberWithFloat:self.quantity.floatValue * self.product.salePrice.floatValue ];
    if (quantity.intValue < .5) {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Removed From Cart" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:.3];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"quantityZero" object:self];
        return;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"orderChanged" object:self];
}
-(void)autoCloseAlertView:(UIAlertView*)alert{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}
-(id)initWithProduct:(ELProduct *)product
{
    self = [self init];
    if (self) {
        self.product = product;
        self.quantity = [NSNumber numberWithInt:1];
    }
    return self;
}
@end
