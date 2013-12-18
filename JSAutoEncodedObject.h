//
//  JSAutoEncodedObject
//  Copyright (c) 2013 John Sundell
//

#import <Foundation/Foundation.h>

@class JSAutoEncodedObjectSchema;

#pragma mark - JSAutoEncodedObject

/**
 *  A class that automatically encodes/decodes all of its properties
 *  when -initWithCoder: or -encodeWithCoder: is sent to it.
 *
 *  @discussion Meant to be used in an abstract manner, inherit from
 *  this class to provide automatic encoding/decoding to the subclass.
 */
@interface JSAutoEncodedObject : NSObject <NSCoding>

/**
 *  Return the schema to use when encoding/decoding an instance of this
 *  class from/to NSData. JSAutoEncodedObject will call this method once
 *  per encoding/decoding.
 *
 *  @discussion Defaults to a schema containing all the properties the
 *  class (and all its superclasses up to NSObject) has, with their
 *  original names retained.
 *  
 *  Override this method in a subclass to provide a custom schema.
 *  This method must not return nil.
 *
 *  @see JSAutoEncodedObjectSchema.
 */
+ (JSAutoEncodedObjectSchema *)schema;

/**
 *  Return an array of NSString * objects containing property names
 *  that should not be automatically encoded or decoded.
 *
 *  @discussion Defaults to nil. The names returned by this method
 *  will be removed from the schema used by the class.
 *
 *  @deprecated This method is deprecated in favor of using schemas
 *  to provide more dynamic encoding/decoding.
 */
+ (NSArray *)encodingExcludedPropertyNames __deprecated_msg("This method is deprecated in favor of schemas");

/**
 *  Sent to an instance that is just about to be encoded or decoded
 *
 *  @param schema The schema that will be used to encode the object
 *
 *  @discussion This method may be used as an override point to provide
 *  custom schemas on an object instance basis.
 *
 *  @return The schema that should be used for encoding or decoding.
 *  By default this method simply returns its parameter, obtained by
 *  calling [[self class] schema]. This method must not return nil.
 */
- (JSAutoEncodedObjectSchema *)willEncodeOrDecodeUsingSchema:(JSAutoEncodedObjectSchema *)schema;

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

#pragma mark - DictionarySerialization

/**
 *  Category that enables a JSAutoEncodedObject to be serialized/
 *  deserialized to/from an NSDictionary.
 */
@interface JSAutoEncodedObject (DictionarySerialization)

/**
 *  Initialize an instance of JSAutoEncodedObject with a dictionary
 *
 *  @param dictionary The dictionary to use. The dictionary will be
 *  compared to the object's schema, and the values for all matching keys
 *  will be assigned to the corresponding properties on the object.
 *
 *  @discussion If dictionary is nil, this method will return nil.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Serialize an instance to an NSDictionary. The object's schema
 *  will be used to determine the dictionary keys for the object's properties.
 *
 *	@return A dictionary representation of the object's properties. If the
 *  object has no properties, an empty dictionary is returned.
 */
- (NSDictionary *)serializeToDictionary;

@end

#pragma mark - JSAutoEncodedObjectSchema

/**
 *  Class describing a schema to use when encoding/decoding an instance
 *  of JSAutoEncodedObject.
 */
@interface JSAutoEncodedObjectSchema : NSObject

/**
 *  Create a schema containing all the properties in a class, with
 *  their original names retained.
 *
 *  @param class The class to create a schema for. The class must inherit
 *  from JSAutoEncodedObject.
 *
 *  @discussion This constructor is very useful when only a few properties
 *  should be changed, as to not have to create a full schema manually.
 */
+ (instancetype)schemaForClass:(Class)theClass;

/**
 *  Create a schema containing all the properties in a class, with
 *  their names minimized according to the minimum length name
 *  available.
 *
 *  @param theClass The class to create a schema for. The class must inherit
 *  from JSAutoEncodedObject.
 *
 *  @discussion The minimum encoded name for each property (ordered alphabetically)
 *  is determined by starting from the beginning of the name, and selecting the
 *  minimum length name available. For example; a propety called "score" will be
 *  encoded as "s", and if a "size" property is also present, that will be encoded
 *  as "si" (since "s" is already taken).
 */
+ (instancetype)autoMinimizedSchemaForClass:(Class)theClass;

/**
 *  Create a schema from a dictonary, where each key => value mapping
 *  corresponds to a propertyName => encodedPropertyName mapping.
 *
 *  @param dictionary The dictonary to use to create the schema
 *
 *  @see -setEncodedPropertyName:forPropertyName.
 */
+ (instancetype)schemaFromDictionary:(NSDictionary *)dictionary;

/**
 *  Create a schema from an array, where each member of the array
 *  represents a property name that should be included in the
 *  schema.
 *
 *  @param array The array to use to create the schema.
 *  All members of the array must be NSString * objects.
 */
+ (instancetype)schemaFromArray:(NSArray *)array;

/**
 *  Associate a property name with an encoded property name
 *
 *  @param encodedPropertyName The name the property will
 *  have when encoded
 *  @param propertyName The property name to set a specific
 *  encoded property name for
 *
 *  @discussion When an auto encoded object using this schema
 *  is encoded, the encodedPropertyName will be used instead
 *  of the actual property name. This is useful when minimizing
 *  data, or when conforming to an external data schema.
 *
 *  Any existing mapping for the given propertyName will be
 *  overrided by this new mapping.
 */
- (void)setEncodedPropertyName:(NSString *)encodedPropertyName
               forPropertyName:(NSString *)propertyName;

/**
 *  Remove an array of property names from the schema
 *
 *  @param propertyNames An array of property names to remove.
 *  All members of the array must be NSString * objects.
 */
- (void)removePropertyNames:(NSArray *)propertyNames;

@end