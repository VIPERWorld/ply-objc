//
//  PLYReader.m
//  PLYReader
//
//  Created by David Brown on 1/15/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYReader.h"
#include "asl.h"

NSString *const kPLYPlyKeyword = @"ply";
NSString *const kPLYHeaderKeyword = @"header";
NSString *const kPLYCommentKeyword = @"comment";
NSString *const kPLYElementKeyword = @"element";
NSString *const kPLYFormatKeyword = @"format";
NSString *const kPLYPropertyKeyword = @"property";
NSString *const kPLYEndHeaderKeyword = @"end_header";

typedef enum PLYEnumFormatType {
    PLYFormatTypeASCII = 0,
    PLYFormatTypeBinaryBigEndian = 1,
    PLYFormatTypeBinaryLittleEndian = 2
} PLYFormatType;

@implementation PLYReader
{
    NSURL *_plyURL;
    NSString *_plyFileStrings;
    
    // state/context for use during processing
    NSMutableDictionary *_headerDictionary;
    NSMutableDictionary *_plyDictionary;
    
    
    NSMutableDictionary *_currentElement;
    NSMutableArray *_currentPropertyArray;
    NSMutableArray *_commentStrings;
    NSMutableArray *_elementProperties;
    
    PLYFormatType _fileFormatType;
}


- (id) init
{
    return( [self initWithURL:nil] );
}

- (id) initWithURL:(NSURL *)url
{
    self = [super init];
    
    if(self) {
        _plyURL = url;
        _plyFileStrings = nil;
        _headerDictionary = nil;
        _plyDictionary = nil;
        
        _currentElement = nil;
        _currentPropertyArray = nil;
        _commentStrings = nil;
        _elementProperties = nil;
        
        _fileFormatType = PLYFormatTypeASCII;
    }
    
    return self;
}

- (NSDictionary *)PLYDictionary
{
    NSError *readError = [[NSError alloc] init];
    
    if(_plyDictionary == nil) {
        
        if( _plyURL == nil ) NSLog(@"PLYReader: Internal error, unexpected nil object in PLYDictionary");
        else {

            _plyFileStrings = [NSString stringWithContentsOfURL:_plyURL encoding:NSUTF8StringEncoding error:&readError];
            
            if(_plyFileStrings) {
                
                _plyDictionary = [[NSMutableDictionary alloc] init];
                
                NSArray *stringsArray = [_plyFileStrings componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                asl_log(NULL, NULL, ASL_LEVEL_INFO, [[NSString stringWithFormat:@"found %lu lines",[stringsArray count]] UTF8String]);
                
                // scans the file for a ply header and populates the _headerDictionary ivar
                NSUInteger linesRead = [self processHeadersInStrings:stringsArray];
                
                [_plyDictionary setObject:[NSDictionary dictionaryWithDictionary:_headerDictionary]
                                   forKey:kPLYReaderHeaderKey];
                
                // scans the remainder of the file for the elements described in the header
                linesRead = [self processElementsInStrings:stringsArray fromPosition:linesRead];
                
            } else {
                NSLog(@"PLYReader: Error reading URL %@:\n%@",_plyURL,[readError localizedDescription]);
            }
        }
    }

    NSDictionary *immutableDictionary;
    
    if(_plyDictionary) {
        immutableDictionary = [NSDictionary dictionaryWithDictionary:_plyDictionary];
    } else {
        immutableDictionary = nil;
    }
    
    return immutableDictionary;
}

const NSUInteger kPLYFieldName = 0;

- (NSUInteger) processHeadersInStrings:(NSArray *)headerStrings
{
    NSString *nextLine = nil;
    
    NSUInteger lineNumber = 0;
    
    _commentStrings = [[NSMutableArray alloc] init];
    _elementProperties = [[NSMutableArray alloc] init];
    
    BOOL plyFound = NO;
    
    // for each line
    for(nextLine in headerStrings) {

        // break each line into separate fields
        NSArray *lineFields = [nextLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if( lineFields ) {
            
            NSString *fieldName = [lineFields objectAtIndex:kPLYFieldName];
            
            // ply keyword has no context but indicates a ply formatted file
            if( [fieldName isEqualToString:kPLYPlyKeyword] ) {
                plyFound = YES;
            }
            
            // comment keyword causes remainder of string to be stored
            else if( [fieldName isEqualToString:kPLYCommentKeyword] ) {
                
                if(![self processCommentParameters:lineFields]) {
                    NSLog(@"PLYReader: Internal error, %@ keyword found at line %lu but failed processing.",kPLYCommentKeyword,lineNumber);
                }
            }
            
            // format keyword will inform ascii vs binary
            else if( [fieldName isEqualToString:kPLYFormatKeyword] ) {
                
                if(![self processFormatParameters:lineFields]) {
                    NSLog(@"PLYReader: Internal error, %@ keyword found at line %lu but failed processing.",kPLYFormatKeyword,lineNumber);
                }

            }
            
            // element keyword provides element name and count
            else if( [fieldName isEqualToString:kPLYElementKeyword] ) {

                // if we are seeing a new element keyword, we need to preserve the previous
                // element data, if there was one.
                if(_currentElement) {
                    [_currentElement setObject:[NSArray arrayWithArray:_currentPropertyArray]
                                        forKey:kPLYReaderElementPropertyKey];
                    [_elementProperties addObject:[NSDictionary dictionaryWithDictionary:_currentElement]];
                    _currentElement = nil;
                    _currentPropertyArray = nil;
                }
                
                // make a new dictionary for this element and its properties
                _currentElement = [[NSMutableDictionary alloc] init];
                _currentPropertyArray = [[NSMutableArray alloc] init];
                
                if(![self processElementParameters:lineFields]) {
                    NSLog(@"PLYReader: Internal error, %@ keyword found at line %lu but failed processing.",kPLYElementKeyword,lineNumber);
                }

            }
            
            // property keyword provides further definition to an element
            else if( [fieldName isEqualToString:kPLYPropertyKeyword] ) {

                if(![self processPropertyParameters:lineFields]) {
                    NSLog(@"PLYReader: Internal error, %@ keyword found at line %lu but failed processing.",kPLYPropertyKeyword,lineNumber);
                }
            
            }
            
            // end_header keyword causes header processing to stop
            else if( [fieldName isEqualToString:kPLYEndHeaderKeyword] ) {
                break;
            }
            
        }

        // the first line should contain the ply keyword, if we get to
        // this point the first line processing is completed, so if
        // plyFound is not set we should not continue
        if(!plyFound) {
            lineNumber = [headerStrings count]; // TODO: use better error indicator?
            break;
        }
        
        lineNumber++;

    }

    _headerDictionary = [[NSMutableDictionary alloc] init];
    
    [_headerDictionary setObject:[NSArray arrayWithArray:_elementProperties] forKey:kPLYReaderElementsKey];
    [_headerDictionary setObject:[NSArray arrayWithArray:_commentStrings] forKey:kPLYReaderCommentKey];
    
    asl_log(NULL, NULL, ASL_LEVEL_INFO, [[NSString stringWithFormat:@"Completed reading header: %@",_headerDictionary] UTF8String]);

    return lineNumber;
}

- (BOOL) processCommentParameters:(NSArray *)parameters
{
    NSString *commentString = [[NSString alloc] init];
    NSString *nextString = nil;
    BOOL firstString = YES;
    
    // we previously split up the comment by whitespace, now put it back together.
    // could pass in the whole comment string, but we'd still have to pull out the
    // 'comment' keyword
    for( nextString in parameters ) {
        
        if(!firstString)
            commentString = [commentString stringByAppendingFormat:@" %@",nextString];
        
    }

    [_commentStrings addObject:commentString];
    
    // nothing will stand in tne way of our success
    return YES;
}

NSString *const kPLYFormatASCIIKeyword = @"ascii";
NSString *const kPLYFormatBinaryLittleKeyword = @"binary_little_endian";
NSString *const kPLYFormatBinaryBigKeyword = @"binary_big_endian";

const NSUInteger kPLYMinimumFormatCount = 3;
const NSUInteger kPLYFormatTypeIndex = 1;
const NSUInteger kPLYFormatVersionIndex = 2;

- (BOOL) processFormatParameters:(NSArray *)parameters
{
    BOOL success = NO;
    
    if( parameters == nil ) {
        NSLog(@"PLYReader: Internal error, unexpected nil object in processElementParameters:");
    } else if( [parameters count] < kPLYMinimumElementCount ) {
        NSLog(@"PLYReader: Internal error, %@ keyword found with insufficient (%lu) parameters.",kPLYFormatKeyword,
              [parameters count]);
    } else {
        
        NSString *formatTypeString = [parameters objectAtIndex:kPLYFormatTypeIndex];
        
        if( [formatTypeString isEqualToString:kPLYFormatASCIIKeyword] ) {
            _fileFormatType = PLYFormatTypeASCII;
            success = YES;
        } else if( [formatTypeString isEqualToString:kPLYFormatBinaryBigKeyword] ) {
            _fileFormatType = PLYFormatTypeBinaryBigEndian;
            success = YES;
        } else if( [formatTypeString isEqualToString:kPLYFormatBinaryLittleKeyword] ) {
            _fileFormatType = PLYFormatTypeBinaryLittleEndian;
            success = YES;
        } else {
            NSLog(@"PLYReader: Internal error, %@ keyword found with unsupported parameter (%@)",kPLYFormatKeyword,
                  formatTypeString);
        }
        
    }

    return success;
}

const NSUInteger kPLYMinimumElementCount = 3;
const NSUInteger kPLYElementNameIndex = 1;
const NSUInteger kPLYElementCountIndex = 2;

- (BOOL) processElementParameters:(NSArray *)parameters
{
    BOOL success = NO;
    
    if( parameters == nil ) {
        NSLog(@"PLYReader: Internal error, unexpected nil object in processElementParameters:");
    } else if( [parameters count] < kPLYMinimumElementCount ) {
        NSLog(@"PLYReader: Internal error, %@ keyword found with insufficient (%lu) parameters.",kPLYElementKeyword,
              [parameters count]);
    } else {
        
        NSString *elementName = [parameters objectAtIndex:kPLYElementNameIndex];
        NSString *elementCountString = [parameters objectAtIndex:kPLYElementCountIndex];

        NSNumber *elementCount = [NSNumber numberWithInteger:[elementCountString integerValue]];
        
        [_currentElement setObject:elementName forKey:kPLYReaderElementNameKey];
        [_currentElement setObject:elementCount forKey:kPLYReaderElementCountKey];
        
        success = YES;
    }
    
    return success;
}

const NSUInteger kPLYMinimumPropertyCount = 3;
const NSUInteger kPLYPropertyTypeIndex = 1;
const NSUInteger kPLYPropertyListCountTypeIndex = 2;
const NSUInteger kPLYPropertyListDataTypeIndex = 3;
const NSUInteger kPLYPropertyListNameIndex = 4;
const NSUInteger kPLYPropertyNameIndex = 2;

NSString *const kPLYPropertyListKeyword = @"list";

- (BOOL) processPropertyParameters:(NSArray *)parameters
{
    // uses ivar _currentElement, _currentPropertyArray
    // presumes parameter[0] = "property"
    BOOL success = NO;
    
    if( parameters == nil ) {
        NSLog(@"PLYReader: Internal error, unexpected nil object in processPropertyParameters:");
    } else if( [parameters count] < kPLYMinimumPropertyCount ) {
        NSLog(@"PLYReader: Internal error, %@ keyword found with insufficient (%lu) parameters.",kPLYPropertyKeyword,
              [parameters count]);
    }

    NSString *propertyType = [parameters objectAtIndex:kPLYPropertyTypeIndex];

    if( [propertyType isEqualToString:kPLYPropertyListKeyword] ) {
        NSLog(@"PLYReader: Internal error, %@ keyword found but no handler for %@ element",kPLYPropertyKeyword,kPLYPropertyListKeyword);
    } else {
        NSString *propertyName = [parameters objectAtIndex:kPLYPropertyNameIndex];
        [_currentPropertyArray addObject:[NSDictionary dictionaryWithObject:propertyType forKey:propertyName]];
        success = YES;
    }

    return success;
}

- (NSUInteger) processElementsInStrings:(NSArray *)fileStrings fromPosition:(NSUInteger)startPosition
{

    return 0;
}

@end
