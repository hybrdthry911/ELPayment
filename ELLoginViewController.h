//
//  ELLoginViewController.h
//  Fuel Logic
//
//  Created by Mike on 7/9/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELViewController.h"
@interface ELLoginViewController : ELViewController <UITextFieldDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
 @property BOOL createOnly;
@end
