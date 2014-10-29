//
//  ELPaymentMethodEditViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/2/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#define TOP_SPACING 10
#define LEFT_OFFSET 10
#define ROW_HEIGHT 40
#define ROW_SPACING 5
#define ROW_OFFSET TOP_SPACING + (ROW_HEIGHT + ROW_SPACING)

#define FULL_STATE_ARRAY [NSArray arrayWithObjects:@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil]
#define ABBREVIATED_STATE_ARRAY [NSArray arrayWithObjects:@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY", nil];


#import "ELPaymentHeader.h"

@interface ELPaymentMethodEditViewController()
 @property (strong, nonatomic) NSString *stateString;
 @property (strong, nonatomic) ELTextField *nameTextField, *addressLine1TextField, *addressLine2TextField, *addressZipCodeTextField, *addressCityTextField;
 @property (strong, nonatomic) UIButton *makeDefaultButton, *deleteButton, *stateButton, *expButton;
 @property (strong, nonatomic) UIScrollView *scrollView;
 @property (strong, nonatomic) UIPickerView *statePickerView, *expPickerView;
 @property (strong, nonatomic) NSArray *stateArray, *expMonthArray, *expYearArray;
 @property (strong, nonatomic) NSArray *fullStateArray;
 @property (strong, nonatomic) UIBarButtonItem *saveButton;
 @property (strong, nonatomic) ELPTKView *stripeView;
 @property BOOL validCC;

@end

@implementation ELPaymentMethodEditViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSMutableArray *yearArray = [NSMutableArray array];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy"];
    NSString *yearString = [dateFormat stringFromDate:[NSDate date]];
    int year =[yearString intValue];
    for (int i = year; i<year+20 ; i++) {
        [yearArray addObject:[NSString stringWithFormat:@"%i",i]];
    }
    self.expYearArray = yearArray;
    NSMutableArray *monthArray = [NSMutableArray array];
    for (int i = 1; i<13; i++) {
        [monthArray addObject:[NSString stringWithFormat:@"%i",i]];
    }
    self.expMonthArray = monthArray;
    
    
    self.view.backgroundColor = [UIColor clearColor];
    self.stateArray = ABBREVIATED_STATE_ARRAY;
    self.fullStateArray = FULL_STATE_ARRAY;
    
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.9];
    self.scrollViewToKeyBoardAdjust = self.scrollView;
    [self.view addSubview:self.scrollView];
    
    if (self.card)
    {
        if (![[[[ELUserManager sharedUserManager]currentCustomer]defaultCardId] isEqualToString:self.card.identifier])
        {
            self.makeDefaultButton = [[UIButton alloc]init];
            [self.makeDefaultButton makeMine];
            [self.makeDefaultButton setTitle:@"Make Default Payment Method"];
            [self.makeDefaultButton addTarget:self
                                       action:@selector(makeDefaultCard)
                             forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:self.makeDefaultButton];
        }
        self.deleteButton = [[UIButton alloc]init];
        [self.deleteButton makeMine];
        [self.deleteButton setTitle:@"Delete Payment Method"];
        [self.deleteButton addTarget:self
                              action:@selector(deleteCard)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.deleteButton];

        self.saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.saveButton;
        
        self.expButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.expButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:.85];
        [self.expButton setTitleColor:ICON_BLUE_SOLID forState:UIControlStateNormal];
        self.expButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
        self.expButton.layer.borderWidth = 1;
        self.expButton.layer.cornerRadius = 3;
        [self.expButton addTarget:self action:@selector(expButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.expButton];
        [self updateExpButtonText];
    }

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(customerDownloadComplete:) name:elNotificationCustomerDownloadComplete object:nil];
    
    
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
    
    self.statePickerView = [[UIPickerView alloc]init];
    self.statePickerView.delegate = self;
    [self.view addSubview:self.statePickerView];
    [self pickerView:self.statePickerView didSelectRow:0 inComponent:0];
    self.statePickerView.hidden = YES;
    self.statePickerView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.95];
    
    self.expPickerView = [[UIPickerView alloc]init];
    self.expPickerView.delegate = self;
    [self.view addSubview:self.expPickerView];
    self.expPickerView.hidden = YES;
    self.expPickerView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.95];
    
    self.stateString = self.stateArray[0];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[ELTextField class]]) {
            ELTextField *tField = (ELTextField *)view;
            if (tField.text.length) tField.layer.borderColor =ICON_BLUE_SOLID.CGColor;
        }
    }
    
    if (!self.card)
    {
        self.stripeView = [[ELPTKView alloc] initWithFrame:CGRectMake(15,20, 290,55)];
        self.stripeView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin);
        self.stripeView.delegate = self;
        self.stripeView.elDelegate = self;
        [self.scrollView addSubview:self.stripeView];
    }
    [self populateFromCard];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];   
}
- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    if (self.card) self.title = [NSString stringWithFormat:@"%@:%@",self.card.brand,self.card.dynamicLast4?self.card.dynamicLast4:self.card.last4];
    
    float offset = self.card ? 0: (1.2);
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, ROW_OFFSET * ((self.makeDefaultButton?7.5:6.5)+offset));
    
    [UIView animateWithDuration:.25 animations:
     ^{
         [self placeView:self.nameTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:0+offset];
         [self placeView:self.addressLine1TextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:1+offset];
         [self placeView:self.addressLine2TextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:2+offset];
         [self placeView:self.addressCityTextField withOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf offset:3+offset];
         [self placeView:self.addressZipCodeTextField withOffset:ELViewXOffsetNone width:ELViewWidthQuarter offset:3+offset];
         [self placeView:self.stateButton withOffset:ELViewXOffsetOneQuarter width:ELViewWidthQuarter offset:3+offset];
         [self placeView:self.expButton withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:4+offset];
         [self placeView:self.makeDefaultButton withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:5+offset];
         [self placeView:self.deleteButton withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:(self.makeDefaultButton?6:5)+offset];
     }
                     completion:^(BOOL finished)
     {
         
     }];
}
- (void)customerDownloadComplete:(NSNotification *)notification{
    
    [self hideActivityView];
    if (self.card)
    {
        if (!self.deleteButton) {
            self.deleteButton = [[UIButton alloc]init];
            [self.deleteButton makeMine];
            [self.deleteButton setTitle:@"Delete Payment Method"];
            [self.deleteButton addTarget:self
                                  action:@selector(deleteCard)
                        forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:self.deleteButton];
        }
        if ([[[[ELUserManager sharedUserManager]currentCustomer]defaultCardId] isEqualToString:self.card.identifier])
        {
            [self.makeDefaultButton removeFromSuperview];
            self.makeDefaultButton = nil;
        }
        else if(!self.makeDefaultButton)
        {
            self.makeDefaultButton = [[UIButton alloc]init];
            [self.makeDefaultButton makeMine];
            [self.makeDefaultButton setTitle:@"Make Default Payment Method"];
            [self.makeDefaultButton addTarget:self
                                       action:@selector(makeDefaultCard)
                             forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:self.makeDefaultButton];
        }
        [self.stripeView removeFromSuperview];
        self.stripeView = nil;
        
        if (!self.expButton)
        {
            self.expButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.expButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:.85];
            [self.expButton setTitleColor:ICON_BLUE_SOLID forState:UIControlStateNormal];
            self.expButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
            self.expButton.layer.borderWidth = 1;
            self.expButton.layer.cornerRadius = 3;
            [self.expButton addTarget:self action:@selector(expButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:self.expButton];
            [self updateExpButtonText];
        }
    }
    else
    {
        [self.makeDefaultButton removeFromSuperview];
        self.makeDefaultButton = nil;
        [self.deleteButton removeFromSuperview];
        self.deleteButton = nil;
    }
    [self viewWillLayoutSubviews];
}
- (void)populateFromCard{
    self.addressLine1TextField.text = self.card.addressLine1;
    self.addressLine2TextField.text = self.card.addressLine2;
    self.addressCityTextField.text = self.card.addressCity;
    self.addressZipCodeTextField.text = self.card.addressZip;
    self.stateString = self.card.addressState;
    [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
    self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    self.nameTextField.text = self.card.name;
    for (UIView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[ELTextField class]]) {
            ELTextField *tField = (ELTextField *)view;
            if (tField.text.length) tField.layer.borderColor =ICON_BLUE_SOLID.CGColor;
        }
    }
}
- (void)populateCityState{
    
    [self retrieveCityStateFromZipcode:self.addressZipCodeTextField.text completion:^(NSString *city, NSString *state, NSError *error) {
        for (NSString *string in self.stateArray)
        {
            if ([state isEqualToString:self.stateString])
            {
                [self.statePickerView selectRow:[self.stateArray indexOfObject:string] inComponent:0 animated:YES];
                self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
                break;
            }
        }
        self.stateString = state;
        [self.stateButton setTitle:state];
        self.addressCityTextField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
        self.addressCityTextField.text = city;
        
        [self textFieldDidChange:nil];
    }];
}
- (void)updateExpButtonText{
    if (self.card)
    {
        [self.expButton setTitle:[NSString stringWithFormat:@"Expires: %li/%li",(unsigned long)self.card.expMonth,(unsigned long)self.card.expYear] forState:UIControlStateNormal];
    }
}


#pragma mark Action Methods
- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender{
    [self showActivityView];
    [self hideExpPickerView];
    [self hideStatePickerView];
    
    if (!self.card
        && self.validCC
        && self.nameTextField.text.length
        && self.addressCityTextField.text.length
        && self.addressLine1TextField.text.length
        && self.addressZipCodeTextField.text.length == 5)
    {
        ELCard *card = [[ELCard alloc]init];
        card.name = self.nameTextField.text;
        card.addressCity = self.addressCityTextField.text;
        card.addressLine1 = self.addressLine1TextField.text;
        card.addressLine2 = self.addressLine2TextField.text;
        card.addressState = self.stateString;
        card.addressZip = self.addressZipCodeTextField.text;
        card.number = self.stripeView.cardNumber.formattedString;
        card.expMonth = self.stripeView.cardExpiry.month;
        card.expYear = self.stripeView.cardExpiry.year;
        card.cvc = self.stripeView.cardCVC.string;
        card.addressCountry = @"US";
        [ELStripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
            if (!error) {
                [ELCustomer addCard:token toCustomer:[[ELUserManager sharedUserManager]currentCustomer] completion:^(ELCard *card, NSError *error) {
                    if (!error) {
                        self.card = card;
                    }
                    [[ELUserManager sharedUserManager]fetchCustomer];
                }];
            }
            else
            {
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Credit Card Information" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [myAlert show];
                [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
                [[ELUserManager sharedUserManager]fetchCustomer];
            }
        }];
    }
    else if(!self.card && !self.validCC)
    {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Credit Card Information" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
        [[ELUserManager sharedUserManager]fetchCustomer];
    }
    else if (self.card.identifier)
    {
        ELCard *card = self.card;
        card.name = self.nameTextField.text;
        card.addressCity = self.addressCityTextField.text;
        card.addressLine1 = self.addressLine1TextField.text;
        card.addressLine2 = self.addressLine2TextField.text;
        card.addressState = self.stateString;
        card.addressZip = self.addressZipCodeTextField.text;
        card.identifier = self.card.identifier;
        card.addressCountry = self.card.addressCountry;
        card.expMonth = self.card.expMonth;
        card.expYear = self.card.expYear;
        [ELCard updateCard:card customerId:[[ELUserManager sharedUserManager]currentCustomer].identifier completionHandler:^(ELCard *card, NSError *error) {
            if (!error && card)
            {
                self.card = card;
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [myAlert show];
                [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
            }
            else{
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Credit Card Information" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [myAlert show];
                [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
                [[ELUserManager sharedUserManager]fetchCustomer];
            }
            [[ELUserManager sharedUserManager]fetchCustomer];
        }];
    }
    else{
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Credit Card Information" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
        [[ELUserManager sharedUserManager]fetchCustomer];
    }
    
}
- (IBAction)handleViewTap:(id)sender{
    [super handleViewTap:sender];
    [self hideExpPickerView];
    [self hideStatePickerView];
}
- (IBAction)expButtonPressed:(id)sender{
    if (self.currentTextField) {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    }
    if (self.expPickerView.hidden) [self showExpPickerView];
    else [self hideExpPickerView];

}
- (void)stateButtonPressed:(UIButton *)button{
    if (self.currentTextField) {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    }
    if (self.statePickerView.hidden) [self showStatePickerView];
    else [self hideStatePickerView];
}
- (void)makeDefaultCard{
    [self showActivityView];
    [ELCustomer makeCardId:self.card.identifier defaultCardForCustomerId:[[ELUserManager sharedUserManager]currentCustomer].identifier completion:^(ELCustomer *customer, ELCard *card, NSError *error)
     {
         if (!error && card) {
             self.card = card;
             UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
             [myAlert show];
             [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
             [[ELUserManager sharedUserManager]fetchCustomer];
         }
     }];
}
- (void)deleteCard{
    UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil];
    [myAlert show];
}

#pragma mark PTKView Delegate
- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid{
    self.validCC = valid;
    if (!valid){
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Credit Card Information" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
    }
    [self checkForSave];
}
- (void)checkForSave{
    if (((!self.card && self.validCC)|| self.card)
        &&
        (self.nameTextField.text.length
         && self.addressCityTextField.text.length
         && self.addressLine1TextField.text.length
         && self.addressZipCodeTextField.text.length == 5))
    {
        self.saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    else if (self.saveButton)
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.saveButton = nil;
    }
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
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [super textFieldDidBeginEditing:textField];
    [self hideStatePickerView];
    [self hideExpPickerView];
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
    
    [self checkForSave];
}

#pragma mark PickerView Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return (pickerView == self.expPickerView) ? 2:1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == self.expPickerView) return component ? self.expYearArray.count+1:self.expMonthArray.count+1;
    return self.stateArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    if (pickerView == self.expPickerView) {
        if (!row) {
            return component ? @"Year":@"Month";
        }
     return component?self.expYearArray[row-1]:self.expMonthArray[row-1];
    }
    return self.fullStateArray[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView == self.expPickerView)
    {
        if (row)
        {
            if (component) self.card.expYear = [self.expYearArray[row-1] integerValue];
            else self.card.expMonth = [self.expMonthArray[row-1] integerValue];
            [self updateExpButtonText];
        }
        return;
    }
    
    self.stateString =self.stateArray[row];
    [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
    self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
}
- (void)showExpPickerView{
    if (self.currentTextField) {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy"];
    int year =[[dateFormat stringFromDate:[NSDate date]] intValue];
    [UIView animateWithDuration:.3 animations:
     ^{
         
         [self.expPickerView selectRow:self.card.expMonth inComponent:0 animated:YES];
         [self.expPickerView selectRow:self.card.expYear-year+1 inComponent:1 animated:YES];
         self.expPickerView.hidden = NO;
         self.expPickerView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
         self.expPickerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*.75);
     }
                     completion:^(BOOL finished)
     {
     }];
}
- (void)hideExpPickerView{
    [UIView animateWithDuration:.3 animations:
     ^{
         
         self.expPickerView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
         self.expPickerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*1.25);
     }
                     completion:^(BOOL finished)
     {
         self.expPickerView.hidden = YES;
     }];
}
- (void)showStatePickerView{
    if (self.currentTextField)
    {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    }
    [UIView animateWithDuration:.3 animations:
     ^{
         self.statePickerView.hidden = NO;
         self.statePickerView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
         self.statePickerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*.75);
     }
                     completion:^(BOOL finished)
     {
         
     }];
}
- (void)hideStatePickerView{
    [UIView animateWithDuration:.3 animations:
     ^{
         
         self.statePickerView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
         self.statePickerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*1.25);
     }
                     completion:^(BOOL finished)
     {
         self.statePickerView.hidden = YES;
     }];
}


#pragma mark alertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [self showActivityView];
        [self.card deleteWithCompletionHandler:^(NSString *identifier, BOOL success, NSError *error) {
            if (success) {
                [[ELUserManager sharedUserManager]fetchCustomer];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}
@end
