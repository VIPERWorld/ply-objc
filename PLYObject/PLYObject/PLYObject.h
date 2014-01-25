//
//  PLYObject.h
//  PLYObject
//
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLYElement, PLYProperty;

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
 An array of element names
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
 @param error an error object if a problem occurred
 @return true if successful read occured.
 */
- (BOOL)writeToURL:(NSURL *)url error:(NSError **)error;



/**
 Obtain the binary data for the supplied element name
 @param elementName the name of the element
 @return data object for the element, or nil if data is not available
 */
- (NSData *)dataForElement:(NSString *)elementName;

/**
 */
// a property has a name, type, and is associated with an element
// a list-type property has a name, count type, data type, and is associated with an element
//
// listProperty = [element addListProperty:propName countType:type dataType:type]
// property = [element addProperty:propName dataType:type]
//
// [listProperty
//
// [element setData:meshData];
// NSData *meshData = [element data];
//
// an element has a name, count
//
// element = [object addElement:elementName count:count];
//
//
//



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
 @return the element object in the PLYObject
 */
- (PLYElement *)getElement:(NSString *)name;


/**
 */



@end
