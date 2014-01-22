//
//  PLYProperty.m
//  PLYObject
//
//  Created by David Brown on 1/19/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYProperty.h"

typedef enum PLYDataTypeEnum {
    PLYDataTypeChar = 0,
    PLYDataTypeUchar = 1,
    PLYDataTypeShort = 2,
    PLYDataTypeUshort = 3,
    PLYDataTypeInt = 4,
    PLYDataTypeUint = 5,
    PLYDataTypeFloat = 6,
    PLYDataTypeDouble = 7,
    PLYDataTypeList = 8
} PLYDataType;


@implementation PLYProperty
{
    NSDictionary *_kPLYEnumForDataType;
    NSDictionary *_kPLYBytesForDataType;
}

- (id)init
{
    self = [super init];
    
    if( self ) {
        _kPLYEnumForDataType = @{
                                 @"char": [NSNumber numberWithInt:PLYDataTypeChar],
                                 @"uchar": [NSNumber numberWithInt:PLYDataTypeUchar],
                                 @"short": [NSNumber numberWithInt:PLYDataTypeShort],
                                 @"ushort": [NSNumber numberWithInt:PLYDataTypeUshort],
                                 @"int": [NSNumber numberWithInt:PLYDataTypeInt],
                                 @"uint": [NSNumber numberWithInt:PLYDataTypeUint],
                                 @"float": [NSNumber numberWithInt:PLYDataTypeFloat],
                                 @"double": [NSNumber numberWithInt:PLYDataTypeDouble],
                                 @"list": [NSNumber numberWithInt:PLYDataTypeList]
                                 };

        _kPLYBytesForDataType = @{
                                  @"char": @1,
                                  @"uchar": @1,
                                  @"short": @2,
                                  @"ushort": @2,
                                  @"int": @4,
                                  @"uint": @4,
                                  @"float": @4,
                                  @"double": @8
                                 };

    }
    
    return self;
}

- (NSUInteger)scanPropertyIntoBuffer:(uint8_t *)buffer usingScanner:(NSScanner *)lineScanner {
    
    NSUInteger totalReadBytes = 0;
    
    if( buffer == NULL || lineScanner == nil ) {
        totalReadBytes = 0;
    } else {
        
        NSNumber *propertyTypeNumber = [_kPLYEnumForDataType objectForKey:_type];
        if( propertyTypeNumber ) {
            PLYDataType propertyType = (PLYDataType)[propertyTypeNumber intValue];
            
            if( propertyType == PLYDataTypeList ) {
                // list properties contain a count followed by the data values
                NSInteger listCount;
                NSUInteger idx, readBytes;
                double scanDouble;
                uint8_t *bp = buffer;
                
                // scan in the list count
                //      TODO:   either keep list count or check that all list counts for a
                //              given property are consistent
                [lineScanner scanInteger:&listCount];
                
                PLYDataType dataType = (PLYDataType)[[_kPLYEnumForDataType objectForKey:_dataType] intValue];
                
                // for each data item that follows, scan it in as a double, and then cast it
                // to the appropriate data type and store it in the buffer
                for( idx=0; idx < listCount; idx++ ) {
                    [lineScanner scanDouble:&scanDouble];
                    readBytes = [self convertFromDouble:scanDouble toType:dataType inBuffer:bp];
                    bp += readBytes;
                    totalReadBytes += readBytes;
                }
                
            } else {
                
                double scanDouble;
                
                // scan in the value as a double, and then cast it to the appropriate type and
                // add it to the memory buffer.
                [lineScanner scanDouble:&scanDouble];
                
                totalReadBytes = [self convertFromDouble:scanDouble toType:propertyType inBuffer:buffer];
                
            }
            
            
            
            
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
- (NSUInteger)convertFromDouble:(double)doubleValue toType:(PLYDataType)toType inBuffer:(uint8_t *)buffer
{
    NSUInteger readBytes = 0;
    
    switch (toType) {
        case PLYDataTypeChar:
            *(int8_t *)buffer = (int8_t)doubleValue;
            readBytes = 1;
            break;
            
        case PLYDataTypeUchar:
            *(uint8_t *)buffer = (uint8_t)doubleValue;
            readBytes = 1;
            break;
            
        case PLYDataTypeShort:
            *(int16_t *)buffer = (uint16_t)doubleValue;
            readBytes = 2;
            break;
            
        case PLYDataTypeUshort:
            *(uint16_t *)buffer = (uint16_t)doubleValue;
            readBytes = 2;
            break;
            
        case PLYDataTypeInt:
            *(int32_t *)buffer = (uint16_t)doubleValue;
            readBytes = 4;
            break;
            
        case PLYDataTypeUint:
            *(uint32_t *)buffer = (uint32_t)doubleValue;
            readBytes = 4;
            break;
            
        case PLYDataTypeFloat:
            *(float *)buffer = (float)doubleValue;
            readBytes = 4;
            break;
            
        case PLYDataTypeDouble:
            *(double *)buffer = doubleValue;
            readBytes = 8;
            break;
            
        default:
            break;
    }
    return readBytes;
}


- (NSArray *)dataSizes
{
    PLYDataType propertyType;
    NSNumber *propertyEnum = nil;
    NSMutableArray *dataSizeArray = [[NSMutableArray alloc] init];
    
    if( (propertyEnum = [_kPLYEnumForDataType objectForKey:_type]) ) {
        
        propertyType = (PLYDataType)[propertyEnum intValue];
        
        if( propertyType == PLYDataTypeList ) {
            
        } else {
            [dataSizeArray addObject:[_kPLYBytesForDataType objectForKey:_type]];
        }
        
    }
    
    
}


@end
