//
//  ELPaymentHeader.h
//  OrderManager
//
//  Created by Mike on 10/15/14.
//  Copyright (c) 2014 E-Nough Logic. All rights reserved.
//
#ifndef OrderManager_ELPaymentHeader_h
#define OrderManager_ELPaymentHeader_h
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "ELStripeHeader.h"
#import "ELPaymentBillingViewController.h"
#import "Stripe+ApplePay.h"
#import "ELShippingAddress.h"
#import "ELShippingMethodViewController.h"
#import "ELShippingSelectViewController.h"
#import "ELPaymentShippingViewController.h"
#import "STPTestPaymentAuthorizationViewController.h"
#import "ELView.h"
#import "ELViewController.h"
#import "ELShipment.h"
#import "ELStripeHeader.h"
#import "ELAmountTableViewCell.h"
#import "ELCategory.h"
#import "ELPaymentSummaryViewController.h"
#import "ELChangePasswordViewController.h"
#import "ELCompleteSummaryView.h"
#import "ELCustomerAccountSettingsViewController.h"
#import "ELCustomerAccountViewController.h"
#import "ELCustomerOrderTableViewController.h"
#import "ELExistingLineItemTableViewCell.h"
#import "ELExistingOrder.h"
#import "ELExistingOrderViewController.h"
#import "ELImageViewController.h"
#import "ELLineItem.h"
#import "ELLineItemTableViewCell.h"
#import "ELLoginViewController.h"
#import "ELOrder.h"
#import "ELOrderSummarView.h"
#import "ELOrderViewController.h"
#import "ELPaymentMethodEditViewController.h"
#import "ELPaymentMethodsViewController.h"
#import "ELPaymentViewController.h"
#import "ELPickerView.h"
#import "ELProductAlertView.h"
#import "ELProductListViewController.h"
#import "ELProductTableViewCell.h"
#import "ELProductViewController.h"
#import "ELPTKView.h"
#import "ELPumpTableViewCell.h"
#import "ELTableViewController.h"
#import "ELTrackingViewController.h"
#import "ELUserManager.h"
#import "ELVerifyPasswordView.h"
#import "ELPaymentSelectViewController.h"
#import "UIButton+Addons.h"
#import "UILabel+addOns.h"
#import "UINavigationController+addOns.h"
#import "UITableViewCell+addOns.h"
#import "UIView+UIView_Utilities.h"
#import "PTKTextField.h"

#define MY_FONT_1 @"HelveticaNeue-Thin"
#define MY_FONT_2 @"Helvetica-Oblique"
#define MY_FONT_3 @"HelveticaNeue-Bold"


#define ICON_BLUE [UIColor colorWithRed:(7.0/255.0) green:(166.0/255.0) blue:(235.0/255.0) alpha:.5]
#define ICON_BLUE_SOLID [UIColor colorWithRed:(7.0/255.0) green:(166.0/255.0) blue:(235.0/255.0) alpha:1]
#define CLEAR_COLOR [UIColor clearColor]
#define MENU_BACKGROUND_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:1]
#define CYAN_COLOR [UIColor colorWithRed:(0.0/255.0) green:(120.0/255.0) blue:(171.0/255.0) alpha:.5]


#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#endif
