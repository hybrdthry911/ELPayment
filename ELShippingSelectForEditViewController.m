//
//  ELShippingSelectEditViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/27/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELShippingSelectForEditViewController.h"
#import "ELPaymentHeader.h"

@interface ELShippingSelectForEditViewController ()

 @property BOOL loadedOnce;
@end

@implementation ELShippingSelectForEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    super.tableView.delegate = self;
    super.tableView.dataSource = self;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //reload if already loaded.
    if (self.loadedOnce) [self loadObjects];
    self.loadedOnce = YES;

}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
     return indexPath.row<self.objects.count;
 }
-(void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    [self hideActivityView];
}

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     [self showActivityViewWithMessage:@"Removing Shipping Address..."];
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         [self.objects[indexPath.row] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded) {
                 [self loadObjects];
             }
             else{
                 UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not save. Try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                 [myAlert show];
                 [self hideActivityView];
                 [self performSelector:@selector(autoCloseAlertView:) withObject:myAlert afterDelay:1];
             }
         }];
     }
 }


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ELShippingAddressEditViewController *vc = [ELShippingAddressEditViewController new];
    if (indexPath.row<self.objects.count)
    {
        vc.shippingAddress = self.objects[indexPath.row];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

@end
