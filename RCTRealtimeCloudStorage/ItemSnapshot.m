//
//  ItemSnapshot.m
//  RealtimeCloudStorage
//
//  Created by RealTime on 30/07/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

//#import "ItemSnapshot.h"
//#import "ItemRef.h"
//#import "TableRef.h"
#import "RealTimeCloudStorage.h"
#import "StorageContext.h"

@implementation ItemSnapshot

- (id)initWithRefContextAndVal:(TableRef*) aTableRef storageContext:(StorageContext*)aContext val:(NSDictionary*) aVal{
    if ((self = [super init])) {
        iRef = nil;
        iVal = aVal;
        tRef = aTableRef;
        context = aContext;
    }
    return self;
}

- (ItemRef*) ref{
    NSDictionary *meta = [context getTableMetaFromCache:tRef.name];
    if(meta != nil){
        NSDictionary *mkey = [meta objectForKey:@"key"];
        NSDictionary *primary = [mkey objectForKey:@"primary"];
        NSDictionary *secondary = [mkey objectForKey:@"secondary"];
        NSString *primaryName = nil, *secondaryName = nil, *primaryValue = nil, *secondaryValue = nil;
        primaryName = [primary objectForKey:@"name"];
        primaryValue = [iVal objectForKey:primaryName];
        if(secondary!=nil){
            secondaryName = [secondary objectForKey:@"name"];
            secondaryValue = [iVal objectForKey:secondaryName];
        }        
        iRef = [[ItemRef alloc] initWithPrimaryAndSecondary:tRef context:context primaryKeyValue:primaryValue secondaryKeyValue:secondaryValue];
    }
    return iRef;
}
- (NSDictionary*) val{
    return iVal;
}

@end
