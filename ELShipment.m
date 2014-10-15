//
//  ELShipment.m
//  Fuel Logic
//
//  Created by Mike on 9/29/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELShipment.h"
#import "PostmasterEntity.h"
#import "SBJson.h"
#import "OperationResult.h"
#import "RateResult.h"

@implementation PostmasterEntity(PostmasterEntity_Async)


+(void)executeRequest:(PostMasterRequest*)request completionHandler:(elRateCompletionHandler)handler{
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        RateResult *result = [RateResult alloc];
        if(connectionError){
            result = [result initWithCommonHTTPError:connectionError];
        }
        else
        {
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSMutableDictionary* jsonResponse =[jsonParser objectWithData:data];
            result = [[RateResult alloc]initWithJSON:jsonResponse];
            
        }
        handler(result,connectionError);
        
    }];
}
@end

@implementation ELShipment
+(void)ratesInBackground:(RateQueryMessage *)rateMessage completionHandler:(elRateCompletionHandler)handler
{
    PostMasterRequest *request = [PostMasterRequest rates:rateMessage];
    [self executeRequest:request completionHandler:handler];
}

@end
