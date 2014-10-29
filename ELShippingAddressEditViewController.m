//
//  ELShippingAddressEditViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/27/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELShippingAddressEditViewController.h"
#import "ELPaymentHeader.h"
@interface ELShippingAddressEditViewController ()
 @property (strong, nonatomic) UIBarButtonItem *saveButton;
@end

@implementation ELShippingAddressEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self checkForNext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)checkForNext
{
    if (    self.nameTextField.text.length
        && self.addressCityTextField.text.length
        && self.addressLine1TextField.text.length
        && self.addressZipCodeTextField.text.length == 5
        && self.stateString
        )
    {
        self.saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    else if (self.saveButton)
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.shippingMethodButton = nil;
    }
}
-(IBAction)saveButtonPressed:(id)sender
{
    [self showActivityView];
    BOOL newAddress = NO;
    if (!self.shippingAddress) {
        self.shippingAddress = [ELShippingAddress object];
        newAddress = YES;
    }
    self.shippingAddress.name = self.nameTextField.text;
    self.shippingAddress.line1 = self.addressLine1TextField.text;
    self.shippingAddress.line2 = self.addressLine2TextField.text;
    self.shippingAddress.city = self.addressCityTextField.text;
    self.shippingAddress.state = self.stateString;
    self.shippingAddress.zipCode = self.addressZipCodeTextField.text;
    self.shippingAddress.country = @"US";

    [self.shippingAddress saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [self hideActivityView];
        if (!error) {
            if (newAddress) {
                PFRelation *relation = [[ELUserManager sharedUserManager]currentUser][@"shippingAddresses"];
                [relation addObject:self.shippingAddress];
                [[[ELUserManager sharedUserManager]currentUser] saveEventually];
            }
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [myAlert show];
            [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not save address. Try again later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [myAlert show];
        }
    }];
}

@end
