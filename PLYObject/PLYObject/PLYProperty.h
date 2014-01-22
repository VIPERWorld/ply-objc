//
//  PLYProperty.h
//  PLYObject
//
//  Created by David Brown on 1/19/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLYProperty : NSObject

@property (readwrite) NSString *name;
@property (readwrite) NSString *type;
@property (readwrite) NSString *countType;
@property (readwrite) NSString *dataType;

/**
 Scans the property using the provided scanner into a provided data buffer
 @param buffer the buffer to load the data into
 @param lineScanner the scanner to use to get the data
 @return the number of bytes read by the scan operation
 */
- (NSUInteger)scanPropertyIntoBuffer:(uint8_t *)buffer usingScanner:(NSScanner *)lineScanner;

/**
 Provides the data sizes that are configured for the property
 @return the array of data sizes in the order they appeared in the header file
 */
- (NSArray *)dataSizes;

/**
 Provides the GL data types that are configured for the property
 @return the array of GL data types in the order they appeared in the header file
 */
- (NSArray *)GLtypes;

/**
 Provides the property names that are configured for the property, with list
 properties reporting the property name plus a sequential index number starting
 from 1.
 @return the array of property names
 */
- (NSArray *)propertyNames;

@end
