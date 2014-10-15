//
//  ELTableViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/2/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELViewController.h"
#import <UIKit/UIKit.h>


@interface ELTableViewController : UITableViewController
@property (strong, nonatomic) UIView *hudProgressView;
@property (strong, nonatomic) UILabel *activityLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UITextField *currentTextField, *currentKeyboardTextField;
@property CGSize lastKeyboardSize;
-(void)autoCloseAlertView:(UIAlertView*)alert;
-(void)showActivityView;
-(void)hideActivityView;

+ (UIViewController*) topMostController;
@end
