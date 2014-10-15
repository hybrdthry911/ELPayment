//
//  ELPTKView.m
//  Fuel Logic
//
//  Created by Mike on 9/29/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPTKView.h"

@implementation ELPTKView
- (BOOL)textFieldShouldBeginEditing:(PTKTextField *)textField{
    if ([self.elDelegate respondsToSelector:@selector(pkTextFieldShouldBeginEditing:)])
    {
        return [self.elDelegate pkTextFieldShouldBeginEditing:textField];
    }
    return YES;
}
@end
