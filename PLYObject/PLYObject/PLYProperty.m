//
//  PLYProperty.m
//  PLYObject
//
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYProperty.h"

@implementation PLYProperty
{
    NSString *_name;
    PLYPropertyType _propertyType;
    
    PLYDataType _dataType;
    PLYDataType _countType;
    
    NSString *_propertyString;
}

#pragma mark Init Methods

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

#pragma mark Accessor Methods

const NSUInteger kPLYMinimumPropertyCount = 3;
const NSUInteger kPLYMinimumPropertyListCount = 5;

const NSUInteger kPLYPropertyFieldIndex = 0;
const NSUInteger kPLYPropertyTypeIndex = 1;
const NSUInteger kPLYPropertyScalarTypeIndex = 1;
const NSUInteger kPLYPropertyListCountTypeIndex = 2;
const NSUInteger kPLYPropertyListDataTypeIndex = 3;
const NSUInteger kPLYPropertyListNameIndex = 4;
const NSUInteger kPLYPropertyNameIndex = 2;

NSString *const kPLYPropertyName = @"property";
NSString *const kPLYPropertyList = @"list";

- (void)setPropertyString:(NSString *)propertyString
{
    _dataType = PLYDataTypeInvalid;
    _countType = PLYDataTypeInvalid;
    _propertyType = PLYPropertyTypeInvalid;

    if(propertyString) {

        // separate the property string into whitespace delimited fields
        NSArray *propertyFields = [propertyString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // check a set of constraints on the fields
        if( propertyFields &&
           [[propertyFields objectAtIndex:kPLYPropertyFieldIndex] isEqualToString:kPLYPropertyName] &&
           ([propertyFields count] >= kPLYMinimumPropertyCount) ) {
            
            
            _propertyType = [self propertyTypeForString:
                                            [propertyFields objectAtIndex:kPLYPropertyTypeIndex]];

            _name = [propertyFields objectAtIndex:kPLYPropertyNameIndex];
            
            if( _propertyType == PLYPropertyTypeList ) {
                
                if( [propertyFields count] < kPLYMinimumPropertyListCount ) {
                    // issue
                    _propertyType = PLYPropertyTypeInvalid;
                } else {
                    
                    _name = [propertyFields objectAtIndex:kPLYPropertyListNameIndex];
                    
                    NSString *dataTypeString = [propertyFields objectAtIndex:kPLYPropertyListDataTypeIndex];
                    _dataType = [self dataTypeForString:dataTypeString];
                    
                    NSString *countTypeString = [propertyFields objectAtIndex:kPLYPropertyListCountTypeIndex];
                    _countType = [self dataTypeForString:countTypeString];
                    
                }
                
            } else if( _propertyType == PLYPropertyTypeScalar ) {
                
                _dataType = [self dataTypeForString:
                             [propertyFields objectAtIndex:kPLYPropertyScalarTypeIndex]];
                
                _countType = PLYDataTypeInvalid;
            }
            
        } else {
            // issue!! something wrong with field array,
            _propertyType = PLYPropertyTypeInvalid;
        }

    }
    
    if( _propertyType == PLYPropertyTypeInvalid ) {
        _propertyString = nil;
    } else {
        _propertyString = propertyString;
    }
    
}

- (NSString *) propertyString
{
    NSString *returnString = nil;
    
    // construct a new string if an up-to-date string does not exist
    if(_propertyString == nil) {
        
        if( _name == nil || _propertyType == PLYPropertyTypeInvalid || _dataType == PLYPropertyTypeInvalid ) {
            returnString = nil;
        } else if( _propertyType == PLYPropertyTypeList ) {
            
            if( _countType == PLYPropertyTypeInvalid ) {
                returnString = nil;
            } else {
                returnString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                                kPLYPropertyName, kPLYPropertyList,
                                [self stringForDataType:_countType],
                                [self stringForDataType:_dataType],
                                _name];
            }
            
        } else if( _propertyType == PLYPropertyTypeScalar ) {
            
            returnString = [NSString stringWithFormat:@"%@ %@ %@",
                            kPLYPropertyName, _name,
                            [self stringForDataType:_dataType]];
            
        } else {
            returnString = nil;
        }
        
        _propertyString = returnString;
        
    }
    
    return _propertyString;
}

- (NSString *)name
{
    return _name;
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    // setting a property field explicitly requires the string value to be regenerated
    _propertyString = nil;
}

- (PLYPropertyType) propertyType
{
    return _propertyType;
}

- (void)setPropertyType:(PLYPropertyType)propertyType
{
    _propertyType = propertyType;
    
    // setting a property field explicitly requires the string value to be regenerated
    _propertyString = nil;
}

- (PLYDataType)countType
{
    return _countType;
}

- (void)setCountType:(PLYDataType)countType
{
    _countType = countType;
    
    // setting a property field explicitly requires the string value to be regenerated
    _propertyString = nil;
}

- (PLYDataType)dataType
{
    return _dataType;
}

- (void)setDataType:(PLYDataType)dataType
{
    _dataType = dataType;
    
    // setting a property field explicitly requires the string value to be regenerated
    _propertyString = nil;
}

#pragma mark Data conversion methods

- (NSUInteger)scanPropertyIntoBuffer:(uint8_t *)buffer usingScanner:(NSScanner *)lineScanner {
    
    NSUInteger totalReadBytes = 0;
    
    if( buffer == NULL || lineScanner == nil || _propertyType == PLYPropertyTypeInvalid) {
        totalReadBytes = 0;
    } else {
        
        if( _propertyType == PLYPropertyTypeList ) {
            
            // list properties contain a count followed by the data values
            NSUInteger idx, readBytes;
            double scanDouble;
            NSInteger listCount;
            uint8_t *bp = buffer;
            
            // scan in the list count
            //      TODO:   either keep list count or check that all list counts for a
            //              given property are consistent
            [lineScanner scanDouble:&scanDouble];
            readBytes = [self convertFromDouble:scanDouble toType:_countType inBuffer:bp];
            bp += readBytes;
            totalReadBytes += readBytes;
            listCount = (NSUInteger)scanDouble;
            
            // for each data item that follows, scan it in as a double, and then cast it
            // to the appropriate data type and store it in the buffer
            for( idx=0; idx < listCount; idx++ ) {
                [lineScanner scanDouble:&scanDouble];
                readBytes = [self convertFromDouble:scanDouble toType:_dataType inBuffer:bp];
                bp += readBytes;
                totalReadBytes += readBytes;
            }

        } else if( _propertyType == PLYPropertyTypeScalar ) {
            
            double scanDouble;
                
            // scan in the value as a double, and then cast it to the appropriate type and
            // add it to the memory buffer.
            [lineScanner scanDouble:&scanDouble];
                
            totalReadBytes = [self convertFromDouble:scanDouble toType:_dataType inBuffer:buffer];
                
        } else {
            totalReadBytes = 0;
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
            readBytes = sizeof(int8_t);
            break;
            
        case PLYDataTypeUchar:
            *(uint8_t *)buffer = (uint8_t)doubleValue;
            readBytes = sizeof(uint8_t);
            break;
            
        case PLYDataTypeShort:
            *(int16_t *)buffer = (int16_t)doubleValue;
            readBytes = sizeof(int16_t);
            break;
            
        case PLYDataTypeUshort:
            *(uint16_t *)buffer = (uint16_t)doubleValue;
            readBytes = sizeof(uint16_t);
            break;
            
        case PLYDataTypeInt:
            *(int32_t *)buffer = (int32_t)doubleValue;
            readBytes = sizeof(int32_t);
            break;
            
        case PLYDataTypeUint:
            *(uint32_t *)buffer = (uint32_t)doubleValue;
            readBytes = sizeof(uint32_t);
            break;
            
        case PLYDataTypeFloat:
            *(float *)buffer = (float)doubleValue;
            readBytes = sizeof(float);
            break;
            
        case PLYDataTypeDouble:
            *(double *)buffer = doubleValue;
            readBytes = sizeof(double);
            break;
            
        default:
            readBytes = 0;
            break;
    }
    
    return readBytes;
}

/**
 Converts a type string into an enumerated data type
 @param typeString the string to convert
 @return the data type corresponding to the text string, PLYDataTypeInvalid if
 it is not recognized.
 */
- (PLYDataType)dataTypeForString:(NSString *)typeString {
    
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
                                        @"int8": [NSNumber numberWithInt:PLYDataTypeChar],
                                        @"uint8": [NSNumber numberWithInt:PLYDataTypeUchar],
                                        @"int16": [NSNumber numberWithInt:PLYDataTypeShort],
                                        @"uint16": [NSNumber numberWithInt:PLYDataTypeUshort],
                                        @"int32": [NSNumber numberWithInt:PLYDataTypeInt],
                                        @"uint32": [NSNumber numberWithInt:PLYDataTypeUint],
                                        @"float32": [NSNumber numberWithInt:PLYDataTypeFloat],
                                        @"float64": [NSNumber numberWithInt:PLYDataTypeDouble]
                                        };

    NSNumber *numberForDataType = [plyEnumForDataType objectForKey:typeString];
    
    if( numberForDataType ) {
        dataType = (PLYDataType)[numberForDataType intValue];
    } else {
        dataType = PLYDataTypeInvalid;
    }
    
    return dataType;
}

/**
 Converts an enumerated data type into a type string
 @param dataType the type to convert
 @return a string containing the text corresponding to that data type
 */
- (NSString *)stringForDataType:(PLYDataType)dataType
{
    NSDictionary *plyEnumForDataType = @{
                                         [NSNumber numberWithInt:PLYDataTypeChar]: @"int8",
                                         [NSNumber numberWithInt:PLYDataTypeUchar]: @"uint8",
                                         [NSNumber numberWithInt:PLYDataTypeShort]: @"int16",
                                         [NSNumber numberWithInt:PLYDataTypeUshort]: @"uint16",
                                         [NSNumber numberWithInt:PLYDataTypeInt]: @"int32",
                                         [NSNumber numberWithInt:PLYDataTypeUint]: @"uint32",
                                         [NSNumber numberWithInt:PLYDataTypeFloat]: @"float32",
                                         [NSNumber numberWithInt:PLYDataTypeDouble]: @"float64"
                                         };
    
    NSString *returnString = [plyEnumForDataType objectForKey:[NSNumber numberWithInt:dataType]];
    
    return returnString;
}

/**
 Converts a type string into an enumerated property type
 @param typeString the string to convert
 @return the property type corresponding to the text string, PLYPropertyTypeInvalid if
 it is not recognized.
 */
- (PLYPropertyType)propertyTypeForString:(NSString *)typeString {
    
    PLYPropertyType dataType = PLYPropertyTypeInvalid;
    
    NSDictionary *plyEnumForDataType = @{
                                         @"char": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"uchar": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"short": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"ushort": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"int": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"uint": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"float": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"double": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"list": [NSNumber numberWithInt:PLYPropertyTypeList],
                                         @"int8": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"uint8": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"int16": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"uint16": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"int32": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"uint32": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"float32": [NSNumber numberWithInt:PLYPropertyTypeScalar],
                                         @"float64": [NSNumber numberWithInt:PLYPropertyTypeScalar]
                                         };
    
    NSNumber *numberForDataType = [plyEnumForDataType objectForKey:typeString];
    
    if( numberForDataType ) {
        dataType = (PLYPropertyType)[numberForDataType intValue];
    } else {
        dataType = PLYPropertyTypeInvalid;
    }
    
    return dataType;
}


@end
