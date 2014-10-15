//
//  ELVerifyPasswordView.h
//  Fuel Logic
//
//  Created by Mike on 10/13/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELView.h"

@class ELVerifyPasswordView;
@protocol ELVerifyPasswordViewDelegate <NSObject>
-(void)verifyPasswordView:(ELVerifyPasswordView *)view password:(NSString *)password;
-(void)verifyPasswordViewCancelled:(ELVerifyPasswordView *)view;
-(void)verifyPasswordViewForgotPassword:(ELVerifyPasswordView *)view;
@end

@interface ELVerifyPasswordView : ELView <UITextFieldDelegate>
 @property (assign, nonatomic) id <ELVerifyPasswordViewDelegate> delegate;
-(void)show;
@end
