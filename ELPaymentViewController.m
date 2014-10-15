//
//  ELPaymentViewController.m
//  Fuel Logic
//
//  Created by Mike on 6/16/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#define TOP_SPACING 40
#define LEFT_OFFSET 10
#define ROW_HEIGHT 40
#define ROW_SPACING 5
//#define RIGHT_HALF_OFFSET (self.scrollView.bounds.size.width/2 + LEFT_OFFSET/2)


#define ROW_OFFSET TOP_SPACING+(ROW_HEIGHT+ROW_SPACING)
#define FULL_WIDTH (self.scrollView.bounds.size.width-LEFT_OFFSET*2)
#define HALF_WIDTH ((self.scrollView.bounds.size.width-LEFT_OFFSET*3)/2)
#define QUARTER_WIDTH ((self.scrollView.bounds.size.width - LEFT_OFFSET*5)/4)




#define FULL_STATE_ARRAY [NSArray arrayWithObjects:@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil]
#define ABBREVIATED_STATE_ARRAY [NSArray arrayWithObjects:@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY", nil];
#import "ELPaymentViewController.h"
#import "Defines.h"
#import "PTKTextField.h"
#import "ELCustomer.h"
#import "ELOrder.h"
#import "ELOrderSummarView.h"
#import "ViewController.h"
#import "RadioButton.h"
#import "ELLoginViewController.h"
#import "ELCompleteSummaryView.h"
#import "ELUserManager.h"

typedef enum{
 elPaymentStageAddress,elPaymentStageShipping,elPaymentStageCreditCard,elPaymentStageInProcess,elPaymentStageComplete,elPaymentStageError
}ELPaymentStage;

@interface ELPaymentViewController ()
 @property (strong, nonatomic) ELCompleteSummaryView *completeSummaryView;
 @property (strong, nonatomic) UIBarButtonItem *loginBarButtonItem, *continueBarButtonItem, *payBarButtonItem, *createAccountButtonItem;
 @property (strong, nonatomic) UIScrollView *scrollView;
 @property (strong, nonatomic) UIButton *useExistingRadioButton, *useNewRadioButton;
 @property BOOL useExistingCreditCard;
 @property (strong, nonatomic) UIAlertView *paymentErrorAlertView, *verifyPasswordAlertView, *verifyEmailAlertView;
 @property (strong, nonatomic) ELLoginViewController *loginViewController;
 @property (strong, nonatomic) PFUser *currentUser;
 @property ELPTKView *stripeView;
 @property (strong, nonatomic) ELCard *cardToCharge;
 @property BOOL validCC;
 @property BOOL *validCustomerToCharge;
 @property ELPaymentStage paymentStage;
 @property (strong, nonatomic) ELOrderSummarView *summaryView;
 @property (strong, nonatomic) UIScrollView *addressScrollView, *shippingScrollView, *creditCardScrollView, *completeScrollView, *errorScrollView;
 @property (strong, nonatomic) UILabel *shippingLabel;
 @property (strong, nonatomic) NSString *stateString;
 @property (strong, nonatomic) NSArray *stateArray;
 @property (strong, nonatomic) UIButton *stateButton;
 @property (strong, nonatomic) ELTextField *nameTextField, *addressLine1TextField, *addressLine2TextField,*addressCityTextField, *addressZipCodeTextField, *emailTextField, *phoneNumberTextField;
 @property (strong, nonatomic) ELPickerView *statePickerView, *creditCardPickerView;

@end

@implementation ELPaymentViewController
 @synthesize paymentStage = _paymentStage;
-(void)viewDidLoad{
    [super viewDidLoad];
    self.currentUser = [[ELUserManager sharedUserManager]currentUser];
    self.customer = self.order.customer;
    self.cardToCharge = self.order.card;
    self.title = @"Checkout";
    [self calculatingShipping:YES];
    self.stateArray = ABBREVIATED_STATE_ARRAY;
    [self.view setAutoresizesSubviews:YES];
    
    //Setup Methods
    [self setupScrollViews];
    [self populateShippingLabel];
    [self setupSubviews];
    [self setupStripeView];
    [self setupOrder];
    
    self.currentTextField = self.nameTextField;
    [self.currentKeyboardTextField becomeFirstResponder];
    [self setupNotifications];
}

#pragma mark Setup Methods
-(void)setupOrder{
    [self checkToProceed];
    
    if (self.customer && self.customer.defaultCard && self.order.orderStatus != elOrderStatusComplete && self.order.orderStatus != elOrderStatusChargeSucceeded) {
        [self handleRadioButtonSelect:self.useNewRadioButton];
        [self populateShippingLabel];
    }
    else{
        [self handleRadioButtonSelect:self.useNewRadioButton];
    }
    self.completeSummaryView.order = self.order;
    self.completeSummaryView.card = self.cardToCharge;
    
}
-(void)setupNotifications{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedIn:) name:elNotificationLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(customerDownloadComplete:) name:elNotificationCustomerDownloadComplete object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedOut:) name:elNotificationLogoutSucceeded object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(anonUserLoggedIn:) name:elNotificationAnonLoginSucceeded object:nil];
}
-(void)setupStripeView{
    self.stripeView = [[ELPTKView alloc] initWithFrame:CGRectMake(15,20, 290,55)];
    self.stripeView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin);
    self.stripeView.delegate = self;
    self.stripeView.elDelegate = self;
    [self.creditCardScrollView addSubview:self.stripeView];
    [self.stripeView.cardNumberField resignFirstResponder];
}
-(void)setupScrollViews{
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollView.bounces = NO;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*4, self.scrollView.bounds.size.height);
    self.scrollView.autoresizesSubviews = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:self.scrollView];
    
    self.addressScrollView = [[UIScrollView alloc]initWithFrame:self.scrollView.bounds];
    self.scrollViewToKeyBoardAdjust = self.addressScrollView;
    self.addressScrollView.scrollEnabled = YES;
    self.addressScrollView.bounces = NO;
    self.addressScrollView.contentSize = CGSizeMake(self.addressScrollView.bounds.size.width, ROW_OFFSET*5);
    self.addressScrollView.autoresizesSubviews = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [self.scrollView addSubview:self.addressScrollView];
    
    self.shippingScrollView = [[UIScrollView alloc]initWithFrame:self.scrollView.bounds];
    self.shippingScrollView.scrollEnabled = NO;
    self.shippingScrollView.bounces = NO;
    self.shippingScrollView.contentSize = CGSizeMake(self.shippingScrollView.bounds.size.width, 250);
    self.shippingScrollView.autoresizesSubviews = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [self.scrollView addSubview:self.shippingScrollView];
    
    self.creditCardScrollView = [[UIScrollView alloc]initWithFrame:self.scrollView.bounds];
    self.creditCardScrollView.scrollEnabled = YES;
    self.creditCardScrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, 300);
    self.creditCardScrollView.autoresizesSubviews = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [self.scrollView addSubview:self.creditCardScrollView];
    
    self.summaryView = [[ELOrderSummarView alloc]init];
    [self.creditCardScrollView addSubview:self.summaryView];
    
    
    self.completeScrollView = [[UIScrollView alloc]initWithFrame:self.scrollView.bounds];
    self.completeScrollView.scrollEnabled = NO;
    self.completeScrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width-1, 300);
    self.completeScrollView.bounces = NO;
    self.completeScrollView.autoresizesSubviews = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [self.scrollView addSubview:self.completeScrollView];
    
    self.completeSummaryView = [[ELCompleteSummaryView alloc]init];
    [self.completeScrollView addSubview:self.completeSummaryView];
    
    
    
}
-(void)setupSubviews{
    
    UILabel *label = [[UILabel alloc]init];
    label.text = @"Billing Information";
    label.backgroundColor = [UIColor clearColor];
    label.textColor = ICON_BLUE_SOLID;
    label.font = [UIFont fontWithName:MY_FONT_2 size:20];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin);
    label.bounds = CGRectMake(5, 5, self.addressScrollView.bounds.size.width-10, 30);
    label.center = CGPointMake(self.addressScrollView.bounds.size.width/2, 20);
    [self.addressScrollView addSubview:label];
    
    UILabel *shippingLabel = [[UILabel alloc]init];
    shippingLabel.text = @"Shipping Information";
    shippingLabel.backgroundColor = [UIColor clearColor];
    shippingLabel.textColor = ICON_BLUE_SOLID;
    shippingLabel.font = [UIFont fontWithName:MY_FONT_2 size:20];
    shippingLabel.textAlignment = NSTextAlignmentCenter;
    shippingLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin);
    shippingLabel.bounds = CGRectMake(5, 5, self.shippingScrollView.bounds.size.width-10, 40);
    shippingLabel.center = CGPointMake(self.shippingScrollView.bounds.size.width/2, 20);
    [self.shippingScrollView addSubview:shippingLabel];
    
    UILabel *creditCardLabel = [[UILabel alloc]init];
    creditCardLabel.text = @"Credit Card Information";
    creditCardLabel.backgroundColor = [UIColor clearColor];
    creditCardLabel.textColor = ICON_BLUE_SOLID;
    creditCardLabel.font = [UIFont fontWithName:MY_FONT_2 size:20];
    creditCardLabel.textAlignment = NSTextAlignmentCenter;
    creditCardLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin);
    creditCardLabel.bounds = CGRectMake(5, 5, self.creditCardScrollView.bounds.size.width-10, 30);
    creditCardLabel.center = CGPointMake(self.creditCardScrollView.bounds.size.width/2, 20);
    [self.creditCardScrollView addSubview:creditCardLabel];
    
    self.useExistingRadioButton = [[UIButton alloc]init];
    self.useNewRadioButton = [[UIButton alloc]init];
    
    [self.useExistingRadioButton makeMine];
    [self.useExistingRadioButton setTitle:@"Choose Existing Credit Card"];
    [self.useExistingRadioButton addTarget:self action:@selector(handleRadioButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.useNewRadioButton makeMine];
    [self.useNewRadioButton setTitle:@"Use New Credit Card"];
    [self.useNewRadioButton addTarget:self action:@selector(handleRadioButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.shippingLabel = [[UILabel alloc]init];
    self.shippingLabel.backgroundColor = [UIColor clearColor];
    self.shippingLabel.textColor = ICON_BLUE_SOLID;
    self.shippingLabel.font = [UIFont fontWithName:MY_FONT_2 size:20];
    self.shippingLabel.textAlignment = NSTextAlignmentCenter;
    self.shippingLabel.numberOfLines = 3;
    self.shippingLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin);
    self.shippingLabel.bounds = CGRectMake(5, 5, self.shippingScrollView.bounds.size.width-10, 100);
    self.shippingLabel.center = CGPointMake(self.shippingScrollView.bounds.size.width/2, 100);
    if (self.order.shipping) {
        [self populateShippingLabel];
    }
    [self.shippingScrollView addSubview:self.shippingLabel];
    
    self.nameTextField = [self addNewTextField];
    self.nameTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Name As it appears on Credit Card"];
    self.addressLine1TextField = [self addNewTextField];
    self.addressLine1TextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Address Line 1"];
    self.addressLine2TextField = [self addNewTextField];
    self.addressLine2TextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Address Line 2"];
    self.addressLine2TextField.required = NO;
    self.addressLine2TextField.layer.borderColor = [[UIColor grayColor]CGColor];
    self.addressCityTextField = [self addNewTextField];
    self.addressCityTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"City"];
    self.addressCityTextField.required = YES;
    self.addressCityTextField.layer.borderColor = [[UIColor grayColor]CGColor];
    self.addressZipCodeTextField = [self addNewTextField];
    self.addressZipCodeTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Zip Code"];
    self.addressZipCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.emailTextField = [self addNewTextField];
    self.emailTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"E-Mail Address"];
    self.phoneNumberTextField = [self addNewTextField];
    self.phoneNumberTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Phone Number"];
    self.phoneNumberTextField.keyboardType = UIKeyboardTypePhonePad;
    
    self.stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stateButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:.85];
    [self.stateButton setTitleColor:ICON_BLUE_SOLID forState:UIControlStateNormal];
    self.stateButton.layer.borderColor = [UIColor redColor].CGColor;
    self.stateButton.layer.borderWidth = 1;
    self.stateButton.layer.cornerRadius = 3;
    [self.stateButton setTitle:@"State"];
    [self.stateButton addTarget:self action:@selector(stateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.addressScrollView addSubview:self.stateButton];

    self.stateString = self.stateArray[0];
    
    for (UIView *view in self.addressScrollView.subviews) {
        if ([view isKindOfClass:[ELTextField class]]) {
            ELTextField *tField = (ELTextField *)view;
            if (tField.text.length) tField.layer.borderColor =ICON_BLUE_SOLID.CGColor;
        }
    }
    
    [self moveViewUp:self.nameTextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:YES];
    [self moveViewUp:self.addressLine1TextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:YES];
    [self moveViewUp:self.addressLine2TextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:YES];
    [self moveViewUp:self.addressCityTextField withXOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf addSubView:YES];
    [self moveViewUp:self.addressZipCodeTextField withXOffset:ELViewXOffsetNone width:ELViewWidthQuarter addSubView:YES];
    [self moveViewUp:self.stateButton withXOffset:ELViewXOffsetOneHalf width:ELViewWidthQuarter addSubView:YES];
    [self moveViewUp:self.emailTextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:YES];
    [self moveViewUp:self.phoneNumberTextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:YES];
    [self positionTextFields];
}

#pragma mark Position Methods
-(void)populateCityState{
    
    [self calculatingShipping:YES];
    NSString *strRequestParams = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=&components=postal_code:%@&sensor=false",self.addressZipCodeTextField.text];
    strRequestParams = [strRequestParams stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    NSURL *url = [NSURL URLWithString:strRequestParams];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError || !data) {
            return;
        }
        NSDictionary *addressDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *results = addressDict[@"results"];
        if (!results.count) return;
        NSDictionary *addressDict2 = results[0];
        NSArray *addressComponents = addressDict2[@"address_components"];
        // *addComps = results[0];
        BOOL valid = NO;
        for (NSDictionary *dictionary in addressComponents)
        {
            NSArray *typesArray = dictionary[@"types"];
            for (NSString *string in typesArray)
            {
                if ([string isEqualToString:@"country"] && [dictionary[@"short_name"] isEqualToString:@"US"]) valid = YES;
            }
        }
        if (valid) {
            NSString *city = nil;
            for (NSDictionary *dictionary in addressComponents)
            {
                NSArray *typesArray = dictionary[@"types"];
                for (NSString *string in typesArray) {
                    if ([string isEqualToString:@"administrative_area_level_1"]){
                        self.stateString = dictionary[@"short_name"];
                        self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
                        [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
                        for (NSString *string in self.stateArray) {
                            if ([string isEqualToString:self.stateString]) {
                                self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
                                break;
                            }
                        }
                    }
                    else if([string isEqualToString:@"sublocality"]){
                        self.addressCityTextField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
                        self.addressCityTextField.text =dictionary[@"short_name"];
                        city = string;
                    }
                    else if([string isEqualToString:@"locality"] && !city)
                    {
                        self.addressCityTextField.text =dictionary[@"short_name"];
                        self.addressCityTextField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
                    }
                    else if([string isEqualToString:@"administrative_area_level_3"]){
                        self.addressCityTextField.text =dictionary[@"short_name"];
                        self.addressCityTextField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
                    }
                }
            }
        }
    }];
    
    
}
-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    self.scrollView.bounds = self.view.bounds;
    self.scrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*4, self.scrollView.bounds.size.height);
    
    self.addressScrollView.bounds = self.scrollView.bounds;
    self.addressScrollView.center = CGPointMake(self.scrollView.bounds.size.width/2, self.addressScrollView.bounds.size.height/2);
    
    if([PFAnonymousUtils isLinkedWithUser:self.currentUser])
        self.addressScrollView.contentSize = CGSizeMake(self.addressScrollView.bounds.size.width, ROW_OFFSET*6);
    else self.addressScrollView.contentSize = CGSizeMake(self.addressScrollView.bounds.size.width, ROW_OFFSET*7);
    
    
    
    self.shippingScrollView.bounds = self.scrollView.bounds;
    self.shippingScrollView.center = CGPointMake(self.scrollView.bounds.size.width*1.5, self.addressScrollView.bounds.size.height/2);
    
    self.creditCardScrollView.bounds = self.scrollView.bounds;
    self.creditCardScrollView.center = CGPointMake(self.scrollView.bounds.size.width*2.5, self.creditCardScrollView.bounds.size.height/2);
    
    self.completeScrollView.bounds = self.scrollView.bounds;
    self.completeScrollView.center = CGPointMake(self.scrollView.bounds.size.width*3.5, self.creditCardScrollView.bounds.size.height/2);
    
    self.completeSummaryView.bounds = CGRectMake(0, 0, self.completeScrollView.bounds.size.width, self.completeScrollView.bounds.size.height);
    self.completeSummaryView.center = CGPointMake(self.completeScrollView.bounds.size.width/2, self.completeScrollView.bounds.size.height/2);
    
    self.summaryView.bounds = CGRectMake(0, 0, self.creditCardScrollView.bounds.size.width*.8,150);
    self.summaryView.center = CGPointMake(self.creditCardScrollView.bounds.size.width/2, 190);
    
    self.stripeView.center = CGPointMake(self.creditCardScrollView.bounds.size.width/2, 87);
    
    if (self.statePickerView.hidden){
        self.statePickerView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
        self.statePickerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*1.25);
    }
    else{
        self.statePickerView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
        self.statePickerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*.75);
    }
    self.paymentStage = self.paymentStage;
    
    [self positionRadioButtons];
    [self positionTextFields];
}
-(void)positionRadioButtons{
    
    if(![PFAnonymousUtils isLinkedWithUser:self.currentUser] && self.currentUser && [[[ELUserManager sharedUserManager]currentCustomer]cards].count)
    {
        
        [self.addressScrollView addSubview:self.useExistingRadioButton];
        [self.addressScrollView addSubview:self.useNewRadioButton];
    }
    
    if (self.useExistingCreditCard)
    {
        if (![PFAnonymousUtils isLinkedWithUser:self.currentUser] && [self.currentUser[@"emailVerified"]boolValue]) {
            
            [self.useNewRadioButton makeMine];
            [self.useExistingRadioButton makeMine2];
        }
        else{
            [self.useNewRadioButton makeMine2];
            [self.useExistingRadioButton makeMine];
        }
    }
    else
    {
        [self.useNewRadioButton makeMine2];
        [self.useExistingRadioButton makeMine];
    }
    
    [UIView animateWithDuration:.25 animations:
     ^{
         if([PFAnonymousUtils isLinkedWithUser:self.currentUser] || !self.currentUser || ![[ELUserManager sharedUserManager]currentCustomer] || ![[[ELUserManager sharedUserManager]currentCustomer]cards].count)
         {
             [self placeView:self.useExistingRadioButton withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:-3];
             [self placeView:self.useNewRadioButton  withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:-4];
         }
         else{
             [self placeView:self.useExistingRadioButton withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:0];
             [self placeView:self.useNewRadioButton withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:1];
         }
         
     }
                     completion:^(BOOL finished)
     {
         if([PFAnonymousUtils isLinkedWithUser:self.currentUser] || !self.currentUser || ![[ELUserManager sharedUserManager]currentCustomer] || ![[[ELUserManager sharedUserManager]currentCustomer]cards].count)
         {
             [self.useExistingRadioButton removeFromSuperview];
             [self.useNewRadioButton removeFromSuperview];
         }
         
     }];
}
-(void)positionTextFields{
    if (self.useExistingCreditCard) [self hideTextFields];
    else [self showTextFields];
}
-(void)showTextFields{
    
    [UIView animateWithDuration:.25 animations:
     ^{
         int offset = 2;
         int factor = !self.useExistingCreditCard;
         if([PFAnonymousUtils isLinkedWithUser:self.currentUser] || !self.currentUser || ![[ELUserManager sharedUserManager]currentCustomer] || ![[[ELUserManager sharedUserManager]currentCustomer]cards].count) offset-=2;
         
         [UIView animateWithDuration:.25 animations:
          ^{
              [self placeView:self.nameTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:offset+0*factor];
              [self placeView:self.addressLine1TextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:offset+1*factor];
              [self placeView:self.addressLine2TextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:offset+2*factor];
              [self placeView:self.addressCityTextField withOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf offset:offset+3*factor];
              [self placeView:self.addressZipCodeTextField withOffset:ELViewXOffsetNone width:ELViewWidthQuarter offset:offset+3*factor];
              [self placeView:self.stateButton withOffset:ELViewXOffsetOneQuarter width:ELViewWidthQuarter offset:offset+3*factor];
              [self placeView:self.emailTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:offset+4*factor];
              [self placeView:self.phoneNumberTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:offset+5*factor];
              self.nameTextField.alpha = 1;
              self.addressLine1TextField.alpha = 1;
              self.addressLine2TextField.alpha = 1;
              self.addressCityTextField.alpha = 1;
              self.addressZipCodeTextField.alpha = 1;
              self.stateButton.alpha = 1;
              self.emailTextField.alpha = 1;
              self.phoneNumberTextField.alpha = 1;
          }
                          completion:^(BOOL finished)
          {
              
              
          }];
     }
                     completion:^(BOOL finished)
     {
         self.addressScrollView.contentSize = CGSizeMake(self.addressScrollView.bounds.size.width, ROW_OFFSET*7+ROW_HEIGHT/2);
     }];
    
    
}
-(void)hideTextFields{
    [UIView animateWithDuration:.25 animations:
     ^{
         self.nameTextField.alpha = .25;
         self.addressLine1TextField.alpha = .25;
         self.addressLine2TextField.alpha = .25;
         self.addressCityTextField.alpha = .25;
         self.addressZipCodeTextField.alpha = .25;
         self.stateButton.alpha = .25;
         self.emailTextField.alpha = .25;
         self.phoneNumberTextField.alpha = .25;
         
         
//         [self moveViewUp:self.nameTextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:NO];
//         [self moveViewUp:self.addressLine1TextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:NO];
//         [self moveViewUp:self.addressLine2TextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:NO];
//         [self moveViewUp:self.addressCityTextField withXOffset:ELViewXOffsetOneHalf width:ELViewWidthHalf addSubView:NO];
//         [self moveViewUp:self.addressZipCodeTextField withXOffset:ELViewXOffsetNone width:ELViewWidthQuarter addSubView:NO];
//         [self moveViewUp:self.stateButton withXOffset:ELViewXOffsetOneHalf width:ELViewWidthQuarter addSubView:NO];
//         [self moveViewUp:self.emailTextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:NO];
//         [self moveViewUp:self.phoneNumberTextField withXOffset:ELViewXOffsetNone width:ELViewWidthFull addSubView:NO];
         
     }
                     completion:^(BOOL finished)
     {
//         for (UIView *view in self.addressScrollView.subviews) {
//             if ([view isKindOfClass:[UITextField class]]) {
//                 [view removeFromSuperview];
//             }
//         }
//         [self.stateButton removeFromSuperview];
//         self.addressScrollView.contentSize = CGSizeMake(self.addressScrollView.bounds.size.width, ROW_OFFSET*3+ROW_HEIGHT/2);
     }];
}
-(void)moveViewUp:(UIView *)view withXOffset:(ELViewXOffset)xOffset width:(ELViewWidth)width addSubView:(BOOL)add{
    int offset = 2;
    
    
    switch (width) {
        case ELViewWidthFull:
            view.bounds = CGRectMake(0, 0, FULL_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthHalf:
            view.bounds = CGRectMake(0, 0, HALF_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthQuarter:
            view.bounds = CGRectMake(0, 0, QUARTER_WIDTH, ROW_HEIGHT);
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
        default:
            break;
    }
    if (add) [self.addressScrollView addSubview:view];
}
-(void)placeView:(UIView *)view withOffset:(ELViewXOffset)xOffset width:(ELViewWidth)width offset:(float)offset{
    
    switch (width) {
        case ELViewWidthFull:
            view.bounds = CGRectMake(0, 0, FULL_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthHalf:
            view.bounds = CGRectMake(0, 0, HALF_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthQuarter:
            view.bounds = CGRectMake(0, 0, QUARTER_WIDTH, ROW_HEIGHT);
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
        default:
            break;
    }
}
-(void)showStatePickerView{
    

    self.statePickerView = [[ELPickerView alloc]init];
    self.statePickerView.delegate = self;
    self.statePickerView.elDelegate = self;
    self.statePickerView.dataSource= self;
    
    for (int i = 0; i<self.stateArray.count; i++) {
        if ([self.stateArray[i] isEqualToString:self.stateString]) {
            [self.statePickerView.pickerView selectRow:i inComponent:0 animated:YES];
        }
    }
    
    [self.statePickerView presentGlobally];
    
}
-(void)showCreditCardPickerView{
    
    self.creditCardPickerView = [[ELPickerView alloc]init];
    self.creditCardPickerView.delegate = self;
    self.creditCardPickerView.elDelegate = self;
    self.creditCardPickerView.dataSource= self;
    for (int i = 0; i<self.customer.cards.count; i++) {
        if (self.cardToCharge == self.customer.cards[i]) {
            [self.creditCardPickerView.pickerView selectRow:i inComponent:0 animated:YES];
            [self pickerView:self.creditCardPickerView.pickerView didSelectRow:i inComponent:0];
        }
        else{
            [self.creditCardPickerView.pickerView selectRow:0 inComponent:0 animated:YES];
            [self pickerView:self.creditCardPickerView.pickerView didSelectRow:i inComponent:0];
        }
    }
    [self.creditCardPickerView presentGlobally];
    
    if (self.currentTextField) {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    }
}
-(void)showStripe{
    [UIView animateWithDuration:.25 animations:
     ^{
         [self.creditCardScrollView addSubview:self.stripeView];
         
     }
                     completion:^(BOOL finished)
     {
         
     }];
}
-(void)hideStripe{
    [UIView animateWithDuration:.25 animations:
     ^{
         [self.stripeView removeFromSuperview];
     }
                     completion:^(BOOL finished)
     {
     }];
}
-(void)showLoginButton{
    self.loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                               style:UIBarButtonItemStyleDone target:self action:@selector(login:)];
    if (![PFAnonymousUtils isLinkedWithUser:self.currentUser])self.loginBarButtonItem.title = @"Logout";
}
-(void)showContinue{
    self.continueBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  Next"
                                                                  style:UIBarButtonItemStyleDone target:self action:@selector(proceed:)];
}
-(void)showPayButton{
    self.payBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Complete"
                                                             style:UIBarButtonItemStyleDone target:self action:@selector(pay:)];
}
-(void)showCreateAccount{
    self.createAccountButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create Account"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(login:)];
}
-(void)hideLogin{
    self.loginBarButtonItem = nil;
}
-(void)hideContinue{
    self.continueBarButtonItem = nil;
}
-(void)hidePay{
    self.payBarButtonItem = nil;
}
-(void)hideCreateAccount{
    self.createAccountButtonItem = nil;
}
-(void)displayButtons{
    NSMutableArray *array = [NSMutableArray array];
    if (self.continueBarButtonItem) {
        [array addObject:self.continueBarButtonItem];
    }
    if (self.payBarButtonItem) {
        [array addObject:self.payBarButtonItem];
    }
    if (self.loginBarButtonItem) {
        //No longer showing login button during checkout.
        //[array addObject:self.loginBarButtonItem];
    }
    if (self.createAccountButtonItem) {
        [array addObject:self.createAccountButtonItem];
    }
    self.navigationItem.rightBarButtonItems = array;
}


#pragma mark Control Methods
-(void)resetRadioButtonControl{
    if([PFAnonymousUtils isLinkedWithUser:self.currentUser] || !self.currentUser || ![[ELUserManager sharedUserManager]currentCustomer] || ![[[ELUserManager sharedUserManager]currentCustomer]cards].count)
    {
        [self handleRadioButtonSelect:self.useNewRadioButton];
    }
    else if(self.currentUser)
    {
        if (self.customer && self.customer.defaultCard) {
            [self handleRadioButtonSelect:self.useExistingRadioButton];
        }
        else{
            [self handleRadioButtonSelect:self.useNewRadioButton];
        }
    }
    else
    {
        [self handleRadioButtonSelect:self.useNewRadioButton];
    }
}
-(void)checkToProceed{
    [self hideContinue];
    [self hideLogin];
    [self hidePay];
    [self displayButtons];
    if (self.order.orderStatus == elOrderStatusComplete || self.order.orderStatus == elOrderStatusChargeSucceeded) {
        self.paymentStage = elPaymentStageComplete;
    }
    NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *myPhoneNumberStringSet = [NSCharacterSet characterSetWithCharactersInString:[self simple:self.phoneNumberTextField.text]];
    switch (self.paymentStage)
    {
        case elPaymentStageAddress:
            if(self.customer && self.customer.identifier && self.customer.defaultCard && self.useExistingCreditCard)
            {
                [self calculatingShipping:NO];
                [self showContinue];
            }
            else if (!self.useExistingCreditCard
                     && self.nameTextField.text.length
                     && self.addressCityTextField.text.length
                     && self.addressLine1TextField.text.length
                     && self.addressZipCodeTextField.text.length == 5
                     && [self validateEmail:[self.emailTextField.text lowercaseString]]
                     && [self simple:self.phoneNumberTextField.text].length >= 10
                     && [numericOnly isSupersetOfSet: myPhoneNumberStringSet]
                     ) {
                [self calculatingShipping:NO];
                [self showContinue];
            }
            if (self.currentUser) {
                [self showLoginButton];
            }
            
            
            break;
        case elPaymentStageShipping:
            if (self.order.shipping)
            {
                [self showContinue];
            }
            else [self hideContinue];
            break;
        case elPaymentStageCreditCard:
            if (!self.useExistingCreditCard
                && self.validCC
                && self.nameTextField.text.length
                && self.addressCityTextField.text.length
                && self.addressLine1TextField.text.length
                && self.addressZipCodeTextField.text.length == 5
                && [self validateEmail:[self.emailTextField.text lowercaseString]]
                && [self simple:self.phoneNumberTextField.text].length >= 10
                && [numericOnly isSupersetOfSet: myPhoneNumberStringSet]
                ){
                [self showPayButton];
            }
            else if(self.customer && self.customer.identifier && self.customer.defaultCard && self.useExistingCreditCard) {
                [self showPayButton];
            }
            break;
        default:
            break;
    }
    [self displayButtons];
}

#pragma IBactions
-(IBAction)login:(id)sender{
    if ([PFAnonymousUtils isLinkedWithUser:self.currentUser] )  [self login];
    else
    {
        [[ELUserManager sharedUserManager]logout];
    }
}
-(IBAction)handleLoginButtonPressed:(UIButton *)sender{
    [self login];
}
-(IBAction)stateButtonPressed:(UIButton *)button{
    if (self.useExistingCreditCard) return;
    if (self.currentTextField) {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    }
    [self showStatePickerView];
}
-(IBAction)handleRadioButtonSelect:(UIButton *)sender{
    
    self.order.zipCode = self.addressZipCodeTextField.text.length>=5?self.addressZipCodeTextField.text:nil;
    if (sender == self.useExistingRadioButton)
    {
        if (![PFAnonymousUtils isLinkedWithUser:self.currentUser] && [self.currentUser[@"emailVerified"]boolValue]) {
            self.useExistingCreditCard = YES;
            if (self.creditCardPickerView.hidden) [self showCreditCardPickerView];
            [self showCreditCardPickerView];
            self.stripeView.cardNumberField.text = [NSString stringWithFormat:@"**** **** **** %@",self.customer.defaultCard.last4];
            self.order.zipCode = nil;
        }
        else if(![PFAnonymousUtils isLinkedWithUser:self.currentUser] && ![self.currentUser[@"emailVerified"]boolValue])
        {
            [self.currentUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
            }];
            self.verifyEmailAlertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"You haven't verified your email address associated with your account." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Resend",nil];
            [self.verifyEmailAlertView show];
        }
        else
        {
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:nil message:@"No Available Card to Charge" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [myAlert show];
        }
    }
    else
    {

        self.stripeView.cardNumberField.text = @"";
        self.useExistingCreditCard = NO;
        self.stripeView.cardNumberField.text = nil;
    }

    [self calculatingShipping:YES];
    [self positionRadioButtons];
    [self positionTextFields];
    [self checkToProceed];
    
}
-(IBAction)proceed:(UIBarButtonItem *)sender{
    if (self.currentTextField) [self handleViewTap:nil];
    
    switch (self.paymentStage)
    {
        case elPaymentStageAddress:
        {
            [self calculatingShipping:NO];
            self.paymentStage = elPaymentStageShipping;
            [self checkToProceed];
            break;
        }
        case elPaymentStageShipping:
            self.paymentStage = elPaymentStageCreditCard;
            [self checkToProceed];
            break;
        default:
            
            NSLog(@"other");
            break;
    }
}
-(IBAction)pay:(UIBarButtonItem *)sender{
    if (self.paymentStage == elPaymentStageInProcess) return;
    
    self.paymentStage = elPaymentStageInProcess;
    [self showActivityView];
    if (self.currentTextField) [self handleViewTap:nil];
    [self hidePay];
    [self hideStripe];
    [self performSelectorOnMainThread:@selector(displayButtons) withObject:nil waitUntilDone:YES];
    
    
    ELCustomer *startingcustomer = self.customer ? self.customer : [ELCustomer customer];
    
    if (!self.useExistingCreditCard) {
        startingcustomer.email = [self.emailTextField.text lowercaseString];
        startingcustomer.descriptor = [self simple:self.phoneNumberTextField.text];
    }
    startingcustomer.currency = @"usd";
    
    //If there is no customer immediately create a new customer, and add the card information
    if(!self.customer && self.validCC)
    {
        [self chargeNewCustomer];
    }
    else if (self.customer && self.customer.identifier && !self.useExistingCreditCard && self.validCC)
    {
        [self chargeExistingCustomerWithNewCard];
    }
    else if (self.customer && self.customer.identifier && self.customer.defaultCardId && self.useExistingCreditCard && self.cardToCharge)
    {
        [self chargeExistingCustomerWithSelectedCard];
    }
    else
    {
        [self handlePaymentError:errorFromELErrorType(elErrorCodeNotReadyToChargeGeneral)];
        NSLog(@"no applicable card to charge");
    }
}

#pragma mark Order Methods
-(void)calculatingShipping:(BOOL)override{
    if (!self.order.shipping || override)
    {
        if ([self.order calculateShippingAsync:^(ELOrderStatus orderStatus, NSError *error)
             {
                 if (!error)
                 {
                     [self populateShippingLabel];
                     [self checkToProceed];
                 }
                 else{
                     [self populateErrorShippingLabel];
                     [self checkToProceed];
                 }
             }])
        {
            self.shippingLabel.text = @"Calculating Shipping";
        }
    }
}
-(void)chargeExistingCustomerWithSelectedCard{
    if ([[ELUserManager sharedUserManager] passwordSessionActive]) {
        [self payUsingCustomerExistingCard];
    }
    else{
        [[ELUserManager sharedUserManager] verifyPasswordWithComletion:^(BOOL verified, NSError *error) {
            if (verified && [[ELUserManager sharedUserManager]passwordSessionActive]) [self payUsingCustomerExistingCard];
            else [self handlePaymentError:errorFromELErrorType(elErrorCodeVerificationRequired)];
        }];
    }
}
-(void)chargeExistingCustomerWithNewCard{
    [self.cardToCharge createTokenWithCompletionHandler:^(STPToken *token, NSError *error) {
        if (error || !token)
        {
            [self handlePaymentError:error];
            NSLog(@"%@\n%li",error,(long)error.code);
            
        }
        else {
            ELCustomer *customer = self.customer;
            [customer addToken:token toStripeCustomerWithCompletion:^(ELCustomer *finalCustomer, ELCard *card, NSError *error) {
                if (error || !card)
                {
                    NSLog(@"%@",error.localizedDescription);
                    [self handlePaymentError:error];
                }
                else {
                    self.customer = finalCustomer;
                    self.order.customer = self.customer;
                    self.order.card = card;
                    [self.order processOrderForPayment:^(ELOrderStatus orderStatus, NSError *error) {
                        if (error) {
                            [self handlePaymentError:error];
                        }
                        else if (orderStatus == elOrderStatusComplete) {
                            [self handlePaymentSuccess];
                        }
                        else if(orderStatus == elOrderStatusChargeSucceeded)
                        {
                            NSLog(@"Order successfully charged, error saving to parse:%@",error);
                        }
                    }];
                    
                }
            }];
        }
    }];
}
-(void)chargeNewCustomer{
    ELCustomer *startingcustomer = [ELCustomer customer];
    startingcustomer.email = [self.emailTextField.text lowercaseString];
    startingcustomer.descriptor = [self simple:self.phoneNumberTextField.text];
    startingcustomer.currency = @"usd";

    //If there is no customer immediately create a new customer, and add the card information

    [ELCustomer createStripeCustomer:startingcustomer completionHandler:^(ELCustomer *customer, NSError *error) {
        if (error)
        {
            NSLog(@"Error Creating Customer:%@",error);
            [self handlePaymentError:error];
        }
        else
        {
            [self.cardToCharge createTokenWithCompletionHandler:^(STPToken *token, NSError *error)
             {
                 if (error || !token) NSLog(@"Error creating token:%@",error);
                 else {
                     [customer addToken:token toStripeCustomerWithCompletion:^(ELCustomer *finalCustomer, ELCard *card, NSError *error) {
                         if (error || !finalCustomer){
                             NSLog(@"Error:%@ \n Adding token:%@ \nTo Customer:%@",error,token,finalCustomer);
                             [self handlePaymentError:error];
                         }
                         else {
                             self.customer = finalCustomer;
                             self.order.customer = self.customer;
                             self.order.card = card;
                             [self.order processOrderForPayment:^(ELOrderStatus orderStatus, NSError *error) {
                                 if (error) {
                                     [self handlePaymentError:error];
                                 }
                                 
                                 if (orderStatus == elOrderStatusComplete) {
                                     [self handlePaymentSuccess];
                                 }
                                 else if(orderStatus == elOrderStatusChargeSucceeded)
                                 {
                                     NSLog(@"Order successfully charged, error saving to parse:%@",error);
                                 }
                                 else if(orderStatus == elOrderStatusChargeUnsuccessful){
                                     [self handlePaymentError:error];
                                 }
                             }];
                             
                         }
                     }];
                 }
                 
             }];
        }
        
    }];
}
-(void)payUsingCustomerExistingCard{
    self.order.customer = self.customer;
    self.order.card = self.cardToCharge;
    [self.order processOrderForPayment:^(ELOrderStatus orderStatus, NSError *error) {
        if (error) {
            [self handlePaymentError:error];
        }
        else if (orderStatus == elOrderStatusComplete) {
            [self handlePaymentSuccess];
        }
        else if(orderStatus == elOrderStatusChargeSucceeded)
        {
            NSLog(@"Order successfully charged, error saving to parse:%@",error);
        }
        else if(orderStatus == elOrderStatusChargeUnsuccessful){
            [self handlePaymentError:error];
        }
        else NSLog(@"unhandled condition");
    }];
}
-(void)handlePaymentError:(NSError *)error{
    [self hideActivityView];
    if (self.order.orderStatus == elOrderStatusComplete) {
        self.paymentStage = elPaymentStageComplete;
        [self hideStripe];
    }
    else{
        self.paymentErrorAlertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        switch (error.code) {
                
            case elErrorCodeCardDeclinedCVC:
                self.paymentErrorAlertView.title = @"Declined";
                self.paymentErrorAlertView.message = @"CVC Rejected";
                break;
            case elErrorCodeCardDeclinedExpired:
                self.paymentErrorAlertView.title = @"Declined";
                self.paymentErrorAlertView.message = @"Expired Credit Card";
                break;
            case elErrorCodeCardDeclinedLine1:
                self.paymentErrorAlertView.title = @"Declined";
                self.paymentErrorAlertView.message = @"Address Rejected";
                break;
            case elErrorCodeCardDeclinedLine1Zip:
                self.paymentErrorAlertView.title = @"Declined";
                self.paymentErrorAlertView.message = @"Address Rejected";
                break;
            case elErrorCodeCardDeclinedNoMessage:
                self.paymentErrorAlertView.title = @"Declined";
                self.paymentErrorAlertView.message = @"Declined";
                break;
            case elErrorCodeVerificationRequired:
                self.paymentErrorAlertView.title = @"Error";
                self.paymentErrorAlertView.message = @"Verification Required";
                break;
            default:
                self.paymentErrorAlertView.title = @"Error";
                self.paymentErrorAlertView.message = @"Error processing payment please try again later.";
                break;
        }
        [self.paymentErrorAlertView show];
        [self showStripe];
        self.paymentStage = elPaymentStageError;
    }
    NSLog(@"%@",error);
}
-(void)handlePaymentSuccess{
    [self hideActivityView];
    if ([PFAnonymousUtils isLinkedWithUser:self.currentUser] || ![self.currentUser[@"emailVerified"] boolValue]) {
        [self showCreateAccount];
        [self displayButtons];
    }
    self.completeSummaryView.order = self.order;
    self.completeSummaryView.card = self.cardToCharge;
    self.paymentStage = elPaymentStageComplete;
}
-(ELCard *)cardFromTextFields{
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
-(ELPaymentStage)paymentStage{
    return _paymentStage;
}
-(void)setPaymentStage:(ELPaymentStage)paymentStage{
    _paymentStage = paymentStage;
    [UIView animateWithDuration:.25 animations:
     ^{
         switch (paymentStage) {
             case elPaymentStageAddress:
                 [self checkToProceed];
                 self.scrollView.contentOffset = CGPointMake(0, 0);
                 break;
             case elPaymentStageShipping:
                 [self.currentTextField resignFirstResponder];
                 self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width*1, 0);
                 break;
             case elPaymentStageCreditCard:
                 [self.summaryView setOrder:self.order];
                 self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width*2, 0);
                 break;
             case elPaymentStageInProcess:
                 [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*2, 0)];
                 break;
             case elPaymentStageComplete:
                 [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*3, 0) animated:self.scrollView.contentOffset.x < 300 ? NO:YES];
                 break;
             case elPaymentStageError:
                 self.scrollView.contentOffset = CGPointMake(0, 0);
                 break;
             default:
                 break;
         }
         
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    
}

#pragma mark Login Notification/Delegate Methods
-(void)userLoggedOut:(NSNotification *)notification{
    [self hideLogin];
    [self displayButtons];
    [self resetRadioButtonControl];
    [self positionRadioButtons];
    [self positionTextFields];
    [self clearTextFields];
    [self checkToProceed];
}
-(void)customerDownloadComplete:(NSNotification *)notification{
    self.customer = notification.object;
    [self resetRadioButtonControl];
    [self positionRadioButtons];
    [self positionTextFields];
    [self fillFromCustomerWithCard:self.customer.defaultCard];
    [self checkToProceed];
}
-(void)userLoggedIn:(NSNotification *)notification{
    [self hideCreateAccount];
    self.currentUser = notification.object;
    [self positionRadioButtons];
    [self positionTextFields];
    [self checkToProceed];
}
-(void)anonUserLoggedIn:(NSNotification *)notification{
    self.currentUser = notification.object;
    [self showLoginButton];
    [self displayButtons];
    [self positionRadioButtons];
    [self checkToProceed];
}
//StripeView Delegate
-(void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid{
    NSLog(@"valid:%@",valid?@"YES":@"NO");
    self.validCC = valid;
    if (!valid){
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Credit Card Information" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
    }
    else if(!self.useExistingCreditCard) self.cardToCharge = [self cardFromTextFields];
    [self checkToProceed];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView == self.paymentErrorAlertView) {
        self.stripeView.cardNumberField.text = nil;
        self.stripeView.cardExpiryField.text = nil;
        self.stripeView.cardCVCField.text = nil;
        self.validCC = NO;
        [self showStripe];
        self.paymentStage = elPaymentStageAddress;
    }
    else if(alertView == self.verifyEmailAlertView && buttonIndex)
    {
        
        [self.currentUser setEmail:[NSString stringWithFormat:@"%@",self.currentUser.email]];
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Email Verification Error:%@",error);
            }
            else{
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Sent" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [myAlert show];
                [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:.5];
            }
        }];
    }
}

#pragma mark Utility
-(ELTextField *)addNewTextField{
    ELTextField *textField = [super addNewTextField];
    textField.delegate = self;
    return textField;
}
-(void)populateShippingLabel{
    if (self.order.shipping && self.order.cheapestShipmentCarrier) self.shippingLabel.text = [NSString stringWithFormat:@"%@: $%.2f",self.order.cheapestShipmentCarrier, self.order.shipping.floatValue];
}
-(void)populateErrorShippingLabel{
    self.shippingLabel.text = @"Error Retrieving Shipping Prices. Try again later or Contact E-Nough Logic at 413-206-9184";
}
-(void)fillFromCustomerWithCard:(ELCard *)card{
    if (self.customer && [self.currentUser[@"emailVerified"]boolValue])
    {
        self.emailTextField.text = self.customer.email;
        self.addressLine1TextField.text = card.addressLine1;
        self.addressLine2TextField.text = card.addressLine2;
        self.addressCityTextField.text = card.addressCity;
        self.phoneNumberTextField.text = self.customer.descriptor;
        [self textField:self.phoneNumberTextField shouldChangeCharactersInRange:NSRangeFromString(self.phoneNumberTextField.text) replacementString:self.phoneNumberTextField.text];
        if ([card.addressZip isKindOfClass:[NSString class]]) {
            self.addressZipCodeTextField.text = card.addressZip;
        }
        self.stateString = card.addressState;
        [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
        self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
        self.nameTextField.text = card.name;
        for (UIView *view in self.addressScrollView.subviews) {
            if ([view isKindOfClass:[ELTextField class]]) {
                ELTextField *tField = (ELTextField *)view;
                if (tField.text.length) tField.layer.borderColor =ICON_BLUE_SOLID.CGColor;
            }
        }
    }
    else{
        [self clearTextFields];
    }
    
}
-(void)clearTextFields{
    for (UIView *view in self.addressScrollView.subviews)
    {
        if ([view isKindOfClass:[ELTextField class]]) {
            ELTextField *tField = (ELTextField *)view;
            [tField performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:YES];
            [self textFieldDidChange:tField];
            //  [tField setNeedsDisplay];
            // NSLog(@"text:%@",tField.text);
        }
    }
    // [self.addressScrollView setNeedsDisplay];
}
+ (ViewController*) topMostController{
    ViewController *topController = (ViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = (ViewController *)topController.presentedViewController;
    }
    return topController;
}
-(void)autoCloseAlertView:(UIAlertView*)alert{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

#pragma mark NavigationMethods
-(BOOL)navigationShouldPopOnBackButton{
    BOOL shouldPop = (self.paymentStage == elPaymentStageAddress);
    switch (self.paymentStage) {
        case elPaymentStageCreditCard:
            self.paymentStage = elPaymentStageShipping;
            break;
        case elPaymentStageShipping:
            self.paymentStage = elPaymentStageAddress;
            break;
        case elPaymentStageComplete:
            return YES;
        case elPaymentStageError:
            self.paymentStage = elPaymentStageAddress;
            break;
        default:
            break;
    }
    [self checkToProceed];
    return shouldPop;
}

#pragma mark TextField Edit Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.addressZipCodeTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 5) ? NO : YES;
    }
    else if (textField == self.phoneNumberTextField)
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
        [self checkToProceed];
        return false;
    }
    return YES;

}
-(NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {
    if(simpleNumber.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    // check if the number is to long
    if(simpleNumber.length>10) {
        // remove last extra chars.
        simpleNumber = [simpleNumber substringToIndex:10];
    }
    
    if(deleteLastChar) {
        // should we delete the last digit?
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length<7)
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    
    else   // else do this one..
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}
-(NSString *)simple:(NSString *)string{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
    return string;
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ((textField == self.nameTextField||
        textField == self.addressLine1TextField||
        textField == self.addressLine2TextField||
        textField == self.addressCityTextField||
        textField == self.addressZipCodeTextField||
        textField == self.emailTextField||
        textField == self.phoneNumberTextField)
        && self.useExistingCreditCard) return NO;
    
    return !(self.order.orderStatus == elOrderStatusComplete || self.order.orderStatus == elOrderStatusChargeSucceeded);
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [super textFieldDidBeginEditing:textField];

}
- (BOOL)pkTextFieldShouldBeginEditing:(PTKTextField *)textField{
    
    if (!self.paymentStage == elPaymentStageCreditCard || self.useExistingCreditCard)return NO;
    self.currentTextField = textField;
    return YES;
}
- (void)textFieldDidChange:(ELTextField *)textField{
    if (textField.text.length) textField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    else textField.layer.borderColor =   textField.required ?  [[UIColor redColor] colorWithAlphaComponent:1].CGColor:[[UIColor grayColor] colorWithAlphaComponent:.65].CGColor;
    
    
    if (textField == self.addressZipCodeTextField ) {
        if (self.addressZipCodeTextField.text.length == 5)
        {
            self.order.zipCode = textField.text;
            [self populateCityState];
            [self calculatingShipping:YES];
        }
        else{
            self.order.zipCode = nil;
            textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
        }
    }
    else if(textField == self.emailTextField)
    {
        if (![self validateEmail:[self.emailTextField.text lowercaseString]]) textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
    }
    else if(textField == self.phoneNumberTextField)
    {
        NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *myPhoneNumberStringSet = [NSCharacterSet characterSetWithCharactersInString:[self simple:self.phoneNumberTextField.text]];
        
        
        if ([self simple:self.phoneNumberTextField.text].length < 10 || ![numericOnly isSupersetOfSet:myPhoneNumberStringSet]) textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
    }
    [self checkToProceed];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [super textFieldDidEndEditing:textField];
    [self checkToProceed];
}
#pragma mark - Pickerview Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == self.statePickerView.pickerView)     return self.stateArray.count;
    else if(pickerView == self.creditCardPickerView.pickerView) return self.customer.cards.count;
    return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView == self.statePickerView.pickerView) return self.stateArray[row];
    else if(pickerView == self.creditCardPickerView.pickerView) return [NSString stringWithFormat:@"%@:xxxx%@",[self.customer.cards[row] brand],[self.customer.cards[row] last4]];
    
    return nil;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    [label makeMine];
    if (pickerView == self.statePickerView.pickerView){
        label.text = self.stateArray[row];
    }
    else if(pickerView == self.creditCardPickerView.pickerView)
    {
        label.text = [NSString stringWithFormat:@"%@: x%@",[self.customer.cards[row] brand],[self.customer.cards[row] last4]];
    }
    
    return label;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView == self.statePickerView.pickerView) {
       
        [self.stateButton setTitle:self.stateArray[row] forState:UIControlStateNormal];
    }
    else if(pickerView == self.creditCardPickerView.pickerView) {
        [self fillFromCustomerWithCard:self.customer.cards[row]];
    }
}
-(void)pickerView:(ELPickerView *)pickerView cancelledSelectionAtRow:(NSInteger)row{
    if (pickerView == self.statePickerView) {
        [self fillFromCustomerWithCard:self.cardToCharge];
    }
    else if(pickerView == self.creditCardPickerView)
    {
        if (!self.cardToCharge) {
            [self clearTextFields];
            [self handleRadioButtonSelect:self.useNewRadioButton];
        }
        else [self fillFromCustomerWithCard:self.cardToCharge];
    }
    [pickerView removeFromSuperview];
}
-(void)pickerView:(ELPickerView *)pickerView completedSelectionAtRow:(NSInteger)row{
    if (pickerView == self.statePickerView) {
        self.stateString =self.stateArray[row];
        [self.stateButton setTitle:self.stateString forState:UIControlStateNormal];
        self.stateButton.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    }
    else if(pickerView == self.creditCardPickerView)
    {
        
        ELCard *oldCard = self.cardToCharge;
        self.cardToCharge = self.customer.cards[row];
        if (oldCard != self.cardToCharge) [self calculatingShipping:YES];
        self.order.card = self.cardToCharge;
        [self fillFromCustomerWithCard:self.cardToCharge];
    }
    [pickerView removeFromSuperview];
}


-(void)login{
    self.loginViewController  = [[ELLoginViewController alloc] init];
    // Create the sign up view controller
    [self.navigationController pushViewController:self.loginViewController animated:YES];
}
@end
