//
//  AppDelegate.h
//  Market
//
//  Created by linPeng on 16/9/4.
//  Copyright © 2016年 linPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpTaskManager.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HttpTaskManager *httpTaskManager;
@property (strong, nonatomic) UITabBarController *tabBar;


+(AppDelegate*)shareInstance;
@end


