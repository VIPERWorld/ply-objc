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
#import "PLYProperty.h"

@interface PLYObjectTests : XCTestCase

@end

@implementation PLYObjectTests
{
    NSMutableArray *_testVectorArray;
}

NSString *const kTVFileName = @"fileName";
NSString *const kTVFileURL = @"fileURL";
NSString *const kTVPlyObject = @"plyObject";
NSString *const kTVCommentCount = @"commentCount";
NSString *const kTVElementCount = @"elementCount";
NSString *const kTVElementNames = @"elementNames";
NSString *const kTVElementDataLengths = @"elementDataLengths";
NSString *const kTVPropertyNames = @"propertyNames";

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
                                                                    kTVElementDataLengths: @[ @14096, @15456 ],
                                                                    kTVPropertyNames:
                                                                        @[ @[ @"x", @"y", @"z", @"confidence" ],
                                                                           @[ @"vertex_indices" ] ]
                                                                    } ];
    
    [_testVectorArray addObject:aTestVector];
    
    aTestVector = [NSMutableDictionary dictionaryWithDictionary: @{ kTVFileName: @"dragon_vrip_res4",
                                                                    kTVCommentCount: @1,
                                                                    kTVElementCount: @2,
                                                                    kTVElementNames: @[ @"vertex", @"face" ],
                                                                    kTVElementDataLengths: @[ @62460, @133224 ],
                                                                    kTVPropertyNames:
                                                                        @[ @[ @"x", @"y", @"z" ],
                                                                           @[ @"vertex_indices" ] ]
                                                                    } ];
    
    [_testVectorArray addObject:aTestVector];

    aTestVector = [NSMutableDictionary dictionaryWithDictionary: @{ kTVFileName: @"airplane",
                                                                    kTVCommentCount: @0,
                                                                    kTVElementCount: @2,
                                                                    kTVElementNames: @[ @"vertex", @"face" ],
                                                                    kTVElementDataLengths: @[ @16020, @29424 ],
                                                                    kTVPropertyNames:
                                                                        @[ @[ @"x", @"y", @"z" ],
                                                                           @[ @"vertex_indices" ] ]
                                                                    } ];
    
    [_testVectorArray addObject:aTestVector];
    
    aTestVector = [NSMutableDictionary dictionaryWithDictionary: @{ kTVFileName: @"big_porsche",
                                                                    kTVCommentCount: @0,
                                                                    kTVElementCount: @2,
                                                                    kTVElementNames: @[ @"vertex", @"face" ],
                                                                    kTVElementDataLengths: @[ @62964, @125688 ],
                                                                    kTVPropertyNames:
                                                                        @[ @[ @"x", @"y", @"z" ],
                                                                           @[ @"vertex_indices" ] ]
                                                                    } ];
    
    [_testVectorArray addObject:aTestVector];
    
    aTestVector = [NSMutableDictionary dictionaryWithDictionary: @{ kTVFileName: @"dodecahedron",
                                                                    kTVCommentCount: @1,
                                                                    kTVElementCount: @2,
                                                                    kTVElementNames: @[ @"vertex", @"face" ],
                                                                    kTVElementDataLengths: @[ @240, @240 ],
                                                                    kTVPropertyNames:
                                                                        @[ @[ @"x", @"y", @"z" ],
                                                                           @[ @"vertex_indices" ] ]
                                                                    } ];
    
    [_testVectorArray addObject:aTestVector];
    
    aTestVector = [NSMutableDictionary dictionaryWithDictionary: @{ kTVFileName: @"cube",
                                                                    kTVCommentCount: @2,
                                                                    kTVElementCount: @3,
                                                                    kTVElementNames: @[ @"vertex", @"face", @"edge" ],
                                                                    kTVElementDataLengths: @[ @120, @104, @55  ],
                                                                    kTVPropertyNames:
                                                                        @[ @[ @"x", @"y", @"z", @"red", @"green", @"blue" ],
                                                                           @[ @"vertex_index" ],
                                                                           @[ @"vertex1", @"vertex2", @"red", @"green", @"blue" ] ]
                                                                    } ];
    
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

        NSArray *testElements = [testObject elements];
        XCTAssertEqual([testElements count], trueElementCount,
                       @"File %@ PLYObject read wrong number of elements.",
                       [aTestVector objectForKey:kTVFileName]);
        
        NSString *trueElementName = nil;
        NSArray *trueElementNames = [aTestVector objectForKey:kTVElementNames];
        
        for( trueElementName in trueElementNames ) {
            
            PLYElement *testElement = [testObject getElementWithName:trueElementName];
            XCTAssertNotNil(testElement, @"Element %@ could not be found.",trueElementName);
            
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
            
            PLYElement *testElement = [testObject getElementWithName:trueElementName];
            NSData *testData = [testElement data];

            XCTAssertEqual( [testData length], trueElementDataLength,
                           @"File %@ element %@ data length does not match.",
                           [aTestVector objectForKey:kTVFileName],trueElementName);
            
        }
    }
}

- (void) testPropertyNames
{
    NSMutableDictionary *aTestVector = nil;
    PLYObject *testObject = nil;
    
    for( aTestVector in _testVectorArray ) {
        testObject = [aTestVector objectForKey:kTVPlyObject];
        
        NSString *trueElementName = nil;
        NSArray *trueElementNames = [aTestVector objectForKey:kTVElementNames];
        NSArray *trueAllPropertyNames = [aTestVector objectForKey:kTVPropertyNames];
        
        for( trueElementName in trueElementNames ) {
            
            NSUInteger elementIndex = [trueElementNames indexOfObject:trueElementName];
            NSArray *truePropertyNames = [trueAllPropertyNames objectAtIndex:elementIndex];
            
            PLYElement *testElement = [testObject getElementWithName:trueElementName];
            NSArray *testProperties = [testElement properties];

            XCTAssertEqual([testProperties count], [truePropertyNames count],
                           @"File %@ element %@, wrong number of properties read.",
                           [aTestVector objectForKey:kTVFileName],
                           trueElementName);
            
            PLYProperty *testProperty = nil;
            
            for( testProperty in testProperties ) {
                
                XCTAssertNotEqual([truePropertyNames indexOfObject:testProperty.name], NSNotFound,
                                  @"File %@ element %@, read unexpected property name %@.",
                                  [aTestVector objectForKey:kTVFileName],
                                  trueElementName, testProperty.name);

            }
            
            

            
        }
    }
}

@end
