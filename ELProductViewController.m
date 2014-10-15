//
//  ELProductViewController.m
//  Fuel Logic
//
//  Created by Mike on 7/1/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELProductViewController.h"
#import <Parse/Parse.h>
#define IMAGE_HEIGHT 200
#define CART_SIZE 75
#define VIEW_WIDTH_HALF VIEW_WIDTH/2
#define VIEW_WIDTH self.view.bounds.size.width
@interface ELProductViewController ()

@end

@implementation ELProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.bounces = YES;
    self.scrollView.autoresizingMask = 0;
    [self.view addSubview:self.scrollView];
    [self showActivityView];
    [self.product fetchIfNeeded];
    [self  hideActivityView];
    self.title = self.product.model;
    self.view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.95];
    self.nameLabel = [[UILabel alloc]init];
    [self.nameLabel makeMine];
    self.nameLabel.font = [UIFont fontWithName:MY_FONT_2 size:20];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.product.brand,self.product.model];
    [self.scrollView addSubview:self.nameLabel];
    
    self.mainImageView = [[PFImageView alloc]init];
    self.mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    if (self.product.mainPhoto) {
        [self.scrollView addSubview:self.mainImageView];
    }
    [self.mainImageView setFile:self.product.mainPhoto];
    [self.mainImageView setUserInteractionEnabled:YES];
    [self.mainImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleMainImagePress:)]];
    [self.mainImageView loadInBackground:^(UIImage *image, NSError *error) {
        self.mainImage = image;
    }];
    
    self.priceLabel = [[UILabel alloc]init];
    self.priceLabel.font = [UIFont fontWithName:MY_FONT_2 size:20];
    [self.priceLabel makeMine];
    NSAttributedString *salePrice = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"Price: $%.2f  ",self.product.salePrice.floatValue] attributes:@{NSFontAttributeName: [UIFont fontWithName:MY_FONT_2 size:20],NSForegroundColorAttributeName:ICON_BLUE_SOLID}];
    
                                     
    NSAttributedString *listPrice = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"$%.2f",self.product.listPrice.floatValue] attributes:@{NSFontAttributeName: [UIFont fontWithName:MY_FONT_1 size:14],NSForegroundColorAttributeName:[UIColor grayColor],NSStrikethroughStyleAttributeName:@2}];
    NSMutableAttributedString *priceString = [[NSMutableAttributedString alloc]initWithAttributedString:salePrice];
    if (self.product.listPrice.floatValue > self.product.salePrice.floatValue) {
        [priceString appendAttributedString:listPrice];
    }
    [self.priceLabel setAttributedText:priceString];
    [self.scrollView addSubview:self.priceLabel];
    
    
    
    self.skuLabel = [[UILabel alloc]init];
    [self.skuLabel makeMine];
    
    self.skuLabel.font = [UIFont fontWithName:MY_FONT_1 size:14];
    self.skuLabel.text = [NSString stringWithFormat:@"Product ID:%@",self.product.sku];
    [self.scrollView addSubview:self.skuLabel];
    
    self.descriptorLabel = [[UILabel alloc]init];
    [self.descriptorLabel makeMine];
    self.descriptorLabel.numberOfLines = 0;
    self.descriptorLabel.font = [UIFont fontWithName:MY_FONT_1 size:16];
    self.descriptorLabel.text = self.product.descriptor?[NSString stringWithFormat:@"Description:\n\n\t%@",self.product.descriptor]:nil;
    [self.scrollView addSubview:self.descriptorLabel];
    
    
    self.cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cartButton setImage:[UIImage imageNamed:@"cartIconInvert.png"] forState:UIControlStateNormal];
    [self.cartButton addTarget:self action:@selector(handleCartButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.cartButton];
    
    
    if (self.enableCompatibleProducts)
    {
        self.compatibleProductsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 100) style:UITableViewStylePlain];
        [self fetchCompatibleProducts];
        [self.scrollView addSubview:self.compatibleProductsTableView];
    }
    // Do any additional setup after loading the view.
}
-(void)fetchCompatibleProducts
{
    PFQuery *query = self.product.compatibleProducts.query;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            self.compatibleProductsArray = nil;
            [self.compatibleProductsTableView reloadData];
        }
    }];
}
-(IBAction)handleMainImagePress:(UITapGestureRecognizer *)sender
{
    ELImageViewController *vc = [[ELImageViewController alloc]init];
    vc.image = self.mainImage;
    vc.title = self.title;
    [self.navigationController pushViewController:vc animated:YES];
}
-(IBAction)handleCartButtonPress:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addProductToOrder" object:self.product];
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.descriptorLabel.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
    
    self.scrollView.bounds = CGRectMake(0, 0, VIEW_WIDTH, self.view.bounds.size.height);
    self.scrollView.center = CGPointMake(VIEW_WIDTH_HALF, self.view.bounds.size.height/2);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.nameLabel sizeToFit];
    self.nameLabel.center = CGPointMake(self.nameLabel.bounds.size.width/2+5, self.nameLabel.bounds.size.height/2+5);
    self.mainImageView.bounds = CGRectMake(0, 0, VIEW_WIDTH-20, IMAGE_HEIGHT);
    self.mainImageView.center = CGPointMake(VIEW_WIDTH_HALF, self.nameLabel.center.y+5+IMAGE_HEIGHT/2+self.nameLabel.bounds.size.height/2);
    [self.priceLabel sizeToFit];
    self.priceLabel.center = CGPointMake(self.priceLabel.bounds.size.width/2+10, self.mainImageView.center.y+5+IMAGE_HEIGHT/2+self.priceLabel.bounds.size.height/2);
    [self.skuLabel sizeToFit];
    self.skuLabel.center = CGPointMake(self.skuLabel.bounds.size.width/2+10, self.priceLabel.center.y+1+self.priceLabel.bounds.size.height/2+self.skuLabel.bounds.size.height/2);
    
    self.cartButton.bounds = CGRectMake(0, 0, CART_SIZE, CART_SIZE);
    self.cartButton.center = CGPointMake(VIEW_WIDTH - 5 - CART_SIZE/2, self.mainImageView.center.y+5+IMAGE_HEIGHT/2+self.cartButton.bounds.size.height/2);
    self.descriptorLabel.numberOfLines = 0;
    [self.descriptorLabel sizeToFit];
    
    self.descriptorLabel.center = CGPointMake(5+self.descriptorLabel.bounds.size.width/2, self.skuLabel.center.y+self.skuLabel.bounds.size.height/2+self.descriptorLabel.bounds.size.height/2+25);
    
//#error decide how to implement compatible products list
    
    
    self.scrollView.contentSize = CGSizeMake(VIEW_WIDTH, self.descriptorLabel.center.y+self.descriptorLabel.bounds.size.height/2+10);
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.compatibleProductsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
