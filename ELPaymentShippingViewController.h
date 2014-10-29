//
//  ELPaymentShippingViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/26/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELViewController.h"
#import "ELPickerView.h"
@class ELOrder;
@class ELShippingAddress;
@class STPToken;
@class STPCard;
@class ELCard;
@interface ELPaymentShippingViewController : ELViewController <UITextFieldDelegate, ELPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
 @property (strong, nonatomic) ELOrder *order;
 @property (strong, nonatomic) STPToken *token;
 @property (strong, nonatomic) STPCard *card;
 @property (strong, nonatomic) ELShippingAddress *shippingAddress;
 @property (strong, nonatomic) NSString *stateString;
 @property (strong, nonatomic) ELTextField *nameTextField, *addressLine1TextField, *addressLine2TextField, *addressZipCodeTextField, *addressCityTextField;
 @property (strong, nonatomic) UIButton *stateButton;
 @property (strong, nonatomic) UIScrollView *scrollView;
 @property (strong, nonatomic) ELPickerView *statePickerView;
 @property (strong, nonatomic) NSArray *stateArray, *fullStateArray;
 @property (strong, nonatomic) UIBarButtonItem *shippingMethodButton;
- (void)checkForNext;
@end

