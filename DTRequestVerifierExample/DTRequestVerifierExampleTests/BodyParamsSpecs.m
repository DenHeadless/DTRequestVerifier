//
//  BodyParamsSpecs.m
//  DTRequestVerifierExample
//
//  Created by Denys Telezhkin on 17.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RequestVerifierTestCase.h"

@interface BodyParamsSpecs : RequestVerifierTestCase

@end

@implementation BodyParamsSpecs

- (void)setUp
{
    [super setUp];
    
    self.verifier.host = @"www.foo.com";
    
    NSURL * url = [NSURL URLWithString:@"http://www.foo.com"];
    self.request = [NSMutableURLRequest requestWithURL:url];
}

-(void)testDefaultSerializationTypeRaw
{
    XCTAssert(self.verifier.bodySerializationType == DTBodySerializationTypeJSON);
}

#pragma mark - NSJSONSerialization

-(void)testJSONBodyMustBeValidated
{
    NSDictionary * params = @{@"query":@"bar",@"count":@"5"};
    
    [self.request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params
                                                              options:0 error:nil]];
    
    self.verifier.bodyParams = params;
    
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testNilBody
{
    NSDictionary * params = @{@"query":@"bar",@"count":@"5"};
    
    [self.request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params
                                                              options:0 error:nil]];
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testWrongBody
{
    NSDictionary * params =@{@"query":@"bar",@"count":@"5"};
    
    [self.request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params
                                                              options:0 error:nil]];
    
    self.verifier.bodyParams = @{@"query":@"bar"};
    
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

#pragma mark - NSPropertyListSerialization

-(void)testPlistXMLBodyMustBeValidated
{
    NSDictionary * params = @{@"query":@"bar",@"koo":@[@"foo"],@"count":@{@"boo":@"boo2"}, @"test":@5};
    NSString * error = nil;
    NSData * data =[NSPropertyListSerialization dataFromPropertyList:params
                                                              format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    [self.request setHTTPBody:data];
    
    self.verifier.bodyParams = params;
    self.verifier.bodySerializationType = DTBodySerializationTypePlist;
    
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testPlistBunaryFormatMustBeValidated
{
    NSDictionary * params = @{@"query":@"bar",@"koo":@[@"foo"],@"count":@{@"boo":@"boo2"}, @"test":@5};
    NSString * error = nil;
    NSData * data =[NSPropertyListSerialization dataFromPropertyList:params
                                                              format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
    [self.request setHTTPBody:data];
    
    self.verifier.bodyParams = params;
    self.verifier.bodySerializationType = DTBodySerializationTypePlist;
    
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testNilPlistBody
{
    NSDictionary * params = @{@"query":@"bar",@"count":@5};
    
    [self.request setHTTPBody:[NSPropertyListSerialization dataFromPropertyList:params
                                                                         format:NSPropertyListXMLFormat_v1_0 errorDescription:nil]];
    self.verifier.bodySerializationType = DTBodySerializationTypePlist;
    
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testWrongPlistBody
{
    NSDictionary * params =@{@"query":@"bar",@"count":@5};
    
    [self.request setHTTPBody:[NSPropertyListSerialization dataFromPropertyList:params
                                                                         format:NSPropertyListXMLFormat_v1_0 errorDescription:nil]];
    
    self.verifier.bodyParams = @{@"query":@"bar"};
    self.verifier.bodySerializationType = DTBodySerializationTypePlist;
    
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

#pragma mark - Raw parameters


-(void)testRawBodyMustBeValidated
{
    NSDictionary * params = @{@"query":@"bar",@"count":@"5"};
    
    NSData * data = [@"query=bar&count=5" dataUsingEncoding:NSUTF8StringEncoding];
    [self.request setHTTPBody:data];
    
    self.verifier.bodyParams = params;
    self.verifier.bodySerializationType = DTBodySerializationTypeRaw;
    
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testNilRawBody
{
    NSData * data = [@"query=bar&count=5" dataUsingEncoding:NSUTF8StringEncoding];
    [self.request setHTTPBody:data];
    
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testRawWrongBody
{
    NSData * data = [@"query=bar&count=5" dataUsingEncoding:NSUTF8StringEncoding];
    [self.request setHTTPBody:data];
    
    self.verifier.bodyParams = @{@"query":@"bar"};
    
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

@end
