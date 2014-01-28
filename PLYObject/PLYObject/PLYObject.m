//
//  PLYObject.m
//  PLYObject
//
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYObject.h"
#import "PLYElement.h"
#import "PLYProperty.h"

static NSString *const kPLYPlyKeyword = @"ply";
static NSString *const kPLYEndHeaderKeyword = @"end_header";
static NSString *const kPLYCommentKeyword = @"comment";
static NSString *const kPLYElementKeyword = @"element";
static NSString *const kPLYPropertyKeyword = @"property";
static NSString *const kPLYFormatKeyword = @"format";

static const NSUInteger kPLYKeywordIndex = 0;

@implementation PLYObject
{
    /**
     ordered, mutable collection of element objects
     */
    NSMutableArray *_elements;
    
    /**
     ordered, mutable collection of comments
     */
    NSMutableArray *_comments;
}

#pragma mark Accessor methods

- (NSArray *)comments
{
    return _comments ? [NSArray arrayWithArray:_comments] : nil;
}

- (void)setComments:(NSArray *)comments
{
    _comments = comments ? [NSMutableArray arrayWithArray:comments] : nil;
}

- (NSArray *)elements
{
    return _elements ? [NSArray arrayWithArray:_elements] : nil;
}

- (void)setElements:(NSArray *)elements
{
    _elements = elements ? [NSMutableArray arrayWithArray:elements] : nil;
}

#pragma mark File I/O methods

- (BOOL)readFromURL:(NSURL *)url error:(NSError **)error
{
    NSArray *fileStringArray = nil;
    
    NSError *readError = nil;
    if( error != NULL )
        readError = *error;
    
    if( !url ) {
        return NO;
    }
    
    // load the strings
    NSString *fileString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&readError];
    fileStringArray = [fileString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // confirm ply-end_header bracketing, store element start position
    NSIndexSet *plySet = [fileStringArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        *stop = [kPLYPlyKeyword isEqualToString:(NSString *)obj];
        return *stop;
    }];
    
    NSIndexSet *endHeaderSet = [fileStringArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        *stop = [kPLYEndHeaderKeyword isEqualToString:(NSString *)obj];
        return *stop;
    }];
    
    if( ([plySet count] != 1) || ([endHeaderSet count] != 1) ) {
        // it's not a ply header if it has more or less than 1 ply/header pair
        return NO;
    }
    
    _elements = [[NSMutableArray alloc] init];
    
    NSInteger headerLength = [endHeaderSet firstIndex] - [plySet firstIndex];
    
    if( headerLength <= 0 ) {
        return NO;
    }

    NSRange headerRange = NSMakeRange([plySet firstIndex], headerLength);
    
    NSIndexSet *headerIndexSet = [NSIndexSet indexSetWithIndexesInRange:headerRange];

    NSIndexSet *commentSet = [fileStringArray indexesOfObjectsAtIndexes:headerIndexSet
                                                                options:0
                                                            passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                              {
                                  NSString *testString = (NSString *)obj;
                                  NSRange resultRange = [testString rangeOfString:kPLYCommentKeyword];
                                  return resultRange.location == 0;
                              }];

    NSIndexSet *elementSet = [fileStringArray indexesOfObjectsAtIndexes:headerIndexSet
                                                                options:0
                                                            passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                              {
                                  NSString *testString = (NSString *)obj;
                                  NSRange resultRangeElement = [testString rangeOfString:kPLYElementKeyword];
                                  NSRange resultRangeProperty = [testString rangeOfString:kPLYPropertyKeyword];
                                  return (resultRangeElement.location == 0) || (resultRangeProperty.location == 0);
                              }];

    [commentSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        // we already know each string starts with the comment keyword
        // so no need to check for NSNotFound on keyword range
        NSString *commentString = [fileStringArray objectAtIndex:idx];
        NSRange keywordRange = [commentString rangeOfString:kPLYCommentKeyword];
        NSString *commentOnly = [commentString substringFromIndex:keywordRange.length];
        
        NSRange whitespaceRange = [commentOnly rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if( whitespaceRange.location != NSNotFound ) {
            commentOnly = [commentOnly substringFromIndex:whitespaceRange.length];
        }
        
        [self addComment:commentOnly];

    }];
    
    __block PLYElement *currentElement = nil;
    
    // go through all of the elements that were previously identified, process each,
    // and add to the working dictionary
    [elementSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSString *fieldString = [fileStringArray objectAtIndex:idx];
        
        NSRange resultRangeElement = [fieldString rangeOfString:kPLYElementKeyword];
        NSRange resultRangeProperty = [fieldString rangeOfString:kPLYPropertyKeyword];

        if( resultRangeElement.location == 0 ) {

            if( currentElement ) {
                [_elements addObject:currentElement];
                currentElement = nil;
            }
            
            currentElement = [[PLYElement alloc] init];
            currentElement.elementString = fieldString;
            
        } else if( resultRangeProperty.location == 0 ) {
            
            if( currentElement ) {
                [currentElement addPropertyWithString:fieldString];
            }
        }
        
    }];
    
    
    if( currentElement ) {
        [_elements addObject:currentElement];
        currentElement = nil;
    }
    
    // now we have the header data ready. now read some data using the _element
    // ordered array, since the data section of the .ply file follows the same
    // ordering as used in declaring the elements in the header

    NSUInteger filePosition = [endHeaderSet firstIndex]+1;

    PLYElement *nextElement = nil;
    NSUInteger readLines = 0;
    
    for( nextElement in _elements ) {
        
        readLines = [nextElement readFromStrings:fileStringArray startIndex:filePosition];
        filePosition += readLines;
        
    }
    
    return YES;
}

- (BOOL)writeToURL:(NSURL *)url format:(PLYDataFormatType)format
{
    return NO;
}

#pragma mark Incremental addition methods

- (void)addComment:(NSString *)commentString
{
    if(_comments) {
        [_comments addObject:commentString];
    } else {
        _comments = [NSMutableArray arrayWithObject:commentString];
    }
}

- (PLYElement *)addElement:(NSString *)name count:(NSUInteger)count
{
    PLYElement *newElement = [[PLYElement alloc] init];

    newElement.name = name;
    newElement.count = count;
    
    return newElement;
}

- (PLYElement *)getElementWithName:(NSString *)name
{
    PLYElement *nextElement = nil;
    
    for(nextElement in _elements) {
        if( [nextElement.name isEqualToString:name] ) {
            return nextElement;
        }
    }
    
    return nil;
}

@end
