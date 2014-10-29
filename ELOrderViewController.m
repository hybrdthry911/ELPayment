//
//  ELOrderViewController.m
//  Fuel Logic
//
//  Created by Mike on 6/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentHeader.h"
#import <AddressBook/AddressBook.h>
@interface ELOrderViewController ()
 @property (strong, nonatomic) UITableView *tableView;
 @property NSInteger currentSelectedTableViewCellRow;
 @property (strong, nonatomic) UIView *footerView;
 @property (strong, nonatomic) UILabel *totalLabel, *totalQuantityLabel;
 @property (strong, nonatomic) UIBarButtonItem *loginButton;
 @property (strong, nonatomic) UIAlertView *verifyEmailAlertView;
 @property (strong, nonatomic) ELLoginViewController *loginViewController;
@end

@implementation ELOrderViewController
 @synthesize order = _order;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedIn:) name:elNotificationUserDownloadComplete object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userLoggedOut:) name:elNotificationLogoutSucceeded object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(anonUserLoggedIn:) name:elNotificationAnonLoginSucceeded object:nil];
    
    self.currentSelectedTableViewCellRow = -1;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(quantityZero:) name:@"quantityZero" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orderChanged:) name:@"orderChanged" object:nil];
    [self setupInitialView];
    [self setupTableView];
    
    if (![[ELUserManager sharedUserManager]currentUser] || [PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) {
        //no user logged in
        [self showLoginButton];
    }
    else{
        [self showLogoutButton];
    }
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.order.orderStatus == elOrderStatusComplete) {
        [self.order clearOrder];
    }
}
-(void)userLoggedOut:(NSNotification *)notification
{
    [self showLoginButton];
}
-(void)userLoggedIn:(NSNotification *)notification
{
    if ([[ELUserManager sharedUserManager]currentUser] && ![PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) {
        [self showLogoutButton];
    }
    else [self showLoginButton];
}
-(void)anonUserLoggedIn:(NSNotification *)notification
{
    [self showLoginButton];
}
-(void)showLoginButton
{
    [self.loginButton setTitle:@"Login"];
}
-(void)showLogoutButton
{
    [self.loginButton setTitle:@"Logout"];
}
-(void)collapseViews
{
    self.currentSelectedTableViewCellRow = -1;
    [self.tableView reloadData];
}
-(IBAction)loginButtonPressed:(id)sender
{
    if (![[ELUserManager sharedUserManager]currentUser] || [PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) {
        //no user logged in
        [self login];
    }
    else{
        [self logout];
    }
}
-(void)logout
{
    [[ELUserManager sharedUserManager]logout];
}
-(void)login{
    
    self.loginViewController  = [[ELLoginViewController alloc] init];
    // Create the sign up view controller
    [self.navigationController pushViewController:self.loginViewController animated:YES];
}


-(void)reColor
{
    int i = 0;
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([[self.tableView indexPathForCell:cell] section]) continue;
        if (i % 2 == 0) cell.backgroundColor = [UIColor clearColor];
        else    cell.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.35];
        i++;
    }
}
-(void)setupTableView
{
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)setupInitialView
{
    self.view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.85];
    self.title = @"Shopping Kart";
    
    self.loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                               style:UIBarButtonItemStyleDone target:self action:@selector(loginButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.loginButton;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(ELOrder *)order
{
    if (!_order) {
        _order = [[ELOrder alloc]init];
    }
    return _order;
}
-(void)setOrder:(ELOrder *)order
{
    _order = order;
}
-(void)orderChanged:(NSNotification *)notification
{
    if (notification.object == self.order) [self.tableView reloadData];
    
    self.totalLabel.text = [NSString stringWithFormat:@"Total: $%@",self.order.subTotal];
    self.totalQuantityLabel.text = [NSString stringWithFormat:@"Total Items:%@",self.order.totalNumberOfItems];
    
    if (self.currentSelectedTableViewCellRow>=0)
    {
        ELLineItemTableViewCell *cell = (ELLineItemTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectedTableViewCellRow inSection:0]];
        [cell resetSubtotals];
    }
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)quantityZero:(NSNotification *)notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.order.lineItemsArray indexOfObject:notification.object] inSection:0];
    if (indexPath.row == self.currentSelectedTableViewCellRow) self.currentSelectedTableViewCellRow = -1;
    [self.order.lineItemsArray removeObject:notification.object];
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if (!self.order.lineItemsArray.count){
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];

    [self reColor];
    CGPoint point = CGPointMake(((UIScrollView *)self.tableView).contentOffset.x,
                                ((UIScrollView *)self.tableView).contentOffset.y+1);
    [((UIScrollView *)self.tableView) setContentOffset:point animated:NO];
    
    point = CGPointMake(((UIScrollView *)self.tableView).contentOffset.x,
                        ((UIScrollView *)self.tableView).contentOffset.y-1);
    [((UIScrollView *)self.tableView) setContentOffset:point animated:NO];
    
    self.totalLabel.text = [NSString stringWithFormat:@"Total: $%@",self.order.subTotal];
    self.totalQuantityLabel.text = [NSString stringWithFormat:@"Total Items:%@",self.order.totalNumberOfItems];
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) return 60;
    if (indexPath.row == self.currentSelectedTableViewCellRow) return 80;
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section ? 0:25;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section ? 10:25;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = self.order.lineItemsArray.count?2:1;
    return sections;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    if (section) rows = 1;
    else rows = self.order.lineItemsArray.count?self.order.lineItemsArray.count:1;
    return rows;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section)
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
        view.backgroundColor = [UIColor whiteColor];
        return view;
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
    UILabel *quantityLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 20)];
    view.backgroundColor = ICON_BLUE_SOLID;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = .5;
    quantityLabel.textAlignment = NSTextAlignmentCenter;
    quantityLabel.textColor = [UIColor whiteColor];
    quantityLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
    quantityLabel.text = @"Quantity";
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(105, 0, view.bounds.size.width-110, 20)];
    nameLabel.textAlignment = NSTextAlignmentRight;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
    nameLabel.text = @"Product";
    
    [view addSubview:nameLabel];
    [view addSubview:quantityLabel];
    
    return view;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    if (section) return nil;
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
    self.footerView = footerView;
    footerView.backgroundColor = ICON_BLUE_SOLID;
    footerView.layer.borderColor = [UIColor whiteColor].CGColor;
    footerView.layer.borderWidth = .5;
    
    UILabel *totalQuantityLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 30)];
    self.totalQuantityLabel = totalQuantityLabel;
    totalQuantityLabel.textAlignment = NSTextAlignmentCenter;
    totalQuantityLabel.textColor = [UIColor whiteColor];
    totalQuantityLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
    totalQuantityLabel.text = [NSString stringWithFormat:@"Total Items:%@",self.order.totalNumberOfItems];
    
    UILabel *totalLabel = [[UILabel alloc]initWithFrame:CGRectMake(105, 0, self.footerView.bounds.size.width-110, 30)];
    self.totalLabel = totalLabel;
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.textColor = [UIColor whiteColor];
    totalLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
    totalLabel.text = [NSString stringWithFormat:@"Total: $%.2f",self.order.subTotal.floatValue];
    
    [footerView addSubview:totalLabel];
    [footerView addSubview:totalQuantityLabel];
    
    return footerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *LineCellIdentifier =  @"LineCell";
    static NSString *checkoutIdentifier =  @"CheckoutCell";
    static NSString *emptyCellIdentifier = @"emptyOrderCell";
    
    if (indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:checkoutIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:checkoutIdentifier];
            cell.backgroundColor = ICON_BLUE_SOLID;
            cell.textLabel.font = [UIFont fontWithName:MY_FONT_1 size:18];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.text = @"Checkout";
        }
        return cell;
    }
    if(!self.order.lineItemsArray.count)
    {
        UITableViewCell *emptyOrderCell = [tableView dequeueReusableCellWithIdentifier:emptyCellIdentifier];
        
        if (!emptyOrderCell)
        {
            emptyOrderCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyCellIdentifier];
            [emptyOrderCell shineOnRepeatWithInterval:5];
            emptyOrderCell.textLabel.textColor = ICON_BLUE_SOLID;
            emptyOrderCell.textLabel.font =[UIFont fontWithName:MY_FONT_1 size:15];
        }
        emptyOrderCell.textLabel.text = [NSString stringWithFormat:@"No Items in Kart"];
        return emptyOrderCell;
    }
    else
    {
        ELLineItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LineCellIdentifier];
        if (!cell)
        {
            cell = [[ELLineItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LineCellIdentifier];
        }
        if (indexPath.row % 2 == 0) cell.backgroundColor = [UIColor clearColor];
        else    cell.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.35];
        cell.lineItem = [self.order.lineItemsArray objectAtIndex:indexPath.row];
        return cell;
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (!self.order.lineItemsArray.count) return;
    if (indexPath.section == 1)
    {
        ;
        if (![PFAnonymousUtils isLinkedWithUser:[[ELUserManager sharedUserManager]currentUser]]) {
            [[ELUserManager sharedUserManager]checkForSessionActiveThen:^(BOOL verified, NSError *error) {
                if (verified) {
                    ELPaymentSelectViewController *vc = [ELPaymentSelectViewController new];
                    vc.order = self.order;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        
        }
        else
        {
            ELPaymentSelectViewController *vc = [ELPaymentSelectViewController new];
            vc.order = self.order;
            [self.navigationController pushViewController:vc animated:YES];
        }
        return;
    }
    if (indexPath.row == self.currentSelectedTableViewCellRow) self.currentSelectedTableViewCellRow = -1;
    else self.currentSelectedTableViewCellRow = indexPath.row;
    
    [tableView beginUpdates];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell shine];
}


@end
