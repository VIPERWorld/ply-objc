//
//  PLYReader.m
//  PLYReader
//
//  Created by David Brown on 1/15/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import "PLYReader.h"

NSString *const kPLYPlyKeyword = @"ply";
NSString *const kPLYHeaderKeyword = @"header";
NSString *const kPLYCommentKeyword = @"comment";
NSString *const kPLYElementKeyword = @"element";
NSString *const kPLYFormatKeyword = @"format";
NSString *const kPLYPropertyKeyword = @"property";
NSString *const kPLYEndHeaderKeyword = @"end_header";

NSString *const kPLYFormatASCIIKeyword = @"ASCII";


@implementation PLYReader
{
    NSURL *_plyURL;
    NSString *_plyFileStrings;
    
    // state/context for use during processing
    NSMutableDictionary *_headerDictionary;
    NSDictionary *_plyDictionary;
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
    }
    return self;
}

- (NSDictionary *)PLYDictionary
{
    NSError *readError = [[NSError alloc] init];
    
    if(_plyDictionary == nil) {

        if( _plyURL == nil ) NSLog(@"PLYReader: No URL supplied.");
        else {

            _plyFileStrings = [NSString stringWithContentsOfURL:_plyURL encoding:NSUTF8StringEncoding error:&readError];
            
            if(_plyFileStrings) {
                NSArray *stringsArray = [_plyFileStrings componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                NSLog(@"found %lu lines",[stringsArray count]);
                
                // scans the file for a ply header and populates the _headerDictionary ivar
                NSUInteger linesRead = [self processHeadersInStrings:stringsArray];
                
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

- (NSUInteger) processHeadersInStrings:(NSArray *)headerStrings
{
    NSString *nextLine = nil;
    NSScanner *lineScanner = [[NSScanner alloc] init];
    NSString *headerKeyword = [[NSString alloc] init];
    
    NSUInteger lineNumber = 0;
    
    NSMutableArray *commentStrings = [[NSMutableArray alloc] init];
    NSMutableArray *elementStrings = [[NSMutableArray alloc] init];
    NSMutableDictionary *elementProperties = [[NSMutableDictionary alloc] init];
    
    BOOL plyFound = NO;
    
    // for each line
    for(nextLine in headerStrings) {

        // re-init with next line string each pass through loop
        lineScanner = [lineScanner initWithString:nextLine];
        
        // ply keyword has no context but indicates a ply formatted file
        if( [lineScanner scanString:kPLYPlyKeyword intoString:&headerKeyword] ) {
            plyFound = YES;
        }
        
        // comment keyword causes remainder of string to be stored
        else if( [lineScanner scanString:kPLYCommentKeyword intoString:&headerKeyword] ) {
            NSString *comment = [[lineScanner string] substringFromIndex:[lineScanner scanLocation]];
            [commentStrings addObject:comment];
        }
        
        // format keyword will inform ascii vs binary
        else if( [lineScanner scanString:kPLYFormatKeyword intoString:&headerKeyword] ) {
            NSLog(@"%@ keyword found but has no handler.",kPLYFormatKeyword);
        }
        
        // element keyword provides element name and count
        else if( [lineScanner scanString:kPLYElementKeyword intoString:&headerKeyword] ) {
            
            NSInteger elementCount = 0;
            NSString *elementName = [[NSString alloc] init];
            
            if( [lineScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                                            intoString:&elementName] &&
                [lineScanner scanInteger:&elementCount] ) {
                    
                [elementStrings addObject:elementName];
                [elementProperties setObject:[NSNumber numberWithInteger:elementCount] forKey:elementName];
                    
            } else {
                NSLog(@"%@ keyword found but corrupted: %@",kPLYElementKeyword, nextLine);
            }
            
        }
        
        // property keyword provides further definition to an element
        else if( [lineScanner scanString:kPLYPropertyKeyword intoString:&headerKeyword] ) {
            NSLog(@"%@ keyword found but has no handler.",kPLYPropertyKeyword);
        }
        
        // end_header keyword causes header processing to stop
        else if( [lineScanner scanString:kPLYEndHeaderKeyword intoString:&headerKeyword] ) {
            break;
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

    _headerDictionary = [NSMutableDictionary dictionaryWithDictionary:elementProperties];
    [_headerDictionary setObject:[NSArray arrayWithArray:commentStrings] forKey:kPLYReaderCommentKey];
    [_headerDictionary setObject:[NSArray arrayWithArray:elementStrings] forKey:kPLYReaderElementsKey];
    
    NSLog(@"Completed reading header: %@",_headerDictionary);
    
    return lineNumber;
}

- (NSUInteger) processElementsInStrings:(NSArray *)fileStrings fromPosition:(NSUInteger)startPosition
{

    return 0;
}





@end
