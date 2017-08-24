//
//  ViewController.h
//  Niuyou
//
//  Created by linPeng on 16/5/26.
//  Copyright © 2016年 linPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol NativeJSExport <JSExport>

JSExportAs(open, -(void)open:(NSString *)url type:(NSString *)type);
JSExportAs(openEx, -(void)openEx:(NSString *)url text:(NSString *)text);
JSExportAs(progress, -(void)progress:(NSString *)type message:(NSString *)message method:(NSString *)method);
JSExportAs(confirm, -(void)confirm:(NSString *)title message:(NSString *)message method:(NSString *)method);
JSExportAs(saveGlobalInfo, -(void)saveGlobalInfo:(NSString *)key info:(NSString *)info );
JSExportAs(saveNotGlobalInfo, -(void)saveNotGlobalInfo:(NSString *)key info:(NSString *)info );

JSExportAs(Sign,-(NSString *)md5SignWithJsonString:(NSString*)jsonString);
JSExportAs(conchoosefirm, -(void)conchoosefirm:(NSString *)title message:(NSString *)message  po_text:(NSString *)po_text ne_text:(NSString *)ne_text method:(NSString *)method method2:(NSString *)method2);

JSExportAs(changuserinfo, -(void)updataUserInfo:(NSString *)name sex:(NSString *)sex email:(NSString *)email);
JSExportAs(showrtb, -(void)setNvigaionRightItem:(NSString *)content url:(NSString *)url);
JSExportAs(savesupply,-(void)savesupply:(NSString *)supplyId name:(NSString *)supplyName);

JSExportAs(startActionIM, -(void)startActionIM:(NSString *)subAccount is_seller:(NSInteger)is_seller);
JSExportAs(startActionIMList, -(void)startActionIMList:(NSInteger)is_seller);
JSExportAs(sendBaojiaInfo, -(void)sendBaojiaInfo:(NSString*)subAccount newsInfo:(NSString *)newsJson );
JSExportAs(sendBaojiaRespondInfo, -(void)sendBaojiaRespondInfo:(NSString*)subAccount newsInfo:(NSString *)newsJson );
JSExportAs(ShowPicture, -(void)ShowPicture:(NSInteger)index images:(NSString *)urls);
JSExportAs(setLoginInfo, -(void)setLoginInfo:(NSString *)userName password:(NSString *)password);
//-(NSString *)Base64mod:(NSString *)input;
-(void)finishactivity:(NSInteger)index;
-(void)setParm:(NSString *)parm;
-(NSString *)getParm;
-(NSString *)getVerName;
-(NSString *)getitem:(NSString *)groupId;
-(NSString *)getallcompany;
-(void)changecompany:(NSString *)index;
-(NSString *)getuerinfo;
-(NSString *)getcompanyid;
-(NSString *)getuserid;
-(void)setToptitle:(NSString *)title;
-(void)hidertb;
-(void)savePoint:(NSInteger)point;
-(NSString *)getrolelist;
-(void)mlog:(NSString *)log;
-(NSString *)getsupply;
-(void)removeallsupply;
-(void)show:(NSString *)url;
//-(void)openPhotos:(NSString *)method;
//-(void)takePhotos:(NSString *)method;
-(void)openphoto;
-(void)opencontact;
-(void)hidebar;
-(void)qrCode;
-(NSInteger)activitySize;
-(void)share1:(NSInteger)index;
-(NSString *)readNotGlobalInfo:(NSString *)key;
-(NSString *)readGlobalInfo:(NSString *)key;
-(void)tohtml;
-(NSString *)getImei;
-(void)dialPhoneNumber:(NSString *)phoneNum;
-(NSString *)getUserJson;
-(void)setUserJson:(NSString *)userStr;
-(NSString *)getlocalhost;
-(NSString *)getIpPort;
-(NSString *)getavatarPort;
-(NSString *)getfilePort;
-(void)logout;
-(void)goBack;
-(NSString *)getAppId;
-(void)Login:(NSString *)userJson;
-(void)loginWithOther:(NSInteger)type;
-(void)pickImage;
-(void)showMsg:(NSString *)message;
-(void)gotoWeb;
-(void)LoginFromWX;
-(NSString *)getApp_Id;
-(NSString *)getApp_Secret;
-(void)saveUserName:(NSString *)userName;
-(void)openShoucang:(NSString *)url;
-(void)ShowShoucangFlag:(NSInteger)status;
@end

typedef enum
{
    kUserLoginWX,
    kUserLoginWB,
    kUserLoginQQ,
    kUserLoginLocal,
}UserLoginType;

@interface ViewController : UIViewController<UIWebViewDelegate,NativeJSExport>
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) NSString *startPage;
@property (nonatomic,strong) JSContext *context;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *rightItmeTitle;
@property (nonatomic,strong) NSString *rightMethod;
@property (nonatomic ,unsafe_unretained) BOOL navigatinHidden;
@property (nonatomic ,unsafe_unretained) BOOL isRoot;
@end

