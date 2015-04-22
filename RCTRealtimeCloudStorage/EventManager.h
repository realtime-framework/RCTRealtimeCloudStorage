//
//  EventManager.h
//  RealTimeCloudStorage
//
//  Created by Lion User on 02/12/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "StorageContext.h"

@class Event;

@interface EventManager : NSObject{
    StorageContext *context;
    NSMutableDictionary *events;
}

- (id) initWithContext:(StorageContext*) aContext;

- (void) addEvent:(Event*)anEvent;
- (void) delEvent:(Event*)anEvent;
- (void) delEventsForChannel:(NSString*) aChannel eventType:(StorageEventType)anEventType;
- (void) processMessage:(NSString*)aChannel eventType:(StorageEventType)anEventType itemSnapshot:(ItemSnapshot*)anItemSnapshot;

- (void) enablePushNotificationsForTableRef:(TableRef*)tableRef;
- (void) disablePushNotificationsForTableRef:(TableRef*)tableRef;

- (void) enablePushNotificationsForItemRef:(ItemRef*)itemRef;
- (void) disablePushNotificationsForItemRef:(ItemRef*)itemRef;


@end


@interface Subscription : NSObject

@property BOOL isSubscribed;
@property BOOL toBeSubscribed;
@property BOOL toBeUnsubscribed;
@property BOOL toBeReSubscribed;
@property BOOL subscribeWithNotifications;

- (id) init;

@end