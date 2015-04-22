//
//  Event.h
//  RealtimeCloudStorage
//
//  Created by RealTime on 21/08/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StorageContext.h"

@class StorageContext;
@class ItemSnapshot;

@interface Event : NSObject{
    StorageContext *context;
    StorageEventType type;
    NSString *tableName;
    NSString *primaryKey;
    NSString *secondaryKey;
    BOOL isOnce;
    BOOL isSubscribed;
    void (^callback)(ItemSnapshot*);
    id caller;
    SEL callerSelector;
    int state;
}

@property (nonatomic, readwrite) BOOL pushNotificationsEnable;

- (id)initWithBlock:(StorageContext*)aContext eventType:(StorageEventType)aType tableName:(NSString*)aTableName primaryKey:(NSString*)aPrimary secondaryKey:(NSString*)aSecondary isOnce:(BOOL)aIsOnce callback:(void (^)(ItemSnapshot*)) aCallback;
- (id)initWithSelector:(StorageContext*)aContext eventType:(StorageEventType)aType tableName:(NSString*)aTableName primaryKey:(NSString*)aPrimary secondaryKey:(NSString*)aSecondary isOnce:(BOOL)aIsOnce objectToNotify:(id)objToNotify  selector:(SEL) aSelector;

- (NSString*) getChannelName;
- (void) setSubscribed;
- (BOOL) isOnce;
- (NSString*) getTableName;
- (id) getCaller;
- (SEL) getSelector;
- (StorageEventType) getType;
- (NSString*) getPrimary;
- (NSString*) getSecondary;
- (void) callTheCallback:(ItemSnapshot*)item;

@end
