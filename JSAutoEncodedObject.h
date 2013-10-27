//
//  JSAutoEncodedObject
//  Copyright (c) 2013 John Sundell
//

#import <Foundation/Foundation.h>

/**
 *  A class that automatically encodes/decodes all of its properties
 *  when -initWithCoder: or -encodeWithCoder: is sent to it.
 *
 *  @discussion Meant to be used in an abstract manner, inherit from
 *  this class to provide automatic encoding/decoding to the subclass.
 */
@interface JSAutoEncodedObject : NSObject <NSCoding>

/**
 *  Return an array of NSString * objects containing property names
 *  that should not be automatically encoded or decoded.
 *
 *  @discussion Defaults to nil.
 */
+ (NSArray *)encodingExcludedPropertyNames;

/**
 *  Returns the value that should be encoded for a specific property.
 *  Called for every property the object has when -initWithCoder: is
 *  sent to it.
 *
 *  @param propertyName The name of the property about to be encoded.
 *
 *  @discussion Override this method in a subclass to provide custom
 *  encoding on a property name basis.
 */
- (id)encodedValueForPropertyNamed:(NSString *)propertyName;

/**
 *  Sets the object's value for a property to a recently decoded value.
 *  Called for every property the object has when -initWithCoder: is
 *  sent to it.
 *
 *  @param propertyName The name of the property that is about to be
 *  assigned.
 *  @param decodedValue The decoded value that the property is about
 *  to be set to.
 *
 *  @discussion Override this method in a subclass to provide custom
 *  decoding on a property name basis.
 */
- (void)setValueForPropertyNamed:(NSString *)propertyName toDecodedValue:(id)decodedValue;

@end
