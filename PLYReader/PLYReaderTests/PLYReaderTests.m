//
//  PLYReaderTests.m
//  PLYReaderTests
//
//  Created by David Brown on 1/15/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PLYReader.h"
#include "asl.h"

@interface PLYReaderTests : XCTestCase

@end

@implementation PLYReaderTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
//    asl_add_log_file(NULL, STDERR_FILENO);
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit
{
    PLYReader *testPLYReader = nil;
    
    
    testPLYReader = [[PLYReader alloc] init];
    
    XCTAssertNil([testPLYReader PLYDictionary], @"PLYReader returned a dictionary without being provided data!");

    NSURL *plyUrl = [[NSBundle bundleForClass:[PLYReaderTests class]] URLForResource:@"drill_shaft_zip" withExtension:@"ply"];
    testPLYReader = [testPLYReader initWithURL:plyUrl];
    
    NSDictionary *myPlyDictionary = [testPLYReader PLYDictionary];
    
    XCTAssertNotNil(myPlyDictionary, @"PLYReader returned no dictionary when data was supplied!");
    
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testHeader
{
    PLYReader *testPLYReader = nil;
    
    NSURL *plyUrl = [[NSBundle bundleForClass:[PLYReaderTests class]] URLForResource:@"drill_shaft_zip" withExtension:@"ply"];
    testPLYReader = [[PLYReader alloc] initWithURL:plyUrl];
    NSDictionary *myPlyDictionary = [testPLYReader PLYDictionary];

    NSDictionary *headerDictionary = [myPlyDictionary objectForKey:kPLYReaderHeaderKey];
    
    XCTAssertNotNil(headerDictionary,
                    @"PLYReader returned no header dictionary when data was supplied!");
    
    NSArray *commentArray = [headerDictionary objectForKey:kPLYReaderCommentKey];
    
    XCTAssertNotNil(commentArray, @"Comment array should have been provided.");
    XCTAssertEqual([commentArray count], (NSUInteger)0, @"There are no comments in %@.",plyUrl);
    
    NSArray *elementArray = [headerDictionary objectForKey:kPLYReaderElementsKey];
    
    XCTAssertNotNil(elementArray, @"Element array should have been provided.");
    XCTAssertEqual([elementArray count], (NSUInteger)2, @"There are 2 elements in %@",plyUrl);
    
    
}

@end
