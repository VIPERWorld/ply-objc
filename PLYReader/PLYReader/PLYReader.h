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
// key: elements object: NSArray elementStrings
// key: <element 1 name> obj: NSDictionary element1Properties
// key: <element 2 name> obj: NSDictionary element2Properties
// key: <element 3 name> obj: NSDictionary element3Properties
//
// elementPropertyDictionary
// key: <property 1 name> obj: typeofEnum
//

NSString *const kPLYReaderHeaderKey = @"header";
NSString *const kPLYReaderFormatKey = @"format";
NSString *const kPLYReaderCommentKey = @"comment";
NSString *const kPLYReaderElementsKey = @"elements";

@interface PLYReader : NSObject

- (id) initWithURL:(NSURL *)url;

- (NSDictionary *)PLYDictionary;

@end
