JSAutoEncodedObject
===================

#### Automatically encode or decode any Objective-C object

* No need to write manual NSCoding implementations, just inherit from JSAutoEncodedObject and all NSData or NSDictionary encoding and decoding will be done automatically for your class.
* Provides an override point, to let you specify any properties you don't want to encode for a specific class.
* Super-useful when working with Apple's NSData-based APIs, such as NSUserDefaults or GameCenter, or when working with JSON.

#### Here's how to use JSAutoEncodedObject:

##### Inherit from JSAutoEncodedObject

```objective-c
#import "JSAutoEncodedObject.h"

@interface MyClass : JSAutoEncodedObject

@end
```

##### Optional: Provide a schema that JSAutoEncodedObject will use when encoding/decoding your objects

```objective-c
+ (JSAutoEncodedObjectSchema *)schema
{
	return [JSAutoEncodedObjectSchema schemaFromDictionary:@{
		@"property1": @"p1",
		@"property2": @"p2"
	}];
}
```

##### Optional: Override -encodedValueForPropertyNamed: and/or -setValueForPropertyNamed:toDecodedValue: to add custom encoding/decoding to a specific property

```objective-c
- (id)encodedValueForPropertyNamed:(NSString *)propertyName
{
	if ([propertyName isEqualToString:@"specialProperty"]) {
		return [self.specialProperty stringByAppendingString:@"aCustomSuffix"];
	}

	return [super encodedValueForPropertyNamed:propertyName];
}

- (void)setValueForPropertyNamed:(NSString *)propertyName toDecodedValue:(id)decodedValue
{
	if ([propertyName isEqualToString:@"specialProperty"]) {
		NSString *decodedString = [decodedValue stringByReplacingOccurrencesOfString:@"aCustomSuffix" withString:@""];
		[super setValueForPropertyNamed:propertyName toDecodedValue:decodedString];
		return;
	}

	[super setValueForPropertyNamed:propertyName toDecodedValue:decodedValue];
}
```

##### Encoding/decoding to/from NSData

Instances from your class will now be automatically encoded to NSData when used with NSKeyedArchiver:

```objective-c
NSData *data = [NSKeyedArchiver archivedDataWithRootObject:myClassInstance];
```

Decoding will also be done automatically:

```objective-c
MyClass *decodedInstance = [NSKeyedUnarchiver unarchiveObjectWithData:data];
```

##### Serializing/deserializing to/from an NSDictionary

You may now also automatically serialize instances of your class to an NSDictionary:

```objective-c
NSDictionary *dictionary = [myClassInstance serializeToDictionary];
```

And back:

```objective-c
MyClass *decodedInstance = [[MyClass alloc] initWithDictionary:dictionary];
```

#### Parse-support

JSAutoEncodedObject also comes with Parse-support for converting your model objects to/from Parse's PFObject (see [www.parse.com](http://www.parse.com) for more info).
Parse-support is provided through the `JSAutoEncodedObject+Parse` category.

#### Hope that you'll enjoy using JSAutoEncodedObject!

Why not give me a shout on Twitter: [@johnsundell](https://twitter.com/johnsundell)
