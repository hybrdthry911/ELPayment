//
//  ELPickerView.m
//  Digital Logic
//
//  Created by Mike on 9/21/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPickerView.h"

@interface ELPickerView()
 @property NSInteger row;
 @property NSInteger component;
 @property (strong, nonatomic) UIView *touchExitView;
@end

@implementation ELPickerView
+(instancetype)pickerViewWithDelegateDataSource:(id)delegateDataSource
{
    ELPickerView *pickerView = [[ELPickerView alloc]init];
    if (pickerView) {
        pickerView.delegate = delegateDataSource;
        pickerView.dataSource = delegateDataSource;
        pickerView.elDelegate = delegateDataSource;
    }
    return pickerView;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        
        self.backgroundColor = [UIColor clearColor];
        self.pickerView = [[UIPickerView alloc]init];
        self.pickerView.backgroundColor = [UIColor whiteColor];
        self.pickerView.showsSelectionIndicator = YES;
        self.pickerView.frame = CGRectMake(0, self.bounds.size.height-216, self.bounds.size.width, 216);
        [self addSubview:self.pickerView];
        
        self.touchExitView = [[UIView alloc]init];
        self.touchExitView.backgroundColor = [UIColor clearColor];
        [self.touchExitView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTouchExitViewTap:)]];
        self.touchExitView.frame =  CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-216);
        [self addSubview:self.touchExitView];
        
        self.toolbar = [[UIToolbar alloc]init];
        self.toolbar.opaque = YES;
        [self.toolbar setTranslucent:NO];
        self.doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonSelected:)];
        [self.doneButton setTitle:@"Select"];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonSelected:)];
        [self.cancelButton setTitle:@"Cancel"];
        [self.toolbar setItems:@[self.cancelButton,spacer,self.doneButton]];
        [self addSubview:self.toolbar];
    }
    return self;
}

-(void)presentGlobally{
    
    UIViewController *mainViewController = [ELPickerView topMostController];
    
    self.frame = CGRectMake(0, mainViewController.view.bounds.size.height, mainViewController.view.bounds.size.width,mainViewController.view.bounds.size.height);
    [UIView animateWithDuration:.25 animations:
     ^{
         self.frame = mainViewController.view.bounds;
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    [mainViewController.view addSubview:self];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    UIViewController *mainViewController = [ELPickerView topMostController];
    self.frame = mainViewController.view.bounds;
    [self.toolbar setFrame:CGRectMake(0, self.bounds.size.height-180, self.bounds.size.width, 44)];
    self.pickerView.frame = CGRectMake(0, self.bounds.size.height-180, self.bounds.size.width, 216);
    self.touchExitView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-180);
    [self bringSubviewToFront:self.toolbar];
}
-(IBAction)handleTouchExitViewTap:(id)sender
{
    [self cancelButtonSelected:self.cancelButton];
}
-(void)setDelegate:(id<UIPickerViewDelegate>)delegate
{
    self.pickerView.delegate = delegate;
}
-(void)setDataSource:(id<UIPickerViewDataSource>)dataSource
{
    self.pickerView.dataSource = dataSource;
}
-(IBAction)doneButtonSelected:(UIBarButtonItem *)sender
{
    
    if ([self.elDelegate respondsToSelector:@selector(pickerView:completedSelectionAtRow:)])
    {
        for (int i = 0; i<self.pickerView.numberOfComponents; i++) {
            [self.elDelegate pickerView:self completedSelectionAtRow:[self.pickerView selectedRowInComponent:i]];
        }

    }
}
-(IBAction)cancelButtonSelected:(UIBarButtonItem *)sender
{
    if ([self.elDelegate respondsToSelector:@selector(pickerViewCancelled:)])
    {
        [self.elDelegate pickerViewCancelled:self];
    }
}

@end
