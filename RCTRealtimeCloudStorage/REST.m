//
//  RealtimeCloudREST.m
//  RealtimeCloudStorage
//
//  Created by Realtime on 30/07/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import "RealTimeCloudStorage.h"
#import "REST.h"
#import "SBalancer.h"
//#import "TableRef.h"
//#import "TableSnapshot.h"
#import "StorageContext.h"
//#import "ItemSnapshot.h"

@implementation REST

@synthesize receivedData;
@synthesize url;
@synthesize order;
@synthesize limit;
@synthesize sortKey;
@synthesize sortKeyType;
@synthesize rType;
@synthesize body;

- initWithContext:(StorageContext*)aContext{
    return [self initWithContextAndTable:aContext table:nil];
}

- initWithContextAndTable:(StorageContext*)aContext table:(TableRef*) aTable{
    if ((self = [super init])) {
        _endWithNil = NO;
 		self.url = aContext.url;
        tRef = aTable;
        context = aContext;
        stopKeyStr = nil;
        allItems = [[NSMutableArray alloc] init];
    }    
    return self;
}

- (void)balancerResponse:(NSString*) anError result:(NSString*)tUrl{
    NSString *postStr;
    if(tUrl == nil) {
        if (self.errorCallback){
            self.errorCallback([NSError errorWithDomain:@"RealtimeCloudStorage" code:500 userInfo:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Can not get url from cluster!", NSLocalizedDescriptionKey, nil]]);
        }
        return;
    }
    
    NSString *connUrl = [NSString stringWithFormat:@"%@%@%@", tUrl, [tUrl hasSuffix:@"/"]?@"":@"/", [self decodeRequestPath: rType]];
    if(stopKeyStr==nil){
        postStr = body;
    } else {
        postStr = [NSString stringWithFormat:@"%@, \"startKey\":%@}", [body substringToIndex:[body length]-1], stopKeyStr];
    }
    
    //NSLog(@"%@", connUrl);
    //NSLog(@"%@", postStr);

    NSData* postData = [postStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString* postLength = [NSString stringWithFormat:@"%ld", (unsigned long)[postData length]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:connUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [self post:request];

}

- (void)doRest{
    if(context.isCluster){
        (void)[[SBalancer alloc] initWithTarget:self selector:@selector(balancerResponse:result:) cluster:context.url appKey:context.appKey ];
    } else {
        [self balancerResponse:nil result:url];
    }
    
    //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
        //[self _doRest];
    //});
}

- (void)_doRest{
    NSString *postStr;
    NSString *tUrl = (context.isCluster) ? [self getServerFromBalancer] : url;
    if(tUrl == nil) {
        if (self.errorCallback){
            self.errorCallback([NSError errorWithDomain:@"RealtimeCloudStorage" code:500 userInfo:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Can not get url from cluster!", NSLocalizedDescriptionKey, nil]]);
        }
        return;
    }
            
    NSString *connUrl = [NSString stringWithFormat:@"%@%@%@", tUrl, [tUrl hasSuffix:@"/"]?@"":@"/", [self decodeRequestPath: rType]];
    if(stopKeyStr==nil){
        postStr = body;
    } else {
        postStr = [NSString stringWithFormat:@"%@, \"startKey\":%@}", [body substringToIndex:[body length]-1], stopKeyStr];
    }
    
    //NSLog(@"%@", postStr);
    
    NSData* postData = [postStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString* postLength = [NSString stringWithFormat:@"%ld", (unsigned long)[postData length]];    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:connUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [self post:request];
}

- (void)post: (NSMutableURLRequest *)request{
    self.receivedData = [[NSMutableData alloc] init];

 	//NSURLConnection* ret = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.receivedData = [[NSMutableData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil]];
    
    [self callTheCallback:(NSData*)self.receivedData error:nil];
//    if (ret == nil){
//        NSMutableDictionary* details = [NSMutableDictionary dictionary];
//        [details setValue:@"The connection can't be initialized." forKey:NSLocalizedDescriptionKey];
//        NSError *error = [NSError errorWithDomain:@"RealtimeCloudStorage" code:500 userInfo:details];
//        //self.callback(error, NULL);
//        [self callTheCallback:nil error:error];
//    }
}

- (NSString*)getServerFromBalancer{
    NSString *result = nil;
    NSString* parsedUrl = [NSString stringWithFormat:@"%@?appkey=%@", context.url, context.appKey];    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:parsedUrl]];
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(response==nil)
        return nil;
    NSError *parseError = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&parseError];
    if(dic != nil){
        if([dic isKindOfClass:[NSDictionary class]]){
            result = [dic objectForKey:@"url"];
            return result;
        }
    }
    return nil;
}

- (void) callTheCallback:(NSData*) aResponse error:(NSError*) aError{

	if(self.onCompleted)
        self.onCompleted();
    
    if(aResponse == nil){
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Can not get response form storage server." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"RealtimeCloudStorage" code:500 userInfo:details];
        if(self.errorCallback)
            self.errorCallback(error);
        return;
    }
    
    NSError *parseError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:aResponse options:NSJSONReadingMutableLeaves error:&parseError];

    if(res != nil){
        if([res isKindOfClass:[NSDictionary class]]){
            if([res objectForKey:@"error"] != [NSNull null] && [res objectForKey:@"error"] != nil){
                NSNumber *code = [[res objectForKey:@"error"] objectForKey:@"code"];
                NSString *message = [[res objectForKey:@"error"] objectForKey:@"message"];
                NSMutableDictionary* errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:message forKey:NSLocalizedDescriptionKey];
                if(self.errorCallback)
                    self.errorCallback([NSError errorWithDomain:@"RealtimeCloudStorage" code:[code integerValue] userInfo:errorDetails]);
                return;
            } else {
                
                if(rType == deleteTable){
                    if (self.dictCallback) {
                        self.dictCallback([res objectForKey:@"data"]);
                    }
                }

                if(rType == isAuthenticated){
                    Boolean b = (Boolean)[[res objectForKey:@"data"] boolValue];
                    if(self.boolCallback)
                        self.boolCallback(b);
                    return;
                }
               
                NSDictionary *data = [res objectForKey:@"data"];
                if([data isKindOfClass:[NSDictionary class]]){
                    /*
                    NSLog(@"Data :");
                    NSArray *keys = [data allKeys];
                    int keysCount = (int)[keys count];
                    for (int i = 0; i < keysCount; i++){
                        NSLog(@" - %@ :  %@", [keys objectAtIndex:i], [data objectForKey:[keys objectAtIndex:i]]);
                    }*/
                    if(rType == getItem || rType == deleteItem){
                        if(self.itemCallback){
                            
                            if ([data count] == 0) {
                                self.itemCallback(nil);
                                return;
                            }
                            
                            self.itemCallback([[ItemSnapshot alloc] initWithRefContextAndVal:tRef storageContext:context val:data]);
                            if (rType == getItem && _endWithNil == YES) {
                                 self.itemCallback(nil);
                            }
                        }
                    }

                    if(rType == createTable || rType == describeTable || rType == updateTable)
                        if(self.dictCallback)
                            self.dictCallback(data);
                    if(rType == putItem || rType == updateItem || rType == incrementItem || rType == decrementItem)
                        if(self.itemCallback)
                            self.itemCallback([[ItemSnapshot alloc] initWithRefContextAndVal:tRef storageContext:context val:data]);
                    if(rType == listTables){
                        NSArray *tables = [data objectForKey:@"tables"];
                        if(self.tableSnapshotCallback){
                            for(int i = 0; i < [tables count]; i++)
                                self.tableSnapshotCallback([[TableSnapshot alloc] initWithContextAndName:context val:[tables objectAtIndex:i]]);
                            self.tableSnapshotCallback(nil);
                        }
                    }
                    if(rType == queryItems || rType == listItems){
                        NSArray *items = [data objectForKey:@"items"];
                        [allItems addObjectsFromArray:items];
                    
                        NSDictionary *stopKey = [data objectForKey:@"stopKey"];
                        if(stopKey!=nil && limit == 0) {
                            NSError *error;
                            NSData *jData = [NSJSONSerialization dataWithJSONObject:stopKey options:0 error:&error];
                            stopKeyStr = [[NSString alloc] initWithData:jData encoding:NSUTF8StringEncoding];
                            [self doRest];
                            return;
                        }
                    }
                    
                    
                    if(rType == queryItems){
                        //NSArray *items = [data objectForKey:@"items"];
                        int itemsCount = (int)[allItems count];
                        for(int i = 0; i < itemsCount; i++){
                            NSDictionary *item = [allItems objectAtIndex:i];
                            if([item isKindOfClass:[NSDictionary class]]){
                                ItemSnapshot *iSnapshot = [[ItemSnapshot alloc] initWithRefContextAndVal:tRef storageContext:context val:item];
                                if(self.itemCallback)
                                    self.itemCallback(iSnapshot);
                            }
                        }
                        if(self.itemCallback){
                            self.itemCallback(nil);
                        }
                    }
                    if(rType == listItems){
                        //NSArray *items = [data objectForKey:@"items"];                        
                        if(order != StorageOrder_NULL){
                            NSArray *sorted = [allItems sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
                                NSDictionary *da = (NSDictionary*)a;
                                NSDictionary *db = (NSDictionary*)b;
                                if([sortKeyType isEqualToString:@"string"]){
                                    return [[da objectForKey:sortKey]compare:[db objectForKey:sortKey] options:NSLiteralSearch] * (order==(NSInteger*)StorageOrder_ASC?1:-1);
                                }
                                return [[[da objectForKey:sortKey] stringValue] compare:[[db objectForKey:sortKey] stringValue] options:NSLiteralSearch] * (order==(NSInteger*)StorageOrder_ASC?1:-1);
                            }];
                            allItems = (NSMutableArray*)sorted;
                        }
                        int itemsCount = (int)[allItems count];
                        if(limit > 0 && limit < itemsCount)
                            itemsCount = limit;
                        for(int i = 0; i < itemsCount; i++){
                            NSDictionary *item = [allItems objectAtIndex:i];
                            if([item isKindOfClass:[NSDictionary class]]){
                                ItemSnapshot *iSnapshot = [[ItemSnapshot alloc] initWithRefContextAndVal:tRef storageContext:context val:item];
                                if(self.itemCallback)
                                    self.itemCallback(iSnapshot);
                            }
                        }
                        if(self.itemCallback) {
                            self.itemCallback(nil);
                        }
                    }
				}
            } 
        }
    } else {
        if(self.errorCallback)
            self.errorCallback(parseError);
    }
    
}

- (NSString*) decodeRequestPath: (RestRequestType) aType{
    switch (aType){
        case authenticate: return @"authenticate";
        case isAuthenticated: return @"isAuthenticated";
        case getRole: return @"getRole";
        case setRole: return @"setRole";
        case deleteRole: return @"deleteRole";
        case listItems: return @"listItems";
        case queryItems: return @"queryItems";
        case getItem: return @"getItem";
        case putItem: return @"putItem";
        case updateItem: return @"updateItem";
        case deleteItem: return @"deleteItem";
        case createTable: return @"createTable";
        case updateTable: return @"updateTable";
        case deleteTable: return @"deleteTable";
        case listTables: return @"listTables";
        case describeTable: return @"describeTable";
		case incrementItem: return @"incr";
		case decrementItem: return @"decr";
    }
    return @"undeclared";
}

#pragma mark NSURLConnection delegate methods
- (NSURLRequest *)connection:(NSURLConnection *)connection
 			 willSendRequest:(NSURLRequest *)request
 			redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)aError {
    //self.callback(error, NULL);
    if([SBalancer clear]){
        [self doRest]; //try one more time (this time ask balancer)
    }
    [self callTheCallback:nil error:aError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
 	//NSString *dataStr=[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    //self.callback(NULL, dataStr);
    //[self callTheCallback:dataStr error:nil];
    
    [self callTheCallback:(NSData*)self.receivedData error:nil];
}


@end
