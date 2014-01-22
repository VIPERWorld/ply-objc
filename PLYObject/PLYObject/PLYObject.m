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
    
    /**
     ordered collection of element keys for enumeration during element data import
     */
    NSMutableArray *_elementNames;
    
}

- (BOOL)readFromURL:(NSURL *)url error:(NSError **)error
{
    BOOL success = YES;
    
    NSError *readError = nil;
    if( error != NULL )
        readError = *error;
    
    if( url ) {

        // load the strings
        NSString *fileString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&readError];
        _fileStringArray = [fileString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
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
            
            _elementNames = [[NSMutableArray alloc] init];
            
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
                                          NSRange resultRangeProperty = [testString rangeOfString:kPLYPropertyKeyword];
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
                        [_elementNames addObject:[newElement name]];
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
                [_elementNames addObject:[newElement name]];
                newElement = nil;
            }
            
            _elements = [NSDictionary dictionaryWithDictionary:elementWork];
            elementWork = nil;
            
            // now we have the header data ready. let's read some data, use the ordered
            // list of keys we generated when we read the header above, since the data
            // section of the .ply file follows the same ordering as used in the header
            
            PLYElement *nextElement = nil;
            NSString *nextElementName = nil;
            NSUInteger readLines = 0;
            
            for( nextElementName in _elementNames ) {
                
                nextElement = [_elements objectForKey:nextElementName];
                readLines = [nextElement readFromStrings:_fileStringArray startPosition:_elementDataPosition];
                _elementDataPosition += readLines;
                
            }
        }
        
    }
    
    return success;
}

- (NSData *)dataForElementName:(NSString *)elementName
{
    return [(PLYElement *)[_elements objectForKey:elementName] data];
}

- (NSArray *)sizesForElementName:(NSString *)elementName
{
    NSMutableArray *sizes = nil;
    
    PLYElement *theElement = [_elements objectForKey:elementName];

    if( theElement ) {
        sizes = [[NSMutableArray alloc] init];

        // traverse the element's configured properties and assemble an array
        PLYProperty *nextProperty = nil;
        for( nextProperty in [theElement properties] ) {
            [sizes addObjectsFromArray:[nextProperty dataSizes]];
        }
        
        if( [sizes count] == 0 ) sizes = nil;
    }
    
    // convert it to an array but only if there is data for it
    return sizes ? [NSArray arrayWithArray:sizes] : nil;
}

- (NSArray *)GLtypesForElementName:(NSString *)elementName
{
    NSMutableArray *GLtypes = nil;
    
    PLYElement *theElement = [_elements objectForKey:elementName];
    
    if( theElement ) {
        GLtypes = [[NSMutableArray alloc] init];
        
        // traverse the element's configured properties and assemble an array
        PLYProperty *nextProperty = nil;
        for( nextProperty in [theElement properties] ) {
            [GLtypes addObjectsFromArray:[nextProperty GLtypes]];
        }
        
        if( [GLtypes count] == 0 ) GLtypes = nil;
        
    }
    
    // convert it to an array but only if there is data for it
    return GLtypes ? [NSArray arrayWithArray:GLtypes] : nil;

}

- (NSArray *)propertyNamesForElementName:(NSString *)elementName
{
    NSMutableArray *propertyNames = nil;
    
    PLYElement *theElement = [_elements objectForKey:elementName];
    
    if( theElement ) {
        propertyNames = [[NSMutableArray alloc] init];
        
        // traverse the element's configured properties and assemble an array
        PLYProperty *nextProperty = nil;
        for( nextProperty in [theElement properties] ) {
            [propertyNames addObjectsFromArray:[nextProperty propertyNames]];
        }
        
        if( [propertyNames count] == 0 ) propertyNames = nil;
        
    }
    
    // convert it to an array but only if there is data for it
    return propertyNames ? [NSArray arrayWithArray:propertyNames] : nil;
}



const NSUInteger kPLYMinimumElementCount = 3;

const NSUInteger kPLYElementNameIndex = 1;
const NSUInteger kPLYElementCountIndex = 2;

/**
 Process an array of data fields for a pre-qualified element string in
 the header of a .PLY file.
 @param fieldArray an array of strings representing each whitespace separated
 field from a given "element" line
 @return a PLYElement object containing the parsed data
 */
- (PLYElement *)processElementFieldArray:(NSArray *)fieldArray
{
    NSString *countString = [fieldArray objectAtIndex:kPLYElementCountIndex];
    
    PLYElement *newElement = [[PLYElement alloc] init];
    newElement.name = [fieldArray objectAtIndex:kPLYElementNameIndex];
    newElement.count = (NSUInteger)[countString integerValue];
    
    return newElement;
}

const NSUInteger kPLYMinimumPropertyCount = 3;
const NSUInteger kPLYMinimumPropertyListCount = 5;

const NSUInteger kPLYPropertyTypeIndex = 1;
const NSUInteger kPLYPropertyListCountTypeIndex = 2;
const NSUInteger kPLYPropertyListDataTypeIndex = 3;
const NSUInteger kPLYPropertyListNameIndex = 4;
const NSUInteger kPLYPropertyNameIndex = 2;

NSString *const kPLYPropertyTypeList = @"list";

/**
 Process an array of data fields for a pre-qualified property string in
 the header of a .PLY file.
 @param fieldArray an array of strings representing each whitespace separated
 field from a given "property" line
 @return a PLYProperty object containing the parsed data
 */
- (PLYProperty *)processPropertyFieldArray:(NSArray *)fieldArray
{
    PLYProperty *newProperty = [[PLYProperty alloc] init];
    
    NSString *propertyType = [fieldArray objectAtIndex:kPLYPropertyTypeIndex];
    newProperty.type = propertyType;
    
    if( [propertyType isEqualToString:kPLYPropertyTypeList] ) {
        newProperty.name = [fieldArray objectAtIndex:kPLYPropertyListNameIndex];
        newProperty.dataType = [fieldArray objectAtIndex:kPLYPropertyListDataTypeIndex];
        newProperty.countType = [fieldArray objectAtIndex:kPLYPropertyListCountTypeIndex];
    } else {
        newProperty.name = [fieldArray objectAtIndex:kPLYPropertyNameIndex];
        newProperty.dataType = propertyType;
    }
    
    return newProperty;
}


@end
