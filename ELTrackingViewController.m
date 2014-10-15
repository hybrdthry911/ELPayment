//
//  ELTrackingViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/6/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELTrackingViewController.h"

@implementation ELTrackingViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    UIWebView *webview = [[UIWebView alloc]initWithFrame:self.view.bounds];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    [webview loadRequest:requestObj];
    [self.view addSubview:webview];
}

@end
