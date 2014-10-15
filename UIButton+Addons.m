//
//  UIButton+Addons.m
//  Fuel Logic
//
//  Created by Mike on 6/22/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#define TOP_SPACING 40
#define LEFT_OFFSET 10
#define ROW_HEIGHT 40
#define ROW_SPACING 5
#define RIGHT_HALF_OFFSET (self.scrollView.bounds.size.width/2 + LEFT_OFFSET/2)
#define ROW_OFFSET TOP_SPACING+(ROW_HEIGHT+ROW_SPACING)
#define FULL_WIDTH (self.scrollView.bounds.size.width - LEFT_OFFSET*2)
#define HALF_WIDTH (self.scrollView.bounds.size.width/2 - LEFT_OFFSET*1.5)
#define QUARTER_WIDTH ((self.scrollView.bounds.size.width - LEFT_OFFSET*2.5)/4)


#import "UIButton+Addons.h"
#import <objc/runtime.h>

@implementation UIButton (Addons)

+(UIButton *)myButton
{
    UIButton *button = [[UIButton alloc]init];
    [button makeMine];
    return button;
}

//lkdsjkldjs


-(void)makeMine
{
    self.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    self.backgroundColor = ICON_BLUE_SOLID;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:.15];
//    [self setTitleColor:ICON_BLUE_SOLID forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:MY_FONT_1 size:17];
    self.layer.cornerRadius = 3;
    self.layer.borderWidth = .5;
}
-(void)makeMine2
{
    
    self.layer.borderColor = ICON_BLUE_SOLID.CGColor;
    self.backgroundColor = [UIColor colorWithHue:1 saturation:0 brightness:.7 alpha:.7 ];
    [self setTitleColor:ICON_BLUE_SOLID forState:UIControlStateNormal];

    [self.titleLabel setFont:[UIFont fontWithName:MY_FONT_1 size:17]];
    self.layer.cornerRadius = 3;
    self.layer.borderWidth = .5;
}
- (UIView *)leftBar {
    return objc_getAssociatedObject(self, @selector(leftBar));
}

- (void)setLeftBar:(UIView *)leftBar{
    objc_setAssociatedObject(self, @selector(leftBar), leftBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont fontWithName:MY_FONT_1 size:17]];
}

@end
