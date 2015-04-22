//
//  Balancer.h
//  RealTimeCloudStorage
//
//  Created by Marcin Kulwikowski on 09/07/14.
//  Copyright (c) 2014 RealTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBalancer : NSObject

@property (atomic,retain) NSMutableData *receivedData;
- initWithTarget:(id)aTarget selector:(SEL)aSelector cluster:(NSString*)aCluster appKey:(NSString*)anAppKey;

+ (BOOL)clear;

@end
