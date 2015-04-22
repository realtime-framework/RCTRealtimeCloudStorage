//
//  Filter.m
//  RealtimeCloudStorage
//
//  Created by RealTime on 08/08/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import "Filter.h"

@implementation Filter

- (id)initWithParams:(StorageFilter) aOperator item:(NSString*)aItem value:(NSObject*)aValue{
    return [self initWithParamsEx:aOperator item:aItem value:aValue valueEx:nil];
}
- (id)initWithParamsEx:(StorageFilter) aOperator item:(NSString*)aItem value:(NSObject*)aValue valueEx:(NSObject*)aValueEx{
    if ((self = [super init])) {
 		self.fOperator = aOperator;
        self.item = aItem;
        self.value = aValue;
        self.valueEx = aValueEx;
    }
    return self;
}
- (NSString*) getJSON{
    if(self.fOperator == StorageFilter_BETWEEN){
        if([self.value isKindOfClass:[NSString class]])
           return [NSString stringWithFormat:@"{\"operator\":\"%@\", \"item\":\"%@\", \"value\":[\"%@\", \"%@\"]}", [self getfilterOperatorString], self.item, self.value, self.valueEx];
        else
           return [NSString stringWithFormat:@"{\"operator\":\"%@\", \"item\":\"%@\", \"value\":[%@, %@]}", [self getfilterOperatorString], self.item, self.value, self.valueEx];
    }
    if(self.fOperator == StorageFilter_NOTNULL || self.fOperator == StorageFilter_NULL)
        return [NSString stringWithFormat:@"{\"operator\":\"%@\", \"item\":\"%@\"}", [self getfilterOperatorString], self.item];
    if([self.value isKindOfClass:[NSString class]])
        return [NSString stringWithFormat:@"{\"operator\":\"%@\", \"item\":\"%@\", \"value\":\"%@\"}", [self getfilterOperatorString], self.item, self.value];
    else
        return [NSString stringWithFormat:@"{\"operator\":\"%@\", \"item\":\"%@\", \"value\":%@}", [self getfilterOperatorString], self.item, self.value];
}

- (NSString*) getfilterOperatorString{
    switch(self.fOperator) {
        case StorageFilter_EQUALS: return @"equals";
        case StorageFilter_NOTEQUAL: return @"notEqual";
        case StorageFilter_GREATEREQUAL: return @"greaterEqual";
        case StorageFilter_GREATERTHAN: return @"greaterThan";
        case StorageFilter_LESSEREQUAL: return @"lessEqual";
        case StorageFilter_LESSERTHAN: return @"lessThan";
        case StorageFilter_NOTNULL: return @"notNull";
        case StorageFilter_NULL: return @"null";
        case StorageFilter_CONTAINS: return @"contains";
        case StorageFilter_NOTCONTAINS: return @"notContains";
        case StorageFilter_BEGINSWITH: return @"beginsWith";
        case StorageFilter_BETWEEN: return @"between";
    }
}

@end
