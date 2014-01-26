//
//  JSAutoEncodedObject + Parse
//  Copyright (c) 2014 John Sundell
//

#import "JSAutoEncodedObject.h"

@class PFObject;

/**
 *  Category adding Parse (www.parse.com) specific
 *  functionality to JSAutoEncodedObject
 */
@interface JSAutoEncodedObject (Parse)

/**
 *  Return the parse class name that should be used for this class
 *
 *  @discussion Defaults to the name of the object's class
 */
+ (NSString *)parseClassName;

/**
 *  Return the schema that should be used when converting an object
 *  of this class from/to a parse object.
 *
 *  @discussion Defaults to the schema returned from +schema.
 */
+ (JSAutoEncodedObjectSchema *)parseSchema;

/**
 *  Initialize an instance of this class with a parse object
 *
 *  @param parseObject The parse object that should be used
 *  to initialize this instance. The values contained within
 *  the parse object will be used to assign values to the
 *  instance's properties.
 *
 *  @discussion The parse object's class name must match the
 *  string returned from +parseClassName by this class, or else
 *  this method will return nil.
 *
 *  Only properties matching the schema returned from +parseSchema
 *  by this class will assigned.
 */
- (instancetype)initWithParseObject:(PFObject *)parseObject;

/**
 *  Return a parse object representation of the object
 */
- (PFObject *)parseObject;

@end
