//
//  OpenGLLayer20.h
//  ffmpegTestNew
//
//  Created by liucairong on 15/8/30.
//  Copyright (c) 2015 year liucairong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#include <sys/time.h>


@interface OpenGLLayer20 : CAEAGLLayer
#pragma mark - interface

/**
 init OpenGLES 2.0 layer
 **/
- (id)initWithFrame:(CGRect)frame;


/**
 display YUV：
 data：YUV420p data
 w：the pixel width of image
 h：the pixel height of image
 */
- (void)displayYUV420pData:(void *)data width:(NSInteger)w height:(NSInteger)h;


/**
 clear screen
 */
- (void)clearFrame;


#pragma mark - demo

/**
// init OpenGLLayer20 class object
 
 OpenGLLayer20 *glLayer;
 glLayer = [[OpenGLLayer20 alloc] initWithFrame:VideoView.bounds];
 [VideoView.layer addSublayer:glLayer];
 
 **/

/**
 //clear yuv display
 
 [glLayer clearFrame];
 
 **/

/**
 //display AVFrame from ffmpeg decoder
 
 -(void)aVFrameToYUV420pToDisplay:(AVFrame *)pAVFrame
 {
     char *YUVbuf = (char *)malloc(pAVFrame->width * pAVFrame->height * 3 / 2);
     
     AVPicture *pict;
     int w, h, i;
     char *y, *u, *v;
     pict = (AVPicture *)pAVFrame;
     w = pAVFrame->width;
     h = pAVFrame->height;
     y = YUVbuf;
     u = y + w * h;
     v = u + w * h / 4;
     
     for (i=0; i<h; i++)
     memcpy(y + w * i, pict->data[0] + pict->linesize[0] * i, w);
     for (i=0; i<h/2; i++)
     memcpy(u + w / 2 * i, pict->data[1] + pict->linesize[1] * i, w / 2);
     for (i=0; i<h/2; i++)
     memcpy(v + w / 2 * i, pict->data[2] + pict->linesize[2] * i, w / 2);
     
     //rend yuv
     [glLayer displayYUV420pData:YUVbuf width:w height:h];
     
     free(YUVbuf);
 
 }
 
 **/

/**
 //display CVPixelBufferRef from ios hard decoder
 
 -(void)pixelBufferToYUV420pToDisplay:(CVPixelBufferRef *)pCVpixelBuffer
 {
 CVPixelBufferRef pixelBuffer= *pCVpixelBuffer;
 
 CVPixelBufferLockBaseAddress(pixelBuffer,0);
 size_t width = CVPixelBufferGetWidth(pixelBuffer);
 size_t height = CVPixelBufferGetHeight(pixelBuffer);
 //printf("width = %d ; height = %d ;\n",width,height);
 
 //uint8_t *baseAddress2 = (uint8_t*)CVPixelBufferGetBaseAddress(pixelBuffer);
 
 uint8_t *yBuffer = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
 uint8_t *cbCrBuffer = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
 
 CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
 
 NSInteger yPitch = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
 NSInteger cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
 
 char *YUVbuf = (char *)malloc(width * height * 3 / 2);
 {
 
 int w, h, i, j;
 char *y, *u, *v;
 w = (int)width;
 h = (int)height;
 y = YUVbuf;
 u = y + w * h;
 v = u + w * h / 4;
 
 
 for (i=0; i<h; i++)
 memcpy(y + w * i, yBuffer + yPitch * i, w);
 
 for(i=0; i<h/2; i++)
 {
 for(j=0;j<w/2;j++)
 {
 memcpy(u + w / 2 * i + j, cbCrBuffer + cbCrPitch * i + j*2, 1);
 memcpy(v + w / 2 * i + j, cbCrBuffer + cbCrPitch * i + j*2+1, 1);
 }
 }
 }
 
 //rend yuv
 [glLayer displayYUV420pData:YUVbuf width:width height:height];
 free(YUVbuf);
 }
 
 **/


@end
