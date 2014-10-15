//
//  UINavigationController+addOns.m
//  Fuel Logic
//
//  Created by Mike on 6/19/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#import "UINavigationController+addOns.h"


@implementation UINavigationController (ShouldPopOnBackButton)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
	if([self.viewControllers count] < [navigationBar.items count]) {
		return YES;
	}
    
	BOOL shouldPop = YES;
	UIViewController* vc = [self topViewController];
	if([vc respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
		shouldPop = [vc navigationShouldPopOnBackButton];
	}
    
	if(shouldPop) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self popViewControllerAnimated:YES];
		});
	} else {
		// Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
		for(UIView *subview in [navigationBar subviews]) {
			if(subview.alpha < 1.) {
				[UIView animateWithDuration:.25 animations:^{
					subview.alpha = 1.;
				}];
			}
		}
	}
    
	return NO;
}

- (UIViewController*)replaceTopViewControllerWithViewController: (UIViewController*)controller
{
    UIViewController* poppedViewController = [self popViewControllerAnimated:NO];
    [self pushViewController:controller animated:YES];
    return poppedViewController;
}


@end