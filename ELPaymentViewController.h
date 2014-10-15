//
//  ELPaymentViewController.h
//  Fuel Logic
//
//  Created by Mike on 6/16/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#import "ELViewController.h"
#import <UIKit/UIKit.h>
#import "PTKView.h"
#import "PTKTextField.h"
#import "ELPTKView.h"
#import "ELPickerView.h"
#import <Parse/Parse.h>
@class ELCustomer;
@class ELOrder;
@class ELCustomer;
@class STPCard;
@class STPToken;
@interface ELPaymentViewController : ELViewController <PTKViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIScrollViewDelegate, ELPTKViewDelegate, UIAlertViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIAlertViewDelegate, ELPickerViewDelegate, UIPickerViewDataSource>
 @property (strong, nonatomic) ELCustomer *customer;
 @property (strong, nonatomic) STPToken *token;
 @property (strong, nonatomic) ELOrder  *order;

@end


