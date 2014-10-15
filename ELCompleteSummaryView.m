//
//  ELCompleteSummaryView.m
//  Fuel Logic
//
//  Created by Mike on 7/11/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#define TOP_SPACING 15
#define LEFT_OFFSET 10
#define LINE_ITEM_HEIGHT 15
#define ROW_HEIGHT 25
#define ROW_SPACING 0
#define RIGHT_HALF_OFFSET (self.scrollView.bounds.size.width/2 + LEFT_OFFSET/2)
#define ROW_OFFSET TOP_SPACING+(ROW_HEIGHT+ROW_SPACING)
#define FULL_WIDTH (self.scrollView.bounds.size.width-LEFT_OFFSET*2)
#define HALF_WIDTH ((self.scrollView.bounds.size.width-LEFT_OFFSET*3)/2)
#define THIRD_WIDTH ((self.scrollView.bounds.size.width - LEFT_OFFSET*4)/3)
#define QUARTER_WIDTH ((self.scrollView.bounds.size.width - LEFT_OFFSET*5)/4)



#import "ELPaymentHeader.h"
@interface ELCompleteSummaryView()
 @property (strong, nonatomic) UIScrollView *scrollView;
 @property (strong, nonatomic) UILabel *quantityLabel, *nameLabel, *priceLabel;
 @property (strong, nonatomic) UILabel *addressLabel;
 @property (strong, nonatomic) UILabel *summaryLabel;
@property (strong, nonatomic) UILabel  *subTotalTitleLabel, *shippingTitleLabel, *totalTitleLabel, *taxTitleLabel;
@property (strong, nonatomic) UILabel  *subTotalLabel, *shippingLabel, *totalLabel, *taxLabel;
 @property (strong, nonatomic) NSMutableArray *lineItemLabelArray;
 @property (strong, nonatomic) NSMutableArray *lineItemPriceLabelArray;
 @property (strong, nonatomic) NSMutableArray *lineItemQuantityLabelArray;
@end

@implementation ELCompleteSummaryView

-(id)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.bounds = CGRectMake(0, 0, self.bounds.size.width-30, self.bounds.size.height-40);
    self.scrollView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    
    [self placeView:self.summaryLabel withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:0 alignment:NSTextAlignmentCenter height:ROW_HEIGHT];
    [self placeView:self.quantityLabel withOffset:ELViewXOffsetNone width:ELViewWidthHalf offset:1 alignment:NSTextAlignmentLeft height:ROW_OFFSET];
    [self placeView:self.nameLabel withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:1 alignment:NSTextAlignmentCenter height:ROW_OFFSET];
    [self placeView:self.priceLabel withOffset:ELViewXOffsetThreeQuarter width:ELViewWidthQuarter offset:1 alignment:NSTextAlignmentRight height:ROW_OFFSET];
    
    int i = 2;
    for (UILabel *label in self.lineItemQuantityLabelArray) {
        [self placeView:label withOffset:ELViewXOffsetNone width:ELViewWidthQuarter offset:i alignment:NSTextAlignmentLeft height:LINE_ITEM_HEIGHT];
        i++;
    }
    i = 2;
    for (UILabel *label in self.lineItemLabelArray) {
        [self placeView:label withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:i alignment:NSTextAlignmentLeft height:LINE_ITEM_HEIGHT];
        i++;
    }
    i = 2;
    for (UILabel *label in self.lineItemPriceLabelArray) {
        [self placeView:label withOffset:ELViewXOffsetThreeQuarter width:ELViewWidthQuarter offset:i alignment:NSTextAlignmentRight height:LINE_ITEM_HEIGHT];
        i++;
    }
    [self placeView:self.subTotalTitleLabel withOffset:ELViewXOffsetNone width:ELViewWidthHalf offset:i alignment:NSTextAlignmentRight height:ROW_HEIGHT];
    [self placeView:self.subTotalLabel withOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf offset:i alignment:NSTextAlignmentRight height:ROW_HEIGHT];
    i++;
    [self placeView:self.taxTitleLabel withOffset:ELViewXOffsetNone width:ELViewWidthHalf offset:i alignment:NSTextAlignmentRight height:ROW_HEIGHT];
    [self placeView:self.taxLabel withOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf offset:i alignment:NSTextAlignmentRight height:ROW_HEIGHT];
    i++;
    [self placeView:self.shippingTitleLabel withOffset:ELViewXOffsetNone width:ELViewWidthHalf offset:i alignment:NSTextAlignmentRight height:ROW_HEIGHT];
    [self placeView:self.shippingLabel withOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf offset:i alignment:NSTextAlignmentRight height:ROW_HEIGHT];
    i++;
    [self placeView:self.totalTitleLabel withOffset:ELViewXOffsetNone width:ELViewWidthHalf offset:i alignment:NSTextAlignmentRight height:ROW_HEIGHT];
    [self placeView:self.totalLabel withOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf offset:i alignment:NSTextAlignmentRight height:ROW_HEIGHT];
    i++;
    self.addressLabel.bounds = CGRectMake(0, 0, FULL_WIDTH, ROW_HEIGHT*5);
    self.addressLabel.center = CGPointMake(self.scrollView.bounds.size.width/2,ROW_OFFSET*i+self.addressLabel.bounds.size.height/2);
    
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width-30, self.addressLabel.bounds.size.height+self.addressLabel.frame.origin.y);
    
}
-(void)placeView:(UIView *)view withOffset:(ELViewXOffset)xOffset width:(ELViewWidth)width offset:(int)offset alignment:(NSTextAlignment)align height:(float)height
{
    if ([view isKindOfClass:[UILabel class]]) {
        [(UILabel *)view setTextAlignment:align];
    }
    
    
    switch (width) {
        case ELViewWidthFull:
            view.bounds = CGRectMake(0, 0, FULL_WIDTH, height);
            break;
        case ELViewWidthHalf:
            view.bounds = CGRectMake(0, 0, HALF_WIDTH, height);
            break;
        case ELViewWidthQuarter:
            view.bounds = CGRectMake(0, 0, QUARTER_WIDTH, height);
            break;
        case ELViewWidthThird:
            view.bounds = CGRectMake(0, 0, THIRD_WIDTH, height);
            break;
        default:
            break;
    }
    float y  = ROW_OFFSET*offset+ROW_HEIGHT/2;
    
    switch (xOffset) {
        case ELViewXOffsetNone:
            view.center = CGPointMake(LEFT_OFFSET + view.bounds.size.width/2, y);
            break;
        case ELViewXOffsetOneHalf:
            view.center = CGPointMake(self.scrollView.bounds.size.width/2 + LEFT_OFFSET/2 + view.bounds.size.width/2, y);
            break;
        case ELViewXOffsetOneQuarter:
            view.center = CGPointMake(LEFT_OFFSET*2+QUARTER_WIDTH + view.bounds.size.width/2,y);
            break;
        case ELViewXOffsetThreeQuarter:
            view.center = CGPointMake(LEFT_OFFSET*4+QUARTER_WIDTH*3 + view.bounds.size.width/2,y);
            break;
        case ELViewXOffsetOneThird:
            view.center = CGPointMake(LEFT_OFFSET*2+THIRD_WIDTH + view.bounds.size.width/2,y);
            break;
        case ELViewXOffsetTwoThird:
            view.center = CGPointMake(LEFT_OFFSET*3+THIRD_WIDTH*2 + view.bounds.size.width/2,y);
            break;
        default:
            break;
    }
}

-(void)setupViews
{
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.bounds = CGRectInset(self.bounds, 20, 15);
    self.scrollView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    self.lineItemLabelArray = [NSMutableArray array];
    self.lineItemPriceLabelArray = [NSMutableArray array];
    self.lineItemQuantityLabelArray = [NSMutableArray array];
    [self addSubview:self.scrollView];
    self.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.5];
    self.scrollView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:.1];
    self.layer.cornerRadius = 5;
    self.quantityLabel = [self myLabel];
    self.quantityLabel.font =[UIFont fontWithName:MY_FONT_3 size:16];
    self.nameLabel = [self myLabel];
    self.nameLabel.font =[UIFont fontWithName:MY_FONT_3 size:16];
    self.priceLabel = [self myLabel];
    self.priceLabel.font =[UIFont fontWithName:MY_FONT_3 size:16];
    self.subTotalLabel = [self myLabel];
    self.taxLabel = [self myLabel];
    self.shippingLabel = [self myLabel];
    self.totalLabel = [self myLabel];
    self.subTotalTitleLabel = [self myLabel];
    self.taxTitleLabel = [self myLabel];
    self.shippingTitleLabel = [self myLabel];
    self.totalTitleLabel = [self myLabel];
    self.totalLabel.font =[UIFont fontWithName:MY_FONT_3 size:18];
    self.totalTitleLabel.font =[UIFont fontWithName:MY_FONT_3 size:18];
    
    self.addressLabel = [self myLabel];
    self.addressLabel.textAlignment = NSTextAlignmentLeft;
    self.addressLabel.numberOfLines = 5;
    
    self.summaryLabel = [self myLabel];
    self.summaryLabel.font = [UIFont fontWithName:MY_FONT_3 size:20];
    
    [self setupLabelText];
}
-(void)setupLabelText
{
    self.priceLabel.text = @"Price";
    self.quantityLabel.text = @"Quantity";
    self.nameLabel.text = @"Product";
    self.summaryLabel.text = @"Order Summary";
    self.subTotalTitleLabel.text = @"Subtotal:";
    self.taxTitleLabel.text = @"Tax:";
    self.shippingTitleLabel.text = @"Shipping:";
    self.totalTitleLabel.text = @"Grand Total:";
    
    self.subTotalLabel.text = [NSString stringWithFormat:@"$%.02f",self.order.subTotal.floatValue];
    self.taxLabel.text = [NSString stringWithFormat:@"$%.02f",self.order.tax?self.order.tax.floatValue:0.00];
    self.shippingLabel.text = [NSString stringWithFormat:@"$%.02f",self.order.shipping?self.order.shipping.floatValue:0.00];
    self.totalLabel.text = [NSString stringWithFormat:@"$%.02f",self.order.total.floatValue];
    
    
    self.addressLabel.text = [NSString stringWithFormat:@"%@" //name
                                                        "\n%@" //line1
                                                        "%@" //line2
                                                        "\n%@, %@ %@" //city state zip
                                                        "\n%@"
                                                        ,self.card.name,self.card.addressLine1,(self.card.addressLine2 && self.card.addressLine2.length) ?[NSString stringWithFormat:@"\n%@",self.card.addressLine2]:@"",
                                                        self.card.addressCity, self.card.addressState, self.card.addressZip, self.order.customer.email];
}
-(void)setOrder:(ELOrder *)order
{
    _order = order;
    for (ELLineItem *lineItem in self.order.lineItemsArray)
    {
        UILabel *quantityLabel = [self myLabel];
        quantityLabel.text = [NSString stringWithFormat:@"%i",lineItem.quantity.intValue];
        [self.lineItemQuantityLabelArray addObject:quantityLabel];
        
        UILabel *nameLabel = [self myLabel];
        nameLabel.text = lineItem.productName;
        [self.lineItemLabelArray addObject:nameLabel];
        
        UILabel *priceLabel = [self myLabel];
        priceLabel.text = [NSString stringWithFormat:@"%.2f",lineItem.subTotal.floatValue];
        [self.lineItemPriceLabelArray addObject:priceLabel];
    }
    [self setupLabelText];
    [self setNeedsDisplay];
}
-(void)setCard:(STPCard *)card{
    _card = card;
    [self setupLabelText];
    [self setNeedsDisplay];
}
-(UILabel *)myLabel
{
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = ICON_BLUE_SOLID;
    label.font = [UIFont fontWithName:MY_FONT_1 size:17];
    label.textAlignment = NSTextAlignmentRight;
    label.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin);
    [self.scrollView addSubview:label];
    return label;
}
@end
