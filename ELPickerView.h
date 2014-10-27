//
//  ELPickerView.h
//  Digital Logic
//
//  Created by Mike on 9/21/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ELView.h"
@class ELPickerView;

@protocol ELPickerViewDelegate <NSObject>
-(void)pickerView:(ELPickerView *)pickerView completedSelectionAtRow:(NSInteger)row;
-(void)pickerViewCancelled:(ELPickerView *)pickerView;
@end

@interface ELPickerView : ELView
@property (strong, nonatomic) UIPickerView *pickerView;
@property (assign, nonatomic) id <ELPickerViewDelegate> elDelegate;
 @property (assign, nonatomic) id <UIPickerViewDataSource> dataSource;
 @property (assign, nonatomic) id <UIPickerViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
-(void)presentGlobally;
+(instancetype)pickerViewWithDelegateDataSource:(id)delegateDataSource;
@end
