//
//  Filter.h
//  RealtimeCloudStorage
//
//  Created by RealTime on 08/08/2013.
//  Copyright (c) 2013 RealTime. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StorageFilter) {
    StorageFilter_EQUALS,
    StorageFilter_NOTEQUAL,
    StorageFilter_GREATEREQUAL,
    StorageFilter_GREATERTHAN,
    StorageFilter_LESSEREQUAL,
    StorageFilter_LESSERTHAN,
    StorageFilter_NOTNULL,
    StorageFilter_NULL,
    StorageFilter_CONTAINS,
    StorageFilter_NOTCONTAINS,
    StorageFilter_BEGINSWITH,
    StorageFilter_BETWEEN
};

@interface Filter : NSObject

@property (nonatomic) StorageFilter fOperator;
@property (nonatomic, retain) NSString *item;
@property (nonatomic, retain) NSObject *value;
@property (nonatomic, retain) NSObject *valueEx;

- (id)initWithParams:(StorageFilter) aOperator item:(NSString*)aItem value:(NSObject*)aValue;
- (id)initWithParamsEx:(StorageFilter) aOperator item:(NSString*)aItem value:(NSObject*)aValue valueEx:(NSObject*)aValueEx;
- (NSString*) getJSON;
- (NSString*) getfilterOperatorString;

@end
