//
//  ELCompleteSummaryView.h
//  Fuel Logic
//
//  Created by Mike on 7/11/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELOrder.h"
@interface ELCompleteSummaryView : UIView
 @property (strong, nonatomic) ELOrder *order;
 @property (strong, nonatomic) STPCard *card;
@end
