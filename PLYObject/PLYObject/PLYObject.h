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

@end
