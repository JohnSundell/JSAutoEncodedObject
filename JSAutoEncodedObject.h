//
//  JSAutoEncodedObject
//  Copyright (c) 2013 John Sundell
//

#import <Foundation/Foundation.h>

/**
 *  A class that automatically encodes/decodes all of its
 *  properties when -initWithCoder: and -encodeWithCoder
 *  is sent to it.
 *
 *  @discussion Meant to be used in an abstract manner,
 *  inherit from this class to provide automatic encoding/
 *  decoding to the subclass.
 */
@interface JSAutoEncodedObject : NSObject <NSCoding>

/**
 *  Return an array of NSString * objects containing property names
 *  that should not be automatically encoded or decoded.
 *
 *  @discussion Defaults to nil.
 */
- (NSArray *)encodingExcludedPropertyNames;

@end
