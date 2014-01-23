//
//  PLYElement.h
//  PLYObject
//
//  Created by David Brown on 1/19/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple model class to contain data for elements in PLY files
 */
@interface PLYElement : NSObject
{
    NSString *_name;
    NSString *_elementString;
    NSUInteger _count;
    NSData *_data;
}

/**
 The name of the element
 */
@property (readwrite) NSString *name;


/**
 The element string conforming to the PLY file specification
 */
@property (readwrite) NSString *elementString;

/**
 The number of these elements in the PLY file
 */
@property (readonly) NSUInteger count;

/**
 An array of properties for this element ordered by their appearance
 in the PLY file header's element definition
 */
@property (readonly) NSArray *properties;

/**
 The binary data for this element
 */
@property (readonly) NSData *data;

/**
 Flag indicating a property of the element is a list
 */
@property (readonly, getter = isList) BOOL list;

/**
 The lengths of all element data values in bytes.  If the element has a list property,
 the first value in the array is the count length and the second is the data length.
 */
@property (readonly) NSArray *elementLengths;

/**
 The OpenGL data types of all element data values.  If the element has a list property,
 the first value in the array is the count GL type and the second is the data GL type.
 */
@property (readonly) NSArray *dataGLTypes;

/**
 The property names for this element.
 */
@property (readonly) NSArray *propertyNames;

/**
 Configures the element
 @param string the element declaration string from a PLY file
 @return an object initialized with the supplied element string
 */
- (id) initWithElementString:(NSString *)string;

/**
 Add a property described by the string to the element
 @param propertyString the property to add
 @return nothing
 */
- (void)addPropertyWithString:(NSString *)propertyString;

/**
 Read an element set from a string array.
 @param strings the array of string data to read from
 @param start the starting string position
 @return number of lines read for this element
 */
- (NSUInteger)readFromStrings:(NSArray *)strings startPosition:(NSUInteger)start;

@end
