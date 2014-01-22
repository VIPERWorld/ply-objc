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
    NSMutableArray *_properties;
}

- (void)addProperty:(PLYProperty *)newProperty
{
    
    // add a non-nil object to the existing mutable array, or create
    // it if it does not yet exist
    if(newProperty) {
        if(_properties == nil) {
            _properties = [NSMutableArray arrayWithObject:newProperty];
        } else {
            [_properties addObject:newProperty];
        }
    }
    
}

- (NSArray *)properties
{
    return [NSArray arrayWithArray:_properties];
}

const NSUInteger kPLYBufferSize = 512;

- (NSUInteger)readFromStrings:(NSArray *)strings startPosition:(NSUInteger)start
{
    __block NSUInteger readLines = 0;
    
    NSIndexSet *elementSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(start, _count)];
    __block NSMutableData *elementData = [[NSMutableData alloc] init];
    
    uint8_t *lineBuffer = calloc(kPLYBufferSize, sizeof(uint8_t));

    [strings enumerateObjectsAtIndexes:elementSet
                               options:0
                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                
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
                                
                                readLines += (totalBytes > 0) ? 1 : 0; // gratuitous ternary action
    
                            }];
    
    _data = [NSData dataWithData:elementData];
    
    free(lineBuffer);
    
    return readLines;
}

@end
