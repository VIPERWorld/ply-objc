//
//  PLYProperty.m
//  PLYObject
//
//  Created by David Brown on 1/19/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYProperty.h"
#import "OpenGL/gl3.h"

typedef enum PLYDataTypeEnum {
    PLYDataTypeInvalid = 0,
    PLYDataTypeChar = 1,
    PLYDataTypeUchar = 2,
    PLYDataTypeShort = 3,
    PLYDataTypeUshort = 4,
    PLYDataTypeInt = 5,
    PLYDataTypeUint = 6,
    PLYDataTypeFloat = 7,
    PLYDataTypeDouble = 8,
    PLYDataTypeList = 9
} PLYDataType;

const NSUInteger kPLYDataTypeCount = (NSUInteger)PLYDataTypeList + 1;

NSUInteger kPLYBytesForDataType[kPLYDataTypeCount] = { 0, 1, 1, 2, 2, 4, 4, 4, 8, 0 };

GLenum kPLYGlTypeForDataType[kPLYDataTypeCount] =
{
    0, GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT, GL_UNSIGNED_SHORT,
    GL_INT, GL_UNSIGNED_INT, GL_FLOAT, GL_DOUBLE, 0
};

@implementation PLYProperty
{
    PLYDataType _dataType;
    PLYDataType _countType;
    
    NSString *_dataTypeString;
    NSString *_countTypeString;
}

- (id)init
{
    return [self initWithPropertyString:nil];
}

- (id)initWithPropertyString:(NSString *)string
{
    self = [super init];

    if( self ) {
        [self setPropertyString:string];
    }
    
    return self;
}

const NSUInteger kPLYMinimumPropertyCount = 3;
const NSUInteger kPLYMinimumPropertyListCount = 5;

const NSUInteger kPLYPropertyFieldIndex = 0;
const NSUInteger kPLYPropertyTypeIndex = 1;
const NSUInteger kPLYPropertyListCountTypeIndex = 2;
const NSUInteger kPLYPropertyListDataTypeIndex = 3;
const NSUInteger kPLYPropertyListNameIndex = 4;
const NSUInteger kPLYPropertyNameIndex = 2;

NSString *const kPLYPropertyName = @"property";

- (void)setPropertyString:(NSString *)propertyString
{
    _propertyString = propertyString;
    
    _dataType = PLYDataTypeInvalid;
    _countType = PLYDataTypeInvalid;
    _dataTypeString = nil;
    _countTypeString = nil;
    
    _list = NO;
    
    if(_propertyString) {

        // separate the property string into whitespace delimited fields
        NSArray *propertyFields = [_propertyString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // check a set of constraints on the fields
        if( propertyFields &&
           [[propertyFields objectAtIndex:kPLYPropertyFieldIndex] isEqualToString:kPLYPropertyName] &&
           ([propertyFields count] >= kPLYMinimumPropertyCount) ) {
            
            
            PLYDataType propertyType = [self dataTypeForPropertyString:[propertyFields objectAtIndex:kPLYPropertyTypeIndex]];

            _list = (propertyType == PLYDataTypeList);
            _name = [propertyFields objectAtIndex:kPLYPropertyNameIndex];
            
            if( propertyType == PLYDataTypeInvalid ) {
                // issue!!
            } else if( propertyType == PLYDataTypeList ) {
                
                if( [propertyFields count] < kPLYMinimumPropertyListCount ) {
                    // issue
                } else {
                    
                    _dataTypeString = [propertyFields objectAtIndex:kPLYPropertyListDataTypeIndex];
                    _dataType = [self dataTypeForPropertyString:_dataTypeString];
                    
                    _countTypeString = [propertyFields objectAtIndex:kPLYPropertyListCountTypeIndex];
                    _countType = [self dataTypeForPropertyString:_countTypeString];
                    
                }
                
            } else {
                _dataTypeString = [propertyFields objectAtIndex:kPLYPropertyTypeIndex];
                _dataType = propertyType;
                
                _countTypeString = nil;
                _countType = PLYDataTypeInvalid;
            }
            
        } else {
            // issue!! something wrong with field array,
        }

    }
    
}

- (NSString *) propertyString
{
    return _propertyString;
}

- (NSUInteger) dataLength
{
    return kPLYBytesForDataType[(NSUInteger)_dataType];
}

- (NSUInteger) countLength
{
    return kPLYBytesForDataType[(NSUInteger)_countType];
}

- (GLenum) dataGLType
{
    return kPLYGlTypeForDataType[(NSUInteger)_dataType];
}

- (GLenum) countGLType
{
    return kPLYGlTypeForDataType[(NSUInteger)_countType];
}


- (NSUInteger)scanPropertyIntoBuffer:(uint8_t *)buffer usingScanner:(NSScanner *)lineScanner {
    
    NSUInteger totalReadBytes = 0;
    
    if( buffer == NULL || lineScanner == nil || _dataType == PLYDataTypeInvalid) {
        totalReadBytes = 0;
    } else {
        
        if( _list ) {
            
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
                
            totalReadBytes = [self convertFromDouble:scanDouble toType:_dataType inBuffer:buffer];
                
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
   
    switch (toType) {
        case PLYDataTypeChar:
            *(int8_t *)buffer = (int8_t)doubleValue;
            break;
            
        case PLYDataTypeUchar:
            *(uint8_t *)buffer = (uint8_t)doubleValue;
            break;
            
        case PLYDataTypeShort:
            *(int16_t *)buffer = (uint16_t)doubleValue;
            break;
            
        case PLYDataTypeUshort:
            *(uint16_t *)buffer = (uint16_t)doubleValue;
            break;
            
        case PLYDataTypeInt:
            *(int32_t *)buffer = (uint16_t)doubleValue;
            break;
            
        case PLYDataTypeUint:
            *(uint32_t *)buffer = (uint32_t)doubleValue;
            break;
            
        case PLYDataTypeFloat:
            *(float *)buffer = (float)doubleValue;
            break;
            
        case PLYDataTypeDouble:
            *(double *)buffer = doubleValue;
            break;
            
        default:
            break;
    }
    
    return kPLYBytesForDataType[toType];
}

/**
 Converts a property string into an enumerated data value
 @param propertyString the string to convert
 @return the property type corresponding to the text string, PLYDataTypeInvalid if
 it is not recognized.
 */
- (PLYDataType)dataTypeForPropertyString:(NSString *)propertyString {
    
    PLYDataType dataType = PLYDataTypeInvalid;
    
    NSDictionary *plyEnumForDataType = @{
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

    NSNumber *numberForDataType = [plyEnumForDataType objectForKey:propertyString];
    
    if( numberForDataType ) {
        dataType = (PLYDataType)[numberForDataType intValue];
    } else {
        dataType = PLYDataTypeInvalid;
    }
    
    return dataType;
}

@end
