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


typedef enum{
    elCustomerAccountIndexOrders, elCustomerAccountIndexPaymentMethods, elCustomerAccountIndexShippingMethods, elCustomerAccountIndexAccountSettings, elCustomerAccountIndexLogout, elCustomerAccountIndexDefault
}elCustomerAccountIndex;
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
        if (self.tableView.numberOfSections && [self.tableView numberOfRowsInSection:1])
            
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]]
             
             
                                                                      withRowAnimation: UITableViewRowAnimationMiddle];
        if ([self.tableView numberOfRowsInSection:0]!=elCustomerAccountIndexDefault)
        {
            for (int i = 0;i<elCustomerAccountIndexDefault;i++) {
                 [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
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
    if (section)
        return (![[ELUserManager sharedUserManager]currentUser] || [PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) ? 1 : 0;
    else{
        return (![[ELUserManager sharedUserManager]currentUser] || [PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) ? 0: elCustomerAccountIndexDefault;
    }
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
            case elCustomerAccountIndexOrders:
                cell.textLabel.text = @"Orders";
                break;
            case elCustomerAccountIndexPaymentMethods:
                cell.textLabel.text = @"Payment Methods";
                break;
            case elCustomerAccountIndexShippingMethods:
                cell.textLabel.text = @"Shipping Methods";
                break;
            case elCustomerAccountIndexAccountSettings:
                cell.textLabel.text = @"Account Settings";
                break;
            case elCustomerAccountIndexLogout:
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section)
    {
        ELLoginViewController *loginController = [[ELLoginViewController alloc]init];
        [self.navigationController pushViewController:loginController animated:YES];
    }
    else{
        if (indexPath.row == elCustomerAccountIndexLogout)  [[ELUserManager sharedUserManager]logout];
        else
        {
            PFUser *user = [[ELUserManager sharedUserManager]currentUser];            
            switch (indexPath.row)
            {
                case elCustomerAccountIndexOrders:
                {
                    [[ELUserManager sharedUserManager] checkForSessionActiveThen:^(BOOL verified, NSError *error) {
                        if (verified) {
                            ELCustomerOrderTableViewController *customerOrderVC = [[ELCustomerOrderTableViewController alloc]initWithStyle:UITableViewStylePlain];
                            [self.navigationController pushViewController:customerOrderVC animated:YES];
                        }
                    }];
                }
                    break;
                case elCustomerAccountIndexPaymentMethods:
                {
                    [[ELUserManager sharedUserManager] checkForSessionActiveThen:^(BOOL verified, NSError *error) {
                        if (verified) {
                            ELPaymentMethodsViewController *paymentMethodVC = [[ELPaymentMethodsViewController alloc]initWithStyle:UITableViewStylePlain];
                            [self.navigationController pushViewController:paymentMethodVC animated:YES];
                        }
                    }];
                    
                }
                    break;
                case elCustomerAccountIndexShippingMethods:
                {
                    [[ELUserManager sharedUserManager] checkForSessionActiveThen:^(BOOL verified, NSError *error) {
                        if(verified){
                            ELShippingSelectForEditViewController *vc = [ELShippingSelectForEditViewController new];
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                    }];
                    
                }
                    break;
                case elCustomerAccountIndexAccountSettings:
                {
                    [[ELUserManager sharedUserManager] checkForSessionActiveThen:^(BOOL verified, NSError *error) {
                        if (verified) {
                            ELCustomerAccountSettingsViewController *accountVC = [[ELCustomerAccountSettingsViewController alloc]init];
                            [self.navigationController pushViewController:accountVC animated:YES];
                        }
                    }];
                }
                    break;
                default:
                    break;
            }
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
