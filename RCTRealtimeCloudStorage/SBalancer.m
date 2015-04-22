//
//  Balancer.m
//  RealTimeCloudStorage
//
//  Created by Marcin Kulwikowski on 09/07/14.
//  Copyright (c) 2014 RealTime. All rights reserved.
//

#import "SBalancer.h"
#import "REST.h"

static NSString* url;

SEL theSelector;
id theTarget;

@implementation SBalancer

@synthesize receivedData;


- initWithTarget:(id)aTarget selector:(SEL)aSelector cluster:(NSString*)aCluster appKey:(NSString*)anAppKey{
    if ((self = [super init])) {
        theTarget = aTarget;
        theSelector = aSelector;
        if(url != nil){
            [self callTheSelectorWithErrorAndResult:nil result:url];
        } else {
            [self getBalancerFromClusterForApplicationKey:aCluster appKey:anAppKey];
        }
    }
    return nil;
}

- (void) callTheSelectorWithErrorAndResult:(NSString*)anError result:(NSString*)aResult{
    IMP imp = [theTarget methodForSelector:theSelector];
    void (*callback)(id, SEL, NSString*, NSString*) = (void *)imp;
    callback(theTarget, theSelector, anError, aResult);
}


+ (BOOL)clear{
    BOOL ret = url == nil ? false : true;
    url = nil;
    return ret;
}

- (void)getBalancerFromClusterForApplicationKey:(NSString*) aCluster appKey:(NSString*) anAppKey{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?appkey=%@", aCluster, anAppKey]]];
    self.receivedData = [NSMutableData dataWithData: [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil]];
    if(self.receivedData !=nil){
        NSError *parseError = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingMutableLeaves error:&parseError];
        if(dic != nil){
            if([dic isKindOfClass:[NSDictionary class]]){
                NSString* result = [dic objectForKey:@"url"];
                url = result;
                [self callTheSelectorWithErrorAndResult:nil result:result];
                return;
            }
        }
    }
    [self callTheSelectorWithErrorAndResult:@"Wrong balancer response" result:nil];
}


@end
