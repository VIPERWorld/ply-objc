//
//  PLYObject.h
//  PLYObject
//
//  Created by David Brown on 1/18/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class to represent a polygon object related to the PLY file format.
 @cite http://www.mathworks.com/matlabcentral/fx_files/5459/1/content/ply.htm 
 */
@interface PLYObject : NSObject

/**
 All of the comment fields in the file
 */
@property (readwrite) NSArray *comments;

/**
 All of the elements defined in the file
 */
@property (readwrite) NSDictionary *elements;

/**
 Reads a PLYObject from a .ply file
 @param url the url to read the .ply file from
 @return returns an error object if a problem occurred or nil if everythign was fine.
 */
- (BOOL)readFromURL:(NSURL *)url error:(NSError **)error;

/**
 Obtain the binary data for the supplied element name
 @param elementName the name of the element
 @return data object for the element, or nil if data is not available
 */
- (NSData *)dataForElementName:(NSString *)elementName;


/**
 Obtain an array of sizes (in bytes) for each property of the element
 name provided.
 @param elementName the name of the element
 @return array object with sizes in bytes for each property in the element
 in order of their appearance in the data set.
 */
- (NSArray *)sizesForElementName:(NSString *)elementName;

/**
 Obtain an array of OpenGL type identifiers for each property in the element
 @param elementName the name of the element
 @return array object with the OpenGL type identifiers as values for each
 property in the element in order of their appearance in the data set.
 */
- (NSArray *)GLtypesForElementName:(NSString *)elementName;

/**
 Obtain an array of property names in the element
 @param elementName the name of the element
 @return array object with the property names for the element, in order of
 their appearance in the data set
 */
- (NSArray *)propertyNamesForElementName:(NSString *)elementName;

@end
