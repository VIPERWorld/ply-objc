//
//  PLYElement.h
//  PLYObject
//
//  Created by David Brown on 1/19/14.
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
 An array of properties for this element
 */
@property (readonly) NSArray *properties;

/**
 Add a property to the element
 @param newProperty the property to add
 @return nothing
 */
- (void)addProperty:(PLYProperty *)newProperty;


/**
 Read an element set from a string array.
 @param strings the array of string data to read from
 @param start the starting string position
 @return number of lines read for this element
 */
- (NSUInteger)readFromStrings:(NSArray *)strings startPosition:(NSUInteger)start;

@end
