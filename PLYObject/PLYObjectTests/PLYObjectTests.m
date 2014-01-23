//
//  PLYObjectTests.m
//  PLYObjectTests
//
//  Created by David Brown on 1/18/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

/**
 Data files from: http://people.sc.fsu.edu/~jburkardt/data/ply/ply.html
 
 */

#import <XCTest/XCTest.h>
#import "PLYObject.h"
#import "PLYElement.h"
#import "OpenGL/gl3.h"

@interface PLYObjectTests : XCTestCase

@end

@implementation PLYObjectTests
{
    NSURL *_drillPlyUrl;
    PLYObject *_drillShaftObject;
    NSMutableArray *_testVectorArray;
}

NSString *const kTVFileName = @"fileName";
NSString *const kTVFileURL = @"fileURL";
NSString *const kTVPlyObject = @"plyObject";
NSString *const kTVCommentCount = @"commentCount";
NSString *const kTVElementCount = @"elementCount";
NSString *const kTVElementNames = @"elementNames";
NSString *const kTVElementDataLengths = @"elementDataLengths";

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    _testVectorArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *aTestVector = nil;
    
    aTestVector = [NSMutableDictionary dictionaryWithDictionary: @{ kTVFileName: @"drill_shaft_zip",
                                                                    kTVCommentCount: @0,
                                                                    kTVElementCount: @2,
                                                                    kTVElementNames: @[ @"vertex", @"face" ],
                                                                    kTVElementDataLengths: @[ @14096, @15456 ] } ];
    
    [_testVectorArray addObject:aTestVector];
    
    aTestVector = [NSMutableDictionary dictionaryWithDictionary: @{ kTVFileName: @"dragon_vrip_res4",
                                                                    kTVCommentCount: @1,
                                                                    kTVElementCount: @2,
                                                                    kTVElementNames: @[ @"vertex", @"face" ],
                                                                    kTVElementDataLengths: @[ @62460, @133224 ] } ];
    
    [_testVectorArray addObject:aTestVector];

    NSBundle *testClassBundle = [NSBundle bundleForClass:[PLYObjectTests class]];
    
    // set up URLs for each item
    for( aTestVector in _testVectorArray ) {
    
        NSURL *plyUrl = [testClassBundle URLForResource:[aTestVector objectForKey:kTVFileName]
                                          withExtension:@"ply"];
        
        XCTAssertNotNil(plyUrl, @"Could not make URL for file %@",[aTestVector objectForKey:kTVFileName]);
        
        [aTestVector setObject:plyUrl forKey:kTVFileURL];
        
        PLYObject *aPlyObject = [[PLYObject alloc] init];

        XCTAssertTrue([aPlyObject readFromURL:plyUrl error:NULL],@"PLYObject failed reading URL %@",plyUrl);
        [aTestVector setObject:aPlyObject forKey:kTVPlyObject];
        
    }
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReadFromUrl
{
    // TBD
}

- (void)testComments
{
    NSMutableDictionary *aTestVector = nil;
    PLYObject *testObject = nil;
    
    for( aTestVector in _testVectorArray ) {
        testObject = [aTestVector objectForKey:kTVPlyObject];
        NSUInteger trueCommentCount = [[aTestVector objectForKey:kTVCommentCount] unsignedIntegerValue];
        NSUInteger testCommentCount = [[testObject comments] count];
        
        XCTAssertEqual(testCommentCount, trueCommentCount, @"PLYObject read wrong number of comments.");
    }
}

- (void) testElements
{
    NSMutableDictionary *aTestVector = nil;
    PLYObject *testObject = nil;

    for( aTestVector in _testVectorArray ) {
        testObject = [aTestVector objectForKey:kTVPlyObject];
        NSUInteger trueElementCount = [[aTestVector objectForKey:kTVElementCount] unsignedIntegerValue];

        NSDictionary *testElements = [testObject elements];
        XCTAssertEqual([[testElements allKeys] count], trueElementCount,
                       @"File %@ PLYObject read wrong number of elements.",
                       [aTestVector objectForKey:kTVFileName]);
        
        NSString *trueElementName = nil;
        NSArray *trueElementNames = [aTestVector objectForKey:kTVElementNames];
        
        for( trueElementName in trueElementNames ) {
            
            id testElementObj = [testElements objectForKey:trueElementName];
            XCTAssertTrue([testElementObj isKindOfClass:[PLYElement class]], @"Element %@ is not a PLYElement class",trueElementName);
            
        }
    }
}

- (void) testData
{
    NSMutableDictionary *aTestVector = nil;
    PLYObject *testObject = nil;
    
    for( aTestVector in _testVectorArray ) {
        testObject = [aTestVector objectForKey:kTVPlyObject];

        NSString *trueElementName = nil;
        NSArray *trueElementNames = [aTestVector objectForKey:kTVElementNames];
        NSArray *trueElementDataLengths = [aTestVector objectForKey:kTVElementDataLengths];
        
        for( trueElementName in trueElementNames ) {

            NSUInteger elementIndex = [trueElementNames indexOfObject:trueElementName];
            NSUInteger trueElementDataLength = [[trueElementDataLengths objectAtIndex:elementIndex] unsignedIntegerValue];
            
            NSData *testData = [testObject dataForElementName:trueElementName];

            XCTAssertEqual( [testData length], trueElementDataLength,
                           @"File %@ element %@ data length does not match.",
                           [aTestVector objectForKey:kTVFileName],trueElementName);
            
        }
    }
}

- (void) testLengths
{
    // test for matching data length arrays
}

- (void) testGlTypes
{
    // test for matching GL data type arrays
}

- (void) testPropertyNames
{
    // test for number of properties
    // test for matching property names
}

@end
