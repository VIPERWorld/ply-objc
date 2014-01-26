//
//  PLYElement.m
//  PLYObject
//
//  Created by David Brown on 1/19/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYElement.h"
#import "PLYProperty.h"

@implementation PLYElement
{
    NSString *_name;
    NSUInteger _count;
    
    NSString *_elementString;

    // this ivar backs a non-mutable property
    NSMutableArray *_properties;
    
    // this ivar backs a non-mutable property
    NSMutableData *_data;
}

#pragma mark Accessor methods

static const NSUInteger kPLYMinimumElementCount = 3;

static const NSUInteger kPLYElementFieldIndex = 0;
static const NSUInteger kPLYElementNameIndex = 1;
static const NSUInteger kPLYElementCountIndex = 2;

static NSString *const kPLYElementName = @"element";

- (void)setElementString:(NSString *)elementString
{
    _count = 0;
    _name = nil;
    _properties = nil;
    _data = nil;
    _elementString = nil;
    
    if(!elementString) {
        return;
    }
    
    // separate the element string into whitespace delimited fields
    NSArray *elementFields = [elementString componentsSeparatedByCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if( elementFields &&
       [[elementFields objectAtIndex:kPLYElementFieldIndex] isEqualToString:kPLYElementName] &&
       ([elementFields count] >= kPLYMinimumElementCount) ) {
            
        _name = [elementFields objectAtIndex:kPLYElementNameIndex];
        NSString *elementCount = [elementFields objectAtIndex:kPLYElementCountIndex];
        if(elementCount) {
            _count = (NSUInteger)[elementCount integerValue];
        }
        
        _elementString = elementString;
    }
}

- (NSString *)elementString
{
    if(_elementString) {
        return _elementString;
    }
    
    if( _name == nil || _count == 0 ) {
        return nil;
    }
    
    _elementString = [NSString stringWithFormat:@"%@ %@ %ld",kPLYElementName,
                      _name, _count];
    
    return _elementString;
}


- (NSString *)name
{
    return _name;
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    // setting an element field explicitly requires the string value to be regenerated
    _elementString = nil;
}

- (NSUInteger)count
{
    return _count;
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    // setting an element field explicitly requires the string value to be regenerated
    _elementString = nil;
}

- (NSArray *)properties
{
    return [NSArray arrayWithArray:_properties];
}

- (void)addPropertyWithString:(NSString *)propertyString
{
    PLYProperty *newProperty = [[PLYProperty alloc] init];
    newProperty.propertyString = propertyString;
                                
    [self addProperty:newProperty];
}

- (void)addProperty:(PLYProperty *)property
{
    // add a non-nil object to the existing mutable array, or create
    // it if it does not yet exist
    if(!property) {
        return;
    }
    
    if( _properties ) {
        [_properties addObject:property];
    } else {
        _properties = [NSMutableArray arrayWithObject:property];
    }
}

const NSUInteger kPLYBufferSize = 512;

- (NSUInteger)readFromStrings:(NSArray *)strings startIndex:(NSUInteger)start
{
    __block NSUInteger readLines = 0;
    __block NSUInteger readElements = 0;
    
    NSInteger stringsToEnd = [strings count] - start;

    if( stringsToEnd <= 0 ) {
        return readLines;
    }
    
    NSIndexSet *elementSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(start, stringsToEnd)];
    uint8_t *lineBuffer = calloc(kPLYBufferSize, sizeof(uint8_t));

    __block NSMutableData *elementData = [[NSMutableData alloc] init];

    [strings enumerateObjectsAtIndexes:elementSet
                               options:0
                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                
                                if( [obj length] > 0 ) {
                                    
                                    NSScanner *lineScanner = [NSScanner scannerWithString:(NSString *)obj];
                                    
                                    PLYProperty *nextProperty;
                                    NSUInteger bytes, totalBytes;
                                    
                                    uint8_t *buffer = lineBuffer;
                                    totalBytes = 0;
                                    
                                    for( nextProperty in _properties ) {
                                        bytes = [nextProperty scanPropertyIntoBuffer:(uint8_t *)buffer
                                                                        usingScanner:lineScanner];
                                        buffer += bytes;
                                        totalBytes += bytes;
                                    }
                                    
                                    [elementData appendBytes:lineBuffer length:totalBytes];
                                    
                                    readElements += (totalBytes > 0) ? 1 : 0; // gratuitous ternary action

                                }
                                
                                if( readElements == _count ) {
                                    *stop = YES;
                                }
                                
                                readLines++;
                                
                            }];
    
    _data = [NSData dataWithData:elementData];
    
    free(lineBuffer);
    
    return readLines;
}

@end
