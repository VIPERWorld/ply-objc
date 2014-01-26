//
//  PLYObject.h
//  PLYObject
//
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLYElement, PLYProperty;

typedef enum PLYDataFormatEnum {
    PLYDataFormatUTF8 = 0,
    PLYDataFormatBinaryBigEndian = 1,
    PLYDataFormatBinaryLittleEndian = 2
} PLYDataFormatType;


/**
 Class to represent a polygon object related to the PLY file format.
 @cite http://www.mathworks.com/matlabcentral/fx_files/5459/1/content/ply.htm 
 */
@interface PLYObject : NSObject

/**
 An array of comment fields
 */
@property (readwrite) NSArray *comments;

/**
 An array of element objects
 */
@property (readwrite) NSArray *elements;

/**
 Reads a PLYObject from a .ply file
 @param url the url to read the .ply file from
 @param error an error object if a problem occurred
 @return true if successful read occurred
 */
- (BOOL)readFromURL:(NSURL *)url error:(NSError **)error;

/**
 Writes a PLYObject to a .ply file
 @param url the url to write the .ply file to
 @param format the format type to use for writing
 @return true if successful read occured.
 */
- (BOOL)writeToURL:(NSURL *)url format:(PLYDataFormatType)format;


/**
 Add a comment to the objet
 @param commentString the comment text to add
 @return nothing
 */
- (void)addComment:(NSString *)commentString;

/**
 Add an element to the object
 @param name the name of the element to add
 @param count the number of elements to add
 @return the element object, it is already added to the PLYObject
 */
- (PLYElement *)addElement:(NSString *)name count:(NSUInteger)count;

/**
 Get an element object corresponding to the supplied name
 @param name the name of the object to get
 @return the element object, or nil if it does not exist
 */
- (PLYElement *)getElementWithName:(NSString *)name;

@end
