//
//  EventManager.m
//  RealTimeCloudStorage
//
//  Created by Lion User on 02/12/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import "EventManager.h"

@implementation EventManager

- (id) initWithContext:(StorageContext*) aContext{
    if (self =[super init]){
        context = aContext;
        events = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) addEvent:(Event*)anEvent{
    NSString *channelName = [anEvent getChannelName];
    NSMutableArray *channelEvents = [events objectForKey:channelName];
    if(channelEvents == nil){ //channel not subscribed yet
        [context addChannel:[anEvent getChannelName] WithNotifications:anEvent.pushNotificationsEnable];
        NSMutableArray *newArray = [[NSMutableArray alloc] init];
        [newArray addObject:anEvent];
        [events setValue:newArray forKey:channelName];
    } else {
        [channelEvents addObject:anEvent];
    }
}

- (void) delEvent:(Event*)anEvent{
    NSString *channelName = [anEvent getChannelName];
    NSMutableArray *channelEvents = [events objectForKey:channelName];
    if(channelEvents != nil){
        Event *ev = [self findEvent:anEvent array:channelEvents];
        if(ev != nil){
            [channelEvents removeObject:ev];
        }
        if([channelEvents count] == 0){
            [context delChannel:channelName];
            [events removeObjectForKey:channelName];
        }
    }
}

- (void) delEventsForChannel:(NSString*) aChannel eventType:(StorageEventType)anEventType{
    NSMutableArray *channelEvents = [events objectForKey:aChannel];
    if(channelEvents != nil){
        NSMutableArray *discardedItems = [NSMutableArray array];
        for(Event *e in channelEvents){
            if([e getType] == anEventType){
                 [discardedItems addObject:e];                
            }
        }
        [channelEvents removeObjectsInArray:discardedItems];
        if([channelEvents count] == 0){
            [context delChannel:aChannel];
            [events removeObjectForKey:aChannel];
        }
    }
}

- (void) processMessage:(NSString*)aChannel eventType:(StorageEventType)anEventType itemSnapshot:(ItemSnapshot*)anItemSnapshot{
    NSMutableArray *channelEvents = [events objectForKey:aChannel];
    if(channelEvents != nil){
        NSMutableArray *discardedItems = [NSMutableArray array];
        for(Event *e in channelEvents){
            if([e getType] == anEventType){
                [e callTheCallback:anItemSnapshot];
                if([e isOnce]){
                    [discardedItems addObject:e];
                }
            }
        }
        [channelEvents removeObjectsInArray:discardedItems];
        if([channelEvents count] == 0){
            [context delChannel:aChannel];
            [events removeObjectForKey:aChannel];
        }
    }
}


- (Event*) findEvent:(Event*)anEvent array:(NSMutableArray*)arrEvents{
    for(Event *e in arrEvents){
        
        if([[e getChannelName] isEqualToString:[anEvent getChannelName]]){
            if([e getCaller] == [anEvent getCaller]){
                if([e getSelector] == [anEvent getSelector]){
                    if([e getType] == [anEvent getType]){
                        if([[e getPrimary] isEqualToString:[anEvent getPrimary]] || ([e getPrimary]==nil && [anEvent getPrimary]==nil)){
                            if([[e getSecondary] isEqualToString:[anEvent getSecondary]] || ([e getSecondary]==nil && [anEvent getSecondary]==nil)){
                                return e;
                            }
                        }
                    }
                }
            }
        }          
    }
    return nil;
}


- (void) enablePushNotificationsForTableRef:(TableRef*)tableRef {
	
	NSEnumerator *e = [events keyEnumerator];
    id key;
	while((key = [e nextObject])){
		NSArray *chanelsEvents = [events objectForKey:key];
		for (Event *anEvent in chanelsEvents) {
			if ([[anEvent getTableName] isEqualToString:tableRef.name]) {
				anEvent.pushNotificationsEnable = YES;
				Subscription *sub = [context.channels objectForKey:[anEvent getChannelName]];
				if (sub.isSubscribed && !sub.subscribeWithNotifications) {
					
					sub.subscribeWithNotifications = YES;
					sub.toBeSubscribed = YES;
					sub.toBeUnsubscribed = NO;
					sub.toBeReSubscribed = YES;
					
					[context delChannel:[anEvent getChannelName]];
				}
			}
		}
	}
}

- (void) disablePushNotificationsForTableRef:(TableRef*)tableRef {
	
	NSEnumerator *e = [events keyEnumerator];
    id key;
	while((key = [e nextObject])){
		NSArray *chanelsEvents = [events objectForKey:key];
		for (Event *anEvent in chanelsEvents) {
			if ([[anEvent getTableName] isEqualToString:tableRef.name]) {
				anEvent.pushNotificationsEnable = NO;
				Subscription *sub = [context.channels objectForKey:[anEvent getChannelName]];
				if (sub.isSubscribed && sub.subscribeWithNotifications) {
					
					sub.subscribeWithNotifications = NO;
					sub.toBeSubscribed = YES;
					sub.toBeUnsubscribed = NO;
					sub.toBeReSubscribed = YES;
					
					[context delChannel:[anEvent getChannelName]];
				}
			}
		}
	}
}

- (void) enablePushNotificationsForItemRef:(ItemRef*)itemRef {
	
	NSString *tableName = [(TableRef *)[itemRef performSelector:@selector(getItemTableRef) withObject:nil] name];
	NSString *itemPrimary = (NSString *)[itemRef performSelector:@selector(getItemPrimary) withObject:nil];
	NSString *itemSecondary = (NSString *)[itemRef performSelector:@selector(getItemSecondary) withObject:nil];
	
	NSEnumerator *e = [events keyEnumerator];
	id key;
	while((key = [e nextObject])){
		NSArray *chanelsEvents = [events objectForKey:key];
		for (Event *anEvent in chanelsEvents) {
			
			if (!itemSecondary) {
				if ([[anEvent getTableName] isEqualToString:tableName] && [[anEvent getPrimary] isEqualToString:itemPrimary]) {
					
					Subscription *sub = [context.channels objectForKey:[anEvent getChannelName]];
					if (sub.isSubscribed && !sub.subscribeWithNotifications) {
						
						sub.subscribeWithNotifications = YES;
						sub.toBeSubscribed = YES;
						sub.toBeUnsubscribed = NO;
						sub.toBeReSubscribed = YES;
						
						[context delChannel:[anEvent getChannelName]];
					}
				}
			}
			else {
				if ([tableName isEqualToString:[anEvent getTableName]] && [itemPrimary isEqualToString:[anEvent getPrimary]] && [itemSecondary isEqualToString:[anEvent getSecondary]]) {
					
					Subscription *sub = [context.channels objectForKey:[anEvent getChannelName]];
					if (sub.isSubscribed && !sub.subscribeWithNotifications) {
						
						sub.subscribeWithNotifications = YES;
						sub.toBeSubscribed = YES;
						sub.toBeUnsubscribed = NO;
						sub.toBeReSubscribed = YES;
						
						[context delChannel:[anEvent getChannelName]];
					}
				}
			}
		}
	}
}

- (void) disablePushNotificationsForItemRef:(ItemRef*)itemRef {
	
	NSString *tableName = [(TableRef *)[itemRef performSelector:@selector(getItemTableRef) withObject:nil] name];
	NSString *itemPrimary = (NSString *)[itemRef performSelector:@selector(getItemPrimary) withObject:nil];
	NSString *itemSecondary = (NSString *)[itemRef performSelector:@selector(getItemSecondary) withObject:nil];
	
	NSEnumerator *e = [events keyEnumerator];
	id key;
	while((key = [e nextObject])){
		NSArray *chanelsEvents = [events objectForKey:key];
		for (Event *anEvent in chanelsEvents) {
			
			if (!itemSecondary) {
				if ([[anEvent getTableName] isEqualToString:tableName] && [[anEvent getPrimary] isEqualToString:itemPrimary]) {
					
					Subscription *sub = [context.channels objectForKey:[anEvent getChannelName]];
					if (sub.isSubscribed && sub.subscribeWithNotifications) {
						
						sub.subscribeWithNotifications = NO;
						sub.toBeSubscribed = YES;
						sub.toBeUnsubscribed = NO;
						sub.toBeReSubscribed = YES;
						
						[context delChannel:[anEvent getChannelName]];
					}
				}
			}
			
			else {
				if ([tableName isEqualToString:[anEvent getTableName]] && [itemPrimary isEqualToString:[anEvent getPrimary]] && [itemSecondary isEqualToString:[anEvent getSecondary]]) {
					
					Subscription *sub = [context.channels objectForKey:[anEvent getChannelName]];
					if (sub.isSubscribed && sub.subscribeWithNotifications) {
						
						sub.subscribeWithNotifications = NO;
						sub.toBeSubscribed = YES;
						sub.toBeUnsubscribed = NO;
						sub.toBeReSubscribed = YES;
						
						[context delChannel:[anEvent getChannelName]];
					}
				}
			}
		}
	}
}

@end


@implementation Subscription

- (id) init{
    if (self =[super init]){
        _isSubscribed = false;
        _toBeSubscribed = false;
        _toBeUnsubscribed = false;
		_toBeReSubscribed = false;
		_subscribeWithNotifications = false;
	}
    return self;
}

@end
