//
//  ELCustomerAccountViewController.m
//  Fuel Logic
//
//  Created by Mike on 9/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#define TOP_SPACING 40
#define LEFT_OFFSET 10
#define ROW_HEIGHT 40
#define ROW_SPACING 5
//#define RIGHT_HALF_OFFSET (self.scrollView.bounds.size.width/2 + LEFT_OFFSET/2)


#define ROW_OFFSET TOP_SPACING+(ROW_HEIGHT+ROW_SPACING)
#define FULL_WIDTH (self.scrollView.bounds.size.width-LEFT_OFFSET*2)
#define HALF_WIDTH ((self.scrollView.bounds.size.width-LEFT_OFFSET*3)/2)
#define QUARTER_WIDTH ((self.scrollView.bounds.size.width - LEFT_OFFSET*5)/4)


#import "ELPaymentHeader.h"
@interface ELCustomerAccountViewController()
 @property (strong, nonatomic) PFQueryTableViewController *recentOrders;
 @property (strong, nonatomic) UIAlertView *verifyEmailAlertView;
@end

@implementation ELCustomerAccountViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Account Information";
    self.tableView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.95];
    self.navigationController.navigationBar.backgroundColor = ICON_BLUE_SOLID;
    if ([[ELUserManager sharedUserManager]currentUser]) [self userDownloadComplete:nil];
    if ([[ELUserManager sharedUserManager]currentCustomer]) [self customerDownloadComplete:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(customerDownloadComplete:) name:elNotificationCustomerDownloadComplete object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userDownloadComplete:) name:elNotificationUserDownloadComplete object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedOut:) name:elNotificationLogoutSucceeded object:nil];
}
-(void)verifyPassword:(NSString *)password WithCompletionHandler:(ELVerifyPasswordHandler)handler
{
    [PFCloud callFunctionInBackground:@"verifyPassword" withParameters:@{@"password":password} block:^(id object, NSError *error) {
        handler(error ? NO:YES,error);
    }];
}

-(void)populateTextFields
{
    
}
-(void)populateButtonFields
{
    
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}
-(void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
}
-(void)customerDownloadComplete:(NSNotification *)notification
{
    [self.tableView reloadData];
}
-(void)userDownloadComplete:(NSNotification *)notification
{
    PFUser *user = [[ELUserManager sharedUserManager]currentUser];
    if (user && ![PFAnonymousUtils isLinkedWithUser:user])
    {
        self.title = [NSString stringWithFormat:@"Account: %@",user.username];
        self.title = @"Account Information";
        
        [self.tableView beginUpdates];
        [self.tableView numberOfRowsInSection:0];
        if (self.tableView.numberOfSections && [self.tableView numberOfRowsInSection:1])    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]]
                                                                      withRowAnimation: UITableViewRowAnimationMiddle];
        if ([self.tableView numberOfRowsInSection:0]!=4)
        {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],
                                                     [NSIndexPath indexPathForRow:1 inSection:0],
                                                     [NSIndexPath indexPathForRow:2 inSection:0],
                                                     [NSIndexPath indexPathForRow:3 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];
    }
    else
    {
        [self userLoggedOut:nil];
    }
}
-(void)userLoggedOut:(NSNotification *)notification
{
    self.title = @"Account Information";
    [self.tableView beginUpdates];
    [self.tableView
     deleteRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
     withRowAnimation: UITableViewRowAnimationMiddle];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section ? (![[ELUserManager sharedUserManager]currentUser] || [PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) ? 1 : 0 : (![[ELUserManager sharedUserManager]currentUser] || [PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) ? 0 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ELPumpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ELPumpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (!indexPath.section) {
        //User Logged in
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Orders";
                break;
            case 1:
                cell.textLabel.text = @"Payment Methods";
                break;
            case 2:
                cell.textLabel.text = @"Account Settings";
                break;
            case 3:
                cell.textLabel.text = @"Logout";
                break;
            default:
                break;
        }
    }
    else if(indexPath.section){
        //user not logged in
        cell.textLabel.text = @"Login or Create an Account";
    }
    // Configure the cell...
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section) {
        ELLoginViewController *loginController = [[ELLoginViewController alloc]init];
        [self.navigationController pushViewController:loginController animated:YES];
    }
    else if(indexPath.row == 3)
    {
        [[ELUserManager sharedUserManager]logout];
    }
    
    else
    {
        PFUser *user = [[ELUserManager sharedUserManager]currentUser];
        
        if (![user[@"emailVerified"] boolValue]) {
            [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
            }];
            self.verifyEmailAlertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"You haven't verified your email address associated with your account." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Resend",nil];
            [self.verifyEmailAlertView show];
            return;
        }
        switch (indexPath.row)
        {
            case 0:
            {
                if ([[ELUserManager sharedUserManager]passwordSessionActive ]) {
                    ELCustomerOrderTableViewController *customerOrderVC = [[ELCustomerOrderTableViewController alloc]initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:customerOrderVC animated:YES];
                }
                else{
                    [[ELUserManager sharedUserManager]verifyPasswordWithComletion:^(BOOL verified, NSError *error) {
                        if (verified) {
                            ELCustomerOrderTableViewController *customerOrderVC = [[ELCustomerOrderTableViewController alloc]initWithStyle:UITableViewStylePlain];
                            [self.navigationController pushViewController:customerOrderVC animated:YES];
                        }
                    }];
                }

            }
                break;
            case 1:
            {
                
                if ([[ELUserManager sharedUserManager]passwordSessionActive]) {
                    ELPaymentMethodsViewController *paymentMethodVC = [[ELPaymentMethodsViewController alloc]initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:paymentMethodVC animated:YES];
                }
                else
                {
                    [[ELUserManager sharedUserManager]verifyPasswordWithComletion:^(BOOL verified, NSError *error) {
                        if (verified) {
                            ELPaymentMethodsViewController *paymentMethodVC = [[ELPaymentMethodsViewController alloc]initWithStyle:UITableViewStylePlain];
                            [self.navigationController pushViewController:paymentMethodVC animated:YES];
                        }
                    }];
                }
                
            }
                break;
            case 2:
            {
                if ([[ELUserManager sharedUserManager]passwordSessionActive]) {
                    ELCustomerAccountSettingsViewController *accountVC = [[ELCustomerAccountSettingsViewController alloc]init];
                    [self.navigationController pushViewController:accountVC animated:YES];
                }
                else
                {
                    [[ELUserManager sharedUserManager]verifyPasswordWithComletion:^(BOOL verified, NSError *error) {
                        if (verified) {
                            ELCustomerAccountSettingsViewController *accountVC = [[ELCustomerAccountSettingsViewController alloc]init];
                            [self.navigationController pushViewController:accountVC animated:YES];
                        }
                    }];
                }
                
            }
                break;
            case 3:
                break;
            default:
                break;
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.verifyEmailAlertView && buttonIndex) {
        [self showActivityView];
        [[[ELUserManager sharedUserManager]currentUser] setEmail:[NSString stringWithFormat:@"%@",[[ELUserManager sharedUserManager]currentUser].email]];
        [[[ELUserManager sharedUserManager]currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Email Verification Error:%@",error);
            }
            else{
                UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Sent" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [myAlert show];
                [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:.5];
            }
            [self hideActivityView];
        }];
    }
}
@end
