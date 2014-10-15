//
//  ELLineItemTableViewCell.h
//  Fuel Logic
//
//  Created by Mike on 6/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
@class ELStepper;
@class ELLineItem;
@interface ELLineItemTableViewCell : UITableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>
 @property (strong, nonatomic) UILabel *unitPriceLabel, *subTotalLabel;
 @property (strong, nonatomic) ELLineItem *lineItem;
 @property (strong, nonatomic) ELStepper *quantityStepper;
 @property (strong, nonatomic) UIPickerView *quantityPicker;
 @property (strong, nonatomic) UIView *quantityPickerHolderView;
-(void)resetSubtotals;
@end



#import <UIKit/UIKit.h>
//@class ELStepper;
//@protocol ELStepperDelegate
//-(void)stepperValueChanged:(ELStepper *)stepper;
//@end

@interface ELStepper : UIButton
@property (assign) double  value, stepValue;
// @property (nonatomic) id <ELStepperDelegate> delegate;

@end
