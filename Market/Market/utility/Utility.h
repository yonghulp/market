//
//  Utility.h
//  Haitian
//
//  Created by linPeng on 16/3/18.
//  Copyright © 2016年 linPeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Utility : NSObject

+(void)configerNavigationBackItem:(UIViewController *)object;

+(NSRange )getTheSubViewRangeInTotail:(NSArray *)numbers index:(NSInteger)index width:(NSInteger) width;

+ (UIImage *) imageWithView:(UIView *)view;

+ (NSString *)NSDateToNSString:(NSDate *)date;
+ (NSString *)NSDateToNSString1:(NSDate *)date;
+ (NSString *)NSDateToNSString2:(NSDate *)date;
+ (NSString *)getNillToNullString:(NSString *)value;
+ (id)getNullToNil:(id)value;
+ (BOOL)isPureNumandCharacters:(NSString *)string;
+ (NSString *)removeNotNumber:(NSString *)str;

+ (NSArray *)screwArraySortWithDataArray:(NSArray *)array;
+ (NSArray *)menuArraySortWithDataArray:(NSArray *)array;

+(NSString *)changetochinese:(NSString *)numstr;
+(NSString *)aes256DecryptWithBase64EncodedString:(NSString *)base64String;
+(NSString *)hexStringToString:(NSString *)hexString;
+(NSData*)dataFormHexString:(NSString*)hexString;
+ (void)redirectNSLogToDocumentFolder ;
@end
