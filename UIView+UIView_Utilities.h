//
//  UIView+UIView_Utilities.h
//  Digital Logic
//
//  Created by Mike on 3/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIView_Utilities)
 @property (strong, nonatomic) UIView *leftBar, *topBar, *bottomBar, *rightBar;
 @property (nonatomic, copy) NSTimer *shineTimer;
-(void)addLeftBarWithColor:(UIColor *)color width:(float)width gradientColor:(UIColor *)gradientColor;
-(void)addRightBarWithColor:(UIColor *)color width:(float)width gradientColor:(UIColor *)gradientColor;
-(void)addLeftBarWithColor:(UIColor *)color width:(float)width;
-(void)addRightBarWithColor:(UIColor *)color width:(float)width;
-(void)addTopBarWithColor:(UIColor *)color width:(float)width gradientColor:(UIColor *)gradientColor;
-(void)addBottomBarWithColor:(UIColor *)color width:(float)width gradientColor:(UIColor *)gradientColor;
-(void)addTopBarWithColor:(UIColor *)color width:(float)width;
-(void)addBottomBarWithColor:(UIColor *)color width:(float)width;

-(void)flip;
-(void)pop;
-(void)standOnBottomLeftCorner;
-(void)standOnBottomLeftCornerAlternate;
-(void)shine;
-(void)stopShine;
-(void)shineOnRepeatWithInterval:(float)interval;
@end

