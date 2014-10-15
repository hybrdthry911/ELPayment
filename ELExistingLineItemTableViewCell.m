//
//  ELExistingLineItemTableViewCell.m
//  Fuel Logic
//
//  Created by Mike on 10/5/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#import "ELPaymentHeader.h"

@interface ELExistingLineItemTableViewCell()
 @property (strong, nonatomic) UILabel *unitPriceLabel, *nameLabel, *quantityLabel;
@end


@implementation ELExistingLineItemTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.unitPriceLabel = [self label];
        self.nameLabel = [self label];
        self.quantityLabel = [self label];
    }
    
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.quantityLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/8-5, self.contentView.bounds.size.height);
    self.quantityLabel.center = CGPointMake(self.contentView.bounds.size.width/16, self.contentView.bounds.size.height/2);
    self.nameLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/8*5-5, self.contentView.bounds.size.height);
    self.nameLabel.center = CGPointMake(self.contentView.bounds.size.width/16*7, self.contentView.bounds.size.height/2);
    self.unitPriceLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/4-5, self.contentView.bounds.size.height);
    self.unitPriceLabel.center = CGPointMake(self.contentView.bounds.size.width/8*7, self.contentView.bounds.size.height/2);
}
-(void)setLineItem:(ELLineItem *)lineItem
{
    _lineItem = lineItem;
    [self populateLabels];
}
-(void)populateLabels
{
    self.quantityLabel.text = [NSString stringWithFormat:@"%@",self.lineItem.quantity];
    self.nameLabel.text = self.lineItem.productName;
    self.unitPriceLabel.text = [NSString stringWithFormat:@"$%.2f",self.lineItem.subTotal.floatValue];
}
-(UILabel *)label
{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont fontWithName:MY_FONT_1 size:15];
    label.numberOfLines = 5;
    label.textColor = ICON_BLUE_SOLID;
    [self.contentView addSubview:label];
    return label;
}
@end
