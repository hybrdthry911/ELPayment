//
//  ELVerifyPasswordView.m
//  Fuel Logic
//
//  Created by Mike on 10/13/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentHeader.h"

@interface ELVerifyPasswordView()
 @property (strong, nonatomic) ELView *alertHolderView;
 @property (strong, nonatomic) ELTextField *textField;
 @property (strong, nonatomic) UIButton *okButton, *forgotButton, *cancelButton;
 @property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation ELVerifyPasswordView
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.75];
        self.alertHolderView = [[ELView alloc]init];
        self.alertHolderView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.85];
        self.alertHolderView.layer.borderColor = ICON_BLUE_SOLID.CGColor;
        self.alertHolderView.layer.cornerRadius = 5;
        self.alertHolderView.layer.borderWidth = 1;
        [self addSubview:self.alertHolderView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(handleTap:)];
        tap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:tap];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleLabel makeMine2];
        self.titleLabel.text = @"Password verification Required";
        self.titleLabel.numberOfLines = 2;
        [self.alertHolderView addSubview:self.titleLabel];
        
        self.textField = [self addNewTextField];
        self.textField.delegate = self;
        self.textField.centerPlaceholder = YES;
        self.textField.layer.borderColor = [[UIColor grayColor]CGColor];
        self.textField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Password"];
        self.textField.secureTextEntry = YES;
        [self.alertHolderView addSubview:self.textField];
        
        self.okButton = [[UIButton alloc]init];
        [self.okButton makeMine];
        [self.okButton setTitle:@"OK"];
        [self.okButton addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.alertHolderView addSubview:self.okButton];
        
        self.forgotButton = [[UIButton alloc]init];
        [self.forgotButton makeMine2];
        [self.forgotButton setTitle:@"Forgot Password?"];
        [self.forgotButton addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.alertHolderView addSubview:self.forgotButton];
        
        self.cancelButton = [[UIButton alloc]init];
        [self.cancelButton makeMine];
        [self.cancelButton setTitle:@"Cancel"];
        [self.cancelButton addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.alertHolderView addSubview:self.cancelButton];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.frame = [[[ELView topMostController] view] bounds];
    if (UIDeviceOrientationIsLandscape(self.orientation)) {
        
        self.alertHolderView.bounds = CGRectMake(0, 0, 400, 130);
        self.alertHolderView.center = CGPointMake(self.bounds.size.width/2, self.alertHolderView.bounds.size.height/2+10);
        
        self.titleLabel.frame =     CGRectMake(5, 5, self.alertHolderView.bounds.size.width-10, 30);
        self.textField.frame =      CGRectMake(self.alertHolderView.bounds.size.width/2-100, 40, 200, 40);
        self.okButton.frame =       CGRectMake(5, 85, 60, 40);
        self.cancelButton.frame =   CGRectMake(self.alertHolderView.bounds.size.width-5-70, 85, 70, 40);
        self.forgotButton.frame =   CGRectMake(70, 85, self.alertHolderView.bounds.size.width-20-self.cancelButton.bounds.size.width-self.okButton.bounds.size.width, 40);
    }
    else{
        self.alertHolderView.bounds = CGRectMake(0, 0, 200, 250);
        self.alertHolderView.center = CGPointMake(self.bounds.size.width/2, self.alertHolderView.bounds.size.height/2+10);
        
        self.titleLabel.frame = CGRectMake(5, 5, self.alertHolderView.bounds.size.width-10, 60);
        self.textField.frame = CGRectMake(5, 70, self.alertHolderView.bounds.size.width-10, 40);
        self.okButton.frame = CGRectMake(5, 115, self.alertHolderView.bounds.size.width-10, 40);
        self.forgotButton.frame = CGRectMake(5, 160, self.alertHolderView.bounds.size.width-10, 40);
        self.cancelButton.frame = CGRectMake(5, 205, self.alertHolderView.bounds.size.width-10, 40);
    }
}
-(void)show
{
    UIViewController *mainViewController = [ELPickerView topMostController];
    
    self.frame = CGRectMake(0, mainViewController.view.bounds.size.height, mainViewController.view.bounds.size.width,mainViewController.view.bounds.size.height);
    [UIView animateWithDuration:.25 animations:
     ^{
         self.frame = mainViewController.view.bounds;
         [self.textField becomeFirstResponder];
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    [mainViewController.view addSubview:self];
}

-(IBAction)handleTap:(id)sender
{
    [self.textField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self handleButtonPress:self.okButton];
    return YES;
}
-(IBAction)textFieldDidChange:(ELTextField *)sender
{
    if (sender.text.length) {
        sender.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    }
    else{
        sender.layer.borderColor = [[UIColor grayColor]CGColor];
    }
}
-(IBAction)handleButtonPress:(id)sender{
    if (sender == self.cancelButton) {
        if ([self.delegate respondsToSelector:@selector(verifyPasswordViewCancelled:)])
        {
            [self.delegate verifyPasswordViewCancelled:self];
        }
    }
    else if (sender == self.okButton) {
        if ([self.delegate respondsToSelector:@selector(verifyPasswordView:password:)])
        {
            [self.delegate verifyPasswordView:self password:self.textField.text];
        }
    }
    else if (sender == self.forgotButton) {
        if ([self.delegate respondsToSelector:@selector(verifyPasswordViewForgotPassword:)])
        {
            [self.delegate verifyPasswordViewForgotPassword:self];
        }
    }
    [self removeFromSuperview];
}
@end
