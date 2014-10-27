//
//  ELPaymentBillingViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/25/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentBillingViewController.h"
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


@interface ELPaymentBillingViewController ()
@property (strong, nonatomic) NSString *stateString;
@property (strong, nonatomic) ELTextField *nameTextField, *addressLine1TextField, *addressLine2TextField, *addressZipCodeTextField, *addressCityTextField, *emailTextField, *phoneNumberTextField;
@property (strong, nonatomic) UIButton *stateButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) ELPickerView *statePickerView;
@property (strong, nonatomic) NSArray *stateArray, *fullStateArray;
@property (strong, nonatomic) UIBarButtonItem *shippingButton;
@property (strong, nonatomic) ELPTKView *stripeView;
@property BOOL validCC;
@end

@implementation ELPaymentBillingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Billing Information";
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

    self.emailTextField = [self addNewTextField];
    self.emailTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"E-Mail"];
    if ([PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) [self.scrollView addSubview:self.emailTextField];
    else self.emailTextField.text = [[ELUserManager sharedUserManager]currentUser].email;

    
    self.phoneNumberTextField = [self addNewTextField];
    self.phoneNumberTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Phone Number"];
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    if ([PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]] || ![[ELUserManager sharedUserManager]currentCustomer] ||  ![[ELUserManager sharedUserManager]currentCustomer].descriptor) [self.scrollView addSubview:self.phoneNumberTextField];
    else self.phoneNumberTextField.text = [[ELUserManager sharedUserManager]currentCustomer].descriptor;
    
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
    
    if (!self.card)
    {
        self.stripeView = [[ELPTKView alloc] initWithFrame:CGRectMake(15,20, 290,55)];
        self.stripeView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin);
        self.stripeView.delegate = self;
        self.stripeView.elDelegate = self;
        [self.scrollView addSubview:self.stripeView];
    }
    else [self populateFromCard];

}
- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    float offset = self.card ? 0: (1.2);
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, ROW_OFFSET * 7+offset);
    if (self.stripeView) self.stripeView.center = CGPointMake(self.view.bounds.size.width/2, 40);
    [UIView animateWithDuration:.25 animations:
     ^{
         [self placeView:self.nameTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:0+offset];
         [self placeView:self.addressLine1TextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:1+offset];
         [self placeView:self.addressLine2TextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:2+offset];
         [self placeView:self.addressCityTextField withOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf offset:3+offset];
         [self placeView:self.addressZipCodeTextField withOffset:ELViewXOffsetNone width:ELViewWidthQuarter offset:3+offset];
         [self placeView:self.stateButton withOffset:ELViewXOffsetOneQuarter width:ELViewWidthQuarter offset:3+offset];
         [self placeView:self.emailTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:4+offset];
         [self placeView:self.phoneNumberTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:5+offset];
     }
                     completion:^(BOOL finished)
     {
     }];
}
- (void)populateFromCard{
    self.addressLine1TextField.text = self.card.addressLine1;
    self.addressLine2TextField.text = self.card.addressLine2;
    self.addressCityTextField.text = self.card.addressCity;
    self.addressZipCodeTextField.text = self.card.addressZip;
    self.stateString = self.card.addressState;
    [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
    self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    self.stateButton.alpha = .5;
    self.nameTextField.text = self.card.name;
    self.emailTextField.text = [[[ELUserManager sharedUserManager]currentUser]email];
    self.phoneNumberTextField.text = [[[ELUserManager sharedUserManager]currentCustomer]descriptor];
    for (UIView *view in self.scrollView.subviews)
    {
        if ([view isKindOfClass:[ELTextField class]])
        {
            ELTextField *tField = (ELTextField *)view;
            if (tField.text.length) tField.layer.borderColor =ICON_BLUE_SOLID.CGColor;
            if (tField != self.phoneNumberTextField) tField.alpha = .5;
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
        [self checkForNext];
    }];
}

- (IBAction)stateButtonPressed:(id)sender{
    if (!self.card) [self showStatePicker];
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
- (IBAction)shippingButtonPressed:(id)sender{
    //Generate new token from card or textfields
    self.order.email = self.emailTextField.text;
    self.order.phoneNumber = self.phoneNumberTextField.text;
    if (self.card)
    {
        ELShippingSelectViewController *vc = [ELShippingSelectViewController new];
        vc.order = self.order;
        vc.card = self.card;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    [self showActivityView];
    ELCard *card = [self cardFromTextFields];
    [card createTokenWithCompletionHandler:^(STPToken *token, NSError *error)
    {
        if (!error)
        {
            self.stripeView.cardNumberField.text = @"";
            self.stripeView.cardExpiryField.text = @"";
            self.stripeView.cardCVCField.text = @"";
            self.validCC = NO;
            ELShippingSelectViewController *vc = [ELShippingSelectViewController new];
            vc.order = self.order;
            vc.token = token;
            [self checkForNext];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            NSLog(@"Error:%@",error);
            [self hideActivityView];
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error communication with payment networks. Try agian later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [myAlert show];
        }
        [self hideActivityView];
    }];
}
- (ELCard *)cardFromTextFields{
    ELCard *card = [[ELCard alloc]init];
    card.name = self.nameTextField.text;
    card.addressLine1 = self.addressLine1TextField.text;
    card.addressLine2 = self.addressLine2TextField.text;
    card.addressCity = self.addressCityTextField.text;
    card.addressCountry = @"US";
    card.addressState = self.stateString;
    card.addressZip = self.addressZipCodeTextField.text;
    card.number = self.stripeView.cardNumber.formattedString;
    card.expMonth = self.stripeView.cardExpiry.month;
    card.expYear = self.stripeView.cardExpiry.year;
    card.cvc = self.stripeView.cardCVC.string;
    return card;
}

#pragma mark PTKView Delegate
- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid{
    self.validCC = valid;
    if (!valid){
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Credit Card Information" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
    }
    [self checkForNext];
}
- (void)checkForNext{
    NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *myPhoneNumberStringSet = [NSCharacterSet characterSetWithCharactersInString:[self simple:self.phoneNumberTextField.text]];
    
    if ((self.validCC || self.card)
        &&
        (
         self.nameTextField.text.length
         && self.addressCityTextField.text.length
         && self.addressLine1TextField.text.length
         && self.addressZipCodeTextField.text.length == 5
         && [self validateEmail:self.emailTextField.text]
         && self.stateString
         && [self simple:self.phoneNumberTextField.text].length >= 10
         && [numericOnly isSupersetOfSet: myPhoneNumberStringSet]
         )
        )
    {
        self.shippingButton = [[UIBarButtonItem alloc]initWithTitle:@"Continue" style:UIBarButtonItemStyleDone target:self action:@selector(shippingButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.shippingButton;
    }
    else if (self.shippingButton)
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.shippingButton = nil;
    }
}


#pragma mark TextField Methods
- (ELTextField *)addNewTextField{
    ELTextField *textField = [super addNewTextField];
    textField.delegate = self;
    return textField;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ((textField == self.nameTextField||
         textField == self.addressLine1TextField||
         textField == self.addressLine2TextField||
         textField == self.addressCityTextField||
         textField == self.addressZipCodeTextField||
         textField == self.emailTextField)
        && self.card) return NO;
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.addressZipCodeTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 5) ? NO : YES;
    }
    else if(textField == self.phoneNumberTextField)
    {
        
        NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        
        // if it's the phone number textfield format it.
        if (range.length == 1) {
            // Delete button was hit.. so tell the method to delete the last char.
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:YES];
        } else {
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:NO ];
        }
        NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:[self simple:self.phoneNumberTextField.text]];
        if (!([self simple:self.phoneNumberTextField.text].length >= 10 && [numericOnly isSupersetOfSet: myStringSet])) textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
        else textField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
        [self checkForNext];
        return false;

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
    else if(textField == self.emailTextField && ![self validateEmail:self.emailTextField.text]) textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
    
    [self checkForNext];
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
