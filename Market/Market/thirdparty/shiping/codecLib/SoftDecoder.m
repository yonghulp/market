//
//  SoftDecoder.m
//  ffmpegTestNew
//
//  Created by liucairong on 15/9/7.
//  Copyright (c) 2015年 liucairong. All rights reserved.
//

#import "SoftDecoder.h"
#import <CoreImage/CoreImageDefines.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <CoreVideo/CVPixelBufferPool.h>

#define lily_debug 0

typedef struct OutTime
{
    BOOL firstFrameDecFlag;
    int stopDecId;//0:not stop; 1:stop for Init TimeOut; 2:stop for Dec TimeOut; 3:stop for button
    UINT64 prevTime_ms_forTimeOut;
    UINT64 interval_init_ms;
    UINT64 interval_dec_ms;
}OutTime;


#define TimeoutInit_ms 30000
#define TimeoutDec_ms 5000

static int interruptCallBack(void *ctx)
{
    OutTime *outTime = (OutTime *)ctx;
    
    // do something
    if(outTime->firstFrameDecFlag == NO)
    {
        NSTimeInterval tmpTime = [[NSDate date] timeIntervalSince1970];
        //NSLog(@"当前 tmpTime=%f",tmpTime);
        outTime->interval_init_ms = tmpTime*1000 - outTime->prevTime_ms_forTimeOut;
        //NSLog(@"outTime->interval_init_ms=%lld",outTime->interval_init_ms);
        if(outTime->interval_init_ms >= TimeoutInit_ms)
        {
            outTime->stopDecId = 1;
            NSLog(@"int time out !!!");
        }
    }
    else
    {
        NSTimeInterval tmpTime = [[NSDate date] timeIntervalSince1970];
        //NSLog(@"当前 tmpTime=%f",tmpTime);
        outTime->interval_dec_ms = tmpTime*1000 - outTime->prevTime_ms_forTimeOut;
        //NSLog(@"outTime->interval_dec_ms=%lld",outTime->interval_dec_ms);
        if(outTime->interval_dec_ms > TimeoutDec_ms)
        {
            outTime->stopDecId = 2;
            NSLog(@"decoder time out !!!");
        }
    }
    
    //once your preferred time is out you can return 1 and exit from the loop
    if(outTime->stopDecId != 0 )  //timeOutFlag 要保持一段时间，以保证回调一段时间都返回1
    {
        //exit
        return 1;  //如果只有一次返回1，接着又返回0,不能保证 av_read_frame 返回失败。
    }
    
    //continue
    return 0;
    
}

@interface SoftDecoder()
{
    AVFormatContext *pFormatCtx;
    int videoStreamIndex;
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVPicture picture; //拍照
    
    OutTime *outTime;
    int _index;
    NSString *_URLString;
    BOOL _isUdp;
    BOOL pauseFlag;
    
    //lily debug
    UINT64 prevTime_ms;
    UINT64 interval_display_ms;
    UINT64 interval_receive_ms;
    
}
@end


@implementation SoftDecoder

- (id)init
{
    self = [super init];
    if (self)
    {
        _index = 0;
        _URLString = NULL;
        _isUdp = YES;
        pauseFlag = NO;
        
        
        //lily debug
        prevTime_ms = 0;
        interval_display_ms = 0;
        interval_receive_ms = 0;
    }
    return self;
}

-(BOOL)openInputURL:(NSString *)URLString UdpOrTcp:(BOOL)isUdp Restart:(BOOL)isRestart
{
    int ret, i;
    videoStreamIndex=-1;
    _URLString = URLString;
    _isUdp = isUdp;

    //注册回调函数
    pFormatCtx = avformat_alloc_context();
    //Initialize intrrupt callback
    if(outTime  == NULL)
    {
        outTime = (OutTime *)malloc(sizeof(OutTime));
        //NSLog(@" outTime malloc");
    }
    memset(outTime, 0, sizeof(OutTime));
    
    pFormatCtx->interrupt_callback.callback = interruptCallBack;
    pFormatCtx->interrupt_callback.opaque = outTime;
    
    NSTimeInterval tmpTime = [[NSDate date] timeIntervalSince1970];
    //NSLog(@"当前 tmpTime=%f",tmpTime);
    outTime->prevTime_ms_forTimeOut = (UINT64)(tmpTime*1000);
    
    
    //有三种传输方式：tcp udp_multicast udp，强制采用tcp传输
    AVDictionary* options = NULL;
    if(isUdp)
        av_dict_set(&options, "rtsp_transport", "udp", 0);
    else
        av_dict_set(&options, "rtsp_transport", "tcp", 0);
    //---------
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate softDecCallBackIndex:self StatusCode:SoftDecNetworkConnecting];
    });
    
    // 打开视频文件
    if ((ret = avformat_open_input(&pFormatCtx, [URLString UTF8String], 0, &options)) < 0)
        //if ((ret = avformat_open_input(&pFormatCtx, URLString, 0, NULL)) < 0)
    {
        av_dict_free(&options);
        printf( "Could not open input file,error is:%d\n",ret);
        [self releaseAll];
        switch (ret)
        {
            case -51:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate softDecCallBackIndex:self StatusCode:SoftDecNetworkConnectFaild];
                });
                return NO;
            }
            case -825242872:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate softDecCallBackIndex:self StatusCode:SoftDecUsenameOrPasswordFaild];
                });
                return NO;
            }
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate softDecCallBackIndex:self StatusCode:SoftDecOpenInputFailed];
                });
                return NO;
            }
        }
        
    }
    
    av_dict_free(&options);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate softDecCallBackIndex:self StatusCode:SoftDecDataWaiting];
    });
    
    //取出包含在文件中的流信息：
    if ((ret = avformat_find_stream_info(pFormatCtx, 0)) < 0)
    {
        printf( "Failed to retrieve input stream information\n");
        [self releaseAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate softDecCallBackIndex:self StatusCode:SoftDecGetInputStreamInfoFailed];
        });
        return NO;
    }
    
    //输出视频信息
    //av_dump_format(pFormatCtx, 0, [URLString UTF8String], 0);
    //dump只是个调试函数，输出文件的音、视频流的基本信息了，帧率、分辨率、音频采样等等
    
    for(i=0; i<pFormatCtx->nb_streams; i++)        //区分视频流和音频流
        if(pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) //找到视频流，这里也可以换成音频
        {
            videoStreamIndex=i;
            break;
        }
    
    if(videoStreamIndex == -1)
    {
        printf("didn't find a video stream.\n");
        [self releaseAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate softDecCallBackIndex:self StatusCode:SoftDecHasNoVideoStream];
        });
        return NO;
    }
    
    // 得到视频流编码上下文的指针
    pCodecCtx = pFormatCtx->streams[videoStreamIndex]->codec;
    NSLog(@"first  width:%d ; height:%d",pCodecCtx->width,pCodecCtx->height);
    
    if(!isRestart)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            [self.delegate softDecoder:self SetDisplaySize:pCodecCtx->width Height:pCodecCtx->height];
        });
    }
    
    avpicture_alloc(&picture,PIX_FMT_RGB24, pCodecCtx->width, pCodecCtx->height);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate softDecCallBackIndex:self StatusCode:SoftDecOpenInputSuccessful];
    });
    return YES;
    
}


-(void)startDecRestart:(BOOL)isRestart
{
    //查找对应的解码器
    AVCodec *pCodec;
    
    int ret;
    
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec == NULL)
    {
        printf( "Codec not found! \n");
        [self releaseAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate softDecCallBackIndex:self StatusCode:SoftDecCodecNotFound];
        });
        return;
    }
    
    ret = avcodec_open2(pCodecCtx, pCodec, NULL);  // 打开解码器
    if (ret < 0)
    {
        printf( "Could not open video codec! \n");
        [self releaseAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate softDecCallBackIndex:self StatusCode:SoftDecCodecCannotOpen];
        });
        return;
    }
    
    /*pCodecCtx->time_base现在已经保存了帧率的信息。time_base是一 个结构体，它里面有一个分子和分母 (AVRational)。我们使用分数的方式来表示帧率是因为很多编解码器使用非整数的帧率（例如NTSC使用29.97fps）。*/
    
    //给视频帧分配空间以便存储解码后的图片：
    pFrame= av_frame_alloc();//avcodec_alloc_frame();
    if(pFrame==NULL)
    {
        printf( "alloc pFrame failed! \n");
        [self releaseAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate softDecCallBackIndex:self StatusCode:SoftDecAllocPFrameFailed];
        });
        return;
    }
    
    /////////////////////////////////////////开始解码///////////////////////////////////////////
    //读取数据
    //我们将要做的是通过读取包来读取整个视频流，然后把它解码成帧，最好后转换格式并且保存。
    int frameFinished;
    AVPacket packet;


    //----lily debug
#if lily_debug
    NSTimeInterval tmpTime = [[NSDate date] timeIntervalSince1970];
    //NSLog(@"当前 tmpTime=%f",tmpTime);
    prevTime_ms = (UINT64)(tmpTime*1000);
#endif
    //----lily debug

    //while(av_read_frame(pFormatCtx, &packet)>=0)
    while(1)
    {    //读数据
        // Is this a packet from the video stream?
        ret = av_read_frame(pFormatCtx, &packet);
        if (ret < 0)
        {
            int tmpDecId = outTime->stopDecId;

            av_free_packet(&packet);
            [self releaseAll];//初始化成功后，所有异常关闭都从这里退出
            switch (tmpDecId)
            {
                case 1://初始化超时
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate softDecCallBackIndex:self StatusCode:SoftDecInitTimeOut];
                    });
                    return;
                }
                case 2://解码超时
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate softDecCallBackIndex:self StatusCode:SoftDecrDecTimeOut];
                    });
                    return;
                }
                case 4://解码暂停
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate softDecCallBackIndex:self StatusCode:SoftDecPause];
                    });
                    return;
                }
                default://解码结束
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate softDecCallBackIndex:self StatusCode:SoftDecExit];
                    });
                    return;
                }
            }
        }
        
        if(packet.stream_index==videoStreamIndex) //判断是否视频流
        {
          
             //----lily debug
            #if lily_debug
             NSTimeInterval tmpTime = [[NSDate date] timeIntervalSince1970];
             //NSLog(@"当前 tmpTime=%f",tmpTime);
             interval_receive_ms = tmpTime*1000 - prevTime_ms;
             prevTime_ms = (UINT64)(tmpTime*1000);
             NSLog(@"***************interval_receive_ms = %lld",interval_receive_ms);
            #endif
             //----lily debug
          
            
            
            // Decode video frame
            avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
            
            // Did we get a video frame?
            if(frameFinished)//帧结束标志frameFinished
            {
                if(outTime->firstFrameDecFlag == NO)
                {
                    outTime->firstFrameDecFlag  = YES;
                    if(!isRestart)//第一次播放就采集图像；暂停后再播放不需要。
                    {
                        //capturePhoto
                        UIImage *imagePhoto = [self capturePhoto];
                        //回调处理照片：如果用UIImageview来刷新imagePhoto，只有在主线程中才有效。
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate softDecCallBackIndex:self GetPhoto:imagePhoto];
                        });
                    }
                }
                
                [self.delegate softDecoder:self SetDisplayAVFrame:pFrame];
                
                NSTimeInterval tmpTime = [[NSDate date] timeIntervalSince1970];
                //NSLog(@"当前 tmpTime=%f",tmpTime);
                outTime->prevTime_ms_forTimeOut = (UINT64)(tmpTime*1000);
                
                //----lily debug
            #if lily_debug
                //NSTimeInterval
                tmpTime = [[NSDate date] timeIntervalSince1970];
                //NSLog(@"当前 tmpTime=%f",tmpTime);
                interval_display_ms = tmpTime*1000 - prevTime_ms;
                
                prevTime_ms = (UINT64)(tmpTime*1000);
                
                NSLog(@"interval_display_ms = %lld",interval_display_ms);
            #endif
                //----lily debug
                
            }
            
        }
        
        // Free the packet that was allocated by av_read_frame
        av_free_packet(&packet);                       //释放
    }

    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [self.delegate softDecCallBackIndex:self StatusCode:SoftDecExit];
    //});
    
    return;
}

-(void)releaseAll
{
     //清理一切
     // Free the YUV frame
     av_free(pFrame);
     avpicture_free(&picture);
    
     // Close the codec
     avcodec_close(pCodecCtx);
     
     // Close the video file
     //avformat_close_input(&pFormatCtx);
    if (pFormatCtx) {
        pFormatCtx->interrupt_callback.opaque = NULL;
        pFormatCtx->interrupt_callback.callback = NULL;
        avformat_close_input(&pFormatCtx);
        pFormatCtx = NULL;
    }
    
     memset(outTime, 0, sizeof(OutTime));
     free(outTime);
     outTime = NULL;
     avformat_free_context(pFormatCtx);
}

-(void)stopDec
{
//暂停后，再退出，调用“outTime->stopDecId”会崩溃，why？？？？outTime被释放了。
//暂停后再退出，没有清屏幕。
    
    if(!pauseFlag)
        outTime->stopDecId = 3;

}

-(void)pauseDec
{
    pauseFlag = YES;
    outTime->stopDecId = 4;
}

-(void)restartDec
{
    dispatch_async(dispatch_get_global_queue(0, 0),^
                   {
                       if([self openInputURL:_URLString UdpOrTcp:_isUdp Restart:YES])
                       {
                           [self startDecRestart:YES];//如果没有退出，一直在这里循环。直到停止播放。
                       }
                   });
    pauseFlag = NO;
    
}

- (UIImage *)capturePhoto//convertFrameToRGB
{
     float with = pCodecCtx->width;
     float height = pCodecCtx->height;
    
    if (pFrame->data[0])
    {
        
        struct SwsContext * scxt =sws_getContext(with,
                                                 height,
                                                 PIX_FMT_YUV420P,
                                                 with,
                                                 height,
                                                 PIX_FMT_RGB24,//PIX_FMT_RGBA,
                                                 SWS_POINT,
                                                 NULL,NULL,NULL);
        
        if (scxt == NULL)
        {
            
            return nil;
            
        }
        
        //AVPicture picture;
        //avpicture_alloc(&picture,PIX_FMT_RGB24, with, height);
        
        sws_scale (scxt, (const uint8_t **)pFrame->data, pFrame->linesize, 0,height,picture.data, picture.linesize);
        
        CGBitmapInfo bitmapInfo =kCGBitmapByteOrderDefault;
        
        CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,picture.data[0],picture.linesize[0]*height,kCFAllocatorNull);
        
        CGDataProviderRef provider =CGDataProviderCreateWithCFData(data);
        
        CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
        
        CGImageRef cgImage = CGImageCreate(with,
                                           height,
                                           8,
                                           24,
                                           picture.linesize[0],
                                           colorSpace,
                                           bitmapInfo,
                                           provider,
                                           NULL,NO,kCGRenderingIntentDefault);
        
        CGColorSpaceRelease(colorSpace);
        UIImage *image = [UIImage imageWithCGImage:cgImage];//只有指针，no cache
        //UIImage* image = [[UIImage alloc]initWithCGImage:cgImage];   //crespo modify 20111020
        CGImageRelease(cgImage);
        CGDataProviderRelease(provider);
        CFRelease(data);
        sws_freeContext(scxt);
        //avpicture_free(&picture);
        return image;
        
    }
    
    return nil;
    
}


/*
-(UIImage *)capturePhoto
{
 
    if (pFrame->data[0])
    {
        AVFrame *pFrameRGB;
        pFrameRGB=av_frame_alloc();//avcodec_alloc_frame();
        if(pFrameRGB==NULL)
        {
            printf( "alloc pFrameRGB failed");
            return nil;
        }
        
        //即使我们申请了一帧的内存，当转换的时候，我们仍然需要一个地方来放置原始的数据。
        //我们使用avpicture_get_size来获得我们需要的大小，然后手工申请内存空间：
        uint8_t *buffer;
        int numBytes;
        // Determine required buffer size and allocate buffer
        numBytes=avpicture_get_size(PIX_FMT_RGB24, pCodecCtx->width,pCodecCtx->height);
        buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));
        
        avpicture_fill((AVPicture *)pFrameRGB, buffer, PIX_FMT_RGB24,pCodecCtx->width, pCodecCtx->height);
        
        //ws_scale来进行图像缩放和格式转换,
        struct SwsContext *pSwsCtx;
        pSwsCtx = sws_getContext (pCodecCtx->width,
                                  pCodecCtx->height,
                                  pCodecCtx->pix_fmt,
                                  pCodecCtx->width,
                                  pCodecCtx->height,
                                  PIX_FMT_BGR24,
                                  SWS_BICUBIC,
                                  NULL, NULL, NULL);

        sws_scale (pSwsCtx, (const uint8_t **)pFrame->data, pFrame->linesize, 0, pCodecCtx->height, pFrameRGB->data, pFrameRGB->linesize);
        
        UIImage *image = [self imageFromAVPicture:(AVPicture *)pFrameRGB width:pCodecCtx->width height:pCodecCtx->height];


        av_free(buffer);
        av_frame_free(&pFrameRGB);
        return image;
  

    }
    
    return nil;
    
}
 */


//RGB to UIimage
-(UIImage *)imageFromAVPicture:(AVPicture *)pict width:(int)width height:(int)height
{
    CGBitmapInfo bitmapInfo =kCGBitmapByteOrderDefault;
    CFDataRef data =CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict->data[0], pict->linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider =CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    int bitsPerComponent = 8;              // 8位存储一个Component
    int bitsPerPixel = 3 * bitsPerComponent;         // RGB存储，只用三个字节，而不是像RGBA要用4个字节，所以这里一个像素点要3个8位来存储
    // 这里3个字节是来自于 PIX_FMT_RGB24的定义中说明的， 是一个24位的数据，其中RGB各占8位
    //这里// PIX_FMT_RGB24,    ///< packed RGB 8:8:8, 24bpp, RGBRGB...
    
    int bytesPerRow =3 * width;           // 每行有width个象素点，每个点用3个字节，另外注意：pict.linesize[0]=bytesPerRow=1056
    CGImageRef cgImage =CGImageCreate(width,
                                      height,
                                      bitsPerComponent,
                                      bitsPerPixel,
                                      bytesPerRow,//pict->linesize[0],等效
                                      colorSpace,
                                      bitmapInfo,
                                      provider,
                                      NULL,
                                      NO,
                                      kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    //UIImage *image = [UIImageimageWithCGImage:cgImage];
    UIImage* image = [[UIImage alloc]initWithCGImage:cgImage];   //crespo modify 20111020
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    return image;
}



-(void)setIndex:(int)index
{
    _index = index;
}

-(int)getIndex
{
    return _index;
}
@end
