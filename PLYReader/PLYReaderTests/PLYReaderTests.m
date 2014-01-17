//
//  PLYReaderTests.m
//  PLYReaderTests
//
//  Created by David Brown on 1/15/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PLYReader.h"

@interface PLYReaderTests : XCTestCase

@end

@implementation PLYReaderTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

@end
