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

@end
