//
//  TableRef.m
//  RealtimeCloudStorage
//
//  Created by RealTime on 31/07/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

//#import "TableRef.h"
//#import "ItemRef.h"
#import "RealTimeCloudStorage.h"
#import "Filter.h"
#import "REST.h"
#import "StorageContext.h"
//#import "ItemSnapshot.h"
#import "Event.h"

@interface TableRef () {
	BOOL pushNotificationsEnable;
}
@end

@implementation TableRef

- (id) initWithName:(NSString*)aName context:(StorageContext*)aContext{
    if ((self = [super init])) {
        context = aContext;
        name = aName;
        limit = 0;
        order = StorageOrder_NULL;
        filterList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (TableRef*) create:(NSString*)aPrimaryKey primaryKeyDataType:(StorageDataType)aPrimaryKeyDataType provisionType:(ProvisionType)aProvisionType provisionLoad:(ProvisionLoad)aProvisionLoad success:(void (^)(NSDictionary*)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"key\":{\"primary\":{\"name\":\"%@\",\"dataType\":\"%@\"}}, \"provisionType\":%ld, \"provisionLoad\":%ld}", [context getCredentialsJSON], name, aPrimaryKey, [self getDataTypeValue:aPrimaryKeyDataType], (long)aProvisionType, (long)aProvisionLoad];
    
    REST *r = [[REST alloc] initWithContext:context];
    r.errorCallback = aErrorCallback;
    r.dictCallback = aSuccessCallback;
    r.rType = createTable;
    r.body = body;
    [context processREST:r];
    //[r doRest:createTable body:body];
    
    return self;
}

- (TableRef*) create: (NSString*) aPrimaryKey primaryKeyDataType:(StorageDataType) aPrimaryKeyDataType secondaryKey:(NSString*) aSecondaryKey secondaryKeyDataType:(StorageDataType) aSecondaryKeyDataType provisionType:(ProvisionType) aProvisionType provisionLoad:(ProvisionLoad)aProvisionLoad success:(void (^)(NSDictionary*)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"key\":{\"primary\":{\"name\":\"%@\",\"dataType\":\"%@\"}, \"secondary\":{\"name\":\"%@\",\"dataType\":\"%@\"}}, \"provisionType\":%ld, \"provisionLoad\":%ld}", [context getCredentialsJSON], name, aPrimaryKey, [self getDataTypeValue:aPrimaryKeyDataType], aSecondaryKey, [self getDataTypeValue:aSecondaryKeyDataType], (long)aProvisionType, (long)aProvisionLoad];
    
    REST *r = [[REST alloc] initWithContext:context];
    r.errorCallback = aErrorCallback;
    r.dictCallback = aSuccessCallback;
    r.rType = createTable;
    r.body = body;
    [context processREST:r];
    //[r doRest:createTable body:body];
    
    return self;
}

- (void) del: (void (^)(NSDictionary*)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\"}", [context getCredentialsJSON], name];

    void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* b){
        if(b)
            [context delTableMetaInCache:name];
        aSuccessCallback(b);
    };
    
    REST *r = [[REST alloc] initWithContext:context];
    r.errorCallback = aErrorCallback;
    r.dictCallback = cbSuccess;
    r.rType = deleteTable;
    r.body = body;
    [context processREST:r];
    //[r doRest:deleteTable body:body];
}

- (TableRef*) meta: (void (^)(NSDictionary*)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\"}", [context getCredentialsJSON], name];
    
    void (^cbSuccess)(NSDictionary*) = ^(NSDictionary *d){
        NSDictionary *key = [d objectForKey:@"key"];
        NSDictionary *prvLoad = [d objectForKey:@"provisionLoad"];
        NSDictionary *prvType = [d objectForKey:@"provisionType"];
        NSDictionary *meta = [NSDictionary dictionaryWithObjectsAndKeys:key, @"key", prvLoad, @"provisionLoad", prvType, @"provisionType", nil];
        [context putTableMetaInCache:name tableMetadata:meta];
        aSuccessCallback(d);
    };
    
    REST *r = [[REST alloc] initWithContext:context];
    r.errorCallback = aErrorCallback;
    r.dictCallback = cbSuccess;// aSuccessCallback;
    r.rType = describeTable;
    r.body = body;
    [context processREST:r];
    return self;
}


- (NSString*) name{
    return name;
}

- (TableRef*) asc{
    order = StorageOrder_ASC;
    return self;
}

- (TableRef*) desc{
    order = StorageOrder_DESC;
    return self;
}


- (TableRef*) push: (NSDictionary*) aItem success:(void (^)(ItemSnapshot*)) aSuccessCallback error:(void (^)(NSError*)) aErrorCallback{
    NSError *error = nil;
    NSData *itemData = [NSJSONSerialization dataWithJSONObject:aItem options:0 error:&error];
    if(error != nil){
        aErrorCallback(error);
        return self;
    }
    NSString *itemString = [[NSString alloc] initWithData:itemData encoding:NSUTF8StringEncoding];
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"item\":%@}", [context getCredentialsJSON], name, itemString];
    
    REST *r = [[REST alloc] initWithContext:context];
    r.errorCallback = aErrorCallback;
    r.itemCallback = aSuccessCallback;
    r.rType = putItem;
    r.body = body;
    [context processREST:r];   
    return self;
}



- (TableRef*) limit: (int) value{
    limit = value;
    return self;
}

- (void) _update:(ProvisionType) aProvisionType provisionLoad:(ProvisionLoad) aProvisionLoad success:(void (^)(NSDictionary*)) aSuccessCallback error:(void (^)(NSError*)) aErrorCallback{
    NSDictionary *meta = [context getTableMetaFromCache:name];
    NSDictionary *prvType = [meta objectForKey:@"provisionType"];
    NSDictionary *prvLoad = [meta objectForKey:@"provisionLoad"];
    int iPrvLoad = [[prvLoad objectForKey:@"id"] intValue];
    int iPrvType = [[prvType objectForKey:@"id"] intValue];
    if(abs(iPrvLoad - (int)aProvisionLoad) > 1 || abs(iPrvType - (int)aProvisionType) > 1){
        NSError *e = [NSError errorWithDomain:@"RealTimeCloudStorage" code:501 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"You can not make such a radical change to throughput", NSLocalizedDescriptionKey, nil]];
        aErrorCallback(e);
        return;
    }
    
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"provisionType\":%ld, \"provisionLoad\":%ld}", [context getCredentialsJSON], name, (long)aProvisionType, (long)aProvisionLoad];
    
    REST *r = [[REST alloc] initWithContext:context];
    r.errorCallback = aErrorCallback;
    r.dictCallback = aSuccessCallback;
    r.rType = updateTable;
    r.body = body;
    [context processREST:r];
}

- (TableRef*) update: (ProvisionType) aProvisionType provisionLoad:(ProvisionLoad) aProvisionLoad success:(void (^)(NSDictionary*)) aSuccessCallback error:(void (^)(NSError*)) aErrorCallback{
    NSDictionary *meta = [context getTableMetaFromCache:name];
    if(meta==nil){
        void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* d){
            [self _update:aProvisionType provisionLoad:aProvisionLoad success:aSuccessCallback error:aErrorCallback];
        };
        [self meta:cbSuccess error:aErrorCallback];
    } else {
        [self _update:aProvisionType provisionLoad:aProvisionLoad success:aSuccessCallback error:aErrorCallback];
    }

    return self;
}

- (void) setFilter:(StorageFilter)aStorageFilter item:(NSString*) aItem value:(NSObject*) aValue{
    Filter *f = [[Filter alloc] initWithParams:aStorageFilter item:aItem value:aValue];
    [filterList addObject:f];
}
- (void) setFilterEx:(StorageFilter)aStorageFilter item:(NSString*) aItem value:(NSObject*) aValue valueEx:(NSObject*) aValueEx{
    Filter *f = [[Filter alloc] initWithParamsEx:aStorageFilter item:aItem value:aValue valueEx:aValueEx];
    [filterList addObject:f];
}

- (TableRef*) greaterThanString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_GREATERTHAN item:item value:value];
    return self;
}
- (TableRef*) lesserThanString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_LESSERTHAN item:item value:value];
    return self;
}
- (TableRef*) betweenString: (NSString*) item beginValue:(NSString*) beginValue endValue:(NSString*) endValue{
    [self setFilterEx:StorageFilter_BETWEEN item:item value:beginValue valueEx:endValue];
    return self;
}
- (TableRef*) containsString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_CONTAINS item:item value:value];
    return self;
}
- (TableRef*) equalsString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_EQUALS item:item value:value];
    return self;
}
- (TableRef*) greaterEqualString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_GREATEREQUAL item:item value:value];
    return self;
}
- (TableRef*) lesserEqualString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_LESSEREQUAL item:item value:value];
    return self;
}
- (TableRef*) notContainsString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_NOTCONTAINS item:item value:value];
    return self;
}
- (TableRef*) notEqualString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_NOTEQUAL item:item value:value];
    return self;
}
- (TableRef*) beginsWithString: (NSString*) item value:(NSString*) value{
    [self setFilter:StorageFilter_BEGINSWITH item:item value:value];
    return self;
}
- (TableRef*) notNull: (NSString*) item{
    [self setFilter:StorageFilter_NOTNULL item:item value:nil];
    return self;
}
- (TableRef*) null: (NSString*) item{
    [self setFilter:StorageFilter_NULL item:item value:nil];
    return self;
}
- (TableRef*) greaterThanNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_GREATERTHAN item:item value:value];
    return self;
}
- (TableRef*) lesserThanNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_LESSERTHAN item:item value:value];
    return self;
}
- (TableRef*) betweenNumber: (NSString*) item beginValue:(NSNumber*) beginValue endValue:(NSNumber*) endValue{
    [self setFilterEx:StorageFilter_BETWEEN item:item value:beginValue valueEx:endValue];
    return self;
}
- (TableRef*) containsNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_CONTAINS item:item value:value];
    return self;
}
- (TableRef*) equalsNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_EQUALS item:item value:value];
    return self;
}
- (TableRef*) greaterEqualNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_GREATEREQUAL item:item value:value];
    return self;
}
- (TableRef*) lesserEqualNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_LESSEREQUAL item:item value:value];
    return self;
}
- (TableRef*) notContainsNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_NOTCONTAINS item:item value:value];
    return self;
}
- (TableRef*) notEqualNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_NOTEQUAL item:item value:value];
    return self;
}
- (TableRef*) beginsWithNumber: (NSString*) item value:(NSNumber*) value{
    [self setFilter:StorageFilter_BEGINSWITH item:item value:value];
    return self;
}

- (NSString*) _getKeyValue:(NSMutableDictionary*)aKey primaryType:(NSString*)pt{
    NSString *ret = @"";
    NSString *vPrimary = [aKey objectForKey:@"primary"];
    if(vPrimary != nil){
        if([pt isEqualToString:@"string"]){
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@"\"primary\":\"%@\"", vPrimary]];
        } else {
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@"\"primary\":%@", vPrimary]];
        }
    }
    return ret;
}



- (void) _getitem:(NSMutableDictionary*)key : (void (^)(ItemSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSDictionary *meta = [context getTableMetaFromCache:name];
    NSDictionary *mkey = [meta objectForKey:@"key"];
    NSDictionary *primary = [mkey objectForKey:@"primary"];
    NSString *primaryType = [primary objectForKey:@"dataType"];
    
    NSString *body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\", \"key\":{%@}}", [context getCredentialsJSON], [self name], [self _getKeyValue:key primaryType:primaryType]];
    REST *r = [[REST alloc] initWithContextAndTable:context table:self];
    r.errorCallback = aErrorCallback;
    r.itemCallback = aSuccessCallback;
    r.rType = getItem;
    r.body = body;
    r.endWithNil = YES;
    [context processREST:r];
    //[r doRest:getItem body:body];
}



- (void) _getItems: (void (^)(ItemSnapshot *item)) aSuccessCallback error:(void (^)(NSError*)) aErrorCallback{
    NSDictionary *meta = [context getTableMetaFromCache:name];
    NSDictionary *mkey = [meta objectForKey:@"key"];
    NSDictionary *primary = [mkey objectForKey:@"primary"];
    NSDictionary *secondary = [mkey objectForKey:@"secondary"];
    NSString *primaryName = nil, *secondaryName = nil, *primaryType = nil, *secondaryType = nil;
    primaryName = [primary objectForKey:@"name"];
    primaryType = [primary objectForKey:@"dataType"];
    if(secondary!=nil){
        secondaryName = [secondary objectForKey:@"name"];
        secondaryType = [secondary objectForKey:@"dataType"];
    }
    NSMutableDictionary *key = [[NSMutableDictionary alloc] init];
    RestRequestType type = [self decideIfQueryOrScan:primaryName secondaryName:secondaryName key:&key];

    NSString *body;
    if(type==getItem) {
        [self _getitem:key :aSuccessCallback error:aErrorCallback];
        return;
    }else if(type==listItems) {
        body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\"%@}", [context getCredentialsJSON], name, [self getfilterListString:type]];
    } else {
        body = [NSString stringWithFormat:@"{%@, \"table\":\"%@\"%@, \"key\":{%@}}", [context getCredentialsJSON], name, [self getfilterListString:type], [self getKeyJSON:key primaryType:primaryType secondaryType:secondaryType]];
    }
    
    REST *r = [[REST alloc] initWithContextAndTable:context table:self];
    r.errorCallback = aErrorCallback;
    r.itemCallback = aSuccessCallback;
	r.limit = limit;
	
    if(type==listItems) {
		r.sortKey = secondary!=nil? secondaryName : primaryName;
        r.sortKeyType = secondary!=nil?secondaryType : primaryType;
    }
	if (type == queryItems) {
		r.order = (NSInteger*)order;
	}
	
    r.rType = type;
    r.body = body;
    [context processREST:r];
}

- (TableRef*) getItems: (void (^)(ItemSnapshot *item)) aSuccessCallback error:(void (^)(NSError*)) aErrorCallback{
    
    NSDictionary *meta = [context getTableMetaFromCache:name];
    if(meta==nil){
        void (^cbSuccess)(NSDictionary*) = ^(NSDictionary* d){
            [self _getItems:aSuccessCallback error:aErrorCallback];
        };
        [self meta:cbSuccess error:aErrorCallback];
        
    } else {
        [self _getItems:aSuccessCallback error:aErrorCallback];
    }
    return self;
}

- (NSString*) getKeyJSON:(NSMutableDictionary*)aKey primaryType:(NSString*)pt secondaryType:(NSString*)st{
    NSString *ret = @"";
    NSString *vSecondary = [aKey objectForKey:@"secondary"];
    NSString *vPrimary = [aKey objectForKey:@"primary"];
    if(vPrimary != nil){
        if([pt isEqualToString:@"string"]){
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@"\"primary\":\"%@\"", vPrimary]];
        } else {
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@"\"primary\":%@", vPrimary]];
        }
    }
    if(vSecondary != nil){
        if([st isEqualToString:@"string"]){
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@", \"secondary\":\"%@\"", vSecondary]];
        } else {
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@", \"secondary\":%@", vSecondary]];
        }
    }
    return ret;
}

- (NSString*) getfilterListString:(RestRequestType)aType{
    if([filterList count] == 0)
        return @"";
    if([filterList count] == 1) {
        if(aType==listItems) {
            return [NSString stringWithFormat:@", \"filter\":[%@]", [[filterList objectAtIndex:0] getJSON]];
        } else { //type == queryItems
            return [NSString stringWithFormat:@", \"filter\":%@", [[filterList objectAtIndex:0] getJSON]];
        }
    }
    NSString *ret = @", \"filter\":[";
    for(int i = 0; i < (int)[filterList count]; i++)
        ret = [ret stringByAppendingString:[NSString stringWithFormat:@"%@ %@", (i==0?@"":@","), [[filterList objectAtIndex:i] getJSON]]];
    return [ret stringByAppendingString:@"]"];
}

- (RestRequestType) decideIfQueryOrScan:(NSString*)primary secondaryName:(NSString*)secondary key:(NSMutableDictionary**)aKey{
    NSArray *listOnly = [[NSArray alloc] initWithObjects:@"notEqual", @"notNull", @"null", @"contains", @"notContains", nil];

    for(int i = 0; i < (int)[filterList count]; i++)
        if([listOnly containsObject:[[filterList objectAtIndex:i] getfilterOperatorString]])
            return listItems; //because queryItems do not support notEqual, notNull, null, contains and notContains
    
    if(secondary!=nil && [filterList count] == 1){
        Filter *f = [filterList objectAtIndex:0];
        if([f.item isEqualToString:primary] && f.fOperator == StorageFilter_EQUALS){
            [*aKey setValue:f.value forKey:@"primary"];
            [filterList removeAllObjects];
            return queryItems;
        }
    } else if(secondary!=nil && [filterList count] == 2){
        NSObject *tVal = nil;
        Filter *tFilter = nil;
        for(int i = 0; i < [filterList count]; i++){
            Filter *f = [filterList objectAtIndex:i];
            if ([f.item isEqualToString:primary] && f.fOperator == StorageFilter_EQUALS){
                tVal = f.value;
            }
            if ([f.item isEqualToString:secondary]) {
                tFilter = f;
            }
        }
        if(tVal!=nil && tFilter!=nil){
            [filterList removeAllObjects];
            [filterList addObject:tFilter];
            [*aKey setValue:tVal forKey:@"primary"];
            return queryItems;
        } else {
            return listItems;
        }
    } else if(secondary==nil && [filterList count] == 1){
        Filter *f = [filterList objectAtIndex:0];
        if ([f.item isEqualToString:primary] && f.fOperator == StorageFilter_EQUALS){
            [*aKey setValue:f.value forKey:@"primary"];
            [filterList removeAllObjects];
            return getItem;
        } 
    }
    
    
    return listItems;
}

- (NSString*) getDataTypeValue:(StorageDataType) sdt{
    switch (sdt) {
        case StorageDataType_NUMBER: return @"number";
        case StorageDataType_STRING: return @"string";
    }
}


- (ItemRef*) item: (NSString*) primaryKey{
    return [[ItemRef alloc] initWithPrimary:self context:context primaryKeyValue:primaryKey];
}
- (ItemRef*) item: (NSString*) primaryKey secondaryKey:(NSString*) secondaryKey{
    return [[ItemRef alloc] initWithPrimaryAndSecondary:self context:context primaryKeyValue:primaryKey secondaryKeyValue:secondaryKey];
}


- (TableRef*) on: (StorageEventType) eventType callback:(void (^)(ItemSnapshot *item)) callback{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:name primaryKey:nil secondaryKey:nil isOnce:false callback:callback];
    e = [self setEventNotifications:e];
	[context addEvent:e];
    return self;
}
- (TableRef*) on: (StorageEventType) eventType objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:name primaryKey:nil secondaryKey:nil isOnce:false objectToNotify:anObject selector:aSelector];
    e = [self setEventNotifications:e];
	[context addEvent:e];
    return self;
}
- (TableRef*) on: (StorageEventType) eventType primaryKey:(NSString*)aPrimaryKeyValue callback:(void (^)(ItemSnapshot *item)) callback{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:name primaryKey:aPrimaryKeyValue secondaryKey:nil isOnce:false callback:callback];
    e = [self setEventNotifications:e];
	[context addEvent:e];
    return self;
}
- (TableRef*) on: (StorageEventType) eventType primaryKey:(NSString*)aPrimaryKeyValue objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:name primaryKey:aPrimaryKeyValue secondaryKey:nil isOnce:false objectToNotify:anObject selector:aSelector];
    e = [self setEventNotifications:e];
	[context addEvent:e];
    return self;
}

- (TableRef*) off: (StorageEventType) eventType{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:name primaryKey:nil secondaryKey:nil isOnce:false callback:nil];
	[context removeAllSimilarEvents:e];
    return self;
}
- (TableRef*) off: (StorageEventType) eventType objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:name primaryKey:nil secondaryKey:nil isOnce:false objectToNotify:anObject selector:aSelector];
	[context removeEvent:e];
    return self;
}
- (TableRef*) off: (StorageEventType) eventType primaryKey:(NSString*)aPrimaryKeyValue{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:name primaryKey:aPrimaryKeyValue secondaryKey:nil isOnce:false callback:nil];
	[context removeAllSimilarEvents:e];
    return self;
}
- (TableRef*) off: (StorageEventType) eventType primaryKey:(NSString*)aPrimaryKeyValue objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:name primaryKey:aPrimaryKeyValue secondaryKey:nil isOnce:false objectToNotify:anObject selector:aSelector];
	[context removeEvent:e];
    return self;
}


- (TableRef*) once: (StorageEventType) eventType callback:(void (^)(ItemSnapshot *item)) callback{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:name primaryKey:nil secondaryKey:nil isOnce:true callback:callback];
    e = [self setEventNotifications:e];
	[context addEvent:e];
    return self;
}
- (TableRef*) once: (StorageEventType) eventType objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:name primaryKey:nil secondaryKey:nil isOnce:true objectToNotify:anObject selector:aSelector];
	e = [self setEventNotifications:e];
    [context addEvent:e];
    return self;
}
- (TableRef*) once: (StorageEventType) eventType primaryKey:(NSString*)aPrimaryKeyValue callback:(void (^)(ItemSnapshot *item)) callback{
    Event *e = [[Event alloc] initWithBlock:context eventType:eventType tableName:name primaryKey:aPrimaryKeyValue secondaryKey:nil isOnce:true callback:callback];
	e = [self setEventNotifications:e];
    [context addEvent:e];
    return self;
}
- (TableRef*) once: (StorageEventType) eventType primaryKey:(NSString*)aPrimaryKeyValue objectToNotify:(id)anObject selectorToPerform:(SEL)aSelector{
    Event *e = [[Event alloc] initWithSelector:context eventType:eventType tableName:name primaryKey:aPrimaryKeyValue secondaryKey:nil isOnce:true objectToNotify:anObject selector:aSelector];
	e = [self setEventNotifications:e];
    [context addEvent:e];
    return self;
}

- (TableRef*) enablePushNotifications {
	
	pushNotificationsEnable = YES;
	[context enablePushNotificationsForTableRef:self];
	/*
	if (!pushNotificationsEnable) {
		pushNotificationsEnable = YES;
		[context enablePushNotificationsForTableRef:self];
	}
	*/
	return self;
}

- (TableRef*) disablePushNotifications {
	
	pushNotificationsEnable = NO;
	[context disablePushNotificationsForTableRef:self];
	
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
