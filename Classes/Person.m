//
//  Person.m
//  HorzPickerTestApp
//
//  Created by Tapash Mollick on 5/28/15.
//  Copyright (c) 2015 V8 Labs, LLC. All rights reserved.
//

#import "Person.h"

#define kEncodeKeyStringValue   @"kEncodeKeyStringValue"
#define kEncodeKeyIntValue      @"kEncodeKeyIntValue"
#define kEncodeKeyBOOLValue     @"kEncodeKeyBOOLValue"

@implementation Person

@synthesize stringValue;
@synthesize intValue;
@synthesize boolValue;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.stringValue   forKey:kEncodeKeyStringValue];
    [aCoder encodeInt:self.intValue         forKey:kEncodeKeyIntValue];
    [aCoder encodeBool:self.boolValue       forKey:kEncodeKeyBOOLValue];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if(self){
        self.stringValue = [aDecoder decodeObjectForKey:kEncodeKeyStringValue];
        self.intValue    = [aDecoder decodeIntForKey:kEncodeKeyIntValue];
        self.boolValue   = [aDecoder decodeBoolForKey:kEncodeKeyBOOLValue];
    }
    return self;
}
// NS_DESIGNATED_INITIALIZER
@end
