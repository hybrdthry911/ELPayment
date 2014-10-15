//
//  ELPumpTableViewCell.m
//  Fuel Logic
//
//  Created by Mike on 6/11/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELPaymentHeader.h"

@interface ELPumpTableViewCell()

@end


@implementation ELPumpTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.addRemoveIcon = [[UIButton alloc]init];
        [self.contentView addSubview:self.addRemoveIcon];
        self.addRemoveIcon.userInteractionEnabled = YES;
        self.addRemoveIcon.hidden = YES;
        
        self.thumbnail = [[PFImageView alloc]init];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;

        
        
        self.cartIcon = [[UIButton alloc]init];
        [self.cartIcon setImage:[UIImage imageNamed:@"cartIcon2.png"] forState:UIControlStateNormal];
        self.cartIcon.userInteractionEnabled = YES;
        
        
        self.textLabel.textColor = ICON_BLUE_SOLID;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.numberOfLines = 1;
        self.textLabel.font =[UIFont fontWithName:MY_FONT_2 size:18];
        
        self.detailTextLabel.textColor = ICON_BLUE_SOLID;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        
        // Initialization code
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.addRemoveIcon.bounds = CGRectMake(0, 0, self.contentView.bounds.size.height*.75, self.contentView.bounds.size.height*.75);
    self.addRemoveIcon.center = CGPointMake(self.contentView.bounds.size.height/ (self.addRemoveIcon.hidden ? -2:2), self.contentView.bounds.size.height/2);

    self.thumbnail.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    self.thumbnail.center = CGPointMake(self.contentView.bounds.size.width/2, self.contentView.bounds.size.height/2);
    self.cartIcon.bounds = CGRectMake(0, 0, self.contentView.bounds.size.height*.8, self.contentView.bounds.size.height*.8);
    self.cartIcon.center = CGPointMake(self.contentView.bounds.size.width - self.contentView.bounds.size.height/2, self.contentView.bounds.size.height/2);

    self.textLabel.bounds = CGRectMake(0, 0, (self.contentView.bounds.size.width - self.contentView.bounds.size.height -10), self.contentView.bounds.size.height);
    self.textLabel.center = CGPointMake(self.textLabel.bounds.size.width/2+5, self.contentView.bounds.size.height/2);
    if (!self.addRemoveIcon.hidden)
    {
        [UIView animateWithDuration:.001 animations:
         ^{
             self.textLabel.bounds = CGRectMake(0, 0, (self.contentView.bounds.size.width - self.contentView.bounds.size.height*2.5), self.contentView.bounds.size.height);
             self.textLabel.center = CGPointMake(self.textLabel.bounds.size.width/2+self.bounds.size.height, self.contentView.bounds.size.height/2);
         }
          completion:^(BOOL finished)
         {
         }];
    }
}
-(void)showThumbnail
{
    [self.contentView insertSubview:self.thumbnail belowSubview:self.textLabel];
    self.thumbnail.alpha = .10;
}

-(void)hideAddRemoveIcon
{
    self.addRemoveIcon.hidden = YES;
    [self layoutSubviews];
}
-(void)showAddIcon{
    self.addRemoveIcon.hidden = NO;
    [UIView animateWithDuration:.25 animations:
     ^{
         [self.addRemoveIcon setImage:[UIImage imageNamed:@"plusIcon.png"] forState:UIControlStateNormal];
     }
                     completion:^(BOOL finished)
     {
     }];

    [self layoutSubviews];
}
-(void)showRemoveIcon
{
    self.addRemoveIcon.hidden = NO;
    [UIView animateWithDuration:.25 animations:
     ^{
         [self.addRemoveIcon setImage:[UIImage imageNamed:@"minusIcon.png"] forState:UIControlStateNormal];
     }
                     completion:^(BOOL finished)
     {  
     }];

    [self layoutSubviews];
}
-(void)showCart:(BOOL)on
{
    if (on) [self.contentView addSubview:self.cartIcon];
    else [self.cartIcon removeFromSuperview];
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
