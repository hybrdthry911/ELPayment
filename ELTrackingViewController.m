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
    webview.delegate = self;
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    [webview loadRequest:requestObj];
    [self.view addSubview:webview];
    [self showActivityView];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{

}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
        [self hideActivityView];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideActivityView];
    UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not load Tracking Information" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [myAlert show];
}
@end
