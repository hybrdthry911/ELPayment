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
@class ELOrder;
@class ELCustomer;
@class STPCard;
@interface ELPaymentViewController : ELViewController <PTKViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIScrollViewDelegate, ELPTKViewDelegate, UIAlertViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIAlertViewDelegate, ELPickerViewDelegate, UIPickerViewDataSource>
 @property (strong, nonatomic) ELCustomer *customer;
 @property (strong, nonatomic) STPToken *token;
 @property (strong, nonatomic) ELOrder  *order;

@end


