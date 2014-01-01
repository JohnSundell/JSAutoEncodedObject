//
//  JSAutoEncodedObject
//  Copyright (c) 2013 John Sundell
//

#import "JSAutoEncodedObject.h"
#import <objc/runtime.h>

#pragma mark - JSAutoEncodedObjectSchema implementation

@interface JSAutoEncodedObjectSchema()

@property (nonatomic, strong) NSMutableDictionary *propertyNameMap;

@end

@implementation JSAutoEncodedObjectSchema

+ (instancetype)schemaForClass:(Class)theClass
{
    NSMutableArray *propertyNames = [NSMutableArray new];
    
    Class currentClass = theClass;
    
    while (currentClass && currentClass != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            
            if (![propertyNames containsObject:propertyName]) {
                [propertyNames addObject:propertyName];
            }
        }
        
        free(propertyList);
        
        currentClass = [currentClass superclass];
    }
    
    return [self schemaFromArray:propertyNames];
}

+ (instancetype)autoMinimizedSchemaForClass:(Class)theClass
{
    JSAutoEncodedObjectSchema *schema = [self schemaForClass:theClass];
    NSMutableArray *encodedPropertyNames = [[schema allPropertyNames] mutableCopy];
    
    for (NSString *propertyName in [schema allPropertyNames]) {
        NSString *minimizedPropertyName = nil;
        
        while ([minimizedPropertyName length] < [propertyName length]) {
            minimizedPropertyName = [propertyName substringToIndex:[minimizedPropertyName length] + 1];
            
            if (![encodedPropertyNames containsObject:minimizedPropertyName]) {
                [encodedPropertyNames removeObject:propertyName];
                [encodedPropertyNames addObject:minimizedPropertyName];
                
                break;
            }
        }
        
        [schema setEncodedPropertyName:minimizedPropertyName
                       forPropertyName:propertyName];
    }
    
    return schema;
}

+ (instancetype)schemaFromDictionary:(NSDictionary *)dictionary
{
    JSAutoEncodedObjectSchema *schema = [self new];
    schema.propertyNameMap = [dictionary mutableCopy];
    
    return schema;
}

+ (instancetype)schemaFromArray:(NSArray *)array
{
    JSAutoEncodedObjectSchema *schema = [self new];
    schema.propertyNameMap = [NSMutableDictionary new];
    
    for (NSString *propertyName in array) {
        [schema setEncodedPropertyName:propertyName
                       forPropertyName:propertyName];
    }
    
    return schema;
}

- (void)setEncodedPropertyName:(NSString *)encodedPropertyName forPropertyName:(NSString *)propertyName
{
    [self.propertyNameMap setObject:encodedPropertyName forKey:propertyName];
}

- (void)addPropertyNames:(NSArray *)propertyNames
{
    if (!propertyNames) {
        return;
    }
    
    for (NSString *propertyName in propertyNames) {
        [self setEncodedPropertyName:propertyName forPropertyName:propertyName];
    }
}

- (void)removePropertyNames:(NSArray *)propertyNames
{
    if (!propertyNames) {
        return;
    }
    
    for (NSString *propertyName in propertyNames) {
        [self.propertyNameMap removeObjectForKey:propertyName];
    }
}

- (NSString *)encodedPropertyNameForPropertyName:(NSString *)propertyName
{
    return [self.propertyNameMap objectForKey:propertyName];
}

- (NSArray *)allPropertyNames
{
    return [[self.propertyNameMap allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"JSAutoEncodedObjectSchema: %@", self.propertyNameMap];
}

@end

#pragma mark - JSAutoEncodedObject implementation

@implementation JSAutoEncodedObject

#pragma mark - Subclass overrides

+ (JSAutoEncodedObjectSchema *)schema
{
    return [JSAutoEncodedObjectSchema schemaForClass:self];
}

+ (NSArray *)encodingExcludedPropertyNames
{
    return nil;
}

- (JSAutoEncodedObjectSchema *)willEncodeOrDecodeUsingSchema:(JSAutoEncodedObjectSchema *)schema
{
    return schema;
}

- (id)encodedValueForPropertyNamed:(NSString *)propertyName
{
    return [self valueForKey:propertyName];
}

- (void)setValueForPropertyNamed:(NSString *)propertyName toDecodedValue:(id)decodedValue
{
    [self setValue:decodedValue forKey:propertyName];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    if (!(self = [super init])) {
        return nil;
    }
    
    JSAutoEncodedObjectSchema *schema = [self schema];
    
    for (NSString *propertyName in [schema allPropertyNames]) {
        NSString *encodedPropertyName = [schema encodedPropertyNameForPropertyName:propertyName];
        
        id propertyValue = [decoder decodeObjectForKey:encodedPropertyName];
        
        if (propertyValue) {
            [self setValueForPropertyNamed:propertyName
                            toDecodedValue:propertyValue];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    JSAutoEncodedObjectSchema *schema = [self schema];

    for (NSString *propertyName in [schema allPropertyNames]) {
        NSString *encodedPropertyName = [schema encodedPropertyNameForPropertyName:propertyName];
        
        [coder encodeObject:[self encodedValueForPropertyNamed:propertyName]
                     forKey:encodedPropertyName];
    }
}

#pragma mark - Utilities

- (JSAutoEncodedObjectSchema *)schema
{
    JSAutoEncodedObjectSchema *schema = [[self class] schema];
    
    schema = [self willEncodeOrDecodeUsingSchema:schema];
    
    NSAssert(schema, @"No schema defined for instance: %@", self);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    [schema removePropertyNames:[[self class] encodingExcludedPropertyNames]];
    
#pragma clang diagnostic pop
    
    return schema;
}

@end

#pragma mark - DictionarySerialization implementation

@implementation JSAutoEncodedObject (DictionarySerialization)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return nil;
    }
    
    if (!(self = [super init])) {
        return nil;
    }
    
    JSAutoEncodedObjectSchema *schema = [self schema];
    
    for (NSString *propertyName in [schema allPropertyNames]) {
        NSString *encodedPropertyName = [schema encodedPropertyNameForPropertyName:propertyName];
        
        id propertyValue = [dictionary objectForKey:encodedPropertyName];
        
        if (propertyValue) {
            [self setValueForPropertyNamed:propertyName
                            toDecodedValue:propertyValue];
        }
    }
    
    return self;
}

- (NSDictionary *)serializeToDictionary
{
    JSAutoEncodedObjectSchema *schema = [self schema];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    for (NSString *propertyName in [schema allPropertyNames]) {
        NSString *encodedPropertyName = [schema encodedPropertyNameForPropertyName:propertyName];
        
        id propertyValue = [self encodedValueForPropertyNamed:propertyName];
        
        if (propertyValue) {
            [dictionary setObject:propertyValue
                           forKey:encodedPropertyName];
        }
    }
    
    return [dictionary copy];
}

@end