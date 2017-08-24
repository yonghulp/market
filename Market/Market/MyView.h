//
//  MyView.h
//  codecControllerTest
//
//  Created by liucairong on 15/10/9.
//  Copyright (c) 2015年 znv. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef struct
{
    char chPtzIP[16];          //server ip    服务器ip
    int  serverPort;           //server port  服务器端口
    int nPtzPort;              //rtsp port    云台端口
    
    char protocolType[16];       //rtsp or http 目前库只支持rtsp
    char coderID[32];            // coder id  编码器id
    int channelNum;              // channel number  通道号
    int streamNum;               // stream number 第几路码流
    
    BOOL cloudTEnable;           //Cloud Terrace enable or disable 云台是否可控。
    
    char chRtspSession[32];      //rtsp session  云台会话id（内部固定）
    short tiltStep;              //pan-fit speed  云台转速（内部固定）
} RtspServerInfo;

@protocol MyViewDelegate <NSObject>
//it will be called when myView take it's first photo
-(void)myViewCallBackGetPhoto:(UIImage *)imagePhoto;
@end


@interface MyView : UIView

- (void)initMyView;
//-(void)initFilePath:(NSString *)fPath fileName:(NSString *)fName;
-(void)initFilePath:(RtspServerInfo)servInfo;

-(BOOL)setFullScreen;
-(void)setNarrowScreen;

@property id<MyViewDelegate> delegate;
@end
