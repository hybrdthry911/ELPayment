//
//  ELShipment.h
//  Fuel Logic
//
//  Created by Mike on 9/29/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "Shipment.h"

@class RateResult;
typedef void (^elRateCompletionHandler)(RateResult *result, NSError* error);

@interface PostmasterEntity(PostmasterEntity_Async)
+(void)executeRequest:(PostMasterRequest*)request completionHandler:(elRateCompletionHandler)handler;
@end


@interface ELShipment : Shipment
+(void)ratesInBackground:(RateQueryMessage *)rateMessage completionHandler:(elRateCompletionHandler)handler;
@end
