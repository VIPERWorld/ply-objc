//
//  PLYObject.m
//  PLYObject
//
//  Created by David Brown on 1/18/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYObject.h"
#import "PLYElement.h"
#import "PLYProperty.h"

NSString *const kPLYPlyKeyword = @"ply";
NSString *const kPLYEndHeaderKeyword = @"end_header";
NSString *const kPLYCommentKeyword = @"comment";
NSString *const kPLYElementKeyword = @"element";
NSString *const kPLYPropertyKeyword = @"property";
NSString *const kPLYFormatKeyword = @"format";

const NSUInteger kPLYKeywordIndex = 0;


@implementation PLYObject
{
    /**
     array of strings associated with this file
     */
    NSArray *_fileStringArray;
    
    /**
     position in fileStringArray for next unread element data
     */
    NSUInteger _elementDataPosition;
    
    NSUInteger _elementCount;
    NSUInteger _propertyCount;
    
}

- (BOOL)readFromURL:(NSURL *)url error:(NSError **)error
{
    NSError *readError = *error;
    BOOL success = YES;
    
    _elementCount = 1;
    _propertyCount = 1;
    
    if( url ) {

        // load the strings
        NSString *fileString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&readError];
        _fileStringArray = [fileString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // confirm ply-end_header bracketing, store element start position
        NSIndexSet *plySet = [_fileStringArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            *stop = [kPLYPlyKeyword isEqualToString:(NSString *)obj];
            return *stop;
        }];
        
        NSIndexSet *endHeaderSet = [_fileStringArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            *stop = [kPLYEndHeaderKeyword isEqualToString:(NSString *)obj];
            return *stop;
        }];
        
        if( ([plySet count] != 1) || ([endHeaderSet count] != 1) ) {
            // it's not a ply header if it has more or less than 1 ply/header pair
            success = NO;
        } else {
            
            NSRange headerRange = NSMakeRange([plySet firstIndex],[endHeaderSet firstIndex]);
            
            _elementDataPosition = [endHeaderSet firstIndex]+1;
            
            NSIndexSet *headerIndexSet = [NSIndexSet indexSetWithIndexesInRange:headerRange];

            NSIndexSet *commentSet = [_fileStringArray indexesOfObjectsAtIndexes:headerIndexSet
                                                                        options:0
                                                                    passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                                      {
                                          NSString *testString = (NSString *)obj;
                                          NSRange resultRange = [testString rangeOfString:kPLYCommentKeyword];
                                          return resultRange.location == 0;
                                      }];

            NSIndexSet *elementSet = [_fileStringArray indexesOfObjectsAtIndexes:headerIndexSet
                                                                        options:0
                                                                    passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                                      {
                                          NSString *testString = (NSString *)obj;
                                          NSRange resultRangeElement = [testString rangeOfString:kPLYElementKeyword];
                                          NSRange resultRangeProperty = [testString rangeOfString:kPLYElementKeyword];
                                          return (resultRangeElement.location == 0) || (resultRangeProperty.location == 0);
                                      }];

            _comments = [_fileStringArray objectsAtIndexes:commentSet];
            
            NSMutableDictionary *elementWork = [[NSMutableDictionary alloc] init];
            __block PLYElement *newElement = nil;
            
            // go through all of the elements that were previously identified, process each,
            // and add to the working dictionary
            [elementSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                
                NSString *fieldString = [_fileStringArray objectAtIndex:idx];
                NSArray *fieldArray = [fieldString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if( [[fieldArray objectAtIndex:kPLYKeywordIndex] isEqualToString:kPLYElementKeyword] ) {

                    if( newElement ) {
                        [elementWork setObject:newElement forKey:[newElement name]];
                        newElement = nil;
                    }
                    
                    newElement = [self processElementFieldArray:fieldArray];
                    
                } else if( [[fieldArray objectAtIndex:kPLYKeywordIndex] isEqualToString:kPLYPropertyKeyword] ) {
                    
                    PLYProperty *newProperty = [self processPropertyFieldArray:fieldArray];
                    if(newProperty && newElement)
                        [newElement addProperty:newProperty];
                }
                
            }];
            
            if( newElement ) {
                [elementWork setObject:newElement forKey:[newElement name]];
                newElement = nil;
            }
            
            _elements = [NSDictionary dictionaryWithDictionary:elementWork];
            
        }
        
        // now we have the header data ready. let's read some data
        
        PLYElement *nextElement = nil;
        NSUInteger readLines = 0;
        
        for( nextElement in _elements ) {
            
            readLines = [nextElement readFromStrings:_fileStringArray startPosition:_elementDataPosition];
            _elementDataPosition += readLines;
            
        }
        
        
    }
    
    return success;
}

const NSUInteger kPLYMinimumElementCount = 3;

const NSUInteger kPLYElementNameIndex = 1;
const NSUInteger kPLYElementCountIndex = 2;

- (PLYElement *)processElementFieldArray:(NSArray *)fieldArray
{
    return nil;
}

const NSUInteger kPLYMinimumPropertyCount = 3;
const NSUInteger kPLYMinimumPropertyListCount = 5;

const NSUInteger kPLYPropertyTypeIndex = 1;
const NSUInteger kPLYPropertyListCountTypeIndex = 2;
const NSUInteger kPLYPropertyListDataTypeIndex = 3;
const NSUInteger kPLYPropertyListNameIndex = 4;
const NSUInteger kPLYPropertyNameIndex = 2;

- (PLYProperty *)processPropertyFieldArray:(NSArray *)fieldArray
{
    return nil;
}


@end
