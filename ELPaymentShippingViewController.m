//
//  ELPaymentBillingViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/25/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentShippingViewController.h"
#import "ELPaymentHeader.h"

#define TOP_SPACING 20
#define LEFT_OFFSET 10
#define ROW_HEIGHT 40
#define ROW_SPACING 5
//#define RIGHT_HALF_OFFSET (self.scrollView.bounds.size.width/2 + LEFT_OFFSET/2)


#define ROW_OFFSET TOP_SPACING+(ROW_HEIGHT+ROW_SPACING)
#define FULL_WIDTH (self.view.bounds.size.width-LEFT_OFFSET*2)
#define HALF_WIDTH ((self.view.bounds.size.width-LEFT_OFFSET*3)/2)
#define QUARTER_WIDTH ((self.view.bounds.size.width - LEFT_OFFSET*5)/4)


#define FULL_STATE_ARRAY [NSArray arrayWithObjects:@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil]
#define ABBREVIATED_STATE_ARRAY [NSArray arrayWithObjects:@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY", nil];


@interface ELPaymentShippingViewController ()
@end

@implementation ELPaymentShippingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.card) self.card = self.token.card;
    
    self.title = @"Shipping Information";
    self.stateArray = ABBREVIATED_STATE_ARRAY;
    self.fullStateArray = FULL_STATE_ARRAY;
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.9];
    self.scrollViewToKeyBoardAdjust = self.scrollView;
    [self.view addSubview:self.scrollView];
    
    self.nameTextField = [self addNewTextField];
    self.nameTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Name As it appears on Credit Card"];
    [self.scrollView addSubview:self.nameTextField];
    
    self.addressLine1TextField = [self addNewTextField];
    self.addressLine1TextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Address Line 1"];
    [self.scrollView addSubview:self.addressLine1TextField];
    
    self.addressLine2TextField = [self addNewTextField];
    self.addressLine2TextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Address Line 2"];
    self.addressLine2TextField.required = NO;
    self.addressLine2TextField.layer.borderColor = [[UIColor grayColor]CGColor];
    [self.scrollView addSubview:self.addressLine2TextField];
    
    self.addressCityTextField = [self addNewTextField];
    self.addressCityTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"City"];
    self.addressCityTextField.required = YES;
    self.addressCityTextField.layer.borderColor = [[UIColor grayColor]CGColor];
    [self.scrollView addSubview:self.addressCityTextField];
    
    self.addressZipCodeTextField = [self addNewTextField];
    self.addressZipCodeTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Zip Code"];
    self.addressZipCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.scrollView addSubview:self.addressZipCodeTextField];
    
    self.stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stateButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:.85];
    [self.stateButton setTitleColor:ICON_BLUE_SOLID forState:UIControlStateNormal];
    self.stateButton.layer.borderColor = [UIColor redColor].CGColor;
    self.stateButton.layer.borderWidth = 1;
    self.stateButton.layer.cornerRadius = 3;
    [self.stateButton addTarget:self action:@selector(stateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.stateButton];
    
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[ELTextField class]]) {
            ELTextField *tField = (ELTextField *)view;
            if (tField.text.length) tField.layer.borderColor =ICON_BLUE_SOLID.CGColor;
        }
    }
    if (self.shippingAddress)
    {
        [self populateFromShippingAddress];
    }
    else if(self.card)
    {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"New Shipping Address" message:@"Populating from billing information." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
        [self populateFromCard];
    }
    if (self.order)
    {
        self.order.zipCode = self.addressZipCodeTextField.text;
        [self.order calculateShippingAsync:^(ELOrderStatus orderStatus, NSError *error) {
            
        }];
    }
}
- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    float offset = self.card ? 0: (1.2);
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, ROW_OFFSET * 7+offset);
    [UIView animateWithDuration:.25 animations:
     ^{
         [self placeView:self.nameTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:0+offset];
         [self placeView:self.addressLine1TextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:1+offset];
         [self placeView:self.addressLine2TextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:2+offset];
         [self placeView:self.addressCityTextField withOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf offset:3+offset];
         [self placeView:self.addressZipCodeTextField withOffset:ELViewXOffsetNone width:ELViewWidthQuarter offset:3+offset];
         [self placeView:self.stateButton withOffset:ELViewXOffsetOneQuarter width:ELViewWidthQuarter offset:3+offset];
     }
                     completion:^(BOOL finished)
     {
     }];
}
- (void)populateFromShippingAddress{
    self.addressLine1TextField.text = self.shippingAddress.line1;
    self.addressLine2TextField.text = self.shippingAddress.line2;
    self.addressCityTextField.text = self.shippingAddress.city;
    self.addressZipCodeTextField.text = self.shippingAddress.zipCode;
    self.stateString = self.shippingAddress.state;
    [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
    self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    self.nameTextField.text = self.shippingAddress.name;
    for (UIView *view in self.scrollView.subviews)
    {
        if ([view isKindOfClass:[ELTextField class]])
        {
            ELTextField *tField = (ELTextField *)view;
            if (tField.text.length) tField.layer.borderColor =ICON_BLUE_SOLID.CGColor;
        }
    }
    [self textFieldDidChange:nil];
    [self checkForNext];
}
- (void)populateFromCard
{
    self.addressLine1TextField.text = self.card.addressLine1;
    self.addressLine2TextField.text = self.card.addressLine2;
    self.addressCityTextField.text = self.card.addressCity;
    self.addressZipCodeTextField.text = self.card.addressZip;
    self.stateString = self.card.addressState;
    [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
    self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    self.nameTextField.text = self.card.name;
    for (UIView *view in self.scrollView.subviews)
    {
        if ([view isKindOfClass:[ELTextField class]])
        {
            ELTextField *tField = (ELTextField *)view;
            if (tField.text.length) tField.layer.borderColor =ICON_BLUE_SOLID.CGColor;
        }
    }
    [self textFieldDidChange:nil];
    [self checkForNext];
}
- (void)populateCityState{
    if (self.addressZipCodeTextField.text.length<5) {
        return;
    }
    [self retrieveCityStateFromZipcode:self.addressZipCodeTextField.text completion:^(NSString *city, NSString *state, NSError *error) {
        if (!error) {
            if(state){
                self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
                self.stateString = state;
                [self.stateButton setTitle:state];
            }
            if(city)self.addressCityTextField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
            self.addressCityTextField.text = city;
        }
        [self textFieldDidChange:nil];
    }];
}
- (IBAction)stateButtonPressed:(id)sender{
    if (!self.card) [self showStatePicker];
}
- (void)checkForNext{
    if (    self.nameTextField.text.length
         && self.addressCityTextField.text.length
         && self.addressLine1TextField.text.length
         && self.addressZipCodeTextField.text.length == 5
         && self.stateString
        )
    {
        self.shippingMethodButton = [[UIBarButtonItem alloc]initWithTitle:@"Continue" style:UIBarButtonItemStyleDone target:self action:@selector(shippingMethodButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.shippingMethodButton;
    }
    else if (self.shippingMethodButton)
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.shippingMethodButton = nil;
    }
}
-(IBAction)shippingMethodButtonPressed:(id)sender{
    
    ELShippingAddress *address = self.shippingAddress?self.shippingAddress:[ELShippingAddress object];
    address.name = self.nameTextField.text;
    address.line1 = self.addressLine1TextField.text;
    address.line2 = self.addressLine2TextField.text;
    address.city = self.addressCityTextField.text;
    address.state = self.stateString;
    address.zipCode = self.addressZipCodeTextField.text;
    address.country = @"US";
    //only set zip if it has changed. This would clear the shipping rates.
    if (![self.order.zipCode isEqualToString:self.addressZipCodeTextField.text]) self.order.zipCode = self.addressZipCodeTextField.text;
    self.order.shipToState = self.stateString;
    
    ELShippingMethodViewController *vc = [ELShippingMethodViewController new];
    vc.order = self.order;
    vc.token = self.token;
    vc.card = self.card;
    vc.shippingAddress = address;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark TextField Methods
- (ELTextField *)addNewTextField{
    ELTextField *textField = [super addNewTextField];
    textField.delegate = self;
    return textField;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.addressZipCodeTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 5) ? NO : YES;
    }
    return YES;
    
}
- (void)textFieldDidChange:(ELTextField *)textField{
    if (textField.text.length) textField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    else textField.layer.borderColor =   textField.required ?  [[UIColor redColor] colorWithAlphaComponent:1].CGColor:[[UIColor grayColor] colorWithAlphaComponent:.65].CGColor;
    
    if (textField == self.addressZipCodeTextField ) {
        if (self.addressZipCodeTextField.text.length == 5)
        {
            [self populateCityState];
        }
        else
        {
            textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
        }
    }
    [self checkForNext];
}
- (void)showStatePicker{
    self.statePickerView = [[ELPickerView alloc]init];
    self.statePickerView.delegate = self;
    self.statePickerView.elDelegate = self;
    self.statePickerView.dataSource= self;
    [self.statePickerView presentGlobally];
    if (self.currentTextField) {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    }
}


#pragma mark Pickerview delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.fullStateArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.fullStateArray[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self.stateButton setTitle:self.stateArray[row] forState:UIControlStateNormal];
}
- (void)pickerView:(ELPickerView *)pickerView completedSelectionAtRow:(NSInteger)row{
    self.stateString = self.stateArray[row];
    [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
    [pickerView removeFromSuperview];
}
- (void)pickerViewCancelled:(ELPickerView *)pickerView{
    [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
    [pickerView removeFromSuperview];
}
@end
