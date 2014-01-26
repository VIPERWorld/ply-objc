//
//  PLYProperty.h
//  PLYObject
//
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PLYPropertyTypeEnum {
    PLYPropertyTypeInvalid = 0,
    PLYPropertyTypeScalar = 1,
    PLYPropertyTypeList = 2
} PLYPropertyType;

typedef enum PLYDataTypeEnum {
    PLYDataTypeInvalid = 0,
    PLYDataTypeChar = 1,
    PLYDataTypeUchar = 2,
    PLYDataTypeShort = 3,
    PLYDataTypeUshort = 4,
    PLYDataTypeInt = 5,
    PLYDataTypeUint = 6,
    PLYDataTypeFloat = 7,
    PLYDataTypeDouble = 8
} PLYDataType;

@interface PLYProperty : NSObject

/**
 The string value of the property name
 */
@property (readwrite) NSString *name;

/**
 The property type
 */
@property (readwrite) PLYPropertyType propertyType;

/**
 The data type
 */
@property (readwrite) PLYDataType dataType;

/**
 The count type
 */
@property (readwrite) PLYDataType countType;

/**
 The property string conforming to the PLY file specification
 */
@property (readwrite) NSString *propertyString;


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
