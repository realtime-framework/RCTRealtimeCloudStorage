//
//  ItemRef.m
//  RealtimeCloudStorage
//
//  Created by RealTime on 30/07/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

//#import "ItemRef.h"
//#import "ItemSnapshot.h"
//#import "TableRef.h"
#import "RealTimeCloudStorage.h"
#import "StorageContext.h"
#import "REST.h"
#import "Event.h"

@interface ItemRef () {
	BOOL pushNotificationsEnable;
}
- (TableRef *) getItemTableRef;
- (NSString *) getItemPrimary;
- (NSString *) getItemSecondary;

@end

@implementation ItemRef

- (id) initWithPrimary: (TableRef*) aTable context:(StorageContext*)aContext primaryKeyValue:(NSString*)aPrimary{
    return [self initWithPrimaryAndSecondary:aTable context:aContext primaryKeyValue:aPrimary secondaryKeyValue:nil];
}
- (id) initWithPrimaryAndSecondary: (TableRef*) aTable context:(StorageContext*)aContext primaryKeyValue:(NSString*)aPrimary secondaryKeyValue:(NSString*)aSecondary{
    if ((self = [super init])) {
        context = aContext;
        table = aTable;
        primary = aPrimary;
        secondary = aSecondary;
    }
    return self;
}

- (void) _del: (void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"key\":%@}", [context getCredentialsJSON], [table name], [self getJSONKey]];
    REST *r = [[REST alloc] initWithContextAndTable:context table:table];
    r.errorCallback = aErrorCallback;
    r.itemCallback = aSuccessCallback;
    r.rType = deleteItem;
    r.body = body;
    [context processREST:r];
    //[r doRest:deleteItem body:body];
}

- (ItemRef*) del: (void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSDictionary *meta = [context getTableMetaFromCache:[table name]];
    if(meta==nil){
        void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* d){
            [self _del:aSuccessCallback error:aErrorCallback];
        };
        [table meta:cbSuccess error:aErrorCallback];
    } else {
        [self _del:aSuccessCallback error:aErrorCallback];
    }
    return self;
}

- (void) _get: (void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"key\":%@}", [context getCredentialsJSON], [table name], [self getJSONKey]];
    REST *r = [[REST alloc] initWithContextAndTable:context table:table];
    r.errorCallback = aErrorCallback;
    r.itemCallback = aSuccessCallback;
    r.rType = getItem;
    r.body = body;
    [context processREST:r];
    //[r doRest:getItem body:body];
}


- (ItemRef*) get: (void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSDictionary *meta = [context getTableMetaFromCache:[table name]];
    if(meta==nil){
        void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* d){
            [self _get:aSuccessCallback error:aErrorCallback];
        };
        [table meta:cbSuccess error:aErrorCallback];
    } else {
        [self _get:aSuccessCallback error:aErrorCallback];
    }
    return self;
}


- (void) _set: (NSDictionary*)atributes success:(void (^)(ItemSnapshot *succes)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSDictionary *meta = [context getTableMetaFromCache:[table name]];
    NSDictionary *mkey = [meta objectForKey:@"key"];
    NSDictionary *primaryDic = [mkey objectForKey:@"primary"];
    NSDictionary *secondaryDic = [mkey objectForKey:@"secondary"];
    NSString *primaryName = [primaryDic objectForKey:@"name"];
    NSString *secondaryName = (secondaryDic!=nil) ? [secondaryDic objectForKey:@"name"] : nil;
    NSMutableDictionary *mutAttr = [[NSMutableDictionary alloc] initWithDictionary:atributes];
    [mutAttr removeObjectForKey:primaryName];
    if(secondaryDic!=nil)
        [mutAttr removeObjectForKey:secondaryName];
    NSError *error = nil;
    NSData *itemData = [NSJSONSerialization dataWithJSONObject:mutAttr options:0 error:&error];
    if(error != nil){
        aErrorCallback(error);
        return;
    }
    NSString *itemString = [[NSString alloc] initWithData:itemData encoding:NSUTF8StringEncoding];
    
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"key\":%@, \"item\":%@}", [context getCredentialsJSON], [table name], [self getJSONKey], itemString];
    REST *r = [[REST alloc] initWithContextAndTable:context table:table];
    r.errorCallback = aErrorCallback;
    r.itemCallback = aSuccessCallback;
    r.rType = updateItem;
    r.body = body;
    [context processREST:r];
    //[r doRest:updateItem body:body];
}

- (ItemRef*) set:(NSDictionary*)attributes success:(void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSDictionary *meta = [context getTableMetaFromCache:[table name]];
    if(meta==nil){
        void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* d){
            [self _set:attributes success:aSuccessCallback error:aErrorCallback];
        };
        [table meta:cbSuccess error:aErrorCallback];
    } else {
        [self _set:attributes success:aSuccessCallback error:aErrorCallback];
    }
    return self;
}


- (void) _incr:(NSString *)property withValue:(NSInteger)value success:(void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
	
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"key\":%@, \"property\":\"%@\", \"value\":%ld}", [context getCredentialsJSON], [table name], [self getJSONKey], property, (long)value];
	
	REST *r = [[REST alloc] initWithContextAndTable:context table:table];
    r.errorCallback = aErrorCallback;
    r.itemCallback = aSuccessCallback;
    r.rType = incrementItem;
    r.body = body;
    [context processREST:r];
}

- (ItemRef*) incr:(NSString *)property withValue:(NSInteger) value success:(void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    
	NSDictionary *meta = [context getTableMetaFromCache:[table name]];
	NSNumber *numValue = [NSNumber numberWithInteger:value];
	if (numValue == nil) {
		value = 1;
	}
    if(meta==nil){
		
        void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* d){
			[self _incr:property withValue:value success:aSuccessCallback error:aErrorCallback];
		};
		
		[table meta:cbSuccess error:aErrorCallback];
		
    } else {
		[self _incr:property withValue:value success:aSuccessCallback error:aErrorCallback];
    }
    return self;
}

- (ItemRef*) incr:(NSString *)property success:(void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback {
	
	[self incr:property withValue:1 success:aSuccessCallback error:aErrorCallback];
	return self;
}


- (void) _decr:(NSString *)property withValue:(NSInteger)value success:(void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
	
	NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"key\":%@, \"property\":\"%@\", \"value\":%ld}", [context getCredentialsJSON], [table name], [self getJSONKey], property, (long)value];
	
    REST *r = [[REST alloc] initWithContextAndTable:context table:table];
    r.errorCallback = aErrorCallback;
    r.itemCallback = aSuccessCallback;
    r.rType = decrementItem;
    r.body = body;
    [context processREST:r];
}

- (ItemRef*) decr:(NSString *)property withValue:(NSInteger)value success:(void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    
	NSDictionary *meta = [context getTableMetaFromCache:[table name]];

	NSNumber *numValue = [NSNumber numberWithInteger:value];
	if (numValue == nil) {
		value = 1;
	}
	if(meta==nil){
		
        void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* d){
			[self _decr:property withValue:value success:aSuccessCallback error:aErrorCallback];
		};
		[table meta:cbSuccess error:aErrorCallback];
		
    } else {
		[self _decr:property withValue:value success:aSuccessCallback error:aErrorCallback];
    }
    return self;
}

- (ItemRef*) decr:(NSString *)property success:(void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback {
	
	[self decr:property withValue:1 success:aSuccessCallback error:aErrorCallback];
	return self;
}


- (NSString*) getJSONKey{
    NSString *ret = @"{";
    NSDictionary *meta = [context getTableMetaFromCache:[table name]];
    NSDictionary *mkey = [meta objectForKey:@"key"];
    NSDictionary *primaryDic = [mkey objectForKey:@"primary"];
    NSDictionary *secondaryDic = [mkey objectForKey:@"secondary"];
    NSString *primaryType = nil, *secondaryType = nil;
    primaryType = [primaryDic objectForKey:@"dataType"];
    if([primaryType isEqualToString:@"string"]){
        ret = [ret stringByAppendingString:[NSString stringWithFormat:@"\"primary\":\"%@\"", primary]];
    } else {
        ret = [ret stringByAppendingString:[NSString stringWithFormat:@"\"primary\":%@", primary]];
    }
    if(secondaryDic!=nil){
        secondaryType = [secondaryDic objectForKey:@"dataType"];
        if(secondary!=nil){
            if([secondaryType isEqualToString:@"string"]){
                ret = [ret stringByAppendingString:[NSString stringWithFormat:@", \"secondary\":\"%@\"", secondary]];
            } else {
                ret = [ret stringByAppendingString:[NSString stringWithFormat:@", \"secondary\":%@", secondary]];
            }
        }
    }
    return [ret stringByAppendingString:@"}"];
}


- (TableRef *) getItemTableRef {
	return table;
}

- (NSString *) getItemPrimary {
	return primary;
}

- (NSString *)getItemSecondary {
	return secondary;
}


- (ItemRef*) on: (StorageEventType) eventType callback:(void (^)(ItemSnapshot *item)) callback{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:[table name] primaryKey:primary secondaryKey:secondary isOnce:false callback:callback];
    e = [self setEventNotifications:e];
	[context addEvent:e];
    return self;
}
- (ItemRef*) on: (StorageEventType) eventType objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:[table name] primaryKey:primary secondaryKey:secondary isOnce:false objectToNotify:anObject selector:aSelector];
    e = [self setEventNotifications:e];
	[context addEvent:e];
    return self;
}

- (ItemRef*) off: (StorageEventType) eventType{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:[table name] primaryKey:primary secondaryKey:secondary isOnce:false callback:nil];
	[context removeAllSimilarEvents:e];
    return self;
}
- (ItemRef*) off: (StorageEventType) eventType objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:[table name] primaryKey:primary secondaryKey:secondary isOnce:false objectToNotify:anObject selector:aSelector];
    [context removeEvent:e];
    return self;
}

- (ItemRef*) once: (StorageEventType) eventType callback:(void (^)(ItemSnapshot *item)) callback{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:[table name] primaryKey:primary secondaryKey:secondary isOnce:true callback:callback];
	e = [self setEventNotifications:e];
    [context addEvent:e];
    return self;
}
- (ItemRef*) once: (StorageEventType) eventType objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:[table name] primaryKey:primary secondaryKey:secondary isOnce:true objectToNotify:anObject selector:aSelector];
	e = [self setEventNotifications:e];
    [context addEvent:e];
    return self;
}

- (ItemRef*) enablePushNotifications {
	
	pushNotificationsEnable = YES;
	[context enablePushNotificationsForItemRef:self];
	
	return self;
}

- (ItemRef*) disablePushNotifications {
	
	pushNotificationsEnable = NO;
	[context disablePushNotificationsForItemRef:self];
	
	return self;
}

- (Event *) setEventNotifications:(Event *) anEvent {
	if (pushNotificationsEnable) {
		anEvent.pushNotificationsEnable = YES;
	}
	else {
		anEvent.pushNotificationsEnable = NO;
	}
	return anEvent;
}


@end
