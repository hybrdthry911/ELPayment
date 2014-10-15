//
//  ELPaymentMethodEditViewController.h
//  Fuel Logic
//
//  Created by Mike on 10/2/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELViewController.h"
#import "ELPTKView.h"
@interface ELPaymentMethodEditViewController : ELViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, PTKTextFieldDelegate, PTKViewDelegate, ELPTKViewDelegate, UIAlertViewDelegate>

 @property (strong, nonatomic) ELCard *card;
@end
