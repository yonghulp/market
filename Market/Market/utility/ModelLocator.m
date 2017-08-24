//
//  ModelLocator.m
//  spjk
//
//  Created by PengLin on 14-8-20.
//  Copyright (c) 2014年 PengLin. All rights reserved.
//

#import "ModelLocator.h"

@implementation ModelLocator

static ModelLocator *sharedInstance = nil;

+ (ModelLocator*)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];

    }
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.infoDic =  [[NSMutableDictionary alloc]init];;
    }
    return self;
}
@end
