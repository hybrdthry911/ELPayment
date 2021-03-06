//
//  ELUserManager.h
//  Fuel Logic
//
//  Created by Mike on 9/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELVerifyPasswordView.h"
#import <Parse/Parse.h>
#import "ELCustomer.h"
@class ELCustomer;
typedef void (^ELVerifyHandler)(BOOL verified, NSError* error);

@interface ELUserManager : NSObject <ELVerifyPasswordViewDelegate, UIAlertViewDelegate>
 @property BOOL passwordSessionActive;

+(ELUserManager *)sharedUserManager;
-(void)verifyPasswordWithComletion:(ELVerifyHandler)handler;
//-(void)checkForSessionTimer;
-(PFUser *)currentUser;
-(ELCustomer *)currentCustomer;
-(void)fetchCustomer;
-(void)fetchCustomerCompletion:(ELCustomerCompletionBlock)handler;
-(void)verifyPassword:(NSString *)password completion:(ELVerifyHandler)handler;
-(void)logout;
-(void)checkForSessionActiveThen:(ELVerifyHandler)completion;
@end
