//
//  MyView.m
//  codecControllerTest
//
//  Created by liucairong on 15/10/9.
//  Copyright (c) 2015年 znv. All rights reserved.
//

#import "MyView.h"
#import <AssetsLibrary/AssetsLibrary.h>
//#import "common.h"
#import "sys/socket.h"
#import "sys/types.h"
#import "netinet/in.h"
#import <pthread.h>
#import <arpa/inet.h>

#import "OpenGLLayer20.h"
#import "SoftHardCodec.h"


CGFloat const gestureMinimumTranslation = 20.0;

typedef enum : NSInteger {
    kCameraMoveDirectionNone,
    kCameraMoveDirectionUp,
    kCameraMoveDirectionDown,
    kCameraMoveDirectionRight,
    kCameraMoveDirectionLeft
} CameraMoveDirection;

@interface MyView()<SoftHardCodecDelegate>
{
    SoftHardCodec *sHCodec;
    
    OpenGLLayer20 *glLayer;
    OpenGLLayer20 *glfullLayer;
    NSString *inputURLString;
    BOOL playFlag;
    int indexOfPlayer;
    
    BOOL videoFullFlag;
    BOOL camCtrShowFlag;
    
    //PanGestureDirections
    CameraMoveDirection direction;
    
}

@property (nonatomic, retain) IBOutlet UIView *contentView;


@property (nonatomic, retain) IBOutlet UIView *VideoView;
@property (nonatomic, retain) IBOutlet UIView *FullVideoView;
@property (nonatomic, retain) IBOutlet UILabel *labelCameraName;
@property (nonatomic, retain) IBOutlet UILabel *labelStatus;

@property (nonatomic, retain) IBOutlet UIButton *playButton;//player_pause.png
@property (nonatomic, retain) IBOutlet UIButton *captureButton;//player_snap.png
@property (nonatomic, retain) IBOutlet UIButton *fullScreenButton;//player_fullScreen.png
@property (nonatomic, retain) IBOutlet UIButton *camCtrShowButton;//player_openPTZ.png
@property (nonatomic, retain) IBOutlet UIButton *returnButton;//player_exit.png

@property (nonatomic, retain) IBOutlet UIView *camCtrView;

@property (nonatomic, retain) IBOutlet UIButton *camLeftButton;//player_PTZLeft.png
@property (nonatomic, retain) IBOutlet UIButton *camRightButton;//player_PTZRight.png
@property (nonatomic, retain) IBOutlet UIButton *camUpButton;//player_PTZUp.png
@property (nonatomic, retain) IBOutlet UIButton *camDownButton;//player_PTZDown.png
@property (nonatomic, retain) IBOutlet UIButton *camZoomInButton;//player_zoomIn.png
@property (nonatomic, retain) IBOutlet UIButton *camZoomOutButton;//player_zoomOut.png
@property (nonatomic, retain) IBOutlet UIButton *camNearButton;//player_Near.png
@property (nonatomic, retain) IBOutlet UIButton *camFarButton;//player_Far.png

- (IBAction)returnClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;
- (IBAction)captureButtonClicked:(id)sender;
- (IBAction)fullScreenButtonClicked:(id)sender;
- (IBAction)camCtrShowButtonClicked:(id)sender;

- (IBAction)camCtrLeftButtonDown:(id)sender;
- (IBAction)camCtrRightButtonDown:(id)sender;
- (IBAction)camCtrUpButtonDown:(id)sender;
- (IBAction)camCtrDownButtonDown:(id)sender;
- (IBAction)camCtrZoomInButtonDown:(id)sender;
- (IBAction)camCtrZoomOutButtonDown:(id)sender;
- (IBAction)camCtrNearButtonDown:(id)sender;
- (IBAction)camCtrFarButtonDown:(id)sender;
- (IBAction)camCtrStopButtonUp:(id)sender;

@end

////////////////////////

RtspServerInfo serverInfo;


BOOL ctlThdAlive = NO;//控制云台的线程是否有效：进入view controller4后开始有效，一直循环运行，播放停止时无效
int controlCmd = 0;
int controlStatus = 0;
pthread_t pThread_ctrl;


#define PTZ_TURN_UP			1
#define PTZ_TURN_DOWN		2
#define PTZ_TURN_LEFT		3
#define PTZ_TURN_RIGHT		4
#define PTZ_OPEN_IRIS		5
#define PTZ_CLOSE_IRIS		6
#define PTZ_ZOOM_IN			7
#define PTZ_ZOOM_OUT		8
#define PTZ_FOCUS_NEAR		9
#define PTZ_FOCUS_FAR		10
#define PTZ_STOP			15

#define CTRL_STATUS_NONE		0
#define CTRL_STATUS_CTRL_PAN	1
#define CTRL_STATUS_CTRL_CAM	3
#define CTRL_STATUS_STOP		4

#define SEND_CTRL_CMD_TIMES	2
#define SEND_CTRL_STOP_TIMES 6

static int initCtrlSock();
static void *pControl_Thread();


///////////////////////
/*init ptzsocket*/
static int initCtrlSock()
{
    
    int sockfd = socket(PF_INET ,SOCK_DGRAM ,0);
    if(sockfd < 0 )
    {
        printf("[initCtrlSock] create control socket failed!\n");
        return -1;
    }
    
    struct sockaddr_in serverAddr;
    struct sockaddr_in clientAddr;
    
    bzero(&serverAddr ,sizeof(serverAddr));
    bzero(&clientAddr ,sizeof(clientAddr));
    
    serverAddr.sin_family = AF_INET;
    //lily test
    //serverInfo.chPtzIP = "10.72.68.15";
    // printf("serverInfo.chPtzIP: %s\n", serverInfo.chPtzIP);
    
    //
    serverAddr.sin_addr.s_addr = inet_addr(serverInfo.chPtzIP);
    serverAddr.sin_port = htons((u_short)serverInfo.nPtzPort);
    //printf("*******************serverAddr.sin_port: %d*********************\n", serverAddr.sin_port);
    printf("*******************chPtzIP: %s\n", serverInfo.chPtzIP);
    printf("*******************port: %d\n", serverInfo.nPtzPort);
    printf("*******************id: %s\n", serverInfo.chRtspSession);
    
    clientAddr.sin_family = AF_INET;
    clientAddr.sin_addr.s_addr = INADDR_ANY;
    clientAddr.sin_port = htons((u_short)8008);
    
    if(bind(sockfd, (struct sockaddr *)&clientAddr, sizeof(clientAddr) ) < 0)
    {
        close(sockfd);
        printf("[initCtrlSock] bind socket failed!\n");
        return -1;
    }
    
    if( connect(sockfd , (struct sockaddr*)&serverAddr ,sizeof(serverAddr) ) < 0 )
    {
        close(sockfd);
        printf("]initCtrlSock] connect failed!\n");
        return -1;
    }
    
    return sockfd ;
}

/*camera control thread*/
static void *pControl_Thread()
{
    int clientSock =  initCtrlSock();
    if(clientSock < 0)
    {
        //goto  err_return;
        printf("create PTZ_control socket error!\n");
        return NULL;
    }
    //printf("[pControl_control] start!\n");
    
    //int iLen = 0;
    int nStrLen;
    int iCtrlCount = 0;
    
    char szSessionID[64];
    char szControlMsg[1000];
    char szSipHead[1000];
    bzero(szSessionID, sizeof(szSessionID) );
    bzero(szControlMsg, sizeof(szControlMsg) );
    bzero(szSipHead, sizeof(szSipHead) );
    //printf("*****************create PTZ_control socket ok!****************\n");
    
    while(ctlThdAlive)
    {
        //send control cmd
        //if( iCtrlCount < SEND_CTRL_CMD_TIMES &&(CTRL_STATUS_CTRL_CAM == controlStatus || CTRL_STATUS_CTRL_PAN == controlStatus) )
        if(CTRL_STATUS_CTRL_CAM == controlStatus || CTRL_STATUS_CTRL_PAN == controlStatus)
        {
            iCtrlCount++;
            
            bzero(szControlMsg,  sizeof(szControlMsg));

            sprintf(szControlMsg,"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Message Version=\"1.0\"><IE_HEADER MessageType=\"MSG_PTZ_SET_REQ\" UserID=\"demo\" DestID=\"%s\" PUID=\"%s\" channel=\"1\"/><IE_PTZ OpId=\"%d\" Param1=\"%d\"  Param2=\"0\"/></Message>",
                    serverInfo.chRtspSession,serverInfo.coderID, controlCmd, serverInfo.tiltStep);

            nStrLen = strlen(szControlMsg);
            printf("*******************serverInfo.chRtspSession: %s*********************\n", serverInfo.chRtspSession);
            printf("*******************serverInfo.coderID: %s*********************\n", serverInfo.coderID);
            printf("*******************serverInfo.tiltStep: %d\n", serverInfo.tiltStep);
            
            bzero(szSipHead,sizeof(szSipHead) );
            sprintf(szSipHead,"INFO sip:gebroadcast@x SIP/2.0\r\nContent-Type:application/global_eye_v10+xml\r\nContent-Length:%d\r\nTo:<sip:gebroadcast@x>\r\nFrom:<sip:test@y>\r\nCSeq:1234 INFO\r\nCall-ID:01234567890abcdef\r\nMax-Forwards:70\r\nVia:SIP/2.0/UDP 127.0.0.1;branch=z9hG4bK776asdhds\r\nContact:<sip:test@y>\r\n\r\n",
                    nStrLen);
            strcat(szSipHead ,szControlMsg);
            
            send(clientSock, szSipHead, strlen(szSipHead), 0);
        }//end if
        
        
        if( CTRL_STATUS_STOP == controlStatus )  //send stop cmd
        {
            controlStatus = CTRL_STATUS_NONE ;
            
            bzero(szControlMsg,sizeof(szControlMsg) );
            sprintf(szControlMsg,"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Message Version=\"1.0\"><IE_HEADER MessageType=\"MSG_PTZ_SET_REQ\" UserID=\"demo\" DestID=\"%s\"/><IE_PTZ OpId=\"%d\" Param1=\"%d\"  Param2=\"0\"/></Message>",
                    serverInfo.chRtspSession, 15, 0);
            nStrLen = strlen(szControlMsg);
            bzero(szSipHead, sizeof(szSipHead) );
            sprintf(szSipHead,"INFO sip:gebroadcast@x SIP/2.0\r\nContent-Type:application/global_eye_v10+xml\r\nContent-Length:%d\r\nTo:<sip:gebroadcast@x>\r\nFrom:<sip:test@y>\r\nCSeq:1234 INFO\r\nCall-ID:01234567890abcdef\r\nMax-Forwards:70\r\nVia:SIP/2.0/UDP 127.0.0.1;branch=z9hG4bK776asdhds\r\nContact:<sip:test@y>\r\n\r\n",
                    nStrLen);
            strcat(szSipHead,szControlMsg);
            
            while( iCtrlCount < SEND_CTRL_STOP_TIMES )
            {
                iCtrlCount++;
                usleep(100);
                send(clientSock , szSipHead ,strlen(szSipHead) ,0 );
            }//end while
            iCtrlCount = 0;
        }//end if
        
        usleep(500000);
    }//end while
    close(clientSock);
    
    //printf("[pControl_control] Quit!\n");
    return NULL;
}





@implementation MyView
@synthesize VideoView;
@synthesize FullVideoView;
@synthesize labelCameraName;
@synthesize labelStatus;

@synthesize playButton;
@synthesize captureButton;
@synthesize fullScreenButton;
@synthesize camCtrShowButton;
@synthesize returnButton;

@synthesize camCtrView;

@synthesize camLeftButton;
@synthesize camRightButton;
@synthesize camUpButton;
@synthesize camDownButton;
@synthesize camZoomInButton;
@synthesize camZoomOutButton;
@synthesize camNearButton;
@synthesize camFarButton;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib
{
    NSLog(@"awake from nib");
    [[NSBundle mainBundle] loadNibNamed:@"XIBView" owner:self options:nil];
    [self addSubview:self.contentView];
}


- (void)initMyView //只在加载时，调用一次，可以做初始化函数
{
    NSLog(@"initMyView ....\n");
    
    sHCodec = [[SoftHardCodec alloc] init];
    sHCodec.delegate = self;
    
    
    playFlag   = NO;
    indexOfPlayer = 0;
    videoFullFlag = NO;
    camCtrShowFlag = NO;
    
/*
    CGRect tmpRect = FullVideoView.frame;
    FullVideoView.transform=CGAffineTransformMakeRotation(M_PI*(270.0)/180.0);
    FullVideoView.frame = tmpRect;
 */
    
    [self setFrame:[[UIScreen mainScreen] bounds]];
    [self addGesture];
    
    NSLog(@"initMyView [ok]\n");
    
    //lily add 默认的button图片
    [playButton setImage:[UIImage imageNamed:@"player_pause.png"] forState:UIControlStateNormal];
    [captureButton setImage:[UIImage imageNamed:@"player_snap.png"] forState:UIControlStateNormal];
    [fullScreenButton setImage:[UIImage imageNamed:@"player_fullScreen.png"] forState:UIControlStateNormal];
    [camCtrShowButton setImage:[UIImage imageNamed:@"player_openPTZ.png"] forState:UIControlStateNormal];
    [returnButton setImage:[UIImage imageNamed:@"player_exit.png"] forState:UIControlStateNormal];
    
    
    [camLeftButton setImage:[UIImage imageNamed:@"player_PTZLeft.png"] forState:UIControlStateNormal];
    [camRightButton setImage:[UIImage imageNamed:@"player_PTZRight.png"] forState:UIControlStateNormal];
    [camUpButton setImage:[UIImage imageNamed:@"player_PTZUp.png"] forState:UIControlStateNormal];
    [camDownButton setImage:[UIImage imageNamed:@"player_PTZDown.png"] forState:UIControlStateNormal];
    [camZoomInButton setImage:[UIImage imageNamed:@"player_zoomIn.png"] forState:UIControlStateNormal];
    [camZoomOutButton setImage:[UIImage imageNamed:@"player_zoomOut.png"] forState:UIControlStateNormal];
    [camNearButton setImage:[UIImage imageNamed:@"player_Near.png"] forState:UIControlStateNormal];
    [camFarButton setImage:[UIImage imageNamed:@"player_Far.png"] forState:UIControlStateNormal];
    
    //lily
 
}

- (void) addGesture
{
    // 手势：单击
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullVideoViewSingleTap:)];
    //点击的次数
    singleTapRecognizer.numberOfTapsRequired = 1; // 单击
    [FullVideoView addGestureRecognizer:singleTapRecognizer];
    //[singleTapRecognizer release];
    
    //手势捏合
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [VideoView addGestureRecognizer:pinchGesture];
    //[pinchGesture release];
    
    //手势：上下左右
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [VideoView addGestureRecognizer:panRecognizer];
    //[panRecognizer release];
    
}
//////////////////////
- (void) handlePinch:(UIPinchGestureRecognizer *) recognizer
{
    if(!playFlag)
        return;
    
    if(UIGestureRecognizerStateBegan == recognizer.state)
    {
        CGFloat scale = [recognizer scale];
        if(scale < 1.0)
        {
            controlCmd = PTZ_ZOOM_OUT;
            controlStatus = CTRL_STATUS_CTRL_CAM;
            //NSLog(@"缩小 ！！！！");
        }
        else
        {
            controlCmd = PTZ_ZOOM_IN;
            controlStatus = CTRL_STATUS_CTRL_CAM;
            //NSLog(@"放大 ！！！！");
        }
    }
    else if(UIGestureRecognizerStateEnded == recognizer.state)
    {
        controlStatus = CTRL_STATUS_STOP;
        controlCmd = 0;
        //NSLog(@"停止 ！！！！");
    }
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if(!playFlag)
        return;
    
    CGPoint translation = [recognizer translationInView:VideoView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        direction = kCameraMoveDirectionNone;
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged && direction == kCameraMoveDirectionNone)
    {
        direction = [self determineCameraDirectionIfNeeded:translation];
        
        // ok, now initiate movement in the direction indicated by the user's gesture
        
        switch (direction) {
            case kCameraMoveDirectionDown:
                //NSLog(@"Start moving down");
                controlCmd = PTZ_TURN_DOWN;
                controlStatus = CTRL_STATUS_CTRL_PAN;
                break;
                
            case kCameraMoveDirectionUp:
                //NSLog(@"Start moving up");
                controlCmd = PTZ_TURN_UP;
                controlStatus = CTRL_STATUS_CTRL_PAN;
                break;
                
            case kCameraMoveDirectionRight:
                //NSLog(@"Start moving right");
                controlCmd = PTZ_TURN_RIGHT;
                controlStatus = CTRL_STATUS_CTRL_PAN;
                break;
                
            case kCameraMoveDirectionLeft:
                //NSLog(@"Start moving left");
                controlCmd = PTZ_TURN_LEFT;
                controlStatus = CTRL_STATUS_CTRL_PAN;
                break;
                
            default:
                break;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // now tell the camera to stop
        //NSLog(@"Stop");
        [self setPTZStop];
    }
    
}

// This method will determine whether the direction of the user's swipe

- (CameraMoveDirection)determineCameraDirectionIfNeeded:(CGPoint)translation
{
    if (direction != kCameraMoveDirectionNone)
        return direction;
    
    // determine if horizontal swipe only if you meet some minimum velocity
    
    if (fabs(translation.x) > gestureMinimumTranslation)
    {
        BOOL gestureHorizontal = NO;
        
        if (translation.y == 0.0)
            gestureHorizontal = YES;
        else
            gestureHorizontal = (fabs(translation.x / translation.y) > 5.0);
        
        if (gestureHorizontal)
        {
            if (translation.x > 0.0)
                return kCameraMoveDirectionRight;
            else
                return kCameraMoveDirectionLeft;
        }
    }
    // determine if vertical swipe only if you meet some minimum velocity
    
    else if (fabs(translation.y) > gestureMinimumTranslation)
    {
        BOOL gestureVertical = NO;
        
        if (translation.x == 0.0)
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 5.0);
        
        if (gestureVertical)
        {
            if (translation.y > 0.0)
                return kCameraMoveDirectionDown;
            else
                return kCameraMoveDirectionUp;
        }
    }
    
    return direction;
}


//////////////////////
- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;  
}

- (IBAction)returnClicked:(id)sender
{
    if(indexOfPlayer)
    {
        NSLog(@"stop decoder index：%d",indexOfPlayer);
        [sHCodec decoderStopIndex:indexOfPlayer];
        
    }
    //stopDecId = 3;设置后，异步去结束解码，clearFrame先执行，导致清屏没效果。
    //解决办法：在decoderCallBackIndex中SoftDecExit时，也去清一次屏。
    //清2次屏没影响。
    [glLayer clearFrame];
    [glfullLayer clearFrame];
    
    playButton.enabled = NO;
    captureButton.enabled = NO;
    fullScreenButton.enabled = NO;
    camCtrShowButton.enabled = NO;

    if(camCtrShowFlag)
    {
        [self camCtrShowButtonClicked:nil];
    }

    
    labelStatus.text = @"";
    
    //lily add
    UIViewController *myViewController = [self viewController];
    [myViewController dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (IBAction)playButtonClicked:(id)sender
{
    playFlag  = !playFlag;
    if(playFlag)
    {
        [sHCodec decoderRestartIndex:indexOfPlayer];
        [playButton setImage:[UIImage imageNamed:@"player_pause.png"] forState:UIControlStateNormal];
    }
    else
    {
        [sHCodec decoderPauseIndex:indexOfPlayer];
        [playButton setImage:[UIImage imageNamed:@"player_play.png"] forState:UIControlStateNormal];
    }
}

/*  typedef enum {
 ALAuthorizationStatusNotDetermined = 0, // 用户尚未做出选择这个应用程序的问候
 ALAuthorizationStatusRestricted,        // 此应用程序没有被授权访问的照片数据。可能是家长控制权限
 ALAuthorizationStatusDenied,            // 用户已经明确否认了这一照片数据的应用程序访问
 ALAuthorizationStatusAuthorized         // 用户已经授权应用访问照片数据} CLAuthorizationStatus;
 }*/
- (IBAction)captureButtonClicked:(id)sender
{
    //相册的权限值
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        //无权限
        NSLog(@"author type:%d",author);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"请设置此应用对相册的访问权限！"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        //[alert release];
        return;
    }
    
    //添加到相册我让它执行是异步执行的方式，如果不想用这种方式，可以不去开一个线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       
                       UIImage *image = [sHCodec decoderCaptureIndex:indexOfPlayer];
                       //UIImage *image = [UIImage imageNamed:@"bg_2x.png"];
                       if(image != nil)
                       {
                           NSLog(@"capture a photo");
                           //UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
                           //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                           UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                       }
                       
                   });
    
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL)
    {
        msg = @"保存图片失败" ;
    }
    else
    {
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil,nil]; //autorelease];
    [alert show];
    //[alert release];
    //[msg release];
}

- (IBAction)fullScreenButtonClicked:(id)sender
{
    videoFullFlag = !videoFullFlag;
    if(videoFullFlag)
    {
        //竖屏点击按钮 旋转到横屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    }
    else
    {
        //横屏点击按钮, 旋转到竖屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    
}

- (void)fullVideoViewSingleTap:(UITapGestureRecognizer *)recognizer
{
    //横屏点击按钮, 旋转到竖屏
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
}

-(BOOL)setFullScreen
{
    if(fullScreenButton.enabled == YES)
    {
        videoFullFlag = YES;
        FullVideoView.hidden = NO;
        [glLayer clearFrame];
        return  YES;
    }
    else
        return NO;
    
}

-(void)setNarrowScreen
{
    videoFullFlag = NO;
    FullVideoView.hidden = YES;
    [glfullLayer clearFrame];
}

- (IBAction)camCtrShowButtonClicked:(id)sender
{
    camCtrShowFlag = !camCtrShowFlag;
    if(camCtrShowFlag)
    {
        camCtrView.hidden = NO;
        [camCtrShowButton setImage:[UIImage imageNamed:@"player_openPTZDis.png"] forState:UIControlStateNormal];
    }
    else
    {
        camCtrView.hidden = YES;
        [camCtrShowButton setImage:[UIImage imageNamed:@"player_openPTZ.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)camCtrLeftButtonDown:(id)sender
{
    NSLog(@"----camCtrLeftButtonDown----");
    controlCmd = PTZ_TURN_LEFT;
    controlStatus = CTRL_STATUS_CTRL_PAN;
}

- (IBAction)camCtrRightButtonDown:(id)sender
{
    controlCmd = PTZ_TURN_RIGHT;
    controlStatus = CTRL_STATUS_CTRL_PAN;
}

- (IBAction)camCtrUpButtonDown:(id)sender
{
    controlCmd = PTZ_TURN_UP;
    controlStatus = CTRL_STATUS_CTRL_PAN;
}

- (IBAction)camCtrDownButtonDown:(id)sender
{
    controlCmd = PTZ_TURN_DOWN;
    controlStatus = CTRL_STATUS_CTRL_PAN;
}

- (IBAction)camCtrZoomInButtonDown:(id)sender
{
    controlCmd = PTZ_ZOOM_IN;
    controlStatus = CTRL_STATUS_CTRL_CAM;
}

- (IBAction)camCtrZoomOutButtonDown:(id)sender
{
    controlCmd = PTZ_ZOOM_OUT;
    controlStatus = CTRL_STATUS_CTRL_CAM;
}

- (IBAction)camCtrNearButtonDown:(id)sender
{
    controlCmd = PTZ_FOCUS_NEAR;
    controlStatus = CTRL_STATUS_CTRL_CAM;
}

- (IBAction)camCtrFarButtonDown:(id)sender
{
    controlCmd = PTZ_FOCUS_FAR;
    controlStatus = CTRL_STATUS_CTRL_CAM;
}

- (IBAction)camCtrStopButtonUp:(id)sender;
{
    controlStatus = CTRL_STATUS_STOP;
    controlCmd = 0;
}

- (void) setPTZStop
{
    controlStatus = CTRL_STATUS_STOP;
    controlCmd = 0;
}

/////////////////
/*
-(void)initFilePath:(NSString *)fPath fileName:(NSString *)fName
{
    inputURLString = fPath;
    if(fName)
    {
        NSString *video_dis = [NSString stringWithFormat:NSLocalizedString(@"视频", nil)];
        labelCameraName.text = [NSString stringWithFormat:@"%@：%@",video_dis,fName];
    }
    else
        labelCameraName.text = @"";
    
    indexOfPlayer = [sHCodec decoderStartURL:inputURLString SoftOrHard:YES UdpOrTcp:NO];
    if(indexOfPlayer<=0)
    {
        //NSLog(@"has no more decoder to use.");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有解码器可用，或者硬解码功能尚未完成！" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        [self performSelector:@selector(dimissAlert:) withObject:alert afterDelay:2.5];
        //[alert release];
        return;
    }
    
    NSLog(@"[vc44] initFilePath() [ok]\n");
    
    //this camera cann't be controled, hide the button
    char *cTmp = (char *)( [inputURLString cStringUsingEncoding:1]);
    //if( serverInfo.nPtzPort <0 || serverInfo.nPtzPort > 65535)
    {
        NSLog(@"------serverInfo.nPtzPort=%d " , serverInfo.nPtzPort);
        ctlThdAlive = YES;
        pthread_create(&pThread_ctrl, NULL, pControl_Thread, NULL);
    }
    //else
    //{
    //    NSLog(@"**cann't control\n");
    //}
    
    return;
}
*/

//-(void)initFilePath:(NSString *)fPath fileName:(NSString *)fName
-(void)initFilePath:(RtspServerInfo)servInfo
{
    
    //lily add
    printf("-----lily--------chPtzIP: %s\n", servInfo.chPtzIP);
    printf("-----lily--------serverPort: %d\n", servInfo.serverPort);
    printf("-----lily--------port: %d\n", servInfo.nPtzPort);
    
    printf("-----lily--------protocolType: %s\n", servInfo.protocolType);
    printf("-----lily--------coderID: %s\n", servInfo.coderID);
    printf("-----lily--------channelNum: %d\n", servInfo.channelNum);
    printf("-----lily--------streamNum: %d\n", servInfo.streamNum);

    printf("-----lily--------cloudTEnable: %d\n", servInfo.cloudTEnable);
    
    printf("-----lily--------id: %s\n", servInfo.chRtspSession);
    printf("-----lily--------tiltStep: %d\n", servInfo.tiltStep);
    
    memset(&serverInfo ,0x00 ,sizeof(serverInfo) );
    strcpy(serverInfo.chPtzIP, servInfo.chPtzIP);
    serverInfo.nPtzPort = servInfo.nPtzPort;
    strcpy(serverInfo.chRtspSession, servInfo.chRtspSession);
    strcpy(serverInfo.coderID, servInfo.coderID);
    serverInfo.tiltStep = servInfo.tiltStep;
 
    
    inputURLString = [ModelLocator sharedInstance].urlstr;
  
    NSLog(@"-----lily--------inputURLString: %@\n", inputURLString);
    labelCameraName.text = @"";
    
    indexOfPlayer = [sHCodec decoderStartURL:inputURLString SoftOrHard:YES UdpOrTcp:NO];
    if(indexOfPlayer<=0)
    {
        //NSLog(@"has no more decoder to use.");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有解码器可用，或者硬解码功能尚未完成！" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        [self performSelector:@selector(dimissAlert:) withObject:alert afterDelay:2.5];
        //[alert release];
        return;
    }
    
    NSLog(@"[vc44] initFilePath() [ok]\n");
    
    //this camera cann't be controled, hide the button
    char *cTmp = (char *)( [inputURLString cStringUsingEncoding:1]);
    //if( serverInfo.nPtzPort <0 || serverInfo.nPtzPort > 65535)
    if(servInfo.cloudTEnable)
    {
        NSLog(@"------serverInfo.nPtzPort=%d " , serverInfo.nPtzPort);
        ctlThdAlive = YES;
        pthread_create(&pThread_ctrl, NULL, pControl_Thread, NULL);
        camCtrShowButton.hidden = NO;
    }
    else
    {
        NSLog(@"**cann't control\n");
        camCtrShowButton.hidden = YES;
    }
    
    return;
}

-(void)aVFrameToYUV420pToDisplay:(AVPic *)pict LayerIndex:(int)index
{
    char *YUVbuf = (char *)malloc(pict->width * pict->height * 3 / 2);
    
    //AVPicture *pict;
    int w, h, i;
    char *y, *u, *v;
    //pict = (AVPicture *)pAVFrame;
    w = pict->width;
    h = pict->height;
    y = YUVbuf;
    u = y + w * h;
    v = u + w * h / 4;
    
    for (i=0; i<h; i++)
        memcpy(y + w * i, pict->data[0] + pict->linesize[0] * i, w);
    for (i=0; i<h/2; i++)
        memcpy(u + w / 2 * i, pict->data[1] + pict->linesize[1] * i, w / 2);
    for (i=0; i<h/2; i++)
        memcpy(v + w / 2 * i, pict->data[2] + pict->linesize[2] * i, w / 2);
    
    //NSLog(@"width= %d ;height= %d\n", w, h);
    
    //rend yuv
    if(index == indexOfPlayer)
    {
        if(videoFullFlag)
            [glfullLayer displayYUV420pData:YUVbuf width:w height:h];
        else
            [glLayer displayYUV420pData:YUVbuf width:w height:h];
        
    }
    
    
    free(YUVbuf);
}

- (void) dimissAlert:(UIAlertView *)alert
{
    if(alert)
    {
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
    }
}

//implement SoftHardCodecDelegate
-(void)decoderSetDisplayLayerIndex:(int)index Width:(int)width Height:(int)height
{
    if(index == indexOfPlayer)
    {
        
        //////////
        if(glLayer!= NULL && glfullLayer!= NULL)
        {
            //NSLog(@"-----清空");
            [glLayer removeFromSuperlayer];
            [glfullLayer removeFromSuperlayer];
            //[glLayer release];
            //[glfullLayer release];
        }
        //else
        //NSLog(@"-----不用清空");
        
        
        // init OpenGLLayer20 class object
        CGFloat bkWidth = VideoView.bounds.size.width;
        CGFloat bkHeight = VideoView.bounds.size.height;
        CGFloat w;
        CGFloat h;
        if((CGFloat)width/height >= bkWidth/bkHeight)
        {
            w = bkWidth;
            h = w * height/width;
        }
        else
        {
            h = bkHeight;
            w = h * width/height;
        }
        //NSLog(@"VideoView frame width:%f ; height:%f",bkWidth,bkHeight);
        glLayer = [[OpenGLLayer20 alloc] initWithFrame:CGRectMake((bkWidth-w)/2, (bkHeight-h)/2, w, h)];
        NSLog(@"set video display1 width:%f ; height:%f",w,h);
        [VideoView.layer addSublayer:glLayer];
        
        
        // init OpenGLLayer20 class object
        //CGFloat bkFullWidth = FullVideoView.bounds.size.width;
        //CGFloat bkFullHeight = FullVideoView.bounds.size.height;
        CGFloat bkFullWidth = FullVideoView.bounds.size.height;
        CGFloat bkFullHeight = FullVideoView.bounds.size.width;
        if((CGFloat)width/height >= bkFullWidth/bkFullHeight)
        {
            w = bkFullWidth;
            h = w * height/width;
        }
        else
        {
            h = bkFullHeight;
            w = h * width/height;
        }
        //NSLog(@"FullVideoView frame width:%f ; height:%f",bkFullWidth,bkFullHeight);//320*568
        glfullLayer = [[OpenGLLayer20 alloc] initWithFrame:CGRectMake((bkFullWidth-w)/2, (bkFullHeight-h)/2, w, h)];
        //NSLog(@"set FullVideoView display1 width:%f ; height:%f",w,h);
        [FullVideoView.layer addSublayer:glfullLayer];
    }
    
}

-(void)decoderShowDisplayLayerIndex:(int)index AVFrame:(AVPic *)pAVFrame
{
    if(index == indexOfPlayer)
    {
        //渲染yuv
        [self aVFrameToYUV420pToDisplay:pAVFrame LayerIndex:index];
    }
    
}

-(void)decoderCallBackIndex:(int)index StatusCode:(int)statusCode
{
    NSString *statusString;
    
    switch (statusCode)
    {
            
        case SoftDecNetworkConnecting://网络连接中，显示“正在连接网络“
            statusString = [NSString stringWithFormat:NSLocalizedString(@"正在连接网络...", nil)];
            break;
        case SoftDecNetworkConnectFaild://“已经断开网络连接，请返回上一页”
            //Network Disconnection
            //statusString = @"Network Disconnection";
            statusString = [NSString stringWithFormat:NSLocalizedString(@"已经断开网络连接,请返回上一页", nil)];
            break;
        case SoftDecUsenameOrPasswordFaild:
            //usename or password error
            //statusString = @"usename or password error";
            //break;
        case SoftDecOpenInputFailed:
            //open input failed
            //statusString = @"open input failed";
            //NSLog(@"open input failed");
            //break;
        case SoftDecGetInputStreamInfoFailed:
            //Get Input Stream Info error
            //statusString = @"Get Input Stream Info error";
            //break;
        case SoftDecHasNoVideoStream://以上4项，都提示：“获取视频失败，请返回上一页”
            //Stream Has No Video
            //statusString = @"Stream Has No Video";
            //NSLog(@"提示：获取视频失败，请返回上一页");
            statusString = [NSString stringWithFormat:NSLocalizedString(@"获取视频失败，请返回上一页", nil)];
            break;
        case SoftDecDataWaiting://等待数据，显示“正在等待数据“
            statusString = [NSString stringWithFormat:NSLocalizedString(@"正在等待数据...", nil)];
            break;
        case SoftDecOpenInputSuccessful://打开rtsp成功，显示“正在播放“
            //open input succefull
            //statusString = @"open input successful";
            statusString = [NSString stringWithFormat:NSLocalizedString(@"正在播放", nil)];
            //NSLog(@"open input successful");
            break;
            
            
        case SoftDecCodecNotFound:
            //Codec not found
            //statusString = @"Codec not found";
            //break;
        case SoftDecCodecCannotOpen:
            //Could not open video codec!
            //statusString = @"Could not open video codec!";
            //break;
        case SoftDecAllocPFrameFailed://以上3项，都提示：“系统资源不足，请稍后再试”
            //alloc pFrame failed!
            //statusString = @"alloc pFrame failed!";
            statusString = [NSString stringWithFormat:NSLocalizedString(@"系统资源不足，请稍后再试", nil)];
            break;
            
        case SoftDecPause://暂停，提示“已暂停，请按播放键重新播放”。
            statusString = [NSString stringWithFormat:NSLocalizedString(@"已暂停，请按播放键重新播放", nil)];
            break;
            
        case SoftDecExit://按键退出，提示清空。
            //Normal exit by　stop button
            //statusString = @"Normal exit by stop button";
            statusString = @"";
            break;
        case SoftDecInitTimeOut:
            //init decoder timeout
            //statusString = @"init decoder timeout";
            //break;
        case SoftDecrDecTimeOut://以上2项，都提示：”接收数据超时，请返回上一页“
            //decode timeout
            //statusString = @"decode timeout";
            statusString = [NSString stringWithFormat:NSLocalizedString(@"接收数据超时，请返回上一页", nil)];
            break;
            
        default:
            //exit unknown
            statusString = @"exit unknown";
            break;
    }
    
    if(index == indexOfPlayer)
    {
        labelStatus.text = statusString;
        NSLog(@"set  labelStatus");
        
        if(statusCode%2 == 1)//解码器不正常退出时
        {
            playFlag = NO;
            //需要设置为0，retrun时不重复释放资源，否则decoderStopIndex传入无效的index，stopDec崩溃
            indexOfPlayer = 0;
            [playButton setImage:[UIImage imageNamed:@"player_play.png"] forState:UIControlStateNormal];
            
            playButton.enabled = NO;
            captureButton.enabled = NO;
            fullScreenButton.enabled = NO;
            camCtrShowButton.enabled = NO;

            if(camCtrShowFlag)
            {
                [self camCtrShowButtonClicked:nil];
            }
            ctlThdAlive = NO;
        }
        
        if(statusCode == SoftDecOpenInputSuccessful)
        {
            playFlag = YES;
            [playButton setImage:[UIImage imageNamed:@"player_pause.png"] forState:UIControlStateNormal];
            
            playButton.enabled = YES;
            captureButton.enabled = YES;
            fullScreenButton.enabled = YES;
            camCtrShowButton.enabled = YES;
        }
        
        if(statusCode == SoftDecPause)
        {
            playButton.enabled = YES;
            
            captureButton.enabled = NO;
            fullScreenButton.enabled = NO;
            camCtrShowButton.enabled = NO;

            if(camCtrShowFlag)
            {
                [self camCtrShowButtonClicked:nil];
            }
            //ctlThdAlive = NO;
        }
        
        if(statusCode == SoftDecExit)
        {
            [glLayer clearFrame];
            [glfullLayer clearFrame];
            ctlThdAlive = NO;
            
        }
        
    }
    
}

-(void)decoderCallBackIndex:(int)index GetPhoto:(UIImage *)imagePhoto
{
    if(index == indexOfPlayer)
    {
        NSLog(@"get the first photo from decoder index:%d",index);
        
        //you have got the first photo:imagePhoto,you can do what you want to do.
        [self.delegate myViewCallBackGetPhoto:imagePhoto];
    }
}



@end
