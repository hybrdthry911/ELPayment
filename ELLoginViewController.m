//
//  ELLoginViewController.m
//  Fuel Logic
//
//  Created by Mike on 7/9/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#define TOP_SPACING 60
#define LEFT_OFFSET 10
#define ROW_HEIGHT 40
#define ROW_SPACING 5
#define RIGHT_HALF_OFFSET (self.scrollView.bounds.size.width/2 + LEFT_OFFSET/2)
#define ROW_OFFSET TOP_SPACING+(ROW_HEIGHT+ROW_SPACING)
#define FULL_WIDTH (self.scrollView.bounds.size.width-LEFT_OFFSET*2)
#define HALF_WIDTH ((self.scrollView.bounds.size.width-LEFT_OFFSET*3)/2)
#define THIRD_WIDTH ((self.scrollView.bounds.size.width - LEFT_OFFSET*4)/3)
#define QUARTER_WIDTH ((self.scrollView.bounds.size.width - LEFT_OFFSET*5)/4)


#import "ELPaymentHeader.h"
@interface ELLoginViewController ()
 @property (strong, nonatomic) UILabel *titleLabel;
 @property (strong, nonatomic) PFUser *currentUser;
 @property (strong, nonatomic) ELTextField *usernameTextField, *passwordTextfield, *emailTextField;
@property BOOL signUpMode;
 @property (strong, nonatomic) UIButton *loginButton, *signUpButton, *lostButton;
 @property (strong, nonatomic) UIScrollView *scrollView;
 @property (strong, nonatomic) UITextField *currentTextField, *currentKeyboardTextField;
 @property CGSize lastKeyboardSize;
 @property (strong, nonatomic) NSString *lostPasswordEmail;
 @property (strong, nonatomic) UIAlertView *lostPasswordAlertView;
@end

@implementation ELLoginViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [[ELUserManager sharedUserManager]currentUser];
    self.signUpMode = NO;
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.delegate = self;
    self.scrollViewToKeyBoardAdjust = self.scrollView;
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewTap:)]];
    
    [self.view addSubview:self.scrollView];
    self.title = @"Account Setup";
    self.titleLabel = [[UILabel alloc]init];
    [self.titleLabel makeMine];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setLabelText];
    self.titleLabel.font = [UIFont fontWithName:MY_FONT_1 size:17];
    [self.scrollView addSubview:self.titleLabel];
    
    self.usernameTextField = [self addNewTextField];
    self.usernameTextField.requiredLength = 5;
    self.usernameTextField.delegate = self;
    self.usernameTextField.centerPlaceholder = YES;
    
    self.usernameTextField.layer.borderColor = [[UIColor redColor]CGColor];
    self.usernameTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Username"];

    [self.scrollView addSubview:self.usernameTextField];

    self.emailTextField = [self addNewTextField];
    self.emailTextField.isEmailField = YES;
    self.emailTextField.centerPlaceholder = YES;
    self.emailTextField.required = YES;
    self.emailTextField.delegate = self;
    self.emailTextField.layer.borderColor = [[UIColor redColor]CGColor];
    self.emailTextField.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"E-Mail"];
    [self.scrollView addSubview:self.emailTextField];

    
    self.passwordTextfield = [self addNewTextField];
    self.passwordTextfield.centerPlaceholder = YES;
    self.passwordTextfield.requiredLength = 8;
    self.passwordTextfield.secureTextEntry = YES;
    self.passwordTextfield.delegate = self;
    self.passwordTextfield.layer.borderColor = [[UIColor redColor]CGColor];
    self.passwordTextfield.attributedPlaceholder = [self textFieldPlaceHolderWithString:@"Password"];
    [self.scrollView addSubview:self.passwordTextfield];
    
    
    self.loginButton  = [[UIButton alloc]init];
    [self.loginButton makeMine2];
    [self.loginButton setTitle:@"Login"];
    [self.loginButton addTarget:self action:@selector(handleLoginButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.loginButton];
    
    self.lostButton  = [[UIButton alloc]init];
    [self.lostButton makeMine2];
    [self.lostButton setTitle:@"Lost Password"];
    [self.lostButton addTarget:self action:@selector(handleLostButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.lostButton];
    
    self.signUpButton  = [[UIButton alloc]init];
    [self.signUpButton setTitle:@"New User"];
    [self.signUpButton makeMine];
    [self.signUpButton addTarget:self action:@selector(handleSignUpButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.signUpButton];
    // Do any additional setup after loading the view.
}
-(IBAction)handleLostButtonPress:(id)sender
{
    self.lostPasswordAlertView = [[UIAlertView alloc]initWithTitle:@"Lost Password Request" message:@"Enter E-Mail Address:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    self.lostPasswordAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.lostPasswordAlertView show];
}
-(void)loginUser
{
    if (self.usernameTextField.text.length>=self.usernameTextField.requiredLength)
    {
        if (self.passwordTextfield.text.length>=self.passwordTextfield.requiredLength)
        {
            @try {
                [self showActivityView];
                
                [PFUser logInWithUsernameInBackground:[self.usernameTextField.text lowercaseString] password:self.passwordTextfield.text block:^(PFUser *user, NSError *error)
                 {
                     if (error) {
                         [self.currentUser fetch];
                         UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                         switch (error.code) {
                             case 200:
                                 myAlert.message = @"No Username";
                                 break;
                             case 201:
                                 myAlert.message = @"No Password";
                                 break;
                             case 202:
                                 myAlert.message = @"Username Already In Use";
                                 break;
                             case 203:
                                 myAlert.message = @"E-Mail Already In Use";
                                 break;
                             case 101:
                                 myAlert.message = @"Invalid Login Credentials";
                                 break;
                                 
                             default:
                                 break;
                         }
                         [myAlert show];
                     }
                     else{
                         self.currentUser = user;
                         UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                         [myAlert show];
                         [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:.5];
                         [self.navigationController popViewControllerAnimated:YES];
                         [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationLoginSucceeded object:user];
                     }
                     [self hideActivityView];
                 }];
            }
            @catch (NSException *exception)
            {
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", exception] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                NSLog(@"Caught Exception:%@",exception);
                [myAlert show];
            }
            @finally {
                
            }
            
        }
        else{
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Password Too Short" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [myAlert show];
        }
    }
    else{
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Username Too Short" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [myAlert show];
    }
 
}

-(IBAction)handleLoginButtonPress:(id)sender
{
    if (self.signUpMode){
        self.signUpMode = NO;
        [self positionSubViews];
    }
    else [self loginUser];
    [self setLabelText];
}
-(IBAction)handleSignUpButtonPress:(id)sender
{
    if (!self.signUpMode){
        self.signUpMode = YES;
        [self positionSubViews];
    }
    else [self submitNewUser];
    [self setLabelText];
}
-(void)submitNewUser
{
    
    if (self.usernameTextField.text.length>=self.usernameTextField.requiredLength) {
        self.currentUser.username = [self.usernameTextField.text lowercaseString];
        if (self.passwordTextfield.text.length>=self.passwordTextfield.requiredLength) {
            self.currentUser.password = self.usernameTextField.text;
            if ([self validateEmail:[self.emailTextField.text lowercaseString]]) {
                self.currentUser.email = [self.emailTextField.text lowercaseString];
                @try {
                    [self showActivityView];
                    [[[ELUserManager sharedUserManager]currentUser] signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                    {
                        if (error) {
                            [self.currentUser fetch];
                            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                            switch (error.code) {
                                case 200:
                                    myAlert.message = @"No Username";
                                    break;
                                case 201:
                                    myAlert.message = @"No Password";
                                    break;
                                case 202:
                                    myAlert.message = @"Username Already In Use";
                                    break;
                                case 203:
                                    myAlert.message = @"E-Mail Already In Use";
                                    break;
                                default:
                                    break;
                            }
                            [myAlert show];
                        }
                        else{
                            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                            [myAlert show];
                            [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:.5];
                            [self.navigationController popViewControllerAnimated:YES];
                            [[NSNotificationCenter defaultCenter]postNotificationName:elNotificationLoginSucceeded object:[[ELUserManager sharedUserManager]currentUser]];
                        }
                        [self hideActivityView];
                    }];
                }
                @catch (NSException *exception)
                {
                    UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", exception] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                    NSLog(@"Caught Exception:%@",exception);
                    [myAlert show];
                }
                @finally {
                    
                }

                
            }
            else{
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Email Invalid" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [myAlert show];
            }
        }
        else{
            UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Password Too Short" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [myAlert show];
        }
    }
    else{
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Username Too Short" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [myAlert show];
    }

    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    if (textField != self.passwordTextfield) {
        textField.text = textField.text.lowercaseString;
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextfield && !self.signUpMode) {
        [self handleLoginButtonPress:nil];
    }
    else if(textField == self.passwordTextfield && self.signUpMode){
        [self handleSignUpButtonPress:nil];
    }
    
    return YES;
}

-(void)position:(UIView *)view withOffset:(ELViewXOffset)xOffset width:(ELViewWidth)width offset:(int)offset
{
    switch (width) {
        case ELViewWidthFull:
            view.bounds = CGRectMake(0, 0, FULL_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthHalf:
            view.bounds = CGRectMake(0, 0, HALF_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthQuarter:
            view.bounds = CGRectMake(0, 0, QUARTER_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthThird:
            view.bounds = CGRectMake(0, 0, THIRD_WIDTH, ROW_HEIGHT);
            break;
        default:
            break;
    }
    float y  = ROW_OFFSET*offset+ROW_HEIGHT/2;
    
    switch (xOffset) {
        case ELViewXOffsetNone:
            view.center = CGPointMake(LEFT_OFFSET + view.bounds.size.width/2, y);
            break;
        case ELViewXOffsetOneHalf:
            view.center = CGPointMake(LEFT_OFFSET*2+HALF_WIDTH + view.bounds.size.width/2, y);
            break;
        case ELViewXOffsetOneQuarter:
            view.center = CGPointMake(LEFT_OFFSET*2+QUARTER_WIDTH + view.bounds.size.width/2,y);
            break;
        case ELViewXOffsetThreeQuarter:
            view.center = CGPointMake(LEFT_OFFSET*4+QUARTER_WIDTH*3 + view.bounds.size.width/2,y);
            break;
        case ELViewXOffsetOneThird:
            view.center = CGPointMake(LEFT_OFFSET*2+THIRD_WIDTH + view.bounds.size.width/2,y);
            break;
        case ELViewXOffsetOffScreenRight:
            view.center = CGPointMake(LEFT_OFFSET*2+FULL_WIDTH + view.bounds.size.width/2,y);
            break;
            
        default:
            break;
    }
    
}
-(void)positionSubViews
{
    self.scrollView.bounds = self.view.bounds;
    self.scrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, ROW_OFFSET*7);
    [UIView animateWithDuration:.25 animations:
     ^{
         [self position:self.usernameTextField withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:0];
         [self position:self.passwordTextfield withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:1];
         [self position:self.loginButton withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:self.signUpMode?4.5:2];
         [self position:self.emailTextField withOffset:self.signUpMode?ELViewXOffsetOneQuarter:ELViewXOffsetOffScreenRight width:ELViewWidthHalf offset:2];
         [self position:self.signUpButton withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:self.signUpMode?3:3.5];
         [self position:self.lostButton withOffset:ELViewXOffsetOneQuarter width:ELViewWidthHalf offset:self.signUpMode?6:5];
         [self.signUpButton setTitle:self.signUpMode?@"Create Account":@"New User"];
         [self.loginButton setTitle:self.signUpMode?@"Back to Login":@"Log in"];
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    self.titleLabel.bounds = CGRectMake(0, 0, self.scrollView.bounds.size.width-20, 30);
    self.titleLabel.center = CGPointMake(self.scrollView.bounds.size.width/2,25);
}
-(void)setLabelText
{
    self.titleLabel.text = self.signUpMode?@"Sign up for new E-Nough Logic Account":@"Login to your E-Nough Logic Account";
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self positionSubViews];
}

//make sure to add [self registerForKeyboardNotifications]; in the viewdidload area
//make sure to set _currentTextField in your textfield did begin edit methods
//preset to use _myScrollView
//add <UITextFieldDelegate> to the .h file
//Make sure to set the delegate of all your text fields to self.
#pragma mark TextField Edit Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.lostPasswordAlertView) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self showActivityView];
        [PFUser requestPasswordResetForEmailInBackground:[textField.text lowercaseString] block:^(BOOL succeeded, NSError *error) {
           
            if (succeeded) {
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Password verification sent to your E-mail address." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [myAlert show];
                [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:2];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Sending lost password request. Try again later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                if (error.code == 205) myAlert.message = @"E-Mail Address Not Found.";
                [myAlert show];
            }
            [self hideActivityView];
        }];
    }
}

@end
