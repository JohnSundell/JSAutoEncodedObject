JSAutoEncodedObject
===================

#### Automatically encode or decode any Objective-C object

* No need to write manual NSCoding implementations, just inherit from JSAutoEncodedObject and all NSData encoding and decoding will be done automatically for your class.
* Provides an override point, to let you specify any properties you don't want to encode for a specific class.
* Super-useful when working with Apple's NSData-based APIs, such as NSUserDefaults or GameCenter.

#### Here's how to use JSAutoEncodedObject:

#### 1. Inherit from JSAutoEncodedObject

```objective-c
#import "JSAutoEncodedObject.h"

@interface MyClass : JSAutoEncodedObject

@end
```

#### 2. Optional: Override -encodingExcludedPropertyNames if your class has any properties that you don't want to automatically encode/decode

```objective-c
- (NSArray *)encodingExcludedPropertyNames
{
	return @[@"nonEncodedProperty"];
}
```

#### 3. Done! You can now encode or decode your class and let JSAutoEncodedObject take care of the rest

```objective-c
NSData *data = [NSKeyedArchiver archivedDataWithRootObject:myClassInstance];
```

#### Hope that you'll enjoy using JSAutoEncodedObject!

Why not give me a shout on Twitter: [@johnsundell](https://twitter.com/johnsundell)