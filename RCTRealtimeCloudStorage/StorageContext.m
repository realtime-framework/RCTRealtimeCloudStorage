//
//  StorageContext.m
//  RealtimeCloudStorage
//
//  Created by RealTime on 08/08/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import "StorageContext.h"
#import "OrtcClient.h"
#import "Event.h"
#import "REST.h"
#import "RealTimeCloudStorage.h"

@implementation StorageContext

@synthesize appKey, authToken, prvKey, url, isCluster, isSecure, storage, onReconnected, onReconnecting, bufferIsActive;

- (id) initWithParams:(NSString*) aUrl appKey:(NSString*)aAppKey authToken:(NSString*)aAuthToken prvKey:(NSString*)aPrvKey isCluster:(BOOL)aIsCluster isSecure:(BOOL)aIsSecure {
    if (self =[super init]){
        tablesMetadata = [[NSMutableDictionary alloc] init];
        _channels = [[NSMutableDictionary alloc] init];
        url = aUrl;
        appKey = aAppKey;
        authToken = aAuthToken;
        isCluster = aIsCluster;
        isSecure = aIsSecure;
        onReconnected = nil;
        onReconnecting = nil;
        isReconnecting = false;
        offlineRestBuffer = [[NSMutableArray alloc] init];
        bufferIsActive = true;
        
        ortc = [OrtcClient ortcClientWithConfig:self];
        
        eventManager = [[EventManager alloc] initWithContext:self];
        
        if(isSecure)
            [ortc setClusterUrl:@"https://ortc-storage.realtime.co/server/ssl/2.1"];
        else
            [ortc setClusterUrl:@"http://ortc-storage.realtime.co/server/2.1"];
            
        __weak typeof(self) weakSelf = self;
        onMessage = ^(OrtcClient* anOrtc, NSString* aChannel, NSString* aMessage) {
            [weakSelf preParseMessage:aChannel message:aMessage];
        };

        
        [ortc connect:self.appKey authenticationToken:self.authToken];
    }
    return self;
}

- (void) _preParseMessage:(NSString*)tabName message:(NSString*)aMessage channel:(NSString*)aChannel{
    NSDictionary *meta = [self getTableMetaFromCache:tabName];
    NSDictionary *mkey = [meta objectForKey:@"key"];
    NSDictionary *primary = [mkey objectForKey:@"primary"];
    NSDictionary *secondary = [mkey objectForKey:@"secondary"];
    NSString *primaryName = nil, *secondaryName = nil, *primaryVal = nil, *secondaryVal = nil;
    primaryName = [primary objectForKey:@"name"];
    NSError *parseError = nil;
    NSDictionary *iMess= [NSJSONSerialization JSONObjectWithData:[aMessage dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&parseError];
    NSDictionary *itemDic = [iMess objectForKey:@"data"];
    primaryVal = [itemDic objectForKey:primaryName];
    if(secondary!=nil){
        secondaryName = [secondary objectForKey:@"name"];
        secondaryVal = [itemDic objectForKey:secondaryName];
    }
    NSString *type = [iMess objectForKey:@"type"];
    
    ItemSnapshot *iSnapshot = nil;
    if(itemDic != nil){
        iSnapshot = [[ItemSnapshot alloc] initWithRefContextAndVal:[[TableRef alloc] initWithName:tabName context:self] storageContext:self val:itemDic];
        [eventManager processMessage:aChannel eventType:[self eventTypeFromString:type] itemSnapshot:iSnapshot];
    }
}

- (void) preParseMessage:(NSString*)aChannel message:(NSString*)aMessage{
    NSString *name = [aChannel substringFromIndex:5]; //remove the rtcs_ prefix
    NSRange range = [name rangeOfString:@":"];
    if(range.location !=NSNotFound){
        name = [name substringToIndex:range.location];
    }
    NSDictionary *meta = [self getTableMetaFromCache:name];
    if(meta==nil){
        void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* d){
            [self _preParseMessage:name message:aMessage channel:aChannel];
        };
        TableRef *tr = [[TableRef alloc] initWithName:name context:self];
        [tr meta:cbSuccess error:nil];
    } else {
        [self _preParseMessage:name message:aMessage channel:aChannel];
    }
}

- (void) addEvent:(Event*)anEvent{
    [eventManager addEvent:anEvent];
}

- (void) removeAllSimilarEvents:(Event*)anEvent{
    NSString *channelName = [anEvent getChannelName];
    [eventManager delEventsForChannel:channelName eventType:[anEvent getType]];
}
- (void) removeEvent:(Event*)anEvent{
    [eventManager delEvent:anEvent];
}

- (NSString*) getCredentialsJSON{
    if([self.prvKey length] == 0 && [self.authToken length] == 0){
        return [NSString stringWithFormat:@"\"applicationKey\":\"%@\"", self.appKey];
    }
    if([self.prvKey length] == 0 && [self.authToken length] != 0){
        return [NSString stringWithFormat:@"\"applicationKey\":\"%@\", \"authenticationToken\":\"%@\"", self.appKey, self.authToken];
    }
    if([self.prvKey length] != 0 && [self.authToken length] == 0){
        return [NSString stringWithFormat:@"\"applicationKey\":\"%@\", \"privateKey\":\"%@\"", self.appKey, self.prvKey];
    }
    if([self.prvKey length] != 0 && [self.authToken length] != 0){
        return [NSString stringWithFormat:@"\"applicationKey\":\"%@\", \"authenticationToken\":\"%@\", \"privateKey\":\"%@\"", self.appKey, self.authToken, self.prvKey];
    }
    return @"error";
}

- (void) putTableMetaInCache:(NSString*) aName tableMetadata:(NSDictionary*)aTableMetadata{
    [tablesMetadata setValue:aTableMetadata forKey:aName];
}

- (void) delTableMetaInCache:(NSString*) aName{
    [tablesMetadata removeObjectForKey:aName];
}

- (NSDictionary*) getTableMetaFromCache:(NSString*) aName{
    return [tablesMetadata objectForKey:aName];
}


- (NSString*) eventTypeToString:(StorageEventType)aType{
    switch(aType){
        case StorageEvent_DELETE: return @"delete";
        case StorageEvent_PUT: return @"put";
        case StorageEvent_UPDATE: return @"update";
    }
}

- (StorageEventType) eventTypeFromString:(NSString*)aType{
    if([aType isEqualToString:@"put"]){
        return StorageEvent_PUT;
    }
    if([aType isEqualToString:@"delete"]){
        return StorageEvent_DELETE;
    }
    return StorageEvent_UPDATE;
}

// ORTC
- (void) onConnected:(OrtcClient*) aOrtc {
    NSEnumerator *e = [_channels keyEnumerator];
    id key;
    while((key = [e nextObject])){
        Subscription *sub = [_channels objectForKey:key];
        if(!sub.isSubscribed && sub.toBeSubscribed){
			if (sub.subscribeWithNotifications) {
				[ortc subscribeWithNotifications:key subscribeOnReconnected:true onMessage:onMessage];
			}
			else {
				[ortc subscribe:key subscribeOnReconnected:true onMessage:onMessage];
			}
        }
    }
}
- (void) onDisconnected:(OrtcClient*) aOrtc {
}
- (void) onReconnecting:(OrtcClient*) aOrtc {
    isReconnecting = true;
    if(self.onReconnecting)
        self.onReconnecting(storage);
}

- (void) callNextFromBuffer{
    REST *r = [offlineRestBuffer objectAtIndex:bufferCounter];
    bufferCounter++;
    if(bufferCounter < [offlineRestBuffer count]){
        r.onCompleted = ^() { [self callNextFromBuffer]; };
    } else {
        [offlineRestBuffer removeAllObjects];
    }
    [r doRest];
}

- (void) onReconnected:(OrtcClient*) aOrtc {
    isReconnecting = false;
    
    if([offlineRestBuffer count]>0){
        bufferCounter = 0;
        [self callNextFromBuffer];
    }
    
    if(self.onReconnected)
        self.onReconnected(storage);
}
- (void) onSubscribed:(OrtcClient*) aOrtc channel:(NSString*) aChannel {
    //NSLog(@"#sub: %@", aChannel);
    Subscription *sub = [_channels objectForKey:aChannel];
    if(sub != nil){
        sub.isSubscribed = true;
        sub.toBeSubscribed = false;
		sub.toBeReSubscribed = false;
        if(sub.toBeUnsubscribed){
            [ortc unsubscribe:aChannel];
        }
    }
}
- (void) onUnsubscribed:(OrtcClient*) aOrtc channel:(NSString*) aChannel {
    //NSLog(@"#unsub: %@", aChannel);
    Subscription *sub = [_channels objectForKey:aChannel];
    if(sub != nil){
        sub.isSubscribed = false;
        sub.toBeUnsubscribed = false;
        if(sub.toBeSubscribed || sub.toBeReSubscribed){
			if (sub.subscribeWithNotifications) {
				[ortc subscribeWithNotifications:aChannel subscribeOnReconnected:true onMessage:onMessage];
			}
			else {
				[ortc subscribe:aChannel subscribeOnReconnected:true onMessage:onMessage];
			}
        } else {
            [_channels removeObjectForKey:aChannel];
        }
    }
}
- (void) onException:(OrtcClient*) aOrtc error:(NSError*) aError {
    NSLog(@"::exception %@", [aError localizedDescription]);
}

- (void)processREST:(REST*) rest{
    if(isReconnecting){
		if( (rest.rType == putItem || rest.rType == updateItem || rest.rType == deleteItem || rest.rType == incrementItem || rest.rType == decrementItem) && bufferIsActive) {
            [offlineRestBuffer addObject:rest];
        } else {
            if(rest.errorCallback)
                rest.errorCallback([NSError errorWithDomain:@"RealtimeCloudStorage" code:500 userInfo:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Can not establish connection with storage!", NSLocalizedDescriptionKey, nil]]);
        }      
    } else {
		if (rest.limit > 0) {
			NSString *restBody = [NSString stringWithFormat:@"%@, \"limit\":%d}", [rest.body substringToIndex:[rest.body length]-1], rest.limit];
			rest.body = restBody;
		}
		if (rest.order == (NSInteger *) StorageOrder_DESC) {
			
			NSString *restBody = [NSString stringWithFormat:@"%@, \"searchForward\":false}", [rest.body substringToIndex:[rest.body length]-1]];
			rest.body = restBody;
		}
		[rest doRest];
    }
}


- (void) addChannel:(NSString*)channelName WithNotifications:(BOOL) pushNotifications {
    
	Subscription *sub = [_channels objectForKey:channelName];
    if(sub != nil){
        sub.toBeSubscribed = true;
        sub.toBeUnsubscribed = false;
    } else {
        sub = [[Subscription alloc] init];
        sub.toBeSubscribed = true;
		sub.subscribeWithNotifications = pushNotifications;
		[_channels setValue:sub forKey:channelName];
    }
    if(ortc.isConnected && !sub.isSubscribed){
		if (sub.subscribeWithNotifications) {
			[ortc subscribeWithNotifications:channelName subscribeOnReconnected:true onMessage:onMessage];
		}
		else {
			[ortc subscribe:channelName subscribeOnReconnected:true onMessage:onMessage];
		}
	}
}

- (void) delChannel:(NSString*)channelName{
    Subscription *sub = [_channels objectForKey:channelName];
    if(sub != nil){
        if(ortc.isConnected && sub.isSubscribed && !sub.toBeUnsubscribed){
            [ortc unsubscribe:channelName];
        }
        sub.toBeUnsubscribed = true;
        sub.toBeSubscribed = false;
    }
}


- (void) enablePushNotificationsForTableRef:(TableRef*)tableRef {
	[eventManager enablePushNotificationsForTableRef:tableRef];
}
- (void) disablePushNotificationsForTableRef:(TableRef*)tableRef {
	[eventManager disablePushNotificationsForTableRef:tableRef];
}

- (void) enablePushNotificationsForItemRef:(ItemRef*)itemRef {
	[eventManager enablePushNotificationsForItemRef:itemRef];
}
- (void) disablePushNotificationsForItemRef:(ItemRef*)itemRef {
	[eventManager disablePushNotificationsForItemRef:itemRef];
}

@end
