//
//  ELChangePasswordViewController.m
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
@interface ELChangePasswordViewController()
 @property (strong, nonatomic) ELTextField *oldPasswordTextField, *password1TextField, *password2TextField;
 @property (strong, nonatomic) UIBarButtonItem *saveButton;
 @property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation ELChangePasswordViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Change Password";
    
    self.scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:self.scrollView];
    
    self.oldPasswordTextField = [self addNewTextField];
    self.oldPasswordTextField.secureTextEntry = YES;
    self.oldPasswordTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Old Password"];
    [self.scrollView addSubview:self.oldPasswordTextField];
    
    self.password1TextField = [self addNewTextField];
    self.password1TextField.secureTextEntry = YES;
    self.password1TextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"New Password"];
    [self.scrollView addSubview:self.password1TextField];
    
    self.password2TextField = [self addNewTextField];
    self.password2TextField.secureTextEntry = YES;
    self.password2TextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Verify Password"];
    [self.scrollView addSubview:self.password2TextField];
    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, ROW_OFFSET*4);
    [self placeView:self.oldPasswordTextField withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:0];
    [self placeView:self.password1TextField withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:1];
    [self placeView:self.password2TextField withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:2];
}

- (void)textFieldDidChange:(ELTextField *)textField{
    if (self.oldPasswordTextField.text.length
        && self.password1TextField.text.length
        && self.password2TextField.text.length
        && [self.password1TextField.text isEqualToString:self.password2TextField.text])
    {
        if (!self.saveButton) {
            self.saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
            self.navigationItem.rightBarButtonItem = self.saveButton;
        }
    }
    else if(self.saveButton)
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.saveButton = nil;
    }
    
    if (textField.text.length) textField.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    else textField.layer.borderColor =   [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
}
-(void)saveButtonPressed:(UIBarButtonItem *)saveButton
{
    [self showActivityView];
    [[ELUserManager sharedUserManager] verifyPassword:self.oldPasswordTextField.text completion:^(BOOL verified, NSError *error)
    {
        if (verified)
        {
            [[[ELUserManager sharedUserManager]currentUser]setPassword:self.password1TextField.text];
            [[[ELUserManager sharedUserManager ]currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Password Updated" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [self hideActivityView];
                if (!succeeded) {
                    myAlert.title = @"Error";
                    myAlert.message = @"Password Not Updated";
                }
                [myAlert show];
                [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else [self hideActivityView];
    }];
}
@end
