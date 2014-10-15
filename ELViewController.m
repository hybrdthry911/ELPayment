//
//  ELViewController.m
//  Fuel Logic
//
//  Created by Mike on 7/9/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//
#define TOP_SPACING 20
#define LEFT_OFFSET 10
#define ROW_HEIGHT 40
#define ROW_SPACING 5
//#define RIGHT_HALF_OFFSET (self.scrollView.bounds.size.width/2 + LEFT_OFFSET/2)


#define ROW_OFFSET TOP_SPACING+(ROW_HEIGHT+ROW_SPACING)
#define FULL_WIDTH (self.view.bounds.size.width-LEFT_OFFSET*2)
#define HALF_WIDTH ((self.view.bounds.size.width-LEFT_OFFSET*3)/2)
#define QUARTER_WIDTH ((self.view.bounds.size.width - LEFT_OFFSET*5)/4)



#import "ELViewController.h"
@interface ELViewController ()

@end

@implementation ELViewController
@synthesize activityView = _activityView;
@synthesize hudProgressView = _hudProgressView;
@synthesize activityLabel = _activityLabel;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.95];
    [self registerForKeyboardNotifications];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleViewTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.hudProgressView.bounds = CGRectMake(0, 0, 200, 80);
    self.hudProgressView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.activityView.bounds = CGRectMake(0, 0, 50, 50);
    self.activityView.center = CGPointMake(self.hudProgressView.bounds.size.width/2, 30);
    self.activityLabel.bounds = CGRectMake(0, 0, self.hudProgressView.bounds.size.width/2-5 , 25);
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
-(void)placeView:(UIView *)view withOffset:(ELViewXOffset)xOffset width:(ELViewWidth)width offset:(float)offset{
    
    switch (width) {
        case ELViewWidthFull:
            view.bounds = CGRectMake(0, 0, FULL_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthHalf:
            view.bounds = CGRectMake(0, 0, HALF_WIDTH, ROW_HEIGHT);
            break;
        case ELViewWidthQuarter:
            view.bounds = CGRectMake(0, 0, QUARTER_WIDTH, ROW_HEIGHT);
            break;
        default:
            break;
    }
    float y  = ROW_OFFSET*offset+ROW_HEIGHT/2;
    
    switch (xOffset) {
        case ELViewXOffsetNone:
            view.center = CGPointMake(LEFT_OFFSET + view.bounds.size.width/2, y);
            break;
        case ELViewXOffsetOneHalf:
            view.center = CGPointMake(self.view.bounds.size.width/2 + LEFT_OFFSET/2 + view.bounds.size.width/2, y);
            break;
        case ELViewXOffsetOneQuarter:
            view.center = CGPointMake(LEFT_OFFSET*2+QUARTER_WIDTH + view.bounds.size.width/2,y);
            break;
        case ELViewXOffsetThreeQuarter:
            view.center = CGPointMake(LEFT_OFFSET*4+QUARTER_WIDTH*3 + view.bounds.size.width/2,y);
            break;
        default:
            break;
    }
}

-(NSMutableAttributedString *)textFieldPlaceHolderWithString:(NSString *)string{
    
    NSMutableAttributedString *returnString =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",string]];
    [returnString addAttribute:NSForegroundColorAttributeName value:[[UIColor blackColor]colorWithAlphaComponent:.65] range:NSMakeRange(0, returnString.length)];
    [returnString addAttribute:NSFontAttributeName value:[UIFont fontWithName:MY_FONT_1 size:17] range:NSMakeRange(0, returnString.length)];
    return returnString;
}
-(ELTextField *)addNewTextFieldWithPlaceHolder:(NSString *)placeHolder{
    ELTextField *textField = [self addNewTextField];
    textField.attributedPlaceholder = [self textFieldPlaceHolderWithString:placeHolder];
    return textField;
}

-(IBAction)handleViewTap:(id)sender
{
    [self.currentTextField resignFirstResponder];
    self.currentTextField = nil;
}


#pragma mark Keyboard Methods
- (void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidChangeFrameNotification object:nil];
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    UIScrollView *scrollView = self.scrollViewToKeyBoardAdjust;
    
    NSDictionary* info;
    CGSize kbSize;
    if (aNotification) {
        info = [aNotification userInfo];
        kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        self.lastKeyboardSize = kbSize;
    }
    else kbSize = self.lastKeyboardSize;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, (self.lastKeyboardSize.height<self.lastKeyboardSize.width?self.lastKeyboardSize.height:self.lastKeyboardSize.width), 0);
    if (self.currentKeyboardTextField != self.currentTextField)
    {
        self.currentKeyboardTextField = self.currentTextField;
        return;
    }
    [self adjustForKeyboard];
}
-(void)adjustForKeyboard
{
    UIScrollView *scrollView = self.scrollViewToKeyBoardAdjust;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    if (_currentTextField.superview == scrollView)
    {
        self.currentKeyboardTextField = self.currentTextField;
        
        CGPoint recommendedTextFieldPoint = CGPointMake(0, self.view.bounds.size.height - (self.lastKeyboardSize.height<self.lastKeyboardSize.width?self.lastKeyboardSize.height:self.lastKeyboardSize.width) - 20);
        if (_currentTextField.frame.origin.y-scrollView.contentOffset.y > recommendedTextFieldPoint.y)
        {
            CGPoint scrollPoint = CGPointMake(0,  _currentTextField.frame.origin.y - recommendedTextFieldPoint.y);
            [UIView animateWithDuration:.25 animations:^{
                scrollView.contentOffset = scrollPoint;
            }];
        }
        else if(_currentTextField.frame.origin.y-scrollView.contentOffset.y < 35)
        {
            CGPoint scrollPoint = CGPointMake(0, _currentTextField.frame.origin.y - 15);
            [UIView animateWithDuration:.25 animations:^{
                scrollView.contentOffset = scrollPoint;
            }];
        }
    }
    self.currentKeyboardTextField = self.currentTextField;
}
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    UIScrollView *scrollView = self.scrollViewToKeyBoardAdjust;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    self.currentTextField = nil;
}

#pragma mark TextField Edit Methods
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    self.currentTextField = textField;
    if (self.currentTextField != self.currentKeyboardTextField) [self adjustForKeyboard];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isKindOfClass:[ELTextField class]]) {
        if ([(ELTextField *)textField isEmailField]) textField.text = textField.text.lowercaseString;
    }
    self.currentTextField = nil;
}
-(void)textFieldDidChange:(ELTextField *)textField{
    textField.layer.borderColor = [ICON_BLUE_SOLID CGColor];
    if ((textField.required && !textField.text.length)|| textField.text.length < textField.requiredLength) textField.layer.borderColor = [UIColor redColor].CGColor;
    if (textField.isEmailField && ![self validateEmail:textField.text]) textField.layer.borderColor =  [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
    
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping; //set the line break mode
    NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:textField.font,NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil];
    CGSize size = [textField.text boundingRectWithSize:CGSizeMake(1000, 50)
                                               options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attrDict context:nil].size;
    textField.textAlignment = NSTextAlignmentLeft;
    if (size.width >= textField.bounds.size.width-20)
        textField.textAlignment = NSTextAlignmentRight;
}
-(BOOL)validateEmail:(NSString *)candidate
{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
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
-(void)showActivityView
{
    [self.view addSubview:self.hudProgressView];
    [self.activityView startAnimating];
}
-(void)hideActivityView
{
    [self.activityView stopAnimating];
    [self.hudProgressView removeFromSuperview];
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
@end


#pragma mark ELTextfield implementation
@implementation ELTextField
-(id)init
{
    
    if (self = [super init]) {
        self.required = NO;
        self.requiredLength = 0;
        self.centerPlaceholder = NO;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.required = NO;
        self.requiredLength = 0;
        self.centerPlaceholder = NO;
        // Initialization code
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    
    CGRect rect;
    
    if (!self.attributedPlaceholder || !self.attributedPlaceholder.length || !self.centerPlaceholder) rect = CGRectInset(bounds, 8, 8);
    else
    {
        

        CGSize sizeOfPlaceHolder = self.text.length?[self.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:MY_FONT_2 size:18],NSForegroundColorAttributeName:ICON_BLUE_SOLID}] :[self.attributedPlaceholder size];
        
        
        if (sizeOfPlaceHolder.width>=bounds.size.width-16)
            rect = CGRectInset(bounds, 8, 8);
        
        else if (self.secureTextEntry)
            rect = CGRectInset(bounds,
                               (bounds.size.width - sizeOfPlaceHolder.width)/2-(self.text.length?self.text.length*1.2:.5),
                               8);
        
        else rect = CGRectInset(bounds,
                           (bounds.size.width - sizeOfPlaceHolder.width)/2-2,
                           8);
    }
    return rect;
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    CGRect rect;
    
    if (!self.text || !self.centerPlaceholder) rect = CGRectInset(bounds, 8, 8);
    else
    {
        
        
        CGSize sizeOfPlaceHolder = self.text.length?[self.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:MY_FONT_2 size:18],NSForegroundColorAttributeName:ICON_BLUE_SOLID}] :[self.attributedPlaceholder size];
        
        
        if (sizeOfPlaceHolder.width>=bounds.size.width-16)
            rect = CGRectInset(bounds, 8, 8);
        
        else if (self.secureTextEntry)
            rect = CGRectInset(bounds,
                               (bounds.size.width - sizeOfPlaceHolder.width)/2-(self.text.length?self.text.length*1.2:.5),
                               8);
        
        else rect = CGRectInset(bounds,
                                (bounds.size.width - sizeOfPlaceHolder.width)/2-2,
                                8);
    }
    return rect;
}
//
//-(void)drawTextInRect:(CGRect)rect
//{
//    [ICON_BLUE_SOLID setFill];
//    if (self.secureTextEntry) {
//        [@"*******" drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont fontWithName:MY_FONT_2 size:17],NSForegroundColorAttributeName:ICON_BLUE_SOLID}];
//    }
//    else [self.text drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont fontWithName:MY_FONT_2 size:17],NSForegroundColorAttributeName:ICON_BLUE_SOLID}];
//
//}
//
- (void)drawPlaceholderInRect:(CGRect)rect {
    // Set to any color of your preference
    // We use self.font.pointSize in order to match the input text's font size
    
    [self.placeholder drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont fontWithName:MY_FONT_1 size:17],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
}
@end

