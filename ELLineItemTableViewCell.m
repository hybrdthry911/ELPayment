//
//  ELLineItemTableViewCell.m
//  Fuel Logic
//
//  Created by Mike on 6/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
//
//  ELStepper.m
//  Fuel Logic
//
//  Created by Mike on 6/11/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentHeader.h"




@interface ELLineItemTableViewCell()
@end

@implementation ELLineItemTableViewCell
 @synthesize lineItem = _lineItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self shineOnRepeatWithInterval:6];
        self.quantityStepper = [[ELStepper alloc]init];
        [self.quantityStepper addTarget:self action:@selector(stepperHit:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.quantityStepper];
        
        self.quantityPickerHolderView = [[UIView alloc]init];
        self.quantityPickerHolderView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin);
        self.quantityPickerHolderView.clipsToBounds = YES;
        [self.contentView addSubview:self.quantityPickerHolderView];
        self.quantityPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 40, 34)];
        self.quantityPicker.delegate = self;
        self.quantityPicker.dataSource = self;
        [self.quantityPickerHolderView addSubview:self.quantityPicker];
        [self.quantityPicker selectRow:self.lineItem.quantity.integerValue inComponent:0 animated:YES];
        
        self.unitPriceLabel = [[UILabel alloc]init];
        self.unitPriceLabel.textColor = ICON_BLUE_SOLID;
        self.unitPriceLabel.textAlignment = NSTextAlignmentLeft;
        self.unitPriceLabel.font =[UIFont fontWithName:MY_FONT_2 size:16];
        self.unitPriceLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.unitPriceLabel];
        
        self.subTotalLabel = [[UILabel alloc]init];
        self.subTotalLabel.textColor = ICON_BLUE_SOLID;
        self.subTotalLabel.textAlignment = NSTextAlignmentRight;
        self.subTotalLabel.font =[UIFont fontWithName:MY_FONT_2 size:16];
        self.subTotalLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.subTotalLabel];
        
        
        self.textLabel.textAlignment = NSTextAlignmentRight;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.textColor = ICON_BLUE_SOLID;
        self.detailTextLabel.textColor = ICON_BLUE_SOLID;
        self.textLabel.font =[UIFont fontWithName:MY_FONT_2 size:18];
        
        // Initialization code
    }
    return self;
}

-(IBAction)stepperHit:(ELStepper *)sender
{
    self.lineItem.quantity = [NSNumber numberWithInt:sender.value];
//    [self resetSubtotals];
    if (sender.value > 0) [self.quantityPicker selectRow:self.lineItem.quantity.integerValue inComponent:0 animated:YES];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin);
    self.textLabel.bounds = CGRectMake(0, 0, self.bounds.size.width - (self.quantityStepper.frame.origin.x + self.quantityStepper.bounds.size.width)-10, 40-10);
    self.textLabel.center = CGPointMake(self.bounds.size.width-self.textLabel.bounds.size.width/2-10, 20);
    self.quantityStepper.value = self.lineItem.quantity.intValue;
    [self.quantityStepper setBounds:CGRectMake(0, 0, 55, 34)];
    self.quantityStepper.center = CGPointMake(80, 20);
    
    self.quantityPickerHolderView.bounds = CGRectMake(0, 0, 40, 34);
    self.quantityPickerHolderView.center = CGPointMake(25, 20);
    self.quantityPicker.bounds = self.quantityPickerHolderView.bounds;
    self.quantityPicker.center = CGPointMake(self.quantityPickerHolderView.bounds.size.width/2,self.quantityPickerHolderView.bounds.size.height/2);

    self.quantityPicker.clipsToBounds = YES;
    if ([self.quantityPicker selectedRowInComponent:0] != self.lineItem.quantity.integerValue) [self.quantityPicker selectRow:self.lineItem.quantity.integerValue inComponent:0 animated:YES];
    
    
    
    self.unitPriceLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/2 - 10, 40-10);
    self.unitPriceLabel.center = CGPointMake(self.contentView.bounds.size.width/4, 60);
    self.unitPriceLabel.font =[UIFont fontWithName:MY_FONT_2 size:18];
    self.unitPriceLabel.text = [NSString stringWithFormat:@"Unit Price:$%.2f",self.lineItem.product.salePrice.floatValue];
    
    self.subTotalLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width/2 - 10, 40-10);
    self.subTotalLabel.center = CGPointMake(self.contentView.bounds.size.width/4*3, 60);
    self.subTotalLabel.font =[UIFont fontWithName:MY_FONT_2 size:18];
    [self resetSubtotals];
    
    
    self.textLabel.text = [NSString stringWithFormat:@"%@ %@",self.lineItem.product.brand,self.lineItem.product.model];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}
-(void)resetSubtotals
{
    self.quantityStepper.value = self.lineItem.quantity.integerValue;
    self.subTotalLabel.text = [NSString stringWithFormat:@"Subtotal:$%.2f",self.lineItem.product.salePrice.floatValue * self.lineItem.quantity.intValue];
}
-(ELLineItem *)lineItem
{
    return _lineItem;
}
-(void)setLineItem:(ELLineItem *)lineItem
{
    _lineItem = lineItem;
    [self resetSubtotals];
     self.textLabel.text = [NSString stringWithFormat:@"%@ %@",self.lineItem.product.brand,self.lineItem.product.model];
    [self.quantityPicker selectRow:lineItem.quantity.integerValue inComponent:0 animated:YES];
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 100;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [NSString stringWithFormat:@"%li",(long)row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
  //if (row>0)     [self resetSubtotals];
    
    self.lineItem.quantity = [NSNumber numberWithInteger:row];


}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
      //  tView.font = [UIFont fontWithName:@"DS-Digital-Italic" size:18];
        tView.textColor =ICON_BLUE_SOLID;
        
    }
    tView.text = [NSString stringWithFormat:@"%li",(long)row];
    tView.textAlignment = NSTextAlignmentCenter;
    // Fill the label text here
    return tView;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%i",(int)row];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:ICON_BLUE_SOLID}];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DS-Digital-Italic" size:10] range:NSMakeRange(0, title.length)];
    return attString;
    
}

@end

@implementation ELStepper

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButton];
        // Initialization code
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        [self setupButton];
        // Initialization code
    }
    return self;
}
-(void)setupButton
{
    self.stepValue = 1;
    self.layer.borderColor = ICON_BLUE_SOLID.CGColor;
}
-(void)layoutSubviews
{
    self.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    self.layer.cornerRadius = 3;
    self.layer.borderWidth = (self.bounds.size.width/2 < self.bounds.size.height) ? self.bounds.size.width/100 : self.bounds.size.height/50;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (touches.count) {
        UITouch *touch = touches.anyObject;
        self.value += ([touch locationInView:self].x > self.bounds.size.width/2) ? self.stepValue : (-self.stepValue);
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}
-(void)drawRect:(CGRect)rect
{
    UIBezierPath *bezPath = [UIBezierPath bezierPath];
    bezPath.lineWidth = (self.bounds.size.width/2 < self.bounds.size.height) ? self.bounds.size.width/100 : self.bounds.size.height/50;
    
    [bezPath moveToPoint:CGPointMake(self.bounds.size.width/2, 0)];
    [bezPath addLineToPoint:CGPointMake(self.bounds.size.width/2, self.bounds.size.height)];
    
    [bezPath moveToPoint:CGPointMake(self.bounds.size.width*.25 - ((self.bounds.size.width/2 > self.bounds.size.height) ? self.bounds.size.height*.25:self.bounds.size.width*.15), self.bounds.size.height/2)];
    
    [bezPath addLineToPoint:CGPointMake(self.bounds.size.width*.25 + ((self.bounds.size.width/2 > self.bounds.size.height) ? self.bounds.size.height*.25:self.bounds.size.width*.15), self.bounds.size.height/2)];
    
    [bezPath moveToPoint:CGPointMake(self.bounds.size.width*.75 - ((self.bounds.size.width/2 > self.bounds.size.height) ? self.bounds.size.height*.25:self.bounds.size.width*.15), self.bounds.size.height/2)];
    [bezPath addLineToPoint:CGPointMake(self.bounds.size.width*.75 + ((self.bounds.size.width/2 > self.bounds.size.height) ? self.bounds.size.height*.25:self.bounds.size.width*.15), self.bounds.size.height/2)];
    [bezPath moveToPoint:CGPointMake(self.bounds.size.width/4*3, self.bounds.size.height*.25)];
    [bezPath addLineToPoint:CGPointMake(self.bounds.size.width/4*3, self.bounds.size.height*.75)];
    
    [ICON_BLUE_SOLID setStroke];
    [bezPath stroke];
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




