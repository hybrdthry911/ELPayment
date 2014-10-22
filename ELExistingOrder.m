//
//  ELExistingOrder.m
//  Fuel Logic
//
//  Created by Mike on 10/5/14.
//  Copyright (c) 2014 Michael Cowley. All rights reserved.
//

#import "ELExistingOrder.h"
#import <Parse/PFObject+Subclass.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

@interface ELExistingOrder()


@end


@implementation ELExistingOrder

@dynamic email, stripeChargeIdentifier, billingInformation, status, stripeCustomerId, shippingCarrier, trackingNumber, shipping, orderNumber, subTotal, total, amountRefunded, discount, tax, customer, lineItems, notes, cardId, ipAddress, fingerprint;
 @synthesize stripeCustomer = _stripeCustomer;
 @synthesize card = _card;

+(NSString *)parseClassName
{
    return @"Order";
}
-(void)emailCustomerOrderConfirmation:(PFBooleanResultBlock)handler
{
    [PFCloud callFunctionInBackground:@"emailCustomerInvoiceFromOrder"
                       withParameters:@{
                                        @"objectId":self.objectId
                                        }
                                block:^(id object, NSError *error) {
                                    if (handler) {
                                        handler(!error,error);
                                    }
    }];
}
-(void)emailBusinessOrderConfirmation:(PFBooleanResultBlock)handler
{
    [PFCloud callFunctionInBackground:@"emailBusinessInvoiceFromOrder"
                       withParameters:@{
                                        @"objectId":self.objectId
                                        }
                                block:^(id object, NSError *error) {
                                    if (handler) {
                                        handler(!error,error);
                                    }
    }];
}
-(void)emailCustomerTrackingFromOrder:(PFBooleanResultBlock)handler
{
    [PFCloud callFunctionInBackground:@"emailCustomerTrackingFromOrder"
                       withParameters:@{
                                        @"objectId":self.objectId
                                        }
                                block:^(id object, NSError *error) {
                                    if (handler) {
                                        handler(!error,error);
                                    }
    }];    
}
+(void)nextOrderNumber:(PFIntegerResultBlock)handler{
    [PFCloud callFunctionInBackground:@"nextOrderNumber"
                       withParameters:@{
                                        }
                                block:^(id object, NSError *error) {
        handler([object intValue],error);
    }];
}
-(void)sendMessage:(NSString *)message toCustomerWithCompletion:(PFBooleanResultBlock)handler{
    [PFCloud callFunctionInBackground:@"emailCustomerMessage"
                       withParameters:@{
                                        @"message":message,
                                        @"objectId":self.objectId
                                        }
                                block:^(id object, NSError *error) {
                                    if (handler) {
                                        handler(!error,error);
                                    }
                                }];
}

+ (NSString *)hostname
{
    char baseHostName[256];
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '\0';
    
#if !TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#else
    return [NSString stringWithFormat:@"%s", baseHostName];
#endif
}

// return IP Address
+ (void)localIPAddress:(ELStringCompletionHandler)handler
{
    
    // Defines the webservice URL
    NSURL *URL = [NSURL URLWithString:@"http://ip-api.com/json"];
    
    // Start Connection
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
    
    // Define the JSON header
    [httpClient setDefaultHeader:@"Accept" value:@"text/json"];
    
    // Set the Request
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"" parameters:nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        handler([JSON valueForKey:@"query"],nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        handler(nil,error);
    }];
    
    // Run the Request
    [operation start];
}
@end
