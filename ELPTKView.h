//
//  ELPTKView.h
//  Fuel Logic
//
//  Created by Mike on 9/29/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "PTKView.h"
#import "PTKTextField.h"

@protocol ELPTKViewDelegate <NSObject>
@optional
-(BOOL)pkTextFieldShouldBeginEditing:(PTKTextField *)textField;

@end

@interface ELPTKView : PTKView
 @property (weak, nonatomic)  id <ELPTKViewDelegate> elDelegate;
@end

