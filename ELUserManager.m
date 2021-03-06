//
//  ELUserManager.m
//  Fuel Logic
//
//  Created by Mike on 9/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#import "ELPaymentHeader.h"

@interface ELUserManager ()
 @property (strong, nonatomic) ELVerifyPasswordView *verifyPasswordAlertView;
 @property (strong, nonatomic) NSDate *passwordSessionStartDate;
 @property (nonatomic,copy)ELVerifyHandler passwordHandler, emailHandler;
 @property (strong, nonatomic) PFUser *currentUser;
 @property (strong, nonatomic) ELCustomer *currentCustomer;
 @property (strong, nonatomic) NSTimer *passwordSessionTimer;
 @property (strong, nonatomic) UIAlertView *verifyEmailAlertView;
@end

@implementation ELUserManager
 @synthesize passwordSessionActive = _passwordSessionActive;
 @synthesize currentUser = _currentUser;
 @synthesize currentCustomer = _currentCustomer;
static ELUserManager *sharedUserManager = nil;

-(instancetype)init{
    self = [super init];
    if (self) {
        
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedIn:) name:elNotificationLoginSucceeded object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedOut:) name:elNotificationLogoutSucceeded object:nil];
        [self setSingleton];
        if ([PFUser currentUser]) [self userLoggedIn:nil];
        else{
            [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
                
                if (!error) {
                    self.currentUser = user;
                    [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationAnonLoginSucceeded object:user];
                }
            }];
        }
    }
    return self;
}
-(void)setSingleton{
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        if (sharedUserManager) {
            return;
        }
        sharedUserManager = self;
    });
}
+(ELUserManager *)sharedUserManager{
    if (!sharedUserManager){
        ELUserManager *userManager = [[ELUserManager alloc]init];
        [userManager description];
    }
    return sharedUserManager;
}
-(void)setCurrentUser:(PFUser *)currentUser{
    [self checkForSessionTimer];
    _currentUser = currentUser;
}

#pragma mark notifications
-(void)userLoggedIn:(NSNotification *)notification{
    self.currentUser = [PFUser currentUser];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"user"] = [PFUser currentUser];
    [currentInstallation saveInBackground];
    if ([PFUser currentUser])
    {
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
        {
            if (error.code == 101 && (!object ||!object.objectId))
            {
                //If there is an error, or the user does not exist anymore, logout and create another anonymous user.
                [self logout];
            }
            else
            {
                
                self.currentUser = [PFUser currentUser];
                if (notification) self.passwordSessionActive = YES;
                [self fetchCustomer];
                [PFInstallation currentInstallation][@"user"] = self.currentUser;
                [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [[PFInstallation currentInstallation]saveEventually];
                    }
                }];
                [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationUserDownloadComplete object:self.currentUser];
            }
        }];
    }
}
-(void)userLoggedOut:(NSNotification *)notification{
    self.currentUser = nil;
    self.currentCustomer = nil;
    self.passwordSessionActive = NO;
}

#pragma mark customer
-(void)fetchCustomer{
    [self fetchCustomerCompletion:nil];
}
-(void)fetchCustomerCompletion:(ELCustomerCompletionBlock)handler{
    //If user exists check if the user has verified their email
    if (self.currentUser[@"stripeID"])
    {
        [ELCustomer retrieveCustomerWithID:self.currentUser[@"stripeID"] completion:^(ELCustomer *customer, NSError *error) {
            if (customer && !error)
            {
                self.currentCustomer = customer;
                if (handler) handler(customer,error);
                [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationCustomerDownloadComplete object:self.currentCustomer];
            }
            else [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationCustomerDownloadComplete object:self.currentCustomer];
        }];
    }
}

#pragma mark password
-(void)verifyPasswordWithComletion:(ELVerifyHandler)handler
{
    self.passwordHandler = handler;
    self.verifyPasswordAlertView = [[ELVerifyPasswordView alloc]init];
    self.verifyPasswordAlertView.delegate = self;
    [self.verifyPasswordAlertView show];
}
-(void)verifyPassword:(NSString *)password completion:(ELVerifyHandler)handler
{
    [self verifyPassword:password WithCompletionHandler:^(BOOL verified, NSError *error) {
        if (verified)
        {
            self.passwordSessionActive = YES;
        }
        else{
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Incorrect Password Entered" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [myAlert show];
        }
        handler(verified,error);
        self.passwordHandler = nil;
    }];
}
-(void)verifyPasswordViewCancelled:(ELVerifyPasswordView *)view{
    if (self.passwordHandler) self.passwordHandler(NO,errorFromELErrorType(elErrorCodeVerificationRequired));
    self.passwordHandler = nil;
}
-(void)verifyPasswordView:(ELVerifyPasswordView *)view password:(NSString *)password{
    
    if (password.length)
    {
        ELViewController *vc = (ELViewController *)[ELUserManager topMostController];
        [vc showActivityView];
        
        [self verifyPassword:password completion:^(BOOL verified, NSError *error)
        {
            [vc hideActivityView];
            if (self.passwordHandler) self.passwordHandler(verified,error);
            else [NSException raise:@"Missing Handler" format:@"Password Handler Missing"];
        }];
    }
    else
    {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter Password" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [myAlert show];
        self.passwordHandler(NO,errorFromELErrorType(elErrorCodeVerificationRequired));
        self.passwordHandler = nil;
    }
}
-(void)verifyPasswordViewForgotPassword:(ELVerifyPasswordView *)view{
    ELViewController *vc = (ELViewController *)[ELUserManager topMostController];
    [vc showActivityView];
    
    [PFUser requestPasswordResetForEmailInBackground:self.currentUser.email block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Password verification sent to your E-mail address." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [myAlert show];
            [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
        }
        else{
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Sending lost password request. Try again later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            if (error.code == 205) myAlert.message = @"E-Mail Address Not Found.";
            [myAlert show];
        }
        self.passwordHandler(NO,errorFromELErrorType(elErrorCodeVerificationRequired));
        self.passwordHandler = nil;
        [vc hideActivityView];
    }];
    
    
}
-(void)verifyPassword:(NSString *)password WithCompletionHandler:(ELVerifyHandler)handler{
    [PFCloud callFunctionInBackground:@"verifyPassword" withParameters:@{@"password":password} block:^(id object, NSError *error) {
        if (handler) handler(error ? NO:YES,error);
    }];
}

-(void)logout{
    [PFUser logOut];
    self.currentUser = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:elNotificationLogoutSucceeded object:nil];
    self.currentUser = [PFUser currentUser];
    if (self.currentUser){
        [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationAnonLoginSucceeded object:self.currentUser];
        NSLog(@"currentUser:%@",self.currentUser);
    }
    
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        
        if (!error) {
            self.currentUser = user;
            [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationAnonLoginSucceeded object:user];
        }
    }];
    
}

#pragma mark session
-(void)endSession{
    self.passwordSessionActive = NO;
}
-(BOOL)passwordSessionActive{
    return _passwordSessionActive;
}
-(void)checkForSessionActiveThen:(ELVerifyHandler)completion{
    [self checkForSessionTimer];
    //added to allow handler to persist through email backcompletion
    __block ELVerifyHandler handler = completion;
    if (self.passwordSessionActive) completion(self.passwordSessionActive,nil);
    else [self verifyEmailWithCompletion:^(BOOL verified, NSError *error) {
        if (!verified) {
            completion(NO,error);
        }
        else [self verifyPasswordWithComletion:handler];
    }];
}
-(void)checkForSessionTimer{
    if (self.passwordSessionStartDate && self.passwordSessionStartDate.timeIntervalSinceNow > 60*15) self.passwordSessionActive = NO;
}
-(void)setPasswordSessionActive:(BOOL)passwordSessionActive{
    _passwordSessionActive = passwordSessionActive;
    self.passwordSessionStartDate = nil;
    if (self.passwordSessionTimer) {
        [self.passwordSessionTimer invalidate];
        self.passwordSessionTimer = nil;
    }
    if (_passwordSessionActive)
    {
        self.passwordSessionTimer = [NSTimer scheduledTimerWithTimeInterval:60*15 target:self selector:@selector(endSession) userInfo:nil repeats:NO];
        self.passwordSessionStartDate = [NSDate date];
    }
}

#pragma mark Email
-(void)verifyEmailWithCompletion:(ELVerifyHandler)handler{
    if ([self.currentUser[@"emailVerified"] boolValue]){
        handler(YES,nil);
        return;
    }
    [self.currentUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if (!error)
        {
            if ([object[@"emailVerified"] boolValue ]) {
                handler(YES,nil);
            }
            else{
                self.emailHandler = handler;
                self.verifyEmailAlertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"You haven't verified your email address associated with your account." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Resend",nil];
                [self.verifyEmailAlertView show];
            }
        }
        else{
            handler(NO,errorFromELErrorType(elErrorCodeVerificationRequired));
        }
    }];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex && alertView == self.verifyEmailAlertView)
    {
        [PFUser requestPasswordResetForEmail:self.currentUser.email];
        self.emailHandler(NO,nil);
    }
}

#pragma mark utility
+ (UIViewController*) topMostController{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}
-(void)autoCloseAlertView:(UIAlertView*)alert{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}


@end
