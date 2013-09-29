//
//  RequestVerifier.m
//  CommandCenter-iPad
//
//  Created by Denys Telezhkin on 25.09.13.
//  Copyright (c) 2013 MLSDev. All rights reserved.
//

#import "DTRequestVerifier.h"

@interface DTRequestVerifier()
@property (nonatomic, strong) NSURLRequest * request;
@end

@implementation DTRequestVerifier

+(instancetype)verifier
{
    DTRequestVerifier * verifier = [self new];

    verifier.HTTPMethod = @"GET";
    verifier.loggingEnabled = YES;
    
    return verifier;
}

-(BOOL)verifyRequest:(NSURLRequest *)request
{
    self.request = request;
    
    if (![request.HTTPMethod isEqualToString:self.HTTPMethod])
    {
        if (self.loggingEnabled)
        {
            NSLog(@"request: %@ HTTP method does not match expected value: %@",request,self.HTTPMethod);
        }
        return NO;
    }
    
    if (![[request.URL host] isEqualToString:self.host])
    {
        if (self.loggingEnabled)
        {
            NSLog(@"request host: %@ does not match expected value : %@",[[request URL] host],self.host);
        }
        return NO;
    }
    
    if (![[request.URL path] isEqualToString:self.path])
    {
        if (self.loggingEnabled)
        {
            NSLog(@"request path: %@ does not match expected value : %@",[[request URL] path],self.path);
        }
        return  NO;
    }
    
    if (![self verifyQueryParams:self.queryParams])
    {
        if (self.loggingEnabled)
        {
            NSLog(@"request: %@ query params do not match expected params : %@",request,self.queryParams);
        }
        return  NO;
    }
    
    if (![self verifyBodyParams:self.bodyParams])
    {
        return NO;
    }
    
    return YES;
}

-(BOOL)verifyQueryParams:(NSDictionary *)expectedQueryParams
{
    if (!expectedQueryParams)
    {
        return YES;
    }
    NSString * query = [self.request.URL query];
    
    NSArray * params = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary * receivedParams = [NSMutableDictionary dictionary];
    for (NSString * paramQuery in params)
    {
        NSArray * paramParts = [paramQuery componentsSeparatedByString:@"="];
        receivedParams[paramParts[0]] = [paramParts[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [self verifyParams:expectedQueryParams
                   withParams:receivedParams];
}

-(BOOL)verifyBodyParams:(NSDictionary *)expectedBodyDictionary
{
    if (!expectedBodyDictionary || ![expectedBodyDictionary count])
        return YES;
    
    if (![self.request HTTPBody])
    {
        return NO;
    }
    NSDictionary * params = [NSJSONSerialization JSONObjectWithData:[self.request HTTPBody]
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
    return  [self verifyParams:expectedBodyDictionary
                    withParams:params];
}

-(BOOL)verifyParams:(id)expectedParams
         withParams:(id)receivedParams
{
    BOOL compareResult = NO;
    if ([expectedParams isKindOfClass:[NSArray class]])
    {
        compareResult = [expectedParams isEqualToArray:receivedParams];
    }
    else if ([expectedParams isKindOfClass:[NSDictionary class]])
    {
        compareResult = [expectedParams isEqualToDictionary:receivedParams];
    }
    
    if (!compareResult && self.loggingEnabled)
    {
        NSLog(@"compare failed: %@ %@",expectedParams,receivedParams);
    }
    return compareResult;
}

@end