//
//  SoftDecoder.h
//  ffmpegTestNew
//
//  Created by liucairong on 15/9/7.
//  Copyright (c) 2015年 liucairong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "avformat.h"
#import "avio.h"
#import "avcodec.h"
#import "swscale.h"
#import "avutil.h"
#import "mathematics.h"
#import "swresample.h"
#import "opt.h"
#import "channel_layout.h"
#import "samplefmt.h"
#import "avdevice.h"  //摄像头所用
#import "avfilter.h"
#import "error.h"
#import "mathematics.h"
#import "time.h"
#import "inttypes.h"
#import "stdint.h"
#import "SoftHardCodec.h"

typedef unsigned long long UINT64;

@class SoftDecoder;


@protocol SoftDecDelegate <NSObject>
-(void)softDecoder:(SoftDecoder *)pSoftDec SetDisplaySize:(int)width Height:(int)height;
-(void)softDecoder:(SoftDecoder *)pSoftDec SetDisplayAVFrame:(AVFrame *)pAVFrame;
-(void)softDecCallBackIndex:(SoftDecoder *)pSoftDec StatusCode:(int)statusCode;
-(void)softDecCallBackIndex:(SoftDecoder *)pSoftDec GetPhoto:(UIImage *)imagePhoto;
@end


@interface SoftDecoder : NSObject

@property id<SoftDecDelegate> delegate;

-(BOOL)openInputURL:(NSString *)URLString UdpOrTcp:(BOOL)isUdp Restart:(BOOL)isRestart;
-(void)startDecRestart:(BOOL)isRestart;
-(void)stopDec;
-(void)pauseDec;
-(void)restartDec;
-(UIImage *)capturePhoto;

-(void)setIndex:(int)index;
-(int)getIndex;

@end
