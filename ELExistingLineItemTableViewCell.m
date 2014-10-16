//
//  ELExistingLineItemTableViewCell.m
//  Fuel Logic
//
//  Created by Mike on 10/5/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#import "ELPaymentHeader.h"

@interface ELExistingLineItemTableViewCell()
 @property (strong, nonatomic) UILabel *unitPriceLabel, *nameLabel, *quantityLabel, *additionalInformationLabel;
@end


@implementation ELExistingLineItemTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.unitPriceLabel = [self label];
        self.nameLabel = [self label];
        self.quantityLabel = [self label];
        self.additionalInformationLabel = [self label];
        self.additionalInformationLabel.font = [UIFont fontWithName:MY_FONT_1 size:14];
    }
    
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat height = [[self.lineItem productName]
                      sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:15]
                      constrainedToSize:CGSizeMake(self.bounds.size.width/2-10, 500)].height+10;
    
    CGFloat additionalHeight = [[self.lineItem additionalInformation]
                                sizeWithFont:[UIFont fontWithName:MY_FONT_1 size:14]
                                constrainedToSize:CGSizeMake(self.bounds.size.width/2-10, 500)].height+10;
    
    
    self.quantityLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/8-5, height);
    self.quantityLabel.center = CGPointMake(self.contentView.bounds.size.width/16, height/2);
    self.nameLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/8*5-5, height);
    self.nameLabel.center = CGPointMake(self.contentView.bounds.size.width/16*7, height/2);
    self.unitPriceLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/4-5, height);
    self.unitPriceLabel.center = CGPointMake(self.contentView.bounds.size.width/8*7, height/2);

    self.additionalInformationLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/8*5-5, additionalHeight);
    self.additionalInformationLabel.center = CGPointMake(self.contentView.bounds.size.width/16*8, height + additionalHeight/2-5);
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
    self.additionalInformationLabel.text = self.lineItem.additionalInformation;
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
