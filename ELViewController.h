//
//  ELViewController.h
//  Fuel Logic
//
//  Created by Mike on 7/9/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    ELViewXOffsetNone, ELViewXOffsetOneHalf, ELViewXOffsetOneQuarter, ELViewXOffsetOneThird, ELViewXOffsetTwoThird, ELViewXOffsetThreeQuarter, ELViewXOffsetOffScreenLeft, ELViewXOffsetOffScreenRight, ELViewXOffsetOneSixth, ELViewXOffsetFiveSixth
}ELViewXOffset;

typedef enum
{
    ELViewWidthFull, ELViewWidthHalf, ELViewWidthQuarter, ELViewWidthThird
}ELViewWidth;

typedef void (^ELCityStateCompletionHandler)(NSString *city, NSString *state, NSError *error);

@class ELTextField;
@interface ELViewController : UIViewController
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

@interface ELTextField : UITextField

@property BOOL required;
@property int requiredLength;
@property BOOL isEmailField;
@property BOOL centerPlaceholder;
@end

