//
//  HttpTaskManager.h
//  Plane
//
//  Created by auxiphone on 16/1/27.
//  Copyright © 2016年 linPeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void (^VoidBlock)(void);
typedef void (^ArrayBlock)(NSMutableArray* arrayObjects);
typedef void (^DictronaryBlock)(NSDictionary* dictionary);
typedef void (^ErrorBlock)(NSError* engineError);

@interface HttpTaskManager : AFHTTPSessionManager {
    
}

- (NSURLSessionDataTask * )postWithPortPath:(NSString *)portPath parameters: (NSMutableDictionary *)parameters  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock;

- (NSURLSessionDataTask * )getWithPortPath:(NSString *)portPath parameters: (NSMutableDictionary *)parameters  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock;

- (NSURLSessionDownloadTask *)downLoadMonitorWithURL:(NSString *)downloadURL progress:(NSProgress *)progress  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock;

-(NSURLSessionDataTask *)uploadDataWithURL:(NSString *)uploadURL parameters: (NSMutableDictionary *)parameters fileData:(NSData *)fileData onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock;

- (NSURLSessionDataTask * )changeEmail:(NSString *)portPath parameters: (NSMutableDictionary *)parameters  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock;


@end
