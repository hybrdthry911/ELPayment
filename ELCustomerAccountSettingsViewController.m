//
//  ELCustomerAccountSettingsViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/3/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#define TOP_SPACING 10
#define LEFT_OFFSET 10
#define ROW_HEIGHT 40
#define ROW_SPACING 5
#define ROW_OFFSET TOP_SPACING + (ROW_HEIGHT + ROW_SPACING)


#import "ELPaymentHeader.h"
@interface ELCustomerAccountSettingsViewController()

 @property (strong, nonatomic) ELTextField *emailTextField, *phoneNumberTextField;
 @property (strong, nonatomic) UIButton *changePasswordButton;
 @property (strong, nonatomic) UIScrollView *scrollView;
 @property (strong, nonatomic) UIBarButtonItem *saveButton;
 @property BOOL userSaved, customerSaved;
@end

@implementation ELCustomerAccountSettingsViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc]init];
//    self.scrollView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.9];
    [self.view addSubview:self.scrollView];
    
    self.emailTextField = [self addNewTextField];
    self.emailTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"E-Mail Address"];
    self.emailTextField.text = [[[ELUserManager sharedUserManager]currentCustomer]email];
    self.emailTextField.required = YES;
    self.emailTextField.layer.borderColor = [ICON_BLUE_SOLID CGColor];
    [self.scrollView addSubview:self.emailTextField];
    
    self.phoneNumberTextField = [self addNewTextField];
    self.phoneNumberTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Phone Number"];
    self.phoneNumberTextField.required = YES;
    self.phoneNumberTextField.text = [[[ELUserManager sharedUserManager]currentCustomer]descriptor];
    self.phoneNumberTextField.layer.borderColor = [ICON_BLUE_SOLID CGColor];
    self.phoneNumberTextField.delegate = self;
    [self.scrollView addSubview:self.phoneNumberTextField];
    [self textField:self.phoneNumberTextField shouldChangeCharactersInRange:NSRangeFromString(self.phoneNumberTextField.text) replacementString:self.phoneNumberTextField.text];
    
    
    self.changePasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.changePasswordButton makeMine];
    [self.changePasswordButton setTitle:@"Change Password"];
    [self.changePasswordButton addTarget:self action:@selector(changePasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.changePasswordButton];
    
    self.saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
}
-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, ROW_OFFSET*4);
    [self placeView:self.emailTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:0];
    [self placeView:self.phoneNumberTextField withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:1];
    [self placeView:self.changePasswordButton withOffset:ELViewXOffsetNone width:ELViewWidthFull offset:2];
}
-(void)textFieldDidChange:(ELTextField *)textField
{
    if (textField.text.length) textField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    else textField.layer.borderColor =   textField.required ?  [[UIColor redColor] colorWithAlphaComponent:1].CGColor:[[UIColor grayColor] colorWithAlphaComponent:.65].CGColor;

    if(textField == self.emailTextField)
    {
        if (![self validateEmail:[self.emailTextField.text lowercaseString]]) textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
    }
    else if(textField == self.phoneNumberTextField)
    {
        
        NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:[self simple:self.phoneNumberTextField.text]];
        if (!([self simple:self.phoneNumberTextField.text].length >= 10 && [numericOnly isSupersetOfSet: myStringSet])) textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
    }
    if (self.validForSave) [self showSaveButton];
    else [self hideSaveButton];
}
-(BOOL)validForSave
{
    NSLog(@"simple:%@",[self simple:self.phoneNumberTextField.text]);
    NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:[self simple:self.phoneNumberTextField.text]];
    return ([self validateEmail:[self.emailTextField.text lowercaseString]] && [self simple:self.phoneNumberTextField.text].length >= 10 && [numericOnly isSupersetOfSet: myStringSet]);
    
}
-(void)hideSaveButton
{
    self.navigationItem.rightBarButtonItem = nil;
}
-(void)showSaveButton
{
    self.navigationItem.rightBarButtonItem = self.saveButton;
}
-(IBAction)changePasswordButtonPressed:(id)sender
{
    ELChangePasswordViewController *vc = [[ELChangePasswordViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(IBAction)saveButtonPressed:(id)sender
{
    if (![self validForSave]) return;
    
    [[ELUserManager sharedUserManager]verifyPasswordWithComletion:^(BOOL verified, NSError *error) {
        if (verified) {
            [self showActivityView];

            PFUser *user = [[ELUserManager sharedUserManager] currentUser];
            if ([[user.email lowercaseString] isEqualToString:[self.emailTextField.text lowercaseString]]) {
                self.userSaved = YES;
                [self attemptToHideActivity];
            }
            else{
                user.email = [self.emailTextField.text lowercaseString];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    self.userSaved = YES;
                    [self attemptToHideActivity];
                }];
                
            }
            
            ELCustomer *customer = [[ELUserManager sharedUserManager]currentCustomer];
            if ([[user.email lowercaseString] isEqualToString:[self.emailTextField.text lowercaseString]]) {
                customer.email = [self.emailTextField.text lowercaseString];
            }
            customer.descriptor = self.phoneNumberTextField.text;
            [ELCustomer updateStripeCustomer:customer completionHandler:^(ELCustomer *customer, NSError *error)
            {
                if (error) {
                    NSLog(@"error:%@",error);
                }
                self.customerSaved = YES;
                [self attemptToHideActivity];
                [[ELUserManager sharedUserManager]fetchCustomer];
            }];
        }
    }];
    
}
-(void)attemptToHideActivity
{
    if (self.userSaved && self.customerSaved) {
        self.userSaved = NO;
        self.customerSaved = NO;
        [self hideActivityView];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.phoneNumberTextField)
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
            
            if (self.validForSave) [self showSaveButton];
            else [self hideSaveButton];
            return false;
    }
    return YES;
}
-(BOOL)validateEmail:(NSString *)candidate
{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
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
-(NSString *)simple:(NSString *)string
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
    return string;
    
}
@end
