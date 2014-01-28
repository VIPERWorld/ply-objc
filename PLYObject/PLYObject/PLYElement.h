//
//  PLYElement.h
//  PLYObject
//
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLYProperty;

/**
 A simple model class to contain data for elements in PLY files
 */
@interface PLYElement : NSObject

/**
 The name of the element
 */
@property (readwrite) NSString *name;

/**
 The number of these elements in the PLY file
 */
@property (readwrite) NSUInteger count;

/**
 An array of properties for this element ordered by their appearance
 in the PLY file header's element definition
 */
@property (readonly) NSArray *properties;

/**
 The element string conforming to the PLY file specification
 */
@property (readwrite, strong) NSString *elementString;

/**
 The binary data for this element
 */
@property (readwrite) NSData *data;

/**
 Add a property described by the string to the element
 @param propertyString the property to add
 @return nothing
 */
- (void)addPropertyWithString:(NSString *)propertyString;

/**
 Add a property described by the provided object
 @param property the property to add
 @return nothing
 */
- (void)addProperty:(PLYProperty *)property;

/**
 Read an element set from a string array.
 @param strings the array of string data to read from
 @param start the starting string position
 @return number of lines read for this element
 */
- (NSUInteger)readFromStrings:(NSArray *)strings startIndex:(NSUInteger)start;

@end
