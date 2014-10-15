//
//  ELView.m
//  Fuel Logic
//
//  Created by Mike on 10/13/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELView.h"

@implementation ELView
-(NSMutableAttributedString *)textFieldPlaceHolderWithString:(NSString *)string{
    
    NSMutableAttributedString *returnString =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",string]];
    [returnString addAttribute:NSForegroundColorAttributeName value:[[UIColor blackColor]colorWithAlphaComponent:.65] range:NSMakeRange(0, returnString.length)];
    [returnString addAttribute:NSFontAttributeName value:[UIFont fontWithName:MY_FONT_1 size:17] range:NSMakeRange(0, returnString.length)];
    return returnString;
}
+ (ViewController*) topMostController
{
    ViewController *topController = (ViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = (ViewController *)topController.presentedViewController;
    }
    return topController;
}
-(ELTextField *)addNewTextField{
    ELTextField *textField = [[ELTextField alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
    textField.required = YES;
    textField.layer.borderWidth = 1;
    textField.layer.cornerRadius = 3;
    textField.layer.borderColor = [[UIColor redColor]CGColor];
    textField.textColor = ICON_BLUE_SOLID;
    textField.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.75];
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return textField;
}
-(UIInterfaceOrientation)orientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}
-(IBAction)textFieldDidChange:(ELTextField *)sender{
    
}
@end
