//
//  ELView.h
//  Fuel Logic
//
//  Created by Mike on 10/13/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class ELTextField;


@interface ELView : UIView
-(NSMutableAttributedString *)textFieldPlaceHolderWithString:(NSString *)string;
-(UIInterfaceOrientation)orientation;
+ (ViewController *)topMostController;
-(ELTextField *)addNewTextField;
-(IBAction)textFieldDidChange:(ELTextField *)sender;
@end
