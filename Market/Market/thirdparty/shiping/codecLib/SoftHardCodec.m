//
//  SoftHardCodec.m
//  ffmpegTestNew
//
//  Created by liucairong on 15/9/7.
//  Copyright (c) 2015年 liucairong. All rights reserved.
//

#import "SoftHardCodec.h"
#import "SoftDecoder.h"

@interface SoftHardCodec()<SoftDecDelegate>
{
    SoftDecoder *softDec[5];//1\2\3\4 use,0 not use
    BOOL _isSoft;
    int softDecIndexUsedMask;
}
@end


@implementation SoftHardCodec

- (id)init
{
    self = [super init];
    if (self)
    {
        avcodec_register_all();
        av_register_all();//注册所有容器格式和CODEC
        avformat_network_init();
        
        softDecIndexUsedMask = 0x00;

    }
    return self;
}

-(int)decoderStartURL:(NSString *)URLString SoftOrHard:(BOOL)isSoft UdpOrTcp:(BOOL)isUdp
{
    _isSoft = isSoft;
    int index = 0;
    
    if(_isSoft)
    {
        int i;
        for(i=1;i<5;i++)
        {
            if(((softDecIndexUsedMask >> (i-1))&0x01) == 0x01)
                continue;
            else
            {
                index = i;
                softDecIndexUsedMask = softDecIndexUsedMask | (0x01 << (i-1));
                break;
            }
        }
        if(i == 5)
            return -1;//has no more decoder to use.
        
        softDec[index] = [[SoftDecoder alloc] init];
        softDec[index].delegate = self;
        [softDec[index] setIndex:index];
        
        //异步操作，有可能函数先返回了，这里才返回
        dispatch_async(dispatch_get_global_queue(0, 0),^
        {
            if([softDec[index] openInputURL:URLString UdpOrTcp:isUdp  Restart:NO])
            {
                [softDec[index] startDecRestart:NO];//如果没有退出，一直在这里循环。直到停止播放。
            }
            [self clearSoftDecIndexUsedMask:index];//停止播放后必须清理掉使用的decoder标记，否则无法重利用。
            //[softDec[index] release];//暂停时，这个index dec还要用的，不能释放。否则暂停时，崩溃。

            
        });
        
        return index;
        
    
    }
    else
    {
        NSLog(@"hard decoder is not completed");
        return -1;//has no more decoder to use.
    }
}


-(void)clearSoftDecIndexUsedMask:(int)index
{
    softDecIndexUsedMask =  softDecIndexUsedMask & (~(0x01 << (index-1)));
}


-(void)decoderStopIndex:(int)index
{
    if(_isSoft)
    {
        [softDec[index] stopDec];
        [self clearSoftDecIndexUsedMask:index];
    }
}

-(void)decoderPauseIndex:(int)index
{
    if(_isSoft)
    {
        [softDec[index] pauseDec];
    }
}

-(void)decoderRestartIndex:(int)index
{
    if(_isSoft)
    {
        [softDec[index] restartDec];
    }
}

-(UIImage *)decoderCaptureIndex:(int)index
{
    if(_isSoft)
    {
        return [softDec[index] capturePhoto];
    }
    return nil;
}


//implement SoftDecDelegate
-(void)softDecoder:(SoftDecoder *)pSoftDec SetDisplaySize:(int)width Height:(int)height
{
    int index = [pSoftDec getIndex];
    NSLog(@"SetDisplaySize soft dec index:%d",index);
    [self.delegate decoderSetDisplayLayerIndex:index Width:width Height:height];
}


-(void)softDecoder:(SoftDecoder *)pSoftDec SetDisplayAVFrame:(AVFrame *)pAVFrame
{
    int index = [pSoftDec getIndex];

    //NSLog(@"SetDisplayAVFrame soft dec index:%d",index);

    [self.delegate decoderShowDisplayLayerIndex:index  AVFrame:(AVPic *)pAVFrame];
    
}

-(void)softDecCallBackIndex:(SoftDecoder *)pSoftDec StatusCode:(int)statusCode
{
    int index = [pSoftDec getIndex];
    //NSLog(@"softDecCallBackIndex StatusCode soft dec index:%d",index);
    if(statusCode%2 == 1 || statusCode == SoftDecExit)
    {
        //解码器不正常退出 或者 按键退出，都需要release用过的index dec
        [softDec[index] release];
    }
    [self.delegate decoderCallBackIndex:index StatusCode:statusCode];
}


-(void)softDecCallBackIndex:(SoftDecoder *)pSoftDec GetPhoto:(UIImage *)imagePhoto
{
    int index = [pSoftDec getIndex];
    NSLog(@"softDecCallBackIndex GetPhoto soft dec index:%d",index);
    [self.delegate decoderCallBackIndex:index GetPhoto:imagePhoto];
}

@end
