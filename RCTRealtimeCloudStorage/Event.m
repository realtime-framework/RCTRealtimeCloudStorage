//
//  Event.m
//  RealtimeCloudStorage
//
//  Created by RealTime on 21/08/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import "Event.h"
#import "StorageContext.h"
#import "RealTimeCloudStorage.h"

@implementation Event

- (id)initWithBlock:(StorageContext*)aContext eventType:(StorageEventType)aType tableName:(NSString*)aTableName primaryKey:(NSString*)aPrimary secondaryKey:(NSString*)aSecondary isOnce:(BOOL)aIsOnce callback:(void (^)(ItemSnapshot*)) aCallback{
    if ((self = [super init])) {
        context = aContext;
        type = aType;
        tableName = aTableName;
        primaryKey = aPrimary;
        secondaryKey = aSecondary;
        isOnce = aIsOnce;
        isSubscribed = false;
        callback = aCallback;
        state = 0;
    }
    return self;
}

- (id)initWithSelector:(StorageContext*)aContext eventType:(StorageEventType)aType tableName:(NSString*)aTableName primaryKey:(NSString*)aPrimary secondaryKey:(NSString*)aSecondary isOnce:(BOOL)aIsOnce objectToNotify:(id)objToNotify  selector:(SEL) aSelector{
    if ((self = [super init])) {
        context = aContext;
        type = aType;
        tableName = aTableName;
        primaryKey = aPrimary;
        secondaryKey = aSecondary;
        isOnce = aIsOnce;
        isSubscribed = false;
        callback = nil;
        caller = objToNotify;
        callerSelector = aSelector;
        state = 0;
    }
    return self;
}

- (NSString*) getChannelName{
    //return [NSString stringWithFormat:@"rtcs_%@", tableName];
    
    if(primaryKey==nil)
        return [NSString stringWithFormat:@"rtcs_%@", tableName];
    else if (secondaryKey==nil)
        return [NSString stringWithFormat:@"rtcs_%@:%@", tableName, primaryKey];
    else
        return [NSString stringWithFormat:@"rtcs_%@:%@_%@", tableName, primaryKey, secondaryKey];
}

- (void) setSubscribed{
    isSubscribed = true;
}


- (BOOL) isOnce{
    return isOnce;
}

- (NSString*) getTableName{
    return tableName;
}

- (id) getCaller{
    return caller;
}
- (SEL) getSelector{
    return callerSelector;
}

- (StorageEventType) getType{
    return type;
}

- (NSString*) getPrimary{
    return primaryKey;
}
- (NSString*) getSecondary{
    return secondaryKey;
}

- (void) callTheCallback:(ItemSnapshot*)item{
    if(callback!=nil) {
        callback(item);
    } else {
        [caller performSelector:callerSelector withObject:item];
    }
}

@end
