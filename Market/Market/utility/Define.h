//
//  Define.h
//  MZYY(Doctor)
//
//  Created by PengLin on 15-4-17.
//  Copyright (c) 2015年 PengLin. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Define : NSObject


#ifdef DEBUG
#define DMLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DMLog(...) do { } while (0)
#endif


#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif


//********ARC********
#if __has_feature(objc_arc)
//compiling with ARC
#else
// compiling without ARC
#endif


//********设备属性***********
#define kDeviceVersion [[UIDevice currentDevice] systemVersion]
#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.9? YES :NO )
#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES :NO)

#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//应用版本


#define kKeyChainName @"com.shangchao"


//手机型号
#define kDeviceModel  ([UIDevice currentDevice].localizedModel)
#define iPhone ([kDeviceModel hasPrefix:@"iPhone"])
#define iPad ([kDeviceModel hasPrefix:@"iPad"])

//***********屏幕长宽*************
#define SCREEN_WIDTH ( [UIScreen mainScreen].bounds.size.width )
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define App_Frame_Height  [[UIScreen mainScreen] applicationFrame].size.height
#define App_Frame_Width   [[UIScreen mainScreen] applicationFrame].size.width

#define NavigationBar_HEIGHT  self.navigationController.navigationBar.frame.size.height
//***********G－C－D*************
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)

//***********User Default*************
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]


//***********degrees  /  radian  functions*************
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(radian) (radian*180.0)/(M_PI)

//*******颜色************
#pragma mark - color functions

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]


//*******文件操作***************
#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


//******网络通信************

//+++++++++++++正式++++++++++
#define kBaseURL @"112.33.1.143:88"


//Response Code
#define kSuccessCode  1
#define kServiceTimeOut -1001

//network message
#define kServiceErrorMessage  @"网络异常，请检查网络设置！"
#define kTimeOutMessage  @"连接超时，请重新连接！"
#define kRequestFailedMessage  @"网络链接异常，请稍后在试！"
#define kRequestSuccessMessage  @"查询成功"


//字体
#define kHelvetica  @"Helvetica"
#define kHelveticaBold  @"Helvetica-Bold"
#define kHelveticaLight  @"Helvetica-Light"
#define kArialBoldMT  @"ArialMT"

//***********NSUserDefault 用户信息key****************
#define kIsRemUserPwd @"isRemUserPwd"
#define kAccount @"username"
#define kPassword @"password"
#define kUserJson @"userJson"
#define kInfoDic  @"info dic"

#define  Yuntx_appid @"20150314000000110000000000000010"
#define  Yuntx_apptoken @"17E24E5AFDB6D0C1EF32F3533494502B"

#define kUMAppKey  @"57ca60ac67e58ebc680029fe"
#define kWeixinAppKey  @"wx0a5a05321422afcf"
#define kWeixinAppSecret  @"389bee3aaabf97f8eae4614ba95c232e"
#define kqqAppID  @"1105483343"
#define kqqAppKey  @"obILznWP7zxg4Gex"

//**********消息中心注册*************
#define kPartySucessNotificationCenter  @"PartySucessNotificationCenter"
#define kPaperSucessNotificationCenter  @"PaperSucessNotificationCenter"
#define kReloadSubscribeNewsModelCenter  @"ReloadSubscribeNewsModelCenter"

//应用版本
#define kBundleShortVersion @"CFBundleShortVersionStrin"
#define kBundleVersion @"CFBundleShortVersionString"
//**********iPhone型号*************
#define iPhone5 [UIScreen mainScreen].bounds.size.width == 320 && [UIScreen mainScreen].bounds.size.height == 568
#define iPhone4 [UIScreen mainScreen].bounds.size.width == 320 && [UIScreen mainScreen].bounds.size.height == 480
#define iPhone6 [UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height == 667
#define iPhone6p [UIScreen mainScreen].bounds.size.width == 414 && [UIScreen mainScreen].bounds.size.height == 736
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif



@end
