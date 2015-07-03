//
//  RCTRealtimeCloudStorage.m
//  RCTRealtimeCloudStorage
//
//  Created by Joao Caixinha on 15/04/15.
//  Copyright (c) 2015 Realtime. All rights reserved.
//

#import "RCTRealtimeCloudStorage.h"
#import <RCTConvert.h>


@implementation RCTRealtimeCloudStorage
//storageRef
@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();



//====== DATA CONVERSION =================================================================================


- (ProvisionLoad)convertProvisionLoad:(NSString*)ProvisionLoad
{
    NSDictionary *types = @{@"ProvisionLoad_READ":[NSNumber numberWithInteger:ProvisionLoad_READ],
                            @"ProvisionLoad_WRITE":[NSNumber numberWithInteger:ProvisionLoad_WRITE],
                            @"ProvisionLoad_BALANCED":[NSNumber numberWithInteger:ProvisionLoad_BALANCED]
                            };
    return [((NSNumber*)[types objectForKey:ProvisionLoad]) integerValue];
}


- (ProvisionType)convertProvisionType:(NSString*)ProvisionType
{
    NSDictionary *types = @{@"ProvisionType_LIGHT":[NSNumber numberWithInteger:ProvisionType_LIGHT],
                            @"ProvisionType_MEDIUM":[NSNumber numberWithInteger:ProvisionType_MEDIUM ],
                            @"ProvisionType_INTERMEDIATE":[NSNumber numberWithInteger:ProvisionType_INTERMEDIATE ],
                            @"ProvisionType_HEAVY":[NSNumber numberWithInteger:ProvisionType_HEAVY ],
                            @"ProvisionType_CUSTOM":[NSNumber numberWithInteger:ProvisionType_CUSTOM ]
                            };
    return [((NSNumber*)[types objectForKey:ProvisionType]) integerValue];
}


- (StorageDataType)convertStorageDataType:(NSString*)StorageDataType
{
    NSDictionary *types = @{@"StorageDataType_STRING":[NSNumber numberWithInteger:StorageDataType_STRING],
                            @"StorageDataType_NUMBER":[NSNumber numberWithInteger:StorageDataType_NUMBER]
                            };
    return [((NSNumber*)[types objectForKey:StorageDataType]) integerValue];
}


- (StorageOrder)convertStorageOrder:(NSString*)StorageOrder
{
    NSDictionary *types = @{@"StorageOrder_NULL":[NSNumber numberWithInteger:StorageOrder_NULL],
                            @"StorageOrder_ASC":[NSNumber numberWithInteger:StorageOrder_ASC],
                            @"StorageOrder_DESC":[NSNumber numberWithInteger:StorageOrder_DESC]
                            };
    return [((NSNumber*)[types objectForKey:StorageOrder]) integerValue];
}


- (StorageEventType)convertEventType:(NSString*)eventType
{
    NSDictionary *types = @{@"StorageEvent_PUT":[NSNumber numberWithInteger:StorageEvent_PUT],
                            @"StorageEvent_UPDATE":[NSNumber numberWithInteger:StorageEvent_UPDATE ],
                            @"StorageEvent_DELETE":[NSNumber numberWithInteger:StorageEvent_DELETE ]
                            };
    return [((NSNumber*)[types objectForKey:eventType]) integerValue];
}


//====== DATA CONVERSION =================================================================================


RCT_EXPORT_METHOD(init:(NSString*) aApplicationKey privateKey:(NSString*) aPrivateKey authenticationToken:(NSString*) aAuthenticationToken ide:(NSString*)pid)
{
    if (!_storageRefs) {
        _storageRefs = [[NSMutableDictionary alloc] init];
    }
    
    if (!_itemRefs) {
        _itemRefs = [[NSMutableDictionary alloc] init];
    }
    
    StorageRef *storageref = [_storageRefs objectForKey:pid];
    
    if (!storageref) {
        storageref = [[StorageRef alloc] init:aApplicationKey privateKey:(([aPrivateKey isEqualToString:@""])? nil : aPrivateKey) authenticationToken:aAuthenticationToken];
    }
    
    [_storageRefs setObject:storageref forKey:pid];
}

RCT_EXPORT_METHOD(initCustom:(NSString*) aApplicationKey privateKey:(NSString*) aPrivateKey authenticationToken:(NSString*) aAuthenticationToken isCluster:(BOOL) aIsCluster isSecure:(BOOL) aIsSecure url:(NSString*) aUrl ide:(NSString*)pid)
{
    if (!_storageRefs) {
        _storageRefs = [[NSMutableDictionary alloc] init];
    }
    
    if (!_itemRefs) {
        _itemRefs = [[NSMutableDictionary alloc] init];
    }
    
    StorageRef *storageref = [_storageRefs objectForKey:pid];
    
    if (!storageref) {
        storageref = [[StorageRef alloc] init:aApplicationKey privateKey:(([aPrivateKey isEqualToString:@""])? nil : aPrivateKey) authenticationToken:aAuthenticationToken isCluster:aIsCluster isSecure:aIsSecure url:aUrl];
    }
    
    [_storageRefs setObject:storageref forKey:pid];
}

RCT_EXPORT_METHOD(getTables:(NSString*)pid)
{
    StorageRef *storageref = [_storageRefs objectForKey:pid];
    [storageref getTables:^(TableSnapshot *success) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-getTables", pid]
                                                     body:success.val];
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-getTables", pid]
                                                     body:@{@"error":error.description}];
    }];
}

RCT_EXPORT_METHOD(isAuthenticated: (NSString*) aAuthenticationToken ide:(NSString*)pid){
    StorageRef *storageref = [_storageRefs objectForKey:pid];
    [storageref isAuthenticated:aAuthenticationToken success:^(Boolean success) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-isAuthenticated", pid]
                                                     body:@{@"success": [NSNumber numberWithBool:success]}];
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-isAuthenticated", pid]
                                                     body:@{@"error": error.description}];
    }];
}

RCT_EXPORT_METHOD(table:(NSString*)aName storageRef:(NSString*)sId tableRef:(NSString*)tId ){
    StorageRef *storageref = [_storageRefs objectForKey:sId];
    TableRef *tableref = [_tableRefs objectForKey:tId];
    
    if (!tableref) {
        tableref = [storageref table:aName];
    }
    
    [self appendTable:tableref toStorage:sId withTid:tId];
}

- (void)appendTable:(TableRef*)table toStorage:(NSString*)sId withTid:(NSString*)tId
{
    if (!_tableRefs) {
        _tableRefs = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *objs = [_tableRefs objectForKey:sId];
    if (!objs) {
        objs = [[NSMutableDictionary alloc] init];
    }
    
    [objs setObject:table forKey:tId];
    [_tableRefs setObject:objs forKey:sId];
}


RCT_EXPORT_METHOD(onReconnected:(NSString*)pid){
    StorageRef *storageref = [_storageRefs objectForKey:pid];
    [storageref onReconnected:^(StorageRef *storage) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-onReconnected", pid]
                                                     body:@{}];
    }];
}

RCT_EXPORT_METHOD(onReconnecting:(NSString*)pid){
    StorageRef *storageref = [_storageRefs objectForKey:pid];
    [storageref onReconnecting:^(StorageRef *storage) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-onReconnecting", pid]
                                                     body:@{}];
    }];
}

RCT_EXPORT_METHOD(activateOfflineBuffering:(NSString*)pid){
    StorageRef *storageref = [_storageRefs objectForKey:pid];
    [storageref activateOfflineBuffering];
}

RCT_EXPORT_METHOD(deactivateOfflineBuffering:(NSString*)pid){
    StorageRef *storageref = [_storageRefs objectForKey:pid];
    [storageref deactivateOfflineBuffering];
}


/**
 * TableRef interface
 */

RCT_EXPORT_METHOD(asc:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef asc];
}
RCT_EXPORT_METHOD(desc:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef desc];
}

RCT_EXPORT_METHOD(beginsWithString: (NSString*) item value:(NSString*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef beginsWithString:item value:value];
}

RCT_EXPORT_METHOD(beginsWithNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef beginsWithNumber:item value:value];
}

RCT_EXPORT_METHOD(betweenString: (NSString*) item beginValue:(NSString*) beginValue endValue:(NSString*) endValue storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef betweenString:item beginValue:beginValue endValue:endValue];
}
RCT_EXPORT_METHOD(betweenNumber: (NSString*) item beginValue:(NSNumber*) beginValue endValue:(NSNumber*) endValue storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef betweenNumber:item beginValue:beginValue endValue:endValue];

}
RCT_EXPORT_METHOD(containsString: (NSString*) item value:(NSString*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef containsString:item value:value];
}
RCT_EXPORT_METHOD(containsNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef containsNumber:item value:value];
}
RCT_EXPORT_METHOD(equalsString: (NSString*) item value:(NSString*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef equalsString:item value:value];
}
RCT_EXPORT_METHOD(equalsNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef equalsNumber:item value:value];
}
RCT_EXPORT_METHOD(greaterEqualString: (NSString*) item value:(NSString*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef greaterEqualString:item value:value];
}
RCT_EXPORT_METHOD(greaterEqualNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef greaterEqualNumber:item value:value];
}
RCT_EXPORT_METHOD(greaterThanString: (NSString*) item value:(id) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef greaterThanString:item value:value];
}
RCT_EXPORT_METHOD(greaterThanNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef greaterThanNumber:item value:value];
}
RCT_EXPORT_METHOD(lesserEqualString: (NSString*) item value:(NSString*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef lesserEqualString:item value:value];
}
RCT_EXPORT_METHOD(lesserEqualNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef lesserEqualNumber:item value:value];
}
RCT_EXPORT_METHOD(lesserThanString: (NSString*) item value:(NSString*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef lesserThanString:item value:value];
}
RCT_EXPORT_METHOD(lesserThanNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef lesserThanNumber:item value:value];
}
RCT_EXPORT_METHOD(notContainsString: (NSString*) item value:(NSString*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef notContainsString:item value:value];
}
RCT_EXPORT_METHOD(notContainsNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef notContainsNumber:item value:value];
}
RCT_EXPORT_METHOD(notEqualString: (NSString*) item value:(NSString*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef notEqualString:item value:value];
}
RCT_EXPORT_METHOD(notEqualNumber: (NSString*) item value:(NSNumber*) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef notEqualNumber:item value:value];
}
RCT_EXPORT_METHOD(notNull: (NSString*) item storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef notNull:item];
}
RCT_EXPORT_METHOD(Null: (NSString*) item storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef null:item];
}

RCT_EXPORT_METHOD(create: (NSString*)aPrimaryKey primaryKeyDataType:(NSString*)aPrimaryKeyDataType provisionType:(NSString*)aProvisionType provisionLoad:(NSString*)aProvisionLoad storage:(NSString*)sId table:(NSString*)table){
    
    ProvisionLoad pLoad = [self convertProvisionLoad:aProvisionLoad];
    ProvisionType pType = [self convertProvisionType:aProvisionType];
    StorageDataType sDType = [self convertStorageDataType:aPrimaryKeyDataType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef create:aPrimaryKey primaryKeyDataType:sDType provisionType:pType provisionLoad:pLoad success:^(NSDictionary *success) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-create", table]
                                                        body:success];
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-create", table]
                                                        body:@{@"error": error.localizedDescription}];
    }];
}

RCT_EXPORT_METHOD(createCustom: (NSString*) aPrimaryKey primaryKeyDataType:(NSString*) aPrimaryKeyDataType secondaryKey:(NSString*) aSecondaryKey secondaryKeyDataType:(NSString*) aSecondaryKeyDataType provisionType:(NSString*) aProvisionType provisionLoad:(NSString*)aProvisionLoad storage:(NSString*)sId table:(NSString*)table){
    
    ProvisionLoad pLoad = [self convertProvisionLoad:aProvisionLoad];
    ProvisionType pType = [self convertProvisionType:aProvisionType];
    StorageDataType aPrimaryKeyDataTypeC = [self convertStorageDataType:aPrimaryKeyDataType];
    StorageDataType aSecondaryKeyDataTypeC = [self convertStorageDataType:aSecondaryKeyDataType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef create:aPrimaryKey primaryKeyDataType:aPrimaryKeyDataTypeC secondaryKey:aSecondaryKey secondaryKeyDataType:aSecondaryKeyDataTypeC provisionType:pType provisionLoad:pLoad success:^(NSDictionary *success) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-create", table]
                                                        body:success];
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-create", table]
                                                        body:@{@"error": error.localizedDescription}];
    }];
}

RCT_EXPORT_METHOD(del:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef del:^(NSDictionary *success) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-del", table]
                                                        body:success];
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-del", table]
                                                        body:@{@"error": error.localizedDescription}];
    }];
}

RCT_EXPORT_METHOD(update: (NSString*) aProvisionType provisionLoad:(NSString*) aProvisionLoad storage:(NSString*)sId table:(NSString*)table){
    
    ProvisionLoad pLoad = [self convertProvisionLoad:aProvisionLoad];
    ProvisionType pType = [self convertProvisionType:aProvisionType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef update:pType provisionLoad:pLoad success:^(NSDictionary *success) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-update", table]
                                                        body:success];
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-update", table]
                                                        body:@{@"error": error.localizedDescription}];
    }];
}


RCT_EXPORT_METHOD(item: (NSString*) primaryKey storage:(NSString*)sId table:(NSString*)table item:(NSString*)iId){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    ItemRef* item = [_itemRefs objectForKey:iId];
    if (!item) {
        item = [tableRef item:primaryKey];
    }
    
    [_itemRefs setObject:item forKey: iId];
}

RCT_EXPORT_METHOD(itemCustom: (NSString*) primaryKey secondaryKey:(NSString*) secondaryKey storage:(NSString*)sId table:(NSString*)table item:(NSString*)iId){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    ItemRef* item = [_itemRefs objectForKey:iId];
    if (!item) {
        item = [tableRef item:primaryKey secondaryKey:secondaryKey];
    }

    [_itemRefs setObject:item forKey: iId];
}

RCT_EXPORT_METHOD(push: (NSDictionary*) aItem  storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef push:aItem success:^(ItemSnapshot *item) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-push", table]
                                                        body:item.val];
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-push", table]
                                                        body:@{@"error": error.localizedDescription}];
    }];
}

RCT_EXPORT_METHOD(getItems:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef getItems:^(ItemSnapshot *item) {
        if (item) {
            [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-getItems", table]
                                                         body:item.val];
        }else
        {
            [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-getItems", table]
                                                            body:nil];
        }
        
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-getItems", table]
                                                     body:@{@"error": error.localizedDescription}];
    }];
    
}

RCT_EXPORT_METHOD(limit: (int) value storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef limit:value];
}

RCT_EXPORT_METHOD(meta:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef meta:^(NSDictionary *success) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-meta", table]
                                                        body:success];
    } error:^(NSError *error) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-meta", table]
                                                        body:@{@"error": error.localizedDescription}];
    }];
}

RCT_EXPORT_METHOD(name:(RCTResponseSenderBlock)callback storage:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    callback(@[[tableRef name]]);
}


RCT_EXPORT_METHOD(on: (NSString*) eventType storage:(NSString*)sId table:(NSString*)table){
    
    StorageEventType sEvt = [self convertEventType:eventType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    
    [tableRef on:sEvt callback:^(ItemSnapshot *item) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-on-%@", table, eventType]
                                                        body:item.val];
    }];
}

RCT_EXPORT_METHOD(onCustom: (NSString*) eventType primaryKey:(NSString*)aPrimaryKeyValue storage:(NSString*)sId table:(NSString*)table){
    
    StorageEventType sEvt = [self convertEventType:eventType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef on:sEvt primaryKey:aPrimaryKeyValue callback:^(ItemSnapshot *item) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-on-%@", table, eventType]
                                                        body:item.val];
    }];
}

RCT_EXPORT_METHOD(off: (NSString*) eventType storage:(NSString*)sId table:(NSString*)table){
    
    StorageEventType sEvt = [self convertEventType:eventType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef off:sEvt];
}

RCT_EXPORT_METHOD(offCustom: (NSString*) eventType primaryKey:(NSString*)aPrimaryKeyValue storage:(NSString*)sId table:(NSString*)table){
    
    StorageEventType sEvt = [self convertEventType:eventType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef off:sEvt primaryKey:aPrimaryKeyValue];
}

RCT_EXPORT_METHOD(once: (NSString*) eventType storage:(NSString*)sId table:(NSString*)table){
    
    StorageEventType sEvt = [self convertEventType:eventType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef once:sEvt callback:^(ItemSnapshot *item) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-once-%@", table, eventType]
                                                        body:item.val];
    }];
}

RCT_EXPORT_METHOD(onceCustom: (NSString*) eventType primaryKey:(NSString*)aPrimaryKeyValue storage:(NSString*)sId table:(NSString*)table){
    
    StorageEventType sEvt = [self convertEventType:eventType];
    
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef once:sEvt primaryKey:aPrimaryKeyValue callback:^(ItemSnapshot *item) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:[NSString stringWithFormat:@"%@-once-%@", table, eventType]
                                                        body:item.val];
    }];
}

RCT_EXPORT_METHOD(enablePushNotifications:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef enablePushNotifications];
}

RCT_EXPORT_METHOD(disablePushNotifications:(NSString*)sId table:(NSString*)table){
    NSMutableDictionary *sRefs = [_tableRefs objectForKey:sId];
    TableRef *tableRef = [sRefs objectForKey:table];
    [tableRef disablePushNotifications];
}


//=========================================================

RCT_EXPORT_METHOD(itemRefdel:(NSString*)iId success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)errorC){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item del:^(ItemSnapshot *itemRef) {
        success(@[itemRef.val]);
    } error:^(NSError *error) {
        errorC(@[error.localizedDescription]);
    }];
}

RCT_EXPORT_METHOD(itemRefget:(NSString*)iId success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)errorC){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item get:^(ItemSnapshot *itemRef) {
        success(@[itemRef.val]);
    } error:^(NSError *error) {
        errorC(@[error.localizedDescription]);
    }];
}

RCT_EXPORT_METHOD(itemRefset: (NSDictionary*)attributes item:(NSString*)iId success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)errorC){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item set: attributes success:^(ItemSnapshot *itemRef) {
        success(@[itemRef.val]);
    } error:^(NSError *error) {
        errorC(@[error.localizedDescription]);
    }];
}

RCT_EXPORT_METHOD(itemRefincr:(NSString *)property withValue:(NSInteger)value item:(NSString*)iId success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)errorC){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item incr:property withValue:value success:^(ItemSnapshot *itemRef) {
        success(@[itemRef.val]);
    } error:^(NSError *error) {
        errorC(@[error.localizedDescription]);
    }];
}
RCT_EXPORT_METHOD(itemRefincrCustom:(NSString *)property item:(NSString*)iId success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)errorC){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item incr:property success:^(ItemSnapshot *itemRef) {
        success(@[itemRef.val]);
    } error:^(NSError *error) {
        errorC(@[error.localizedDescription]);
    }];
}
RCT_EXPORT_METHOD(itemRefdecr:(NSString *)property withValue:(NSInteger)value item:(NSString*)iId success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)errorC){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item decr:property withValue:value success:^(ItemSnapshot *itemRef) {
        success(@[itemRef.val]);
    } error:^(NSError *error) {
        errorC(@[error.localizedDescription]);
    }];
}

RCT_EXPORT_METHOD(itemRefdecrCustom:(NSString *)property item:(NSString*)iId success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)errorC){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item decr:property success:^(ItemSnapshot *itemRef) {
        success(@[itemRef.val]);
    } error:^(NSError *error) {
        errorC(@[error.localizedDescription]);
    }];
}


RCT_EXPORT_METHOD(itemRefon: (NSString*) eventType item:(NSString*)iId callback:(RCTResponseSenderBlock)callback){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item on:[self convertEventType:eventType] callback:^(ItemSnapshot *itemRef) {
        callback(@[itemRef.val]);
    }];
}


RCT_EXPORT_METHOD(itemRefoff: (NSString*) eventType item:(NSString*)iId){
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item off:[self convertEventType:eventType]];
}



RCT_EXPORT_METHOD(itemRefonce: (NSString*) eventType item:(NSString*)iId callback:(RCTResponseSenderBlock)callback)
{
    ItemRef *item = [_itemRefs objectForKey:iId];
    [item once:[self convertEventType:eventType] callback:^(ItemSnapshot *itemRef) {
        callback(@[itemRef.val]);
    }];
}

RCT_EXPORT_METHOD(itemRefenablePushNotifications:(NSString*)iId){
ItemRef *item = [_itemRefs objectForKey:iId];
    [item enablePushNotifications];
}

RCT_EXPORT_METHOD(itemRefdisablePushNotifications:(NSString*)iId){
ItemRef *item = [_itemRefs objectForKey:iId];
    [item enablePushNotifications];
}

@end
