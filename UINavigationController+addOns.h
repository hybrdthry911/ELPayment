//
//  UINavigationController+addOns.h
//  Fuel Logic
//
//  Created by Mike on 6/19/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (ShouldPopOnBackButton) <BackButtonHandlerProtocol>

- (UIViewController*) replaceTopViewControllerWithViewController: (UIViewController*) controller;

@end