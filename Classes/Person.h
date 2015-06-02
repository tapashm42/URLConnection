//
//  Person.h
//  HorzPickerTestApp
//
//  Created by Tapash Mollick on 5/28/15.
//  Copyright (c) 2015 V8 Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject<NSCoding>

@property (nonatomic, retain) NSString *stringValue;
@property (nonatomic, assign) int       intValue;
@property (nonatomic, assign) BOOL      boolValue;
@end
