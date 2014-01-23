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
#import "OpenGL/gl3.h"

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
    
    NSData *elementData = [drillShaftObject dataForElementName:@"vertex"];
    
    XCTAssertNotNil(elementData, @"PLYObject provided unepected nil data for vertex element");
    XCTAssertEqual([elementData length], (NSUInteger)14096, @"vertex element data object was incorrect length");

    NSArray *elementLengths = [drillShaftObject lengthsForElementName:@"vertex"];
    
    XCTAssertNotNil(elementLengths, @"PLYObject provided unexpected nil sizes array for vertex element");
    XCTAssertEqual([elementLengths count], (NSUInteger)4, @"PLYObject read wrong number of properties for vertex element");
    NSNumber *length = nil;
    for( length in elementLengths ) {
        XCTAssertEqual([length unsignedIntegerValue], (NSUInteger)4, @"PLYObject read wrong data size for propety on vertex element");
    }

    NSArray *elementGlTypes = [drillShaftObject glTypesForElementName:@"vertex"];
    XCTAssertNotNil(elementGlTypes, @"PLYObject provided unexpected nil data for vertex element");
    NSNumber *glType = nil;
    for( glType in elementGlTypes ) {
        XCTAssertEqual([glType unsignedIntegerValue], (NSUInteger)GL_FLOAT, @"PLYObject provided wrong GLtype for vertex element");
    }
    
    NSArray *propertyNames = [drillShaftObject propertyNamesForElementName:@"vertex"];
    XCTAssertNotNil(propertyNames, @"PLYObject provided unexpected nil data for vertex element");
    XCTAssertEqualObjects(propertyNames[0],@"x",@"PLYObject provided wrong property name for vertex element");
    XCTAssertEqualObjects(propertyNames[1],@"y",@"PLYObject provided wrong property name for vertex element");
    XCTAssertEqualObjects(propertyNames[2],@"z",@"PLYObject provided wrong property name for vertex element");
    XCTAssertEqualObjects(propertyNames[3],@"confidence",@"PLYObject provided wrong property name for vertex element");
    
}
@end
