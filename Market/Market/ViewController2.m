//
//  ViewController2.m
//  codecControllerTest
//
//  Created by liucairong on 15/10/9.
//  Copyright (c) 2015年 znv. All rights reserved.
//

#import "ViewController2.h"
#import "MyView.h"

@interface ViewController2 ()

@end

@implementation ViewController2
@synthesize xibView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [xibView initMyView];
    //NSString *filePath = @"rtsp://10.72.68.15:8006/service?PUID-ChannelNo=180101111000006-1&PlayMethod=0&StreamingType=1&A=zxvnms";
    //NSString *fileName = @"lily test";
    //[xibView initFilePath:filePath fileName:fileName];
    
    RtspServerInfo servInfo;
    memset(&servInfo ,0x00 ,sizeof(RtspServerInfo) );
    
    
    strcpy(servInfo.chPtzIP, "10.72.68.15");
    servInfo.serverPort = 8006;
    servInfo.nPtzPort = 5074;
    
    strcpy(servInfo.protocolType, "rtsp");
    strcpy(servInfo.coderID, "180101111000006");
    
    
    /*
    strcpy(servInfo.chPtzIP, "10.72.68.128");
    servInfo.serverPort = 8004;
    servInfo.nPtzPort = 5064;
    
    strcpy(servInfo.protocolType, "rtsp");
    strcpy(servInfo.coderID, "050012111003000");
    */
    
    
    servInfo.channelNum = 1;
    servInfo.streamNum = 1;
    
    servInfo.cloudTEnable = YES;
    
    strcpy(servInfo.chRtspSession, "zxvnms");
    servInfo.tiltStep = 3;
    
    [xibView initFilePath:servInfo];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    xibView.delegate = self;

}

- (void)viewWillDisappear:(BOOL)animated

{
    [super viewWillDisappear:animated];
    // 使能系统屏保
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationMaskPortrait;//当前controller只支持竖直方向
    //return UIInterfaceOrientationMaskLandscapeLeft;//只支持横屏向右
    //return UIInterfaceOrientationMaskLandscapeRight ;//只支持横屏向左
    //return UIInterfaceOrientationMaskPortraitUpsideDown ;//只支持倒立
    //return UIInterfaceOrientationMaskLandscape ;//支持横屏左右2个方向
    //return UIInterfaceOrientationMaskAll ;//4个方向都支持
    //return UIInterfaceOrientationMaskAllButUpsideDown;//除了倒立，其他3个方向都支持（iphone的默认配置）
    
    
    //宣告一個UIDevice指標，並取得目前Device的狀況
    UIDevice *device = [UIDevice currentDevice] ;
    
    //取得當前Device的方向，來當作判斷敘述。（Device的方向型態為Integer）
    switch (device.orientation)
    {
            /*      case UIDeviceOrientationFaceUp:
             NSLog(@"螢幕朝上平躺");
             return UIInterfaceOrientationMaskAllButUpsideDown;
             break;
             
             case UIDeviceOrientationFaceDown:
             NSLog(@"螢幕朝下平躺");
             return UIInterfaceOrientationMaskAllButUpsideDown;
             break;
             
             //系統無法判斷目前Device的方向，有可能是斜置
             case UIDeviceOrientationUnknown:
             NSLog(@"未知方向");
             return UIInterfaceOrientationMaskAllButUpsideDown;
             break;
             */
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"螢幕向左橫置");
            if([xibView setFullScreen])
                return UIInterfaceOrientationMaskLandscapeRight;//只支持横屏向右
            else
                return UIInterfaceOrientationMaskPortrait;//还不能旋转。
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"螢幕向右橫置");
            if([xibView setFullScreen])
                return UIInterfaceOrientationMaskLandscapeLeft ;//只支持横屏向左
            else
                return UIInterfaceOrientationMaskPortrait;//还不能旋转。
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"螢幕直立");
            [xibView setNarrowScreen];
            return UIInterfaceOrientationMaskPortrait;
            break;
            
            /*
             case UIDeviceOrientationPortraitUpsideDown:
             NSLog(@"螢幕直立，上下顛倒");
             return UIInterfaceOrientationMaskPortrait;
             break;
             */
        default:
            NSLog(@"屏幕方向不做处理");
            break;
            
    }
    return UIInterfaceOrientationMaskPortrait;
    
}


- (BOOL)shouldAutorotate
{
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//implement MyViewDelegate
-(void)myViewCallBackGetPhoto:(UIImage *)imagePhoto;
{
    //you have got the first photo:imagePhoto,you can do what you want to do.
    NSLog(@"------got the first photo-------");
}

@end
