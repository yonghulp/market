//
//  HttpTaskManager.m
//  Plane
//
//  Created by auxiphone on 16/1/27.
//  Copyright © 2016年 linPeng. All rights reserved.
//

#import "HttpTaskManager.h"
#import "SVProgressHUD.h"


@implementation HttpTaskManager

-(NSString *)getURL:(NSString *)portPath{
    NSString *urlStr ;
    if([portPath hasPrefix:@"http"]){
        return portPath;
    }else{
        if([portPath hasPrefix:@"/"]){
           urlStr= [NSString stringWithFormat:@"http://%@%@",kBaseURL,portPath];
        }else{
           urlStr = [NSString stringWithFormat:@"http://%@/%@",kBaseURL,portPath];
        }
    }
    return urlStr ;
}

- (NSURLSessionDataTask * )postWithPortPath:(NSString *)portPath parameters: (NSMutableDictionary *)parameters  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock{
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/html",nil];
    if([portPath length]==0){
        return nil;
    }
    
    [self POST:[self getURL:portPath] parameters:parameters constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@ === %@",task.currentRequest ,[parameters modelToJSONString]);
        NSLog(@"%@",[responseObject modelToJSONString]);
        if([responseObject isKindOfClass:[NSDictionary class]]){
            succeededBlock(responseObject);
        }else if([responseObject isKindOfClass:[NSArray class]]){
            NSMutableDictionary *resposeDic = [[NSMutableDictionary alloc]initWithObjects:@[responseObject,[NSNumber numberWithInt:1]] forKeys:@[@"list",@"ret"]];
            succeededBlock(resposeDic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error description]);
    }];
    
    return nil;
}


- (NSURLSessionDataTask * )getWithPortPath:(NSString *)portPath parameters: (NSMutableDictionary *)parameters  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock{
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/html",nil];
    if([portPath length]==0){
        return nil;
    }
    
    [self GET:[self getURL:portPath] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@ === %@",task.currentRequest ,[parameters modelToJSONString]);
        NSLog(@"%@",[responseObject modelToJSONString]);
        if([responseObject isKindOfClass:[NSDictionary class]]){
            succeededBlock(responseObject);
        }else if([responseObject isKindOfClass:[NSArray class]]){
            NSMutableDictionary *resposeDic = [[NSMutableDictionary alloc]initWithObjects:@[responseObject,[NSNumber numberWithInt:1]] forKeys:@[@"list",@"ret"]];
            succeededBlock(resposeDic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error description]);
        [SVProgressHUD dismissWithError:@"网络异常"];
    }];
    
    return nil;
}

- (NSURLSessionDownloadTask *)downLoadMonitorWithURL:(NSString *)downloadURL progress:(NSProgress *)progress  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock{
     NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    
    NSURLSessionDownloadTask *downTask = [self downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
       NSLog(@"%@",filePath.absoluteString);
    }];
    [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
    [downTask resume];
    
     return downTask;
}


-uploadDataWithURL:(NSString *)uploadURL parameters: (NSMutableDictionary *)parameters fileData:(NSData *)fileData onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock{
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/html",nil];
    [self POST:[self getURL:uploadURL] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /*
         Data: 需要上传的数据
         name: 服务器参数的名称
         fileName: 文件名称
         mimeType: 文件的类型
         */
        //        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        [formData appendPartWithFileData:fileData name:@"file" fileName:@"file" mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeededBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(error);
    }];
    
    return nil;
}

// 收到通知调用的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSProgress *)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%f",1.0 * object.completedUnitCount / object.totalUnitCount);
    // 回到主队列刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        self.progress.progress = 1.0 * object.completedUnitCount / object.totalUnitCount;
    });
}
@end
