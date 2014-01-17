//
//  PLYReader.h
//  PLYReader
//
//  Created by David Brown on 1/15/14.
//  Copyright (c) 2014 David T. Brown. All rights reserved.
//
//  @cite http://www.mathworks.com/matlabcentral/fx_files/5459/1/content/ply.htm

#import <Foundation/Foundation.h>

// plyDictionary:
// key: header obj: headerDictionary
// key: <element 1 name> obj: element1BinaryData
// key: <element 2 name> obj: element2BinaryData
//
// headerDictionary
// key: format object: NSNumber formatType
// key: comment object: NSArray commentStrings
// key: elements object: NSArray elementProperties
//
// elementPropertyDictionary
// key: element.count obj: NSNumber count
// key: element.name obj: NSString name
// key: element.properties obj: NSArray properties
//

NSString *const kPLYReaderHeaderKey = @"header";
NSString *const kPLYReaderFormatKey = @"format";
NSString *const kPLYReaderCommentKey = @"comment";
NSString *const kPLYReaderElementsKey = @"elements";

NSString *const kPLYReaderElementPropertyKey = @"element.properties";
NSString *const kPLYReaderElementCountKey = @"element.count";
NSString *const kPLYReaderElementNameKey = @"element.name";

NSString *const kPLYReaderPropertyCountSizeKey = @"property.countsize";
NSString *const kPLYReaderPropertyDataSizeKey = @"property.datasize";
NSString *const kPLYReaderPropertyNameKey = @"property.name";

@interface PLYReader : NSObject

- (id) initWithURL:(NSURL *)url;

- (NSDictionary *)PLYDictionary;

@end
