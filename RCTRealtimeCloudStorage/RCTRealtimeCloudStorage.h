//
//  RCTRealtimeCloudStorage.h
//  RCTRealtimeCloudStorage
//
//  Created by Joao Caixinha on 15/04/15.
//  Copyright (c) 2015 Realtime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RealTimeCloudStorage.h"
#import "RCTBridgeModule.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

@interface RCTRealtimeCloudStorage : NSObject<RCTBridgeModule>

@property(retain, nonatomic)NSMutableDictionary* storageRefs;
@property(retain, nonatomic)NSMutableDictionary* tableRefs;
@property(retain, nonatomic)NSMutableDictionary* itemRefs;

@end
