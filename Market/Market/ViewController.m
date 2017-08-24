//
//  ViewController.m
//  Niuyou
//
//  Created by linPeng on 16/5/26.
//  Copyright © 2016年 linPeng. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "UIAlertView+Blocks.h"
#import "OpenUDID.h"
#import "Utility.h"
#import "Define.h"
#import "ModelLocator.h"
#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "WXApi.h"
#import "MWPhotoBrowser.h"
#import "ViewController2.h"
@interface ViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate>{
    NSString *tempMethod;
    BOOL isShow;
    BOOL isAdded;
}

@property (strong, nonatomic) UIWindow *keyWindow;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) UINavigationController *photoNavigationController;
@property (strong, nonatomic) MWPhotoBrowser *photoBrowser;
@end


@implementation ViewController



    
-(void)rightItemClicked:(id)sender{
//    [self.context evaluateScript:_rightMethod];
    if(isAdded){
        
    }else{
         [self.context evaluateScript:@"extraAction()"];
    }
}

-(void)showUserDetailView{
    [self.context evaluateScript:@"getmyinfo()"];
    
}
-(void)configuerNigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 40)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    button.layer.borderWidth = 1;
//    button.layer.borderColor = [UIColor whiteColor].CGColor;
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    button.layer.cornerRadius = 20 ;
    [button addTarget:self action:@selector(rightItemClicked:) forControlEvents:UIControlEventTouchUpInside];

   
    [button setTitle:_rightItmeTitle forState:UIControlStateNormal];
    
    
  
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}


-(void)configuerNigationRightItem2{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setTitle:@"编辑" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showUserDetailView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    self.view.backgroundColor = [UIColor colorWithHexString:@"BB0F1B"];
    self.webView = [[UIWebView alloc]init];
    NSInteger height = SCREEN_HEIGHT ;
    if(_isRoot){
        if(!_navigatinHidden){
            height = SCREEN_HEIGHT-64-49;
        }else{
            height = SCREEN_HEIGHT-49;
        }
        self.navigationItem.titleView = [UIView new];
    }else{
        if(!_navigatinHidden){
            height = SCREEN_HEIGHT-64;
        }else{
            height = SCREEN_HEIGHT;
        }
    }
    
    self.webView.backgroundColor =  [UIColor colorWithHexString:@"BB0F1B"];
    self.webView.frame = CGRectMake(0, 0, SCREEN_WIDTH,height);
    self.webView.delegate = self ;
    self.webView.scrollView.bounces = NO;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:self.webView];
    [self loadwebview];
    
}

-(void)configuerBackItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backItem;
}

-(void)reloadData{
    if(self.context !=nil){
        [self.context evaluateScript:@"onResume()"];
    }
}
-(void)viewWillAppear:(BOOL)animated{
   
    if(_navigatinHidden){
        [self.navigationController.navigationBar setHidden:YES];
    }else{
        [self.navigationController.navigationBar setHidden:NO];
        if(!_isRoot){
            [self configuerBackItem];
        }
    }
    
//    if([self.startPage hasPrefix:@"icon"]){
//        [self chatItem];
//    }
    if(self.context !=nil){
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
    if(self.rightItmeTitle !=nil){
        [self  configuerNigationRightItem];
    }
  [self.context evaluateScript:@"onResume()"];
   
}

-(void)viewWillDisappear:(BOOL)animated{
    if(_navigatinHidden){
        [self.navigationController.navigationBar setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLocationDataAfterLogout{
    
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kInfoDic];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserJson];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [ModelLocator sharedInstance].infoDic = nil ;
    [ModelLocator sharedInstance].userJson = nil ;
    [ModelLocator sharedInstance].code = nil;
    
    [self performSelector:@selector(refreshWeb) withObject:nil afterDelay:0.1];
}

//-(void)loginTimeOut{
//    [UIAlertView showAlertViewWithTitle:@"信息提示" message:@"登录超时，请重新登录" cancelButtonTitle:@"确定" otherButtonTitles:nil onDismiss:^(int buttonIndex) {
//        
//    } onCancel:^{
//         [self setLocationDataAfterLogout];
//    }];
//   
//}

#pragma mark Method
-(NSString *)filePath{
    NSString *filePath ;
//    if([[ModelLocator sharedInstance].userName isEqualToString:@"admin"]||[ModelLocator sharedInstance].userName==nil){
        NSBundle *mainBundle = [NSBundle mainBundle];
        filePath = [NSString stringWithFormat:@"%@/html/%@",[mainBundle bundlePath],self.startPage];
    
    
//    }else{
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *cachesPath = [paths objectAtIndex:0];
//        cachesPath=[cachesPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        filePath = [NSString stringWithFormat:@"%@/www/%@",cachesPath,self.startPage];
//    }
    
    return filePath;
}

- (void)loadwebview{
    self.context= nil;
    NSMutableURLRequest * request ;
    if([self.startPage hasPrefix:@"http"]){
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.startPage]];
    }else{
       request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self filePath]]];
    }
    
    NSArray * cookies = [[NSHTTPCookieStorage  sharedHTTPCookieStorage] cookies];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:YES];
    [request setAllHTTPHeaderFields:headers];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.context.exceptionHandler =
    ^(JSContext *context, JSValue *exceptionValue)
    {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };
    
    // 以 JSExport 协议关联 native 的方法
    self.context[@"client"] = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 以 html title 设置 导航栏 title
    // 禁用用户选择
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用长按弹出框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
 
    
    [self.context evaluateScript:@"addNativeOK()"];
   
    [self performSelector:@selector(reloadName) withObject:nil afterDelay:0.5];
}

-(void)reloadName{
    NSString *webName = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    self.navigationItem.title =webName;
     NSLog(@"title=%@",webName);
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",error.domain);
}
#pragma mark JSExport Methods

-(NSString *)readGlobalInfo:(NSString *)key{
    NSString *info= [[ModelLocator sharedInstance].infoDic valueForKey:key];
    if([info length]==0){
        return @"";
    }
    return info ;
}

-(NSString *)readNotGlobalInfo:(NSString *)key{
    NSLog(@"%@",[[ModelLocator sharedInstance].infoDic valueForKey:key]);
    if([key isEqualToString:@"code"]){
       return [ModelLocator sharedInstance].code;
    }else{
       return [[ModelLocator sharedInstance].infoDic valueForKey:key];
    }
    
    
}

-(void)saveGlobalInfo:(NSString *)key info:(NSString *)info{
    
    if([ModelLocator sharedInstance].infoDic ==nil){
        [ModelLocator sharedInstance].infoDic = [[NSMutableDictionary alloc]init];
    }
    if([info isEqualToString:@"null"]){
        [[ModelLocator sharedInstance].infoDic setValue:nil forKey:key];
    }else{
        [[ModelLocator sharedInstance].infoDic setValue:info forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setValue:[ModelLocator sharedInstance].infoDic forKey:kInfoDic];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)saveNotGlobalInfo:(NSString *)key info:(NSString *)info{
    
    if([ModelLocator sharedInstance].infoDic ==nil){
        [ModelLocator sharedInstance].infoDic = [[NSMutableDictionary alloc]init];
    }
    if([info isEqualToString:@"null"]){
        [[ModelLocator sharedInstance].infoDic setValue:nil forKey:key];
    }else{
        [[ModelLocator sharedInstance].infoDic setValue:info forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setValue:[ModelLocator sharedInstance].infoDic forKey:kInfoDic];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)goBack{
    __weak ViewController *weakSelf = self ;
    MAIN(^{
         [weakSelf.navigationController popViewControllerAnimated:YES];
    });
   
}

-(void)show:(NSString *)url{
    MAIN(^{
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController2 *webVC = [story instantiateViewControllerWithIdentifier:@"ViewController2"];
        [ModelLocator sharedInstance].urlstr = url;
        webVC.hidesBottomBarWhenPushed = YES ;
        [self.navigationController pushViewController:webVC animated:YES];
        
    });
}
-(void)openEx:(NSString *)url text:(NSString *)text{
    MAIN(^{
        
        ViewController *webVC = [[ViewController alloc]init];
        webVC.startPage = url;
        webVC.rightItmeTitle = text;
        webVC.hidesBottomBarWhenPushed = YES ;
        [self.navigationController pushViewController:webVC animated:YES];
        
    });
}

-(void)open:(NSString *)url type:(NSString *)type{
    
     MAIN(^{
       
            ViewController *webVC = [[ViewController alloc]init];
            webVC.startPage = url;
           
            webVC.hidesBottomBarWhenPushed = YES ;
            [self.navigationController pushViewController:webVC animated:YES];
         
        
     });
}



-(void)confirm:(NSString *)title message:(NSString *)message method:(NSString *)method{
    MAIN(^{
        if([Utility getNullToNil:method] !=nil){
            [UIAlertView showAlertViewWithTitle:title message:message cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] onDismiss:^(int buttonIndex) {
                [self.context evaluateScript:method];
            } onCancel:^{
                
            }];
        }else{
            [UIAlertView showAlertViewWithTitle:title message:message cancelButtonTitle:@"确认" otherButtonTitles:nil onDismiss:^(int buttonIndex) {
            } onCancel:^{
                
            }];
        }
    });
}

-(void)progress:(NSString *)type message:(NSString *)message method:(NSString *)method{
    MAIN(^{
        

        if([type isEqualToString:@"Show"]){
            [SVProgressHUD show];
        }else if ([type isEqualToString:@"Dismiss"]){
            [SVProgressHUD dismiss];
        }else if ([type isEqualToString:@"Success"]){
            [SVProgressHUD showSuccessWithStatus:message];
             [self.context evaluateScript:method];
        }else if ([type isEqualToString:@"Error"]){
            [SVProgressHUD showErrorWithStatus:message];
            [self.context evaluateScript:method];
        }
    });
}

-(NSString *)getUserJson{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userInfo = [defaults valueForKey:kUserJson];
    if(userInfo ==nil){
        userInfo = @"";
    }
    return userInfo;
}

-(void)savePoint:(NSInteger)point{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userInfo = [defaults valueForKey:kUserJson];
    NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:[userInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    NSMutableDictionary *dic =[[NSMutableDictionary alloc]initWithDictionary:userDic];
    [dic setValue:[NSNumber numberWithInt:point] forKey:@"point"];
    [defaults setValue:[dic modelToJSONString] forKey:kUserJson];
}

-(void)setUserJson:(NSString *)userStr{
    [ModelLocator sharedInstance].userJson = userStr;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:userStr forKey:kUserJson];
    [defaults synchronize];
}

-(NSString *)getlocalhost{
    return [NSString stringWithFormat:@"http://%@",kBaseURL] ;
}


-(NSString *)getImei{
    return [OpenUDID value];
}

-(void)dialPhoneNumber:(NSString *)phoneNum{
    UIWebView*callWebview =[[UIWebView alloc] init];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum ]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    [self.view addSubview:callWebview];
}

-(void)Login:(NSString *)userJson{
   
}

-(void)logout{
     MAIN(^{
         [self setLocationDataAfterLogout];
     });
}

-(void)setLoginInfo:(NSString *)userName password:(NSString *)password{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:userName forKey:kAccount];
    [defaults setValue:password forKey:kPassword];
    [defaults synchronize];
}


- (void)shareCallBack:(NSString *)type
{
   
}

-(void)showMsg:(NSString *)message{
    MAIN(^{
          [SVProgressHUD showErrorWithStatus:message afterDelay:2];
    });
  
}
-(NSString *)getIpPort{
    return kBaseURL ;
}


-(NSString *)getavatarPort{
    return [NSString stringWithFormat:@"%@/market_avatar",kBaseURL];
}

-(NSString *)getfilePort{
    return [NSString stringWithFormat:@"%@/supermarket_images/news",kBaseURL];
}

-(void)gotoWeb{
    [self open:@"http://app1.sfda.gov.cn/datasearch/face3/dir.html" type:@"1"];
}

-(void)conchoosefirm:(NSString *)title message:(NSString *)message  po_text:(NSString *)po_text ne_text:(NSString *)ne_text method:(NSString *)method method2:(NSString *)method2{
    MAIN((^{
        @weakify(self)
        [UIAlertView showAlertViewWithTitle:title message:message cancelButtonTitle:po_text otherButtonTitles:@[ne_text] onDismiss:^(int buttonIndex) {
             @strongify(self);
            [self.context evaluateScript:[NSString stringWithFormat:@"%@()",method]];
        } onCancel:^{
            [self.context evaluateScript:[NSString stringWithFormat:@"%@()",method2]];
        }];
        
    }));
}


-(void)setParm:(NSString *)parm{
    [ModelLocator sharedInstance].parm = parm ;
}

-(NSString *)getParm{
    return  [ModelLocator sharedInstance].parm;
}

-(void)cleanParm{
    [ModelLocator sharedInstance].parm = nil;
    
}

//-(NSString *)getitem:(NSString *)groupId{
//    UserModel *model = [ModelLocator sharedInstance].userModel;
//    return [model groupJson:groupId];
//}
//
//-(NSString *)getallcompany{
//     UserModel *model = [ModelLocator sharedInstance].userModel;
//    return [model.branchList modelToJSONString];
//}
//
//-(void)changecompany:(NSString *)index{
//    [ModelLocator sharedInstance].userModel.index = index;
//}

//-(void)updataUserInfo:(NSString *)name sex:(NSString *)sex email:(NSString *)email{
//    [ModelLocator sharedInstance].userModel.name = name;
//    [ModelLocator sharedInstance].userModel.email = email;
//    [ModelLocator sharedInstance].userModel.sex = sex;
//    
//}

-(void)finishactivit{
    @weakify(self);
    MAIN(^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    });
}

//-(NSString *)getuerinfo{
//     UserModel *model = [ModelLocator sharedInstance].userModel;
//    return [model getUserInfo];
//}

//-(NSString *)getcompanyid{
//    UserModel *model = [ModelLocator sharedInstance].userModel;
//    return [model getCompanyId];
//}
//
//-(NSString *)getuserid{
//    UserModel *model = [ModelLocator sharedInstance].userModel;
//    return model.userId;
//}



-(void)setNvigaionRightItem:(NSString *)content url:(NSString *)url{
    @weakify(self);
    MAIN(^{
        @strongify(self);
        self.rightItmeTitle  = content;
//        [self configuerNigationRightItem];
    });
    
}

-(void)setToptitle:(NSString *)title{
    @weakify(self);
     MAIN(^{
         @strongify(self);
         self.navigationItem.title = title;
     });
}

//-(NSString *)getrolelist{
//     UserModel *model = [ModelLocator sharedInstance].userModel;
//    return [model getAllRoleList];
//}

-(NSString *)getApp_Id{
    return kWeixinAppKey;
}

-(NSString *)getApp_Secret{
    return kWeixinAppSecret;
}

-(void)saveUserName:(NSString *)userName{
    [[ModelLocator sharedInstance].infoDic setValue:userName forKey:@"userName"];
}

-(void)openShoucang:(NSString *)url{
    @weakify(self);
    MAIN(^{
        @strongify(self);
        [self open:url type:@"1"];
    });
}

-(void)ShowShoucangFlag:(NSInteger)status{
    if(status ==0){
        isAdded = NO;
    }else{
         isAdded = YES;
    }
    @weakify(self);
    MAIN(^{
        @strongify(self);
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 40)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    button.layer.borderWidth = 1;
    //    button.layer.borderColor = [UIColor whiteColor].CGColor;
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    //    button.layer.cornerRadius = 20 ;
    [button addTarget:self action:@selector(rightItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:isAdded ?[UIImage imageNamed:@"fav_sel"]:[UIImage imageNamed:@"fav"] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    });
}

-(NSString *)getVerName{
    return [UIApplication sharedApplication ].appVersion;
}
-(void)ShowPicture:(NSInteger)index images:(NSString *)urls{
    NSArray *items = [urls componentsSeparatedByString:@","];
    NSMutableArray *images = [[NSMutableArray alloc]init];
    for (NSString *sub in items) {
        if([sub length]>0){
             MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:sub]];
            [images addObject:photo];
        }
    }
    [self showPhotoBrowser:images index:index];
}

-(void)mlog:(NSString *)log{
    NSLog(@"%@",log);
}

-(void)finishactivity:(NSInteger)index{
    @weakify(self);
    MAIN(^{
        @strongify(self);
         [self.navigationController popViewControllerAnimated:YES];
    });
  
}


-(void)finishto:(NSInteger)index isSaveLast:(BOOL)save{
    
    sleep(1);
    @weakify(self);
    MAIN(^{
        @strongify(self);
         NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
         NSLog(@"controllers=====%d",(int)controllers.count);
        if(save){
           
            for (NSInteger i = controllers.count-2; i>0; i--) {
                [controllers removeObjectAtIndex:i];
                 NSLog(@"remove =====%d",(int)controllers.count);
            }
            
            
        }else{
            for (NSInteger i = controllers.count-1; i>=index; i--) {
                [controllers removeObjectAtIndex:i];
                 NSLog(@"remove =====%d",(int)controllers.count);
            }
        }
        
        self.navigationController.viewControllers = controllers;
         NSLog(@"end =====%d",(int)controllers.count);
    });
}

-(void)LoginFromWX{
    @weakify(self);
    MAIN(^{
        @strongify(self);
        [[ModelLocator sharedInstance] addObserver:self forKeyPath:@"code" options:NSKeyValueObservingOptionNew context:nil];
        [self thirdLandingWithCategory:kUserLoginWX];
    });
}

#pragma mark 第三方登录
//触发方法
- (void) thirdLandingWithCategory:(UserLoginType )state
{
    //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
    NSArray * array = [NSArray arrayWithObjects:UMShareToWechatSession,UMShareToSina, UMShareToQQ, nil];
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:array[state]];
    //设置回调对象
    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        //如果授权成功
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
             [[ModelLocator sharedInstance].infoDic setValue:[ModelLocator sharedInstance].code forKey:@"code"];
             [self.context evaluateScript:@"onMyResume()"];
//            [self thirdLoginRequestInfo:snsAccount LoginType:state];
        }
    });
}
//-(void)savesupply:(NSString *)supplyId name:(NSString *)supplyName{
//    CustomerModel *model = [[CustomerModel alloc]init];
//    model.id = supplyId;
//    model.name = supplyName;
//    [LocalCustomerManager saveTheCustomer:model];
//}

//-(NSString *)getsupply{
//    NSArray *list = [LocalCustomerManager getCustomerList];
//    if(list!=nil){
//        NSDictionary *dic = [NSDictionary dictionaryWithObject:list forKey:@"list"];
//        return [dic modelToJSONString];
//    }else{
//        return @"";
//    }
//}

//-(void)removeallsupply{
//    [LocalCustomerManager deleteAllCustomer];
//}

//-(void)sendMessageWithContent:(NSString *)contentJson subAccount:(NSString *)subAccount type:(BOOL)isBaoJia{
//    
//    NSString * textString=  isBaoJia?@"报价":@"订单";
//   
//    
////    NSData *data = [contentJson dataUsingEncoding:NSUTF8StringEncoding];
////    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil ];
////    NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
////    if(isBaoJia){
////        [newDic setValue:@"baojia" forKey:@"msgtype"];
////        [newDic setValue:@"sell" forKey:@"userType"];
////    }else{
////        [newDic setValue:@"dingdan" forKey:@"msgtype"];
////        [newDic setValue:@"buy" forKey:@"userType"];
////    }
//   
//    UserDataModel *model = [UserDataModel modelWithJSON:contentJson];
//   
//    if(isBaoJia){
//        model.sender_role = @"s";
//        model.msgtype =@"baojia";
//    }else{
//        model.sender_role = @"b";
//        model.msgtype =@"dingdan";
//    }
//    
//     ECMessage  *message = [[DeviceChatHelper sharedInstance] sendTextMessage:textString to:subAccount withUserData:[model modelToJSONString] atArray:nil];
//
//    [[DemoGlobalClass sharedInstance].AtPersonArray removeAllObjects];
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
//
//
//}
//
//-(void)sendBaojiaRespondInfo:(NSString*)subAccount newsInfo:(NSString *)newsJson{
//    @weakify(self);
//    MAIN(^{
//        @strongify(self);
//        [self sendMessageWithContent:newsJson subAccount:subAccount type:NO];
//    });
//}
//
//-(void)sendBaojiaInfo:(NSString*)subAccount newsInfo:(NSString *)newsJson{
//    @weakify(self);
//    MAIN(^{
//        @strongify(self);
//        [self sendMessageWithContent:newsJson subAccount:subAccount type:YES];
//    });
//}
//
//-(void)startActionIM:(NSString *)subAccount is_seller:(NSInteger)is_seller{
//    @weakify(self);
//    MAIN(^{
//        @strongify(self);
//        ChatViewController *chatVC =[[ChatViewController alloc]initWithSessionId:subAccount];
//        if(is_seller ==1){
//           chatVC.is_seller = YES;
//        }else{
//           chatVC.is_seller = NO;
//        }
//        
//        chatVC.hidesBottomBarWhenPushed = YES;
//        
//        [self.navigationController pushViewController:chatVC animated:YES];
//    });
//}

//-(void)startActionIMList:(NSInteger)is_seller{
//    @weakify(self);
//    MAIN(^{
//        @strongify(self);
//        SessionViewController *chatVC =[[SessionViewController alloc]init];
//        if(is_seller ==1){
//            chatVC.is_Sell = YES;
//        }else{
//            chatVC.is_Sell = NO;
//        }
//        chatVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:chatVC animated:YES];
//    });
//   
//}
//
-(void)uploadImage:(NSData *)imageData{
   // http://127.0.0.1:88/plastic/cgi/common!uploadImg.action

    [[AppDelegate shareInstance].httpTaskManager uploadDataWithURL:@"/super_market/app/SuperMarketNew!submitAvatar.action" parameters:nil fileData:imageData onSucceeded:^(NSDictionary *dictionary) {
        isShow = NO;
        NSString *url = [dictionary valueForKey:@"fileName"];
        [self.context evaluateScript:[NSString stringWithFormat:@"refreshtouxiang('%@')",url]];
        
    } onError:^(NSError *engineError) {
        
    }];
}


//
//-(void)takePhotos:(NSString *)method{
//
//    tempMethod = method ;
//    @weakify(self);
//    MAIN(^{
//        @strongify(self);
//           [self takePhoto];
//        
//    });
//}
//
//-(void)openPhotos:(NSString *)method{
//    tempMethod = method ;
//    @weakify(self);
//    MAIN(^{
//         @strongify(self);
//    [self LocalPhoto];
//
//    });
//}

-(void)openphoto{

    if(!isShow){
        isShow = YES ;
        UIActionSheet *actionsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册获取",nil];
        [actionsheet showInView:self.navigationController.view];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self takePhoto];
    }else if(buttonIndex == 1){
        [self LocalPhoto];
    }else{
        isShow = NO;
    }
    
}

-(void)imageData:(NSData *)imageData{
//    [self uploadImage:imageData withMethod:tempMethod];
}

-(void)opencontact{
    
}

-(NSInteger)activitySize{
    return self.navigationController.viewControllers.count-1;
}

-(void)share1:(NSInteger)index{
    @weakify(self)
    MAIN(^{
        @strongify(self);
        [self shareAction:index];
    });
    
}
//开始拍照
-(void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        picker.navigationBar.tintColor = [UIColor whiteColor];
        [self.navigationController presentModalViewController:picker animated:YES];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

-(void)dealloc{
    
}

//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = NO;
    picker.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController presentModalViewController:picker animated:YES];
}


#pragma mark Actionsheet Delegaet



-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *type = [info valueForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        //        image = [Utility handleImage:image withSize:CGSizeMake(SCREEN_WIDTH, 0.5*SCREEN_WIDTH)];
        NSData *data = UIImageJPEGRepresentation(image, 0.1);

         [self uploadImage:data];
//        [self.delegate imageData:data];
        [picker dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    
}

-(void)showShareView{
    
}

-(void)hidebar{
    _navigatinHidden = YES;
   [self.navigationController.navigationBar setHidden:YES];
    self.webView.frame = CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT);
}

#pragma mark --聊天

//-(NSInteger)getUnReadcountWithType:(BOOL)is_seller{
//    NSInteger unReadCout = 0 ;
//    NSArray *array = [[DeviceDBHelper sharedInstance] getMyCustomSession];
//    for(ECSession *sunSession in array){
//        if(sunSession.myrole == is_seller){
//            unReadCout = unReadCout+ sunSession.unreadCount;
//        }
//    }
//    
//    return unReadCout;
//}

//-(void)qrCode{
//    UserModel *model = [ModelLocator sharedInstance].userModel;
//    NSString *_shareUrl = [NSString stringWithFormat:@"%@/plastic/diansu/recommend.html?phone=%@&userId=%@ ",kBaseURL,[ModelLocator sharedInstance].phone,model.userId];
//    UIImage *image = [QRCodeGenerator qrImageForString:_shareUrl imageSize:100];
//    NSString *path = [NSTemporaryDirectory() stringByStandardizingPath];
//    NSString *imagePath = [NSString stringWithFormat:@"%@/image.png",path ] ;
//    NSData *imageData = UIImagePNGRepresentation(image);
//    BOOL success = [imageData writeToFile:imagePath atomically:YES];
//    NSURL *url = [NSURL fileURLWithPath:imagePath];
//    [self.context evaluateScript:[NSString stringWithFormat:@"setGesture('%@')",[url absoluteString]]];
//}

- (void)shareAction:(NSInteger)type
{
    
    type =0 ;
    NSString *_sharePath;
    UIImage *shareImage;
  
    NSString *_shareUrl = @"";
    //NSInteger index = btn.tag - 5500;
    if ([_sharePath isEqualToString:@"(null)"] || ( _sharePath.length ==0)) {
        shareImage = [UIImage imageNamed:@"system"];
        
    }
   
    
    UMSocialUrlResource *resource = [[UMSocialData defaultData]urlResource];
    //    UIPasteboard *pad = [UIPasteboard generalPasteboard];
    if (type==0) {
        [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"%@",_shareUrl];
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"点塑 推广赚积分" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"微信分享成功！");
                [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                //                [self shareCallBack:@"微信好友"];
            }
        }];
    }else if (type==1){
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"%@",_shareUrl];
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:@"点塑 推广赚积分 " image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"微信朋友圈分享成功！");
                [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                //                [self shareCallBack:@"微信朋友圈"];
            }
        }];
    }else if (type==2){
        NSString *urlString= [NSString stringWithFormat:@"%@&type=sina",_shareUrl];
        [resource setResourceType:UMSocialUrlResourceTypeImage url:urlString];
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSina] content:@"" image:shareImage location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                //                [self shareCallBack:@"新浪微博"];
            }
        }];
    }else if (type==3){
        [UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithFormat:@"%@",_shareUrl];
        //[UMSocialData defaultData].extConfig.qqData.url = _shareUrl;
        
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:@"" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                
            }
        }];
    }else if (type==4){
        [UMSocialData defaultData].extConfig.qzoneData.url = [NSString stringWithFormat:@"%@",_shareUrl];
        //[UMSocialData defaultData].extConfig.qzoneData.url = _shareUrl;
        [UMSocialData defaultData].extConfig.qzoneData.title = @"";
        
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:@"" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"qq分享分享成功！");
                //                [self shareCallBack:@"QQ空间"];
            }
        }];
    }
}


#pragma mark - getter

- (UIWindow *)keyWindow
{
    if(_keyWindow == nil)
    {
        _keyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    
    return _keyWindow;
}

- (MWPhotoBrowser *)photoBrowser
{
    if (_photoBrowser == nil) {
        _photoBrowser = [[MWPhotoBrowser alloc] initWithPhotos:self.photos];
        _photoBrowser.delegate = self;
        _photoBrowser.displayActionButton = YES;
        _photoBrowser.displayNavArrows = YES;
        _photoBrowser.displaySelectionButtons = NO;
        _photoBrowser.alwaysShowControls = NO;
        _photoBrowser.wantsFullScreenLayout = YES;
        _photoBrowser.zoomPhotosToFill = YES;
        _photoBrowser.enableGrid = NO;
        _photoBrowser.startOnGrid = NO;
        [_photoBrowser setCurrentPhotoIndex:0];
    }
    
    return _photoBrowser;
}

- (UINavigationController *)photoNavigationController
{
    if (_photoNavigationController == nil) {
        _photoNavigationController = [[UINavigationController alloc] initWithRootViewController:self.photoBrowser];
        _photoNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    [self.photoBrowser reloadData];
    return _photoNavigationController;
}

- (void)showPhotoBrowser:(NSArray *)images  index:(NSInteger)index{
    @weakify(self);
    MAIN(^{
        @strongify(self);
        self.photos = images;
        [self.photoBrowser setCurrentPhotoIndex:index];
        [self.navigationController presentViewController:self.photoNavigationController animated:YES completion:nil];
    });
    
}

-(void)refreshWeb{
    [self.context evaluateScript:@"onMyResume()"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"code"] && object ==  [ModelLocator sharedInstance]){
        if([ModelLocator sharedInstance].code !=nil){
            [[ModelLocator sharedInstance].infoDic setValue:[ModelLocator sharedInstance].code forKey:@"code"];
            [[ModelLocator sharedInstance] removeObserver:self forKeyPath:@"code"];
            [self performSelector:@selector(refreshWeb) withObject:nil afterDelay:0.2];
        }
    }
}
@end
