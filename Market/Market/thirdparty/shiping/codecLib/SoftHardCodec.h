//
//  SoftHardCodec.h
//  ffmpegTestNew
//
//  Created by liucairong on 15/9/7.
//  Copyright (c) 2015年 liucairong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

/**
 * Picture data structure.
 *
 * Up to four components can be stored into it, the last component is
 * alpha.
 */
typedef struct AVPic
{
    unsigned char *data[8];    ///< pointers to the image data planes
    int linesize[8];     ///< number of bytes per line
    uint8_t **extended_data;  // do not care about it
    int width, height;
    
} AVPic;


/**
the status code of soft decoder
 
 */
typedef enum {
    //soft decoder init error response
    SoftDecNetworkConnecting           = 0,         //Network Connecting
    SoftDecNetworkConnectFaild         = 1,         //Network Disconnection
    SoftDecUsenameOrPasswordFaild      = 3,         //usename or password error
    SoftDecOpenInputFailed             = 5,         //open input failed
    SoftDecGetInputStreamInfoFailed    = 7,         //Get Input Stream Info error
    SoftDecHasNoVideoStream            = 9,         //Stream Has No Video
    SoftDecDataWaiting                 = 10,         //frame reading
    SoftDecOpenInputSuccessful         = 20,         //open input successful
    
    SoftDecCodecNotFound               = 11,         //Codec not found
    SoftDecCodecCannotOpen             = 13,         //Could not open video codec!
    SoftDecAllocPFrameFailed           = 15,         //alloc pFrame failed!
    
    SoftDecPause                       = 30,         //Codec pause
    
    //soft decoder exit
    SoftDecExit                        = 100,        //Normal exit by　stop button
    SoftDecInitTimeOut                 = 103,        //init decoder timeout
    SoftDecrDecTimeOut                 = 105,        //decode timeout
    
} ErrorSoftDec;


@protocol SoftHardCodecDelegate <NSObject>
//set the size of displayLayer which has the decoder of index
-(void)decoderSetDisplayLayerIndex:(int)index Width:(int)width Height:(int)height;

//display the yuv data of pAVFrame on the displayLayer which has the decoder of index
-(void)decoderShowDisplayLayerIndex:(int)index AVFrame:(AVPic *)pAVFrame;

//it will be called by decoder of index when there is a status response
-(void)decoderCallBackIndex:(int)index StatusCode:(int)statusCode;

//it will be called by decoder of index when take it's first photo
-(void)decoderCallBackIndex:(int)index GetPhoto:(UIImage *)imagePhoto;

//other functions of decoder will be added later
//-(void)decoderGetFrameRate:(int)frameRate StreamRate:(CGFloat)streamRate Resolution:(CGSize)resolution;

//encoder function will be added later
@end

@interface SoftHardCodec : NSObject


@property id<SoftHardCodecDelegate> delegate;

#pragma mark - decoder interface
/**
 * call this function to start a decoder, it will return the index of decoder's.
 * soft decoders's indexs:1、2、3、4
 * hard decoders's indexs:5、6、7、8
 *
 * @param URLString      url of h264 rtsp stream
 * @param isSoft         YES is soft decoder ; NO is hard decoder;
 * @param isUdp          YES is  udp ; NO is Tcp
 *
 * @return index of decoder:1~8 if decoder was created successful, <=0 if failed.
 *        
 */
-(int)decoderStartURL:(NSString *)URLString SoftOrHard:(BOOL)isSoft UdpOrTcp:(BOOL)isUdp;

/**
 * call this function to stop decoder.
 *
 * @param index          the decoder on this index will be stopped .
 *
 * @return  none
 *
 */
-(void)decoderStopIndex:(int)index;

/**
 * call this function to pause decoder.
 *
 * @param index          the decoder on this index will be paused .
 *
 * @return  none
 *
 */
-(void)decoderPauseIndex:(int)index;

/**
 * call this function to reStart decoder.
 *
 * @param index          the decoder on this index will be restarted.
 *
 * @return  none
 *
 */
-(void)decoderRestartIndex:(int)index;


/**
 * call this function to capture a photo by decoder of index.
 *
 * @param index          the decoder on this index will capture a photo.
 *
 * @return  a uiimage
 *
 */
-(UIImage *)decoderCaptureIndex:(int)index;


//the function of below will be added later
/**
 * capture a picture
 */

/**
 * record a video
 */

/**
 * palyback a video recorded; pause ,play
 */


/**
 * decode audio of aac
 */


#pragma mark - encoder interface
//encoder function will be added later

@end
