//
//  StorageContext.h
//  RealtimeCloudStorage
//
//  Created by RealTime on 08/08/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrtcClient.h"
#import "RealTimeCloudStorage.h"
#import "EventManager.h"

@class Event;
@class OrtcClient;
@class REST;
@class EventManager;
@class Subscription;

@interface StorageContext : NSObject<OrtcClientDelegate> {
    NSMutableDictionary *tablesMetadata;
    EventManager *eventManager;
    
    OrtcClient *ortc;
    void (^onMessage)(OrtcClient* ortc, NSString* channel, NSString* message);
    bool isReconnecting;
    NSMutableArray *offlineRestBuffer;
    int bufferCounter;
}

@property (nonatomic, retain) NSMutableDictionary *channels;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *authToken;
@property (nonatomic, retain) NSString *prvKey;
@property (nonatomic) BOOL isSecure;
@property (nonatomic) BOOL isCluster;
@property (nonatomic, retain) StorageRef *storage;
@property (nonatomic, copy) void (^onReconnected)(StorageRef *storage);
@property (nonatomic, copy) void (^onReconnecting)(StorageRef *storage);
@property bool bufferIsActive;

- (id) initWithParams:(NSString*) aUrl appKey:(NSString*)aAppKey authToken:(NSString*)aAuthToken prvKey:(NSString*)aPrvKey isCluster:(BOOL)aIsCluster isSecure:(BOOL)aIsSecure;
- (void) addEvent:(Event*)anEvent;
- (void) removeAllSimilarEvents:(Event*)anEvent;
- (void) removeEvent:(Event*)anEvent;


- (NSString*) getCredentialsJSON;
- (void) putTableMetaInCache:(NSString*) aName tableMetadata:(NSDictionary*)aTableMetadata;
- (void) delTableMetaInCache:(NSString*) aName;
- (NSDictionary*) getTableMetaFromCache:(NSString*) aName;
- (NSString*) eventTypeToString:(StorageEventType)aType;
- (void)processREST:(REST*) rest;
- (void) addChannel:(NSString*)channelName WithNotifications:(BOOL) pushNotifications;
- (void) delChannel:(NSString*)channelName;


- (void) enablePushNotificationsForTableRef:(TableRef*)tableRef;
- (void) disablePushNotificationsForTableRef:(TableRef*)tableRef;
- (void) enablePushNotificationsForItemRef:(ItemRef*)itemRef;
- (void) disablePushNotificationsForItemRef:(ItemRef*)itemRef;

@end
