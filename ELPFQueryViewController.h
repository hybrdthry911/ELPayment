//
//  ELPFQueryViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/27/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Parse/Parse.h>

@interface ELPFQueryViewController : PFQueryTableViewController

@property (strong, nonatomic) UIView *hudProgressView, *hudProgressHolderView;
@property (strong, nonatomic) UILabel *activityLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UITextField *currentTextField, *currentKeyboardTextField;
@property CGSize lastKeyboardSize;
@property (strong, nonatomic) UIScrollView *scrollViewToKeyBoardAdjust;
-(void)textFieldDidBeginEditing:(UITextField *)textField;
-(void)textFieldDidEndEditing:(UITextField *)textField;
-(void)textFieldDidChange:(ELTextField *)textField;
//hides keyboard and clears currenttextfield
-(IBAction)handleViewTap:(id)sender;
-(NSMutableAttributedString *)textFieldPlaceHolderWithString:(NSString *)string;
-(ELTextField *)addNewTextField;
-(ELTextField *)addNewTextFieldWithPlaceHolder:(NSString *)placeHolder;
-(BOOL)validateEmail:(NSString *)candidate;
-(void)autoCloseAlertView:(UIAlertView*)alert;
-(void)showActivityView;
-(void)hideActivityView;
-(void)placeView:(UIView *)view withOffset:(ELViewXOffset)xOffset width:(ELViewWidth)width offset:(float)offset;
+ (UIViewController*) topMostController;
- (void)retrieveCityStateFromZipcode:(NSString *)zipCode completion:(ELCityStateCompletionHandler)handler;
+ (void)retrieveCityStateFromZipcode:(NSString *)zipCode completion:(ELCityStateCompletionHandler)handler;
-(NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar;
-(NSString *)simple:(NSString *)string;
-(void)showActivityViewWithMessage:(NSString *)message;
@end
