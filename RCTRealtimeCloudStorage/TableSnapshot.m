//
//  TableSnapshot.m
//  RealtimeCloudStorage
//
//  Created by RealTime on 31/07/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

//#import "TableSnapshot.h"
#import "RealTimeCloudStorage.h"

@implementation TableSnapshot


- (id)initWithContextAndName:(StorageContext*) aContext val:(NSString*) aName{
    if ((self = [super init])) {
        context = aContext;
        name = aName;
    }
    return self;
}

- (NSString*) val{
    return name;
}

- (TableRef*) ref{
    return [[TableRef alloc] initWithName:name context:context];
}

@end
