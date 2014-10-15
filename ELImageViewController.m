//
//  ELImageViewController.m
//  Fan Con
//
//  Created by Mike on 5/14/14.
//  Copyright (c) 2014 E-Nough Logic. All rights reserved.
//

#import "ELImageViewController.h"

@interface ELImageViewController ()

@end

@implementation ELImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.9];
    self.scrollView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:self.scrollView];
    
    
    self.imageView = [[UIImageView alloc]init];
    self.imageView.autoresizingMask = 0;
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.delegate = self;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.scrollView.contentSize = self.image.size;
    self.scrollView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.scrollView.contentSize = self.image.size;
    self.imageView.bounds = CGRectMake(0, 0, self.image.size.width,self.image.size.height);
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width/2,self.scrollView.contentSize.height/2);
    self.scrollView.zoomScale = 1;
    self.scrollView.maximumZoomScale = 5;
}
-(void)viewWillLayoutSubviews
{
    if (self.image) {
        self.imageView.center = CGPointMake(self.scrollView.contentSize.width/2,self.scrollView.contentSize.height/2);
        if (self.image.size.width>self.image.size.height)
        {
            self.scrollView.minimumZoomScale = self.view.bounds.size.width/self.image.size.width;
            self.scrollView.contentInset = UIEdgeInsetsMake(self.view.bounds.size.height/2 - (self.image.size.height/2*self.scrollView.minimumZoomScale),0, self.view.bounds.size.height/2 - (self.image.size.height/2*self.scrollView.minimumZoomScale), 0);
        }
        else
        {
            self.scrollView.minimumZoomScale = self.view.bounds.size.height/self.image.size.height;
             self.scrollView.contentInset = UIEdgeInsetsMake(0,self.view.bounds.size.width/2 - (self.image.size.width/2*self.scrollView.minimumZoomScale),0,self.view.bounds.size.width/2 - (self.image.size.width/2*self.scrollView.minimumZoomScale));
        }
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
