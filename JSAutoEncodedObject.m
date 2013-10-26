//
//  JSAutoEncodedObject
//  Copyright (c) 2013 John Sundell
//

#import "JSAutoEncodedObject.h"
#import <objc/runtime.h>

@implementation JSAutoEncodedObject

- (id)initWithCoder:(NSCoder *)decoder
{
    if (!(self = [super init])) {
        return nil;
    }
    
    NSArray *propertyNames = [self encodablePropertyNames];
    
    for (NSString *propertyName in propertyNames) {
        [self setValue:[decoder decodeObjectForKey:propertyName] forKey:propertyName];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSArray *propertyNames = [self encodablePropertyNames];
    
    for (NSString *propertyName in propertyNames) {
        [coder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
}

- (NSArray *)encodablePropertyNames
{
    NSMutableArray *propertyNames = [NSMutableArray new];
    NSArray *excludedPropertyNames = [self encodingExcludedPropertyNames];
    
    unsigned int propertyCount;
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        if (![excludedPropertyNames containsObject:propertyName]) {
            [propertyNames addObject:propertyName];
        }
    }
    
    free(propertyList);
    
    return propertyNames;
}

- (NSArray *)encodingExcludedPropertyNames
{
    return nil;
}

@end
