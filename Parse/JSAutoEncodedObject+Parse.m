//
//  JSAutoEncodedObject + Parse
//  Copyright (c) 2014 John Sundell
//

#import "JSAutoEncodedObject+Parse.h"
#import <Parse/Parse.h>

@implementation JSAutoEncodedObject (Parse)

+ (NSString *)parseClassName
{
    return NSStringFromClass(self);
}

+ (JSAutoEncodedObjectSchema *)parseSchema
{
    return [self schema];
}

- (instancetype)initWithParseObject:(PFObject *)parseObject
{
    if (![parseObject.parseClassName isEqualToString:[[self class] parseClassName]]) {
        return nil;
    }
    
    if (!(self = [self init])) {
        return nil;
    }
    
    JSAutoEncodedObjectSchema *schema = [[self class] parseSchema];
    NSDictionary *schemaDictionary = [schema dictionaryRepresentation];
    
    for (NSString *propertyName in [schemaDictionary allKeys]) {
        NSString *encodedPropertyName = [schemaDictionary objectForKey:propertyName];
        id parseValue = [parseObject objectForKey:encodedPropertyName];
        
        if (parseValue) {
            [self setValueForPropertyNamed:propertyName
                            toDecodedValue:parseValue];
        }
    }
    
    return self;
}

- (PFObject *)parseObject
{
    JSAutoEncodedObjectSchema *schema = [[self class] parseSchema];
    NSDictionary *schemaDictionary = [schema dictionaryRepresentation];
    
    PFObject *parseObject = [PFObject objectWithClassName:[[self class] parseClassName]];
    
    for (NSString *propertyName in [schemaDictionary allKeys]) {
        NSString *encodedPropertyName = [schemaDictionary objectForKey:propertyName];
        id propertyValue = [self encodedValueForPropertyNamed:propertyName];
        
        if ([propertyValue isKindOfClass:[JSAutoEncodedObject class]]) {
            propertyValue = [propertyValue serializeToDictionary];
        }
        
        @try {
            [parseObject setObject:propertyValue forKey:encodedPropertyName];
        }
        @catch (NSException *exception) {
            NSLog(@"The property \"%@\" could not be serialized to a Parse Object", propertyName);
            
            return nil;
        }
    }
    
    return parseObject;
}

@end
