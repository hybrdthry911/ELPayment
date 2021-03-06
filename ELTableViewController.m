//
//  ELTableViewController.m
//  Fuel Logic
//
//  Created by Mike on 10/2/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#define ROW_HEIGHT 40

#import "ELPaymentHeader.h"

@implementation ELTableViewController
@synthesize activityView = _activityView;
@synthesize hudProgressView = _hudProgressView;
@synthesize activityLabel = _activityLabel;



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.90];
    self.tableView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.90];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.hudProgressHolderView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.hudProgressHolderView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.hudProgressView.bounds = CGRectMake(0, 0, self.hudProgressHolderView.bounds.size.width, 80);
    self.hudProgressView.center = CGPointMake(self.hudProgressHolderView.bounds.size.width/2, self.hudProgressHolderView.bounds.size.height/2);
    
    self.activityView.bounds = CGRectMake(0, 0, self.hudProgressHolderView.bounds.size.width, 50);
    self.activityView.center = CGPointMake(self.hudProgressView.bounds.size.width/2, 30);
    self.activityLabel.bounds = CGRectMake(0, 0, self.hudProgressView.bounds.size.width , 25);
    self.activityLabel.center = CGPointMake(self.hudProgressView.bounds.size.width/2, self.hudProgressView.bounds.size.height - 10);
}
-(ELTextField *)addNewTextField{
    ELTextField *textField = [[ELTextField alloc]initWithFrame:CGRectMake(0, 0, 50, ROW_HEIGHT)];
    textField.required = YES;
    textField.layer.borderWidth = 1;
    textField.layer.cornerRadius = 3;
    textField.layer.borderColor = [[UIColor redColor]CGColor];
    textField.textColor = ICON_BLUE_SOLID;
    textField.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.75];
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return textField;
}

-(NSMutableAttributedString *)textFieldPlaceHolderWithString:(NSString *)string{
    
    NSMutableAttributedString *returnString =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",string]];
    [returnString addAttribute:NSForegroundColorAttributeName value:[[UIColor blackColor]colorWithAlphaComponent:.65] range:NSMakeRange(0, returnString.length)];
    [returnString addAttribute:NSFontAttributeName value:[UIFont fontWithName:MY_FONT_1 size:17] range:NSMakeRange(0, returnString.length)];
    return returnString;
}

-(void)autoCloseAlertView:(UIAlertView*)alert{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

-(UIActivityIndicatorView *)activityView
{
    if (!_activityView)
    {
        self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.color = ICON_BLUE_SOLID;
        self.activityView.backgroundColor = [UIColor clearColor];
        self.activityView.bounds = CGRectMake(0, 0, 40, 40);
        self.activityView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    }
    return _activityView;
}
-(void)setActivityView:(UIActivityIndicatorView *)activityView
{
    _activityView = activityView;
}
-(void)showActivityViewWithMessage:(NSString *)message
{
    self.view.userInteractionEnabled = NO;
    [self.view addSubview:self.hudProgressHolderView];
    self.activityLabel.text = message;
    [self.activityView startAnimating];
}
-(void)showActivityView
{
    self.view.userInteractionEnabled = NO;
    [self.view addSubview:self.hudProgressHolderView];
    self.activityLabel.text = @"Processing...";
    [self.activityView startAnimating];
}
-(void)hideActivityView
{
    self.view.userInteractionEnabled = YES;
    [self.activityView stopAnimating];
    [self.hudProgressHolderView removeFromSuperview];
}
-(UIView *)hudProgressHolderView
{
    if (!_hudProgressHolderView) {
        _hudProgressHolderView = [UIView new];
        [_hudProgressHolderView shineOnRepeatWithInterval:2];
        _hudProgressHolderView.userInteractionEnabled = NO;
        [_hudProgressHolderView addSubview:self.hudProgressView];
    }
    return _hudProgressHolderView;
}
-(UIView *)hudProgressView
{
    if (!_hudProgressView) {
        _hudProgressView = [[UIView alloc]init];
        _hudProgressView.backgroundColor = [UIColor colorWithRed:.99 green:.99 blue:.99     alpha:1];
        _hudProgressView.layer.cornerRadius = 3;
        [_hudProgressView addSubview:self.activityLabel];
        [_hudProgressView addSubview:self.activityView];
    }
    return _hudProgressView;
}
-(UILabel *)activityLabel
{
    if (!_activityLabel) {
        _activityLabel = [[UILabel alloc]init];
        [_activityLabel makeMine];
        _activityLabel.font = [UIFont fontWithName:MY_FONT_1 size:15];
        _activityLabel.textAlignment = NSTextAlignmentCenter;
        _activityLabel.text = @"Processing...";
    }
    return _activityLabel;;
}

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}
@end
