//
//  PLYObjectTests.m
//  PLYObjectTests
//
//  Created by David Brown on 1/18/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PLYObject.h"
#import "PLYElement.h"

@interface PLYObjectTests : XCTestCase

@end

@implementation PLYObjectTests

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

- (void)testPLYObject
{
    
    NSURL *plyUrl = [[NSBundle bundleForClass:[PLYObjectTests class]] URLForResource:@"drill_shaft_zip" withExtension:@"ply"];
    PLYObject *drillShaftObject = [[PLYObject alloc] init];
    
    XCTAssertNotNil(drillShaftObject, @"PLYObject did not allocate properly.");
    
    [drillShaftObject readFromURL:plyUrl error:NULL];
    
    XCTAssertEqual([[drillShaftObject comments] count], (NSUInteger)0, @"PLYObject read wrong number of comments.");
    
    XCTAssertEqual([[[drillShaftObject elements] allKeys] count], (NSUInteger)2, @"PLYObject read wrong number of elements.");
    
    // TODO: need more detailed checks of these elements
    
    PLYElement *nextElement = [[drillShaftObject elements] objectForKey:@"vertex"];
    
    XCTAssertNotNil(nextElement, @"PLYObject provided unexpected nil for PLYElement.");
    XCTAssertEqual([nextElement count], (NSUInteger)881, @"vertex element did not contain expected element count");
    XCTAssertEqual([[nextElement properties] count], (NSUInteger)4, @"vertex element did not contain expected property count");
    
    nextElement = [[drillShaftObject elements] objectForKey:@"face"];
    
    XCTAssertNotNil(nextElement, @"PLYObject provided unexpected nil for PLYElement.");
    XCTAssertEqual([nextElement count], (NSUInteger)1288, @"face element did not contain expected element count");
    XCTAssertEqual([[nextElement properties] count], (NSUInteger)1, @"face element did not contain expected property count");

}
@end
