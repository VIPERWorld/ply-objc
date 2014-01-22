//
//  PLYProperty.m
//  PLYObject
//
//  Created by David Brown on 1/19/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYProperty.h"

@implementation PLYProperty

NSString *const kPLYDataTypeChar = @"char";
NSString *const kPLYDataTypeUchar = @"uchar";
NSString *const kPLYDataTypeShort = @"short";
NSString *const kPLYDataTypeUshort = @"ushort";
NSString *const kPLYDataTypeInt = @"int";
NSString *const kPLYDataTypeUint = @"uint";
NSString *const kPLYDataTypeFloat = @"float";
NSString *const kPLYDataTypeDouble = @"double";
NSString *const kPLYDataTypeList = @"list";

- (NSUInteger)scanPropertyIntoBuffer:(uint8_t *)buffer usingScanner:(NSScanner *)lineScanner {
    
    NSUInteger totalReadBytes = 0;
    
    if( buffer == NULL || lineScanner == nil ) {
        totalReadBytes = 0;
    } else {
        
        if( [_type isEqualToString:kPLYDataTypeList] ) {
            // list properties contain a count followed by the data values
            NSInteger listCount;
            NSUInteger idx, readBytes;
            double scanDouble;
            uint8_t *bp = buffer;
            
            // scan in the list count
            //      TODO:   either keep list count or check that all list counts for a
            //              given property are consistent
            [lineScanner scanInteger:&listCount];
            
            // for each data item that follows, scan it in as a double, and then cast it
            // to the appropriate data type and store it in the buffer
            for( idx=0; idx < listCount; idx++ ) {
                [lineScanner scanDouble:&scanDouble];
                readBytes = [self convertFromDouble:scanDouble toType:_dataType inBuffer:bp];
                bp += readBytes;
                totalReadBytes += readBytes;
            }
            
        } else {

            double scanDouble;
            
            // scan in the value as a double, and then cast it to the appropriate type and
            // add it to the memory buffer.
            [lineScanner scanDouble:&scanDouble];

            totalReadBytes = [self convertFromDouble:scanDouble toType:_type inBuffer:buffer];
            
        }
    }
    
    return totalReadBytes;
}

/**
 Converts the supplied double value to the correct property type (specified by the ivar 'type')
 and puts the result into the buffer.
 @param doubleValue the double value to convert
 @param toType a string containing the PLY data type
 @param buffer the buffer to convert the double value into
 @return the byte length of the converted data
 */
- (NSUInteger)convertFromDouble:(double)doubleValue toType:(NSString *)toType inBuffer:(uint8_t *)buffer
{
    NSUInteger readBytes = 0;
    
    if( [toType isEqualToString:kPLYDataTypeChar] ) {
        *(int8_t *)buffer = (int8_t)doubleValue;
        readBytes = 1;
    } else if( [toType isEqualToString:kPLYDataTypeUchar] ) {
        *(uint8_t *)buffer = (uint8_t)doubleValue;
        readBytes = 1;
    } else if( [toType isEqualToString:kPLYDataTypeShort] ) {
        *(int16_t *)buffer = (uint16_t)doubleValue;
        readBytes = 2;
    } else if( [toType isEqualToString:kPLYDataTypeUshort] ) {
        *(uint16_t *)buffer = (uint16_t)doubleValue;
        readBytes = 2;
    } else if( [toType isEqualToString:kPLYDataTypeInt] ) {
        *(int32_t *)buffer = (uint16_t)doubleValue;
        readBytes = 4;
    } else if( [toType isEqualToString:kPLYDataTypeUint] ) {
        *(uint32_t *)buffer = (uint32_t)doubleValue;
        readBytes = 4;
    } else if( [toType isEqualToString:kPLYDataTypeFloat] ) {
        *(float *)buffer = (float)doubleValue;
        readBytes = 4;
    } else if( [toType isEqualToString:kPLYDataTypeDouble] ) {
        *(double *)buffer = doubleValue;
        readBytes = 8;
    } else {
        readBytes = 0;
    }
    
    return readBytes;
}


@end
