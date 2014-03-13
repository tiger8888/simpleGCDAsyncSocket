//
//  IOSocket.m
//  SimpleGCDAsyncSocket
//
//  Created by WuGQ on 14-3-13.
//  Copyright (c) 2014年 runGame. All rights reserved.
//

#import "IOSocket.h"
#import "SocketManager.h"
#define SOCKET_TIME_OUT -1
@implementation IOSocket
{
    NSMutableDictionary* waitCMDDic;
    NSMutableData* dataCache;//数据缓存
    GCDAsyncSocket* socket;
    NSString* gHost;    //服务器地址
    NSInteger gPort;    //服务器端口号
}

/**
 * 设置服务器地址
 */
-(void)setHost:(NSString*)host
{
    if (host == nil || host.length <= 0)
    {
        NSLog(@"host can not be empty");
        return;
    }
    
    gHost = host;
}

/**
 * 设置端口号
 */
-(void)setPort:(NSInteger)port
{
    if (port < 0 || port > 65535)
    {
        NSLog(@"set error port");
        return;
    }
    
    gPort = port;
}

/**
 *  发送协议
 *
 *  @param prot 协议信息
 *  @param data 封装的数据
 */
-(void)sendProt:(Prot*)prot withData:(NSData*)data
{
    [self getConnection];
    [socket writeData:data withTimeout:SOCKET_TIME_OUT tag:prot.protId];
    [socket readDataWithTimeout:SOCKET_TIME_OUT tag:prot.protId];
}

/**
 *  连接socket
 */
-(void)getConnection
{
    if (![socket isConnected])
    {
        [self connectToHost:gHost withPort:gPort];
    }
}

/**
 * 获取连接状态
 */
-(BOOL)isConnected
{
    if(socket){
        return socket.isConnected;
    }
    
    return NO;
}

/**
 *  初始化 socket.
 *
 */
-(id)init
{
    if(self = [super init]){
        if(socket == nil){
            socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            dataCache = [[NSMutableData alloc]init];
        }
    }
    
    return self;
}

/**
 *  连接到服务器
 *
 *  @param host
 *  @param port
 */
-(void) connectToHost:(NSString*)host withPort:(NSInteger)port
{
    NSError *err;
    [socket connectToHost:host onPort:port error:&err];
    
    if (err != nil)
    {
        NSLog(@"%@",err);
    }
}


/**
 *  写入数据委托
 */
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
}

/**
 *  成功连接后的委托方法
 *
 */
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"socket successfully connects to the server:%@:%d",host,port);
    
    [socket readDataWithTimeout:SOCKET_TIME_OUT tag:0];
}

/**
 *  接收数据后的委托方法
 */
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if(data){
        [dataCache appendData:data];
    }
    
    while (YES == [self parseData]) {
        //
    }
}

/**
 *  发送协议
 */
-(void)sendProt:(Prot*)prot waitCMD:(NSInteger)waitCMD
{
    //验证协议是否规范
    if([self validateProt:prot] == NO){
        return;
    }
    
    //协议头
    NSMutableData* data = [[NSMutableData alloc] initWithData:[@"RGDO" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //协议标记,服务器原样返回，整型值长度为4，服务器自动判断
    int waitCMDNet = htonl(waitCMD);
    NSData *waitCMDData = [NSData dataWithBytes: &waitCMDNet length: sizeof(int)];
    [data appendData:waitCMDData];
    
    //(协议号+数据长度),协议号为整形长度为4
    NSInteger protLen = prot.protData.length + 4;
    int protLenNet = htonl(protLen);
    NSData *protLenData = [NSData dataWithBytes:&protLenNet length: sizeof(int)];
    [data appendData:protLenData];
    
    //协议号数据
    int protIdNet =htonl(prot.protId);
    NSData *protIdData = [NSData dataWithBytes: &protIdNet length: sizeof(int)];
    [data appendData:protIdData];
    
    //协议数据
    [data appendData:prot.protData];
    
    
    //设置协议等待
    [self setCMDWait:prot CMD:waitCMD];
    
    //发送协议
    [self sendProt:prot withData:data];
}



/**
 *  设置等待指令
 *
 *  @param prot
 *  @param waitCMD
 */
-(void)setCMDWait:(Prot*)prot CMD:(NSInteger)waitCMD
{
    if(waitCMD <= 0){
        return;
    }
    
    if(waitCMDDic == nil){
        waitCMDDic = [[NSMutableDictionary alloc]init];
    }
    
    NSMutableArray* waitProts = [waitCMDDic objectForKey:[NSNumber numberWithInteger:waitCMD]];
    if(waitProts != nil & waitProts.count > 0){
        //可能是多条协议设置的等待
        [waitProts addObject:[NSNumber numberWithInteger:prot.protId]];
    }else{
        waitProts = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:prot.protId], nil];
    }
}

/**
 *  验证协议
 *
 *  @param prot
 */
-(BOOL)validateProt:(Prot*)prot
{
    if(prot.protId <= 0)
    {
        return NO;
    }
    
    if(prot.protData == nil)
    {
        prot.protData = [[NSData alloc]init];
    }
    return YES;
}


/**
 *
 * 初步解析返回数据
 *
 */
-(BOOL)parseData
{
    if (!dataCache || dataCache.length < 16)
    {
        NSLog(@"error,parse data");
        return NO;
    }
    
    NSData *headData = [dataCache subdataWithRange:NSMakeRange(0, 4)];
    NSString* head = [[NSString alloc] initWithData:headData encoding:NSUTF8StringEncoding];
    if (![head isEqualToString:@"RGDO"])
    {
        NSLog(@"Bad head!");
        return NO;
    }
    
    NSData *waitCMDData = [dataCache subdataWithRange:NSMakeRange(4, 4)];
    int waitCMD;
    [waitCMDData getBytes: &waitCMD length: sizeof(int)];
    waitCMD =ntohl(waitCMD);
    
    NSData *protLenData = [dataCache subdataWithRange:NSMakeRange(8, 4)];
    int protLen;
    [protLenData getBytes: &protLen length: sizeof(int)];
    protLen =ntohl(protLen);
    
    NSData *protIdData = [dataCache subdataWithRange:NSMakeRange(12, 4)];
    int protId;
    [protIdData getBytes: &protId length: sizeof(int)];
    protId =ntohl(protId);
    
    if (dataCache.length < protLen + 12)
    {
        NSLog(@"err data lenth");
        return NO;
    }
    
    NSInteger prefixLen = headData.length + waitCMDData.length + protIdData.length + protLenData.length;
    NSInteger protDataLen = protLen - protIdData.length;
    
    NSData* protData = [dataCache subdataWithRange:NSMakeRange(prefixLen, protDataLen)];
    [self parseProt:protData protId:protId waitCMD:waitCMD];
    [dataCache replaceBytesInRange:NSMakeRange(0, prefixLen + protDataLen) withBytes:NULL length:0];
    
    
    return YES;
}

/**
 *  解析协议解析
 
 *  @return
 */
-(void)parseProt:(NSData*)data protId:(NSInteger)protId waitCMD:(NSInteger)waitCMD
{
    NSLog(@"doProtocol:%ld with waitCMD:%ld",(long)protId,(long)waitCMD);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(doProtocol:protId:)])
    {
        BOOL resultOK = [self.delegate doProtocol:data protId:protId];
        if (resultOK && waitCMD > 0)
        {
            NSMutableArray* waitProts = [waitCMDDic objectForKey:[NSNumber numberWithInteger:waitCMD]];
            if (waitProts && [waitProts count]>0)
            {
                if ([waitProts containsObject:[NSNumber numberWithInteger:protId]]) {
                    [waitProts removeObject:[NSNumber numberWithInteger:protId]];
                }
                
                if ([waitProts count]<=0)
                {
                    [waitCMDDic removeObjectForKey:[NSNumber numberWithInteger:waitCMD]];
                    [self.delegate doProtocolWait:waitCMD];
                }
            }
        }
    }

}




@end
