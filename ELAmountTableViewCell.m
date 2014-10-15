//
//  ELAmountTableViewCell.m
//  Fuel Logic
//
//  Created by Mike on 10/6/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELAmountTableViewCell.h"
#import "ELPaymentHeader.h"
@implementation ELAmountTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.amountLabel = [[UILabel alloc]init];
        [self.amountLabel makeMine];
        [self.contentView addSubview:self.amountLabel];
        

        
        self.amountTypeLabel = [[UILabel alloc]init];
        [self.amountTypeLabel makeMine];
        [self.contentView addSubview:self.amountTypeLabel];
        self.amountTypeLabel.textAlignment = NSTextAlignmentRight;
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.amountTypeLabel.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width-100,self.contentView.bounds.size.height);
    self.amountTypeLabel.center = CGPointMake((self.contentView.bounds.size.width-100)/2, self.contentView.bounds.size.height/2);
    
    self.amountLabel.bounds = CGRectMake(0, 0, 100,self.contentView.bounds.size.height);
    self.amountLabel.center = CGPointMake(self.contentView.bounds.size.width-50, self.contentView.bounds.size.height/2);
}
@end
