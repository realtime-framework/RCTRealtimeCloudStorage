//
//  RealtimeCloudStorage.m
//  RealtimeCloudStorage
//
//  Created by Realtime on 30/07/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import "RealTimeCloudStorage.h"
//#import "OrtcClient.h"
//#import "TableSnapshot.h"
#import "REST.h"
#import "StorageContext.h"
//#import "TableRef.h"


@implementation StorageRef

- (id) init:(NSString*) aApplicationKey privateKey:(NSString*) aPrivateKey authenticationToken:(NSString*) aAuthenticationToken{
    return [self init:aApplicationKey privateKey:aPrivateKey authenticationToken:aAuthenticationToken isCluster:TRUE isSecure:TRUE url:@"https://storage-balancer.realtime.co/server/ssl/1.0"];
}

- (id) init:(NSString*) aApplicationKey privateKey:(NSString*) aPrivateKey authenticationToken:(NSString*) aAuthenticationToken isCluster:(Boolean) aIsCluster isSecure:(Boolean) aIsSecure url:(NSString*) aUrl {
    if (self =[super init]){
        self.context = [[StorageContext alloc] initWithParams:aUrl appKey:aApplicationKey authToken:aAuthenticationToken prvKey:aPrivateKey isCluster:aIsCluster isSecure:aIsSecure];
    }
    return self;
}

- (StorageRef*) getTables: (void (^)(TableSnapshot *success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSString *body = [NSString stringWithFormat:@"{%@}", [self.context getCredentialsJSON]];
    REST *r = [[REST alloc] initWithContext:self.context];
    r.errorCallback = aErrorCallback;
    r.tableSnapshotCallback = aSuccessCallback;
    r.rType = listTables;
    r.body = body;
    [self.context processREST:r];
    //[r doRest:listTables body:body];
    return self;
}

- (StorageRef*) isAuthenticated: (NSString*) aAuthenticationToken success:(void (^)(Boolean success)) aSuccessCallback error:(void (^)(NSError *error)) aErrorCallback{
    NSString *body = [NSString stringWithFormat:@"{\"applicationKey\":\"%@\", \"authenticationToken\":\"%@\"}", self.context.appKey, aAuthenticationToken];
    REST *r = [[REST alloc] initWithContext:self.context];
    r.errorCallback = aErrorCallback;
    r.boolCallback = aSuccessCallback;
    r.rType = isAuthenticated;
    r.body = body;
    [self.context processREST:r];
    //[r doRest:isAuthenticated body:body];
    return self;
}

- (TableRef*) table:(NSString*) aName{
    TableRef *t = [[TableRef alloc]initWithName:aName context:self.context];
    return t;
}

- (StorageRef*) onReconnected: (void (^)(StorageRef* storage)) reconnectedCallback{
    self.context.onReconnected = reconnectedCallback;
    return self;
}

- (StorageRef*) onReconnecting: (void (^)(StorageRef* storage)) reconnectingCallback{
    self.context.onReconnecting = reconnectingCallback;
    return self;
}

- (StorageRef*) activateOfflineBuffering{
    self.context.bufferIsActive = true;
    return self;
}

- (StorageRef*) deactivateOfflineBuffering{
    self.context.bufferIsActive = false;
    return self;
}
@end
