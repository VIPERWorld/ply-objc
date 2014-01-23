//
//  PLYProperty.h
//  PLYObject
//
//  Created by David Brown on 1/19/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLYProperty : NSObject
{
    NSString *_propertyString;
}

/**
 The string value of the property name
 */
@property (readonly) NSString *name;

/**
 The property string conforming to the PLY file specification
 */
@property (readwrite) NSString *propertyString;

/**
 Flag indicating the property is a list
 */
@property (readonly, getter = isList) BOOL list;

/**
 The length of each data value in bytes
 */
@property (readonly) NSUInteger dataLength;

/**
 The length of each count value in bytes
 */
@property (readonly) NSUInteger countLength;

/**
 The OpenGL data type of each data value
 */
@property (readonly) GLenum dataGLType;

/**
 The OpenGL data type of each count value
 */
@property (readonly) GLenum countGLType;



/**
 Configures the property
 @param string the property declaration string from a PLY file
 @return an object initialized with the supplied property string
 */
- (id) initWithPropertyString:(NSString *)string;

/**
 Scans the property using the provided scanner into a provided data buffer
 @param buffer the buffer to load the data into
 @param lineScanner the scanner to use to get the data
 @return the number of bytes read by the scan operation
 */
- (NSUInteger)scanPropertyIntoBuffer:(uint8_t *)buffer usingScanner:(NSScanner *)lineScanner;

@end
