//
//  ELOrderSummarView.m
//  Fuel Logic
//
//  Created by Mike on 6/11/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentHeader.h"
@interface ELOrderSummarView()
 @property (strong, nonatomic) UILabel  *subTotalTitleLabel, *shippingTitleLabel, *totalTitleLabel, *taxTitleLabel;
 @property (strong, nonatomic) UILabel  *subTotalLabel, *shippingLabel, *totalLabel, *taxLabel;

@end

@implementation ELOrderSummarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        // Initialization code
    }
    return self;
}
-(id)init
{
    if(self = [super init])
    {
        [self setupViews];
        
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.subTotalLabel.bounds = CGRectMake(0, 0, self.bounds.size.width/2-20, 20);
    self.subTotalLabel.center = CGPointMake(self.bounds.size.width/4*3, 30);
    
    self.taxLabel.bounds = CGRectMake(0, 0, self.bounds.size.width/2-20, 20);
    self.taxLabel.center = CGPointMake(self.bounds.size.width/4*3, 55);
    
    self.shippingLabel.bounds = CGRectMake(0, 0, self.bounds.size.width/2-20, 20);
    self.shippingLabel.center = CGPointMake(self.bounds.size.width/4*3, 80);
    
    self.totalLabel.bounds = CGRectMake(0, 0, self.bounds.size.width/2-20, 20);
    self.totalLabel.center = CGPointMake(self.bounds.size.width/4*3, 105);
    
    self.subTotalTitleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width/2-20, 20);
    self.subTotalTitleLabel.center = CGPointMake(self.bounds.size.width/4, 30);
    
    self.taxTitleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width/2-20, 20);
    self.taxTitleLabel.center = CGPointMake(self.bounds.size.width/4, 55);
    
    self.shippingTitleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width/2-20, 20);
    self.shippingTitleLabel.center = CGPointMake(self.bounds.size.width/4, 80);
    
    self.totalTitleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width/2-20, 20);
    self.totalTitleLabel.center = CGPointMake(self.bounds.size.width/4, 105);
}
-(void)setupViews
{
    self.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:.15];
    self.layer.cornerRadius = 5;
    self.subTotalLabel = [self myLabel];
    self.taxLabel = [self myLabel];
    self.shippingLabel = [self myLabel];
    self.totalLabel = [self myLabel];
    self.subTotalLabel.textAlignment = NSTextAlignmentLeft;
    self.taxLabel.textAlignment = NSTextAlignmentLeft;
    self.shippingLabel.textAlignment = NSTextAlignmentLeft;
    self.totalLabel.textAlignment = NSTextAlignmentLeft;
    self.subTotalTitleLabel = [self myLabel];
    self.taxTitleLabel = [self myLabel];
    self.shippingTitleLabel = [self myLabel];
    self.totalTitleLabel = [self myLabel];
    self.totalLabel.font =[UIFont fontWithName:MY_FONT_3 size:18];
    self.totalTitleLabel.font =[UIFont fontWithName:MY_FONT_3 size:18];
    
    
    
    [self setupLabelText];
}
-(void)setupLabelText
{
    self.subTotalTitleLabel.text = @"Subtotal:";
    self.taxTitleLabel.text = @"Tax:";
    self.shippingTitleLabel.text = @"Shipping:";
    self.totalTitleLabel.text = @"Grand Total:";
    
    self.subTotalLabel.text = [NSString stringWithFormat:@"\t$%.02f ",self.order.subTotal.floatValue];
    self.taxLabel.text = [NSString stringWithFormat:@"\t$%.02f",self.order.tax?self.order.tax.floatValue:0.00];
    self.shippingLabel.text = [NSString stringWithFormat:@"\t$%.02f",self.order.shipping?self.order.shipping.floatValue:0.00];
    self.totalLabel.text = [NSString stringWithFormat:@"\t$%.02f",self.order.total.floatValue];
    
}
-(void)setOrder:(ELOrder *)order
{
    _order = order;
    [self setupLabelText];
    [self setNeedsDisplay];
}
-(UILabel *)myLabel
{
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = ICON_BLUE_SOLID;
    label.font = [UIFont fontWithName:MY_FONT_2 size:18];
    label.textAlignment = NSTextAlignmentRight;
    label.clipsToBounds = NO;
    label.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin);
    [self addSubview:label];
    return label;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
