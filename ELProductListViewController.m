//
//  ELProductListViewController.m
//  Fuel Logic
//
//  Created by Mike on 6/30/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#import <Parse/Parse.h>
#import "ELPaymentHeader.h"
@interface ELProductListViewController ()
 @property (strong, nonatomic) UIView *hudProgressView;
 @property (strong, nonatomic) UILabel *loadingLabel;
 @property (strong, nonatomic) UIActivityIndicatorView *activityView;
 @property (strong, nonatomic) NSArray *productArray;
 @property (strong, nonatomic) NSArray *categoryArray;
 @property (strong, nonatomic) UITableView *tableView;
@property BOOL productsLoaded, categoriesLoaded;
@end

@implementation ELProductListViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],
                                                          NSForegroundColorAttributeName,
                                                          [UIColor blueColor],
                                                          NSBackgroundColorAttributeName,
                                                          [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                          NSForegroundColorAttributeName,
                                                          [UIFont fontWithName:MY_FONT_2 size:18],
                                                          NSFontAttributeName,
                                                          nil]];
    
    self.hudProgressView = [[UIView alloc]init];
    self.hudProgressView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.35];
    self.hudProgressView.layer.cornerRadius = 3;
    self.loadingLabel = [[UILabel alloc]init];
    [self.loadingLabel makeMine];
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.text = @"Loading . . .";
    [self.hudProgressView addSubview:self.loadingLabel];
    
    self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.color = ICON_BLUE_SOLID;
    [self.hudProgressView addSubview:self.activityView];

    self.navigationController.navigationBar.backgroundColor = ICON_BLUE_SOLID;
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.95];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.scrollsToTop = YES;
    [self.view addSubview:self.tableView];
    
    self.productArray = [NSArray array];
    self.categoryArray = [NSArray array];
    self.productsLoaded = NO;
    self.categoriesLoaded = NO;
    [self loadTableView];

    // Do any additional setup after loading the view.
}
-(void)reload
{
    [self loadTableView];
}
-(void)loadTableView
{
    [self showProgress:YES];

    [self.category fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        if (!object || error) {
            NSLog(@"Error:%@",error);
            return;
        }
        self.title = self.category.name;
        ELCategory *cat = (ELCategory *)object;
        PFQuery *productQuery = cat.products.query;
        [productQuery orderByAscending:@"descriptor"];
        [productQuery whereKey:@"hidden" notEqualTo:[NSNumber numberWithBool:YES]];
        PFQuery *categoriesQuery = cat.children.query;
        [categoriesQuery orderByAscending:@"name"];
        [productQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects && !error) {
                self.productArray = objects;
                if (self.productArray.count) {
                    NSMutableArray *array = [NSMutableArray array];
                    for (int i = 0; i<self.productArray.count; i++) {
                        [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    [self.tableView beginUpdates];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                  withRowAnimation:UITableViewRowAnimationMiddle];
                    // [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationMiddle];
                    [self.tableView endUpdates];
                }
            }
            self.productsLoaded = YES;
            [self showProgress:!self.categoriesLoaded];
        }];
        [categoriesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects && !error) {
                // [self performSelectorOnMainThread:@selector(setCatagoryArray:) withObject:objects waitUntilDone:YES];
                self.categoryArray = objects;
                if (self.categoryArray.count) {
                    NSMutableArray *array = [NSMutableArray array];
                    for (int i = 0; i<self.categoryArray.count; i++) {
                        [array addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                    }
                    [self.tableView beginUpdates];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                  withRowAnimation:UITableViewRowAnimationMiddle];
                    //[self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationMiddle];
                    [self.tableView endUpdates];
                }
            }
            self.categoriesLoaded = YES;
            [self showProgress:!self.productsLoaded];
        }];
    }];
}
-(void)showProgress:(BOOL)on
{
    if (on)
    {
        [self.view addSubview:self.hudProgressView];
        [self.activityView startAnimating];
    }
    else{
        [self.activityView stopAnimating];
        [self.hudProgressView removeFromSuperview];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.tableView.frame = self.view.bounds;
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.hudProgressView.bounds = CGRectMake(0, 0, 90, 90);
    self.hudProgressView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.activityView.center = CGPointMake(self.hudProgressView.bounds.size.width/2, self.hudProgressView.bounds.size.height/2);
    self.loadingLabel.bounds = CGRectMake(0, 0, self.hudProgressView.bounds.size.width, 20);
    self.loadingLabel.center = CGPointMake(self.hudProgressView.bounds.size.width/2, self.hudProgressView.bounds.size.height-12.5);
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section ? self.categoryArray.count : self.productArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((section && self.categoryArray.count) || (!section && self.productArray.count)) {
        return 25;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section ? 60:100;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) cell.contentView.backgroundColor = [UIColor clearColor];
    else    cell.contentView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.35];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = ICON_BLUE_SOLID;
    label.textColor = [UIColor whiteColor];
    label.font =[UIFont fontWithName:MY_FONT_1 size:15];
    label.text = section ? @"Categories":@"Products";
    return label;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *productCellIdentifier = @"ProductCell";
    static NSString *categoryCellIdentifier = @"CatagoryCell";
    UITableViewCell *cell;
    
    if (indexPath.section) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:categoryCellIdentifier];
        if (!cell) {
            cell = [[ELProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:categoryCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row % 2 == 0) cell.contentView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.8];
        else    cell.contentView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.85];
        ELCategory *category = self.categoryArray[indexPath.row];
        cell.textLabel.text = category.name;
    }
    else{
        ELProductTableViewCell *productCell;
        productCell = [tableView dequeueReusableCellWithIdentifier:productCellIdentifier];
        if (!productCell) {
            productCell = [[ELProductTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:productCellIdentifier];
            
        }
        if (indexPath.row % 2 == 0) cell.contentView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.8];
        else    cell.contentView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.85];
      //   [productCell showCart:YES];
        ELProduct *product = self.productArray[indexPath.row];
        [productCell setProduct:product];
        [productCell.thumbnail setFile:product.mainPhoto];
        [productCell.thumbnail loadInBackground];
        cell = productCell;
    }
    // Configure the cell...
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) {
        ELProductListViewController *vc = [[ELProductListViewController alloc]init];
        vc.category  = self.categoryArray[indexPath.row];
        vc.order = self.order;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        ELProductViewController *vc = [[ELProductViewController alloc]init];
        vc.product = self.productArray[indexPath.row];
        vc.order = self.order;
        [self.navigationController pushViewController:vc animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
