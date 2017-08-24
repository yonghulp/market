//
//  AppDelegate.m
//  Market
//
//  Created by linPeng on 16/9/4.
//  Copyright © 2016年 linPeng. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Define.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
@interface AppDelegate ()<UIScrollViewDelegate>{
    UIView *topView;
    UIPageControl *pageCL;
}

@end

@implementation AppDelegate

static AppDelegate *shareInstance = nil;

+(AppDelegate*)shareInstance {
    return [[UIApplication sharedApplication] delegate];
}

-(HttpTaskManager *)httpTaskManager{
    if(_httpTaskManager ==nil){
        _httpTaskManager = [HttpTaskManager manager];
    }
    return _httpTaskManager;
}

//-(HttpTaskManager *)httpTaskManager{
//    if(_httpTaskManager ==nil){
//        _httpTaskManager = [HttpTaskManager manager];
//    }
//    return _httpTaskManager;
//}

-(UIView *)createTopView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    UIScrollView *scrollView= [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    NSArray *images = @[@"wel1.png",@"wel2.png",@"wel3.png"];
    for (NSInteger i = 0; i<images.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        imageView.image = [UIImage imageNamed:images[i]];
        [scrollView addSubview:imageView];
    }
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*images.count, SCREEN_HEIGHT);
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.bounces = NO;
    scrollView.delegate = self ;
    [view addSubview:scrollView];
    
    pageCL = [[UIPageControl alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-120)/2, SCREEN_HEIGHT-60, 120, 40)];
    pageCL.numberOfPages = 3;
    [view addSubview:pageCL];
    return view ;
}
-(void)addAPNS:(UIApplication *)application {
#if !TARGET_IPHONE_SIMULATOR
   NSDateFormatter *dataformater = [[NSDateFormatter alloc] init];
    [dataformater setDateFormat:@"yyyyMMddHH"];
    
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.title = @"查看消息";
        action.identifier = @"action1";
        action.activationMode = UIUserNotificationActivationModeForeground;
        
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = @"alert";
        [category setActions:@[action] forContext:UIUserNotificationActionContextDefault];
        
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:[NSSet setWithObjects:category, nil]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    
#endif
    
}

-(void)tabbarViewController{
    if(_tabBar ==nil){
        _tabBar = [[UITabBarController alloc]init];
    }
    
    
    NSArray *titleArray = @[@"首页",@"公示",@"直通车",@"我的"];
    NSArray *htmls = @[@"index.html",@"gongshi.html",@"zhitongche.html",@"wode.html"];
    NSArray *images = @[@"ioc_17",@"ioc_19",@"ioc_21",@"ioc_23"];
    NSMutableArray *viewcontrollers =[[NSMutableArray alloc]init];
    self.tabBar.tabBar.translucent = NO;
    for (NSInteger i = 0; i< htmls.count; i++) {
        UINavigationController *nav = nil;
        ViewController *viewController = [[ViewController alloc] init];
        viewController.isRoot = YES;
        viewController.startPage  = [htmls objectAtIndex:i];
      
        if(i==2||i==1){
            viewController.navigatinHidden = YES;
        }
        nav = [[UINavigationController alloc]initWithRootViewController:viewController];
        nav.tabBarItem.title =[titleArray objectAtIndex:i];
        
        nav.navigationBar.translucent = NO;
        
        nav.tabBarItem.image = [[UIImage imageNamed:images[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nav.tabBarItem.selectedImage = [UIImage imageNamed:images[i]];
        
        [viewcontrollers addObject:nav];
        
        
    }
    
    self.tabBar.viewControllers = viewcontrollers;
   
    self.window.rootViewController = self.tabBar;
}

-(void)addTopView{
    topView = [self createTopView];
//    UIWindow *mainWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [self.window.rootViewController.view addSubview:topView];
}

- (void)configuerNavigationBar{
    UINavigationBar * appearance = [UINavigationBar appearance];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    UIGraphicsBeginImageContext(lineImage.frame.size);
    [lineImage.image drawInRect:CGRectMake(0, 0, lineImage.frame.size.width, lineImage.frame.size.height)];
    CGMutablePathRef path = CGPathCreateMutable();
    //设置矩形的边界
    CGRect rectangle = CGRectMake(0.0f, 0.0f,320.0f, 64.0f);
    //添加矩形到路径中
    CGPathAddRect(path,NULL, rectangle);
    //获得上下文句柄
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //添加路径到上下文中
    CGContextAddPath(currentContext, path);
    //填充颜色
    
//    [RGBCOLOR(172, 0, 21)  setFill];
//    [RGBCOLOR(173, 0, 21) setStroke];
    [[UIColor colorWithHexString:@"BB0F1B"]  setFill];
    [[UIColor colorWithHexString:@"BB0F1B"] setStroke];
    //设置边框线条宽度
    CGContextSetLineWidth(currentContext,0.1f);
    //画图
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    lineImage.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *navBackgroundImg = lineImage.image;
    [appearance setBackgroundImage:navBackgroundImg forBarMetrics:UIBarMetricsDefault];
    [appearance setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kHelveticaBold size:18],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)configuerTabBar{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UITabBar * appearance = [UITabBar appearance];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];
    UIGraphicsBeginImageContext(lineImage.frame.size);
    [lineImage.image drawInRect:CGRectMake(0, 0, lineImage.frame.size.width, lineImage.frame.size.height)];
    CGMutablePathRef path = CGPathCreateMutable();
    //设置矩形的边界
    CGRect rectangle = CGRectMake(0.0f, 0.0f,SCREEN_WIDTH, 64.0f);
    //添加矩形到路径中
    CGPathAddRect(path,NULL, rectangle);
    //获得上下文句柄
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //添加路径到上下文中
    CGContextAddPath(currentContext, path);
    [RGBCOLOR(245, 245, 245) setFill];
    
    [RGBCOLOR(245, 245, 245) setStroke];
    
    CGContextSetLineWidth(currentContext,0.1f);
    //画图
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    lineImage.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [appearance setBackgroundImage:lineImage.image];
    
    [appearance setTintColor:[UIColor colorWithHexString:@"BB0F1B"]];
    [[UITabBarItem appearance]  setTitleTextAttributes:[NSDictionary dictionaryWithObjects:@[[UIColor lightGrayColor],[UIFont fontWithName:kHelvetica size:10]] forKeys:@[UITextAttributeTextColor,NSFontAttributeName]] forState:UIControlStateNormal];
    
    [[UITabBarItem appearance]  setTitleTextAttributes:[NSDictionary dictionaryWithObjects:@[[UIColor colorWithHexString:@"BB0F1B"],[UIFont fontWithName:kHelvetica size:10]] forKeys:@[UITextAttributeTextColor,NSFontAttributeName]] forState:UIControlStateSelected];
    
}






//-(void)addNotificationAndObserve{
//    [[ModelLocator sharedInstance] addObserver:self forKeyPath:@"userJson" options:NSKeyValueObservingOptionNew context:nil];
//
//}

-(void)showLoginViewController{
    UINavigationController *nav = nil;
    ViewController *viewController = [[ViewController alloc] init];
    viewController.isRoot = YES;
    viewController.startPage  = @"login.html?tohtml=tabbar";
    nav = [[UINavigationController alloc]initWithRootViewController:viewController];

    self.window.rootViewController = nav ;

}

- (void) initUMSocial
{
    [UMSocialData setAppKey:kUMAppKey];
    [UMSocialData openLog:YES];
    [UMSocialWechatHandler setWXAppId:kWeixinAppKey appSecret:kWeixinAppSecret url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setQQWithAppId:kqqAppID appKey:kqqAppKey url:@"http://www.cnnb.com.cn"];
    [UMSocialQQHandler setSupportWebView:YES];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self initUMSocial];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
  
    [self addAPNS:application];
//    [self addNotificationAndObserve];
    
    [self configuerNavigationBar];
    [self configuerTabBar];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self tabbarViewController];
    BOOL isNotFirst = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isNotFirst"] boolValue];
    
    if(!isNotFirst){
        [self addTopView];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"isNotFirst"];
    }
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    NSArray *items = [[url absoluteString] componentsSeparatedByString:@"&"];
    if(items.count ==2){
        NSString *first = items[0];
        items = [first componentsSeparatedByString:@"code="];
        if(items.count ==2){
            [ModelLocator sharedInstance].code = items[1];
             return YES;
        }
    }
//    BOOL result = [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
    return NO;
}
#pragma mark
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    if([keyPath isEqualToString:@"userJson"] && object ==  [ModelLocator sharedInstance]){
//        if([ModelLocator sharedInstance].userJson ==nil){
//            [self showLoginViewController];
//        }else{
//            self.tabBar = nil;
//            [self tabbarViewController];
//        }
//        
//    }
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger page = (NSInteger )scrollView.contentOffset.x/SCREEN_WIDTH;
    pageCL.currentPage = page;
    if(page==2){
        [topView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
