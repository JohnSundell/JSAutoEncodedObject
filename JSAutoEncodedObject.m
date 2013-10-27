//
//  JSAutoEncodedObject
//  Copyright (c) 2013 John Sundell
//

#import "JSAutoEncodedObject.h"
#import <objc/runtime.h>

@implementation JSAutoEncodedObject

+ (NSArray *)encodingExcludedPropertyNames
{
    return nil;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (!(self = [super init])) {
        return nil;
    }
    
    NSArray *propertyNames = [self encodablePropertyNames];
    
    for (NSString *propertyName in propertyNames) {
        id propertyValue = [decoder decodeObjectForKey:propertyName];
        
        if (propertyValue) {
            [self setValueForPropertyNamed:propertyName toDecodedValue:propertyValue];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSArray *propertyNames = [self encodablePropertyNames];
    
    for (NSString *propertyName in propertyNames) {
        [coder encodeObject:[self encodedValueForPropertyNamed:propertyName] forKey:propertyName];
    }
}

- (id)encodedValueForPropertyNamed:(NSString *)propertyName
{
    return [self valueForKey:propertyName];
}

- (void)setValueForPropertyNamed:(NSString *)propertyName toDecodedValue:(id)decodedValue
{
    [self setValue:decodedValue forKey:propertyName];
}

- (NSArray *)encodablePropertyNames
{
    NSMutableArray *propertyNames = [NSMutableArray new];
    
    Class currentClass = [self class];
    
    while (currentClass != [NSObject class]) {
        NSArray *excludedPropertyNames = [currentClass encodingExcludedPropertyNames];
        
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            
            if (![excludedPropertyNames containsObject:propertyName] && ![propertyNames containsObject:propertyNames]) {
                [propertyNames addObject:propertyName];
            }
        }
        
        free(propertyList);
        
        currentClass = [currentClass superclass];
    }
    
    return propertyNames;
}

@end
