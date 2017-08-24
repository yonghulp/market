//
//  ModelLocator.h
//  spjk
//
//  Created by PengLin on 14-8-20.
//  Copyright (c) 2014年 PengLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"


@interface ModelLocator : NSObject


@property(nonatomic,strong) NSString *phone;
@property(nonatomic,strong) NSString *parm;
@property(nonatomic,strong) NSMutableDictionary *infoDic;
@property(nonatomic,strong) NSString *userJson;
@property(nonatomic,strong) NSString *subAccountID;
@property(nonatomic,strong) NSArray *friendArray;
@property(nonatomic,strong) NSString *code;
@property(nonatomic,strong) NSString *urlstr;
@property(nonatomic,unsafe_unretained) NSInteger quoteCount;
@property(nonatomic,unsafe_unretained) NSInteger inquiryCount;
+ (ModelLocator*)sharedInstance;

@end
