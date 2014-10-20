//
//  UIView+UIView_Utilities.m
//  Digital Logic
//
//  Created by Mike on 3/10/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//



#ifndef adddynamic
#define adddynamic

#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_RETAIN); \
} \

#endif

#import "UIView+UIView_Utilities.h"
#import <objc/runtime.h>


@implementation UIView (UIView_Utilities)

ADD_DYNAMIC_PROPERTY(NSTimer*, shineTimer, setShineTimer);

- (UIView *)leftBar {
    return objc_getAssociatedObject(self, @selector(leftBar));
}

- (void)setLeftBar:(UIView *)leftBar{
    objc_setAssociatedObject(self, @selector(leftBar), leftBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)rightBar {
    return objc_getAssociatedObject(self, @selector(rightBar));
}

- (void)setRightBar:(UIView *)rightBar{
    objc_setAssociatedObject(self, @selector(rightBar), rightBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)topBar {
    return objc_getAssociatedObject(self, @selector(topBar));
}

- (void)setTopBar:(UIView *)topBar
{
    objc_setAssociatedObject(self, @selector(topBar), topBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)bottomBar {
    return objc_getAssociatedObject(self, @selector(bottomBar));
}

- (void)setBottomBar:(UIView *)bottomBar{
    objc_setAssociatedObject(self, @selector(bottomBar), bottomBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)flip{
    CGAffineTransform Oldtransform = self.transform;
    
    
    [UIView animateWithDuration:.15 animations:
     ^{
         self.transform = CGAffineTransformMakeScale(Oldtransform.a*.90f, Oldtransform.d*.01f);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:.1 animations:
          ^{
              
              self.transform = Oldtransform;
          }
                          completion:^(BOOL finished)
          {
              
              
          }];
         
     }];
}
-(void)pop
{
    CGAffineTransform Oldtransform = self.transform;
    
    
    [UIView animateWithDuration:.15 animations:
     ^{
         self.transform = CGAffineTransformMakeScale(Oldtransform.a*.75f, Oldtransform.d*.75f);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:.1 animations:
          ^{
              
              self.transform = Oldtransform;
          }
                          completion:^(BOOL finished)
          {
              
          }];
         
     }];
}

-(void)addLeftBarWithColor:(UIColor *)color width:(float)width gradientColor:(UIColor *)gradientColor
{
    if (self.leftBar) {
        [self.leftBar removeFromSuperview];
    }
    self.leftBar = nil;
    self.leftBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, self.bounds.size.height)];
    self.leftBar.backgroundColor = color;
    if (gradientColor) {
        self.leftBar.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.leftBar.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[gradientColor CGColor],(id)[color CGColor],(id)[gradientColor CGColor], nil];
        gradient.startPoint = CGPointMake(0.5,0);
        gradient.endPoint = CGPointMake(0.5,1.0);
        [self.leftBar.layer addSublayer:gradient];
    }
    [self addSubview:self.leftBar];
}        
-(void)addRightBarWithColor:(UIColor *)color width:(float)width gradientColor:(UIColor *)gradientColor
{
    if (self.rightBar) {
        [self.rightBar removeFromSuperview];
    }
    self.rightBar = nil;
    self.rightBar = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width-width, 0, width, self.bounds.size.height)];
    self.rightBar.backgroundColor = color;
    
    if (gradientColor) {
        self.rightBar.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.rightBar.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[gradientColor CGColor],(id)[color CGColor],(id)[gradientColor CGColor], nil];
        gradient.startPoint = CGPointMake(0.5,0);
        gradient.endPoint = CGPointMake(0.5,1.0);
        [self.rightBar.layer addSublayer:gradient];
    }
    [self addSubview:self.rightBar];
}

-(void)addLeftBarWithColor:(UIColor *)color width:(float)width
{
    if (self.leftBar) {
        [self.leftBar removeFromSuperview];
    }
    self.leftBar = nil;
    self.leftBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, self.bounds.size.height)];
    self.leftBar.backgroundColor = color;
    [self addSubview:self.leftBar];
}
-(void)addRightBarWithColor:(UIColor *)color width:(float)width
{
    if (self.rightBar) {
        [self.rightBar removeFromSuperview];
    }
    self.rightBar = nil;
    self.rightBar = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width-width, 0, width, self.bounds.size.height)];
    self.rightBar.backgroundColor = color;
    [self addSubview:self.rightBar];
}
-(void)addTopBarWithColor:(UIColor *)color width:(float)width gradientColor:(UIColor *)gradientColor
{
    if (self.topBar) {
        [self.topBar removeFromSuperview];
    }
    self.topBar = nil;
    self.topBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-width, self.bounds.size.width, 0)];
    self.topBar.backgroundColor = color;
    
    if (gradientColor) {
        self.topBar.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.topBar.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[gradientColor CGColor],(id)[color CGColor],(id)[gradientColor CGColor], nil];
        gradient.startPoint = CGPointMake(0.5,0);
        gradient.endPoint = CGPointMake(0.5,1.0);
        [self.topBar.layer addSublayer:gradient];
    }
    [self addSubview:self.topBar];
}
-(void)addBottomBarWithColor:(UIColor *)color width:(float)width gradientColor:(UIColor *)gradientColor
{
    if (self.bottomBar) {
        [self.bottomBar removeFromSuperview];
    }
    self.bottomBar = nil;
    self.bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
    self.bottomBar.backgroundColor = color;
    if (gradientColor) {
        self.bottomBar.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bottomBar.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[gradientColor CGColor],(id)[color CGColor],(id)[gradientColor CGColor], nil];
        gradient.startPoint = CGPointMake(0.5,0);
        gradient.endPoint = CGPointMake(0.5,1.0);
        [self.bottomBar.layer addSublayer:gradient];
    }
    [self addSubview:self.bottomBar];
}

-(void)addTopBarWithColor:(UIColor *)color width:(float)width
{
    if (self.topBar) {
        [self.topBar removeFromSuperview];
    }
    self.topBar = nil;
    self.topBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-width, self.bounds.size.width, 0)];
    self.topBar.backgroundColor = color;
    [self addSubview:self.topBar];
}
-(void)addBottomBarWithColor:(UIColor *)color width:(float)width
{
    if (self.bottomBar) {
        [self.bottomBar removeFromSuperview];
    }
    self.bottomBar = nil;
    self.bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
    self.bottomBar.backgroundColor = color;
    [self addSubview:self.bottomBar];
}



-(void)standOnBottomLeftCorner
{
    self.layer.anchorPoint = CGPointMake(self.bounds.size.height/self.bounds.size.width/2, self.layer.anchorPoint.y);
    self.center = CGPointMake(self.center.x -(self.bounds.size.width/2-self.bounds.size.height/2), self.center.y);
    self.transform = CGAffineTransformMakeRotation( 90.0f * M_PI / 180.0f);
}
-(void)standOnBottomLeftCornerAlternate
{
    self.transform = CGAffineTransformMakeRotation( 90.0f * M_PI / 180.0f);
    self.center = CGPointMake(self.center.x-(self.bounds.size.width/2-self.bounds.size.height/2), self.center.y-(self.bounds.size.width/2-self.bounds.size.height/2));
}
-(void)shineOnRepeatWithInterval:(float)interval
{
    if (self.shineTimer) {
        [self.shineTimer invalidate];
        self.shineTimer = nil;
    }
    self.shineTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(shine) userInfo:nil repeats:YES];
    [self.shineTimer fire];
}
-(void)stopShine
{
    if (self.shineTimer) {
        [self.shineTimer invalidate];
        self.shineTimer = nil;
    }
}
-(void)shine
{
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [whiteView setUserInteractionEnabled:NO];
    [self addSubview:whiteView];
    
    CALayer *maskLayer = [CALayer layer];
    
    // Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
    // to the same value so the layer can extend the mask image.
    maskLayer.backgroundColor = [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f] CGColor];
    maskLayer.contents = (id)[[UIImage imageNamed:@"shine.png"] CGImage];
    
    // Center the mask image on twice the width of the text layer, so it starts to the left
    // of the text layer and moves to its right when we translate it by width.
    maskLayer.contentsGravity = kCAGravityCenter;
    maskLayer.frame = CGRectMake(-whiteView.frame.size.width,
                                 0.0f,
                                 whiteView.frame.size.width * 2,
                                 whiteView.frame.size.height);
    
    // Animate the mask layer's horizontal position
    CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    maskAnim.byValue = [NSNumber numberWithFloat:self.frame.size.width * 9];
    maskAnim.repeatCount = HUGE_VALF;
    maskAnim.duration = 3.0f;
    [maskLayer addAnimation:maskAnim forKey:@"shineAnim"];
    
    whiteView.layer.mask = maskLayer;
}


@end


