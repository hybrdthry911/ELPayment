//
//  ELProductViewController.h
//  Fuel Logic
//
//  Created by Mike on 7/1/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ELProduct.h"
#import "ELOrder.h"
#import "ELImageViewController.h"
@interface ELProductViewController : ELViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) PFImageView *mainImageView;
@property (strong, nonatomic) UIImage *mainImage;
@property (strong, nonatomic) UILabel *skuLabel;
@property (strong, nonatomic) UIButton *cartButton;
@property (strong, nonatomic) UILabel *descriptorLabel;
@property BOOL enableCompatibleProducts;
 @property (strong, nonatomic) UITableView *compatibleProductsTableView;
 @property (strong, nonatomic) ELProduct *product;
 @property (strong, nonatomic) ELOrder *order;
 @property (strong, nonatomic) NSArray *compatibleProductsArray;
@end
