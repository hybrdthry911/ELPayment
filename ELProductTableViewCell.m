//
//  ELProductTableViewCell.m
//  Fuel Logic
//
//  Created by Mike on 6/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentHeader.h"

@implementation ELProductTableViewCell
 @synthesize product = _product;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.addRemoveIcon = [[UIButton alloc]init];
        [self.contentView addSubview:self.addRemoveIcon];
        self.addRemoveIcon.userInteractionEnabled = YES;
        self.addRemoveIcon.hidden = YES;
        
        
        self.brandLabel = [[UILabel alloc]init];
        [self.brandLabel makeMine];
        [self.contentView addSubview:self.brandLabel];
        
        self.modelLabel = [[UILabel alloc]init];
        [self.modelLabel makeMine];
        [self.contentView addSubview:self.modelLabel];
        
        self.priceLabel = [[UILabel alloc]init];
        [self.priceLabel makeMine];
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.priceLabel];
        
        self.skuLabel = [[UILabel alloc]init];
        [self.skuLabel makeMine];
        self.skuLabel.font = [UIFont fontWithName:MY_FONT_1 size:12];
        [self.contentView addSubview:self.skuLabel];
        
        self.thumbnail = [[PFImageView alloc]init];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.thumbnail];
        
        
        self.cartIcon = [[UIButton alloc]init];
        [self.cartIcon setImage:[UIImage imageNamed:@"cartIconInvert.png"] forState:UIControlStateNormal];
        self.cartIcon.userInteractionEnabled = YES;
        
        
        [self makeMine];
        
        
        // Initialization code
    }
    return self;
}
-(void)setProduct:(ELProduct *)product
{
    _product = product;
    self.textLabel.text = product.descriptor;
    //self.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",product.brand,product.model];
    self.brandLabel.text = product.brand;
    self.modelLabel.text = product.model;
    self.priceLabel.text = [NSString stringWithFormat:@"$%.2f",product.salePrice.floatValue];
    self.skuLabel.text = self.product.sku;
}
-(ELProduct *)product
{
    return _product;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = CGRectInset(self.bounds, 0,self.product ?8:1);
    if (!self.product) {
        self.contentView.layer.borderColor = ICON_BLUE.CGColor;
        self.contentView.layer.borderWidth = .5;
    }
    else{
        self.contentView.layer.borderColor = nil;
        self.contentView.layer.borderWidth = 0;
    }
    self.addRemoveIcon.bounds = CGRectMake(0, 0, self.contentView.bounds.size.height*.75, self.contentView.bounds.size.height*.75);
    self.addRemoveIcon.center = CGPointMake(self.contentView.bounds.size.height/ (self.addRemoveIcon.hidden ? -2:2), self.contentView.bounds.size.height/2);
    
    self.thumbnail.bounds = CGRectMake(0, 0, 0-self.contentView.bounds.size.height, self.contentView.bounds.size.height);
    self.thumbnail.center = CGPointMake(self.contentView.bounds.size.height/2+5, self.contentView.bounds.size.height/2);
    
    self.brandLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width-self.contentView.bounds.size.height*2, 15);
    self.brandLabel.center = CGPointMake(self.contentView.bounds.size.height+10+self.brandLabel.bounds.size.width/2, 40);
    self.modelLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width-self.contentView.bounds.size.height*2, 15);
    self.modelLabel.center = CGPointMake(self.contentView.bounds.size.height+10+self.modelLabel.bounds.size.width/2, 57.5);
    
    self.skuLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width-self.contentView.bounds.size.height*2, 15);
    self.skuLabel.center = CGPointMake(self.contentView.bounds.size.height+10+self.modelLabel.bounds.size.width/2, self.contentView.bounds.size.height - 10);
    
    
    self.priceLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width*.5, 25);
    self.priceLabel.center = CGPointMake(self.contentView.bounds.size.width - self.priceLabel.bounds.size.width/2 - 3, self.contentView.bounds.size.height - self.priceLabel.bounds.size.height/2 - 3);
    
    
    self.cartIcon.bounds = CGRectMake(0, 0, 40, 40);
    self.cartIcon.center = CGPointMake(self.contentView.bounds.size.width - 25, self.contentView.bounds.size.height -25);
    
    self.textLabel.bounds = CGRectMake(0, 0, (self.contentView.bounds.size.width - self.contentView.bounds.size.height -10), 25);
    self.textLabel.center = CGPointMake(self.contentView.bounds.size.height+10+self.textLabel.bounds.size.width/2, 17.5);
    
    if (!self.addRemoveIcon.hidden)
    {
        [UIView animateWithDuration:.001 animations:
         ^{
             self.textLabel.bounds = CGRectMake(0, 0, (self.contentView.bounds.size.width - self.contentView.bounds.size.height*2.5), self.contentView.bounds.size.height);
             self.textLabel.center = CGPointMake(self.textLabel.bounds.size.width/2+self.bounds.size.height, self.contentView.bounds.size.height/2);
             self.thumbnail.bounds = CGRectMake(0, 0, self.contentView.bounds.size.height, self.contentView.bounds.size.height);
             self.thumbnail.center = CGPointMake(self.contentView.bounds.size.height/2, self.contentView.bounds.size.height/2);
         }
                         completion:^(BOOL finished)
         {
         }];
    }
}
-(void)hideAddRemoveIcon
{
    self.addRemoveIcon.hidden = YES;
    [self layoutSubviews];
}
-(void)showAddIcon{
    self.addRemoveIcon.hidden = NO;
    [UIView animateWithDuration:.25 animations:
     ^{
         [self.addRemoveIcon setImage:[UIImage imageNamed:@"plusIcon.png"] forState:UIControlStateNormal];
     }
                     completion:^(BOOL finished)
     {
     }];
    
    [self layoutSubviews];
}
-(void)showRemoveIcon
{
    self.addRemoveIcon.hidden = NO;
    [UIView animateWithDuration:.25 animations:
     ^{
         [self.addRemoveIcon setImage:[UIImage imageNamed:@"minusIcon.png"] forState:UIControlStateNormal];
     }
                     completion:^(BOOL finished)
     {
     }];
    
    [self layoutSubviews];
}
-(void)showCart:(BOOL)on
{
    if (on) [self.contentView addSubview:self.cartIcon];
    else [self.cartIcon removeFromSuperview];
}
- (void)awakeFromNib
{
    // Initialization code
}




@end
