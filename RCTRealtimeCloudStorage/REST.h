//
//  RealtimeCloudREST.h
//  RealtimeCloudStorage
//
//  Created by Realtime on 30/07/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//



#import <Foundation/Foundation.h>

@class ItemSnapshot;
@class TableSnapshot;
@class TableRef;
@class StorageContext;

typedef NS_ENUM(NSInteger, RestRequestType) {
    authenticate,
    isAuthenticated,
    getRole,
    setRole,
    deleteRole,
    listItems,
    queryItems,
    getItem,
    putItem,
    updateItem,
    deleteItem,
    createTable,
    updateTable,
    deleteTable,
    listTables,
    describeTable,
	incrementItem,
	decrementItem
};

@class TableSnapshot;
@class ItemSnapshot;

//typedef NSInteger StorageOrder;

@interface REST : NSObject {
    NSMutableData *receivedData;
    //RestRequestType rType;
    TableRef *tRef;
    StorageContext *context;
    NSString *stopKeyStr;
    //NSString *body;
    NSMutableArray *allItems;
}


@property (assign, readwrite, nonatomic)BOOL endWithNil;
@property (nonatomic,retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, strong) void (^errorCallback)(NSError*);
@property (nonatomic, strong) void (^tableSnapshotCallback)(TableSnapshot*);
@property (nonatomic, strong) void (^boolCallback)(Boolean);
@property (nonatomic, strong) void (^voidCallback)(void);
@property (nonatomic, strong) void (^dictCallback)(NSDictionary*);
@property (nonatomic, strong) void (^itemCallback)(ItemSnapshot*);
@property (nonatomic, strong) void (^onCompleted)(void);
@property (nonatomic) NSInteger *order;
@property int limit;
@property (nonatomic, strong) NSString* sortKey;
@property (nonatomic, retain) NSString* sortKeyType;
@property RestRequestType rType;
@property (nonatomic, strong) NSString* body;

- initWithContext:(StorageContext*)aContext;
- initWithContextAndTable:(StorageContext*)aContext table:(TableRef*) aTable;
//- (void)doRest:(RestRequestType) aType body:(NSString*) aBody;
- (void)doRest;
- (void)balancerResponse:(NSString*) anError result:(NSString*)tUrl;
@end
