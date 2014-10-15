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
@class ELCustomer;
typedef void (^ELVerifyPasswordHandler)(BOOL verified, NSError* error);

@interface ELUserManager : NSObject <ELVerifyPasswordViewDelegate>
 @property BOOL passwordSessionActive;

+(ELUserManager *)sharedUserManager;
-(void)verifyPasswordWithComletion:(ELVerifyPasswordHandler)handler;
-(void)checkForSessionTimer;
-(PFUser *)currentUser;
-(ELCustomer *)currentCustomer;
-(void)fetchCustomer;
-(void)verifyPassword:(NSString *)password completion:(ELVerifyPasswordHandler)handler;
-(void)logout;
@end
