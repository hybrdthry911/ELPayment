//
//  ELImageViewController.h
//  Fan Con
//
//  Created by Mike on 5/14/14.
//  Copyright (c) 2014 E-Nough Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELViewController.h"

@interface ELImageViewController : ELViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
 @property (strong, nonatomic) UIImage *image;
@end
