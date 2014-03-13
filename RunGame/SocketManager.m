^{
    <#code#>
}//
//  Game.m
//  SimpleGCDAsyncSocket
//
//  Created by WuGQ on 14-3-13.
//  Copyright (c) 2014年 runGame. All rights reserved.
//
//  by RG
//
//  Thanks to Google Translate to provide technical support
//
//
#import "SocketManager.h"
#import "IOSocket.h"

@implementation SocketManager
{
    IOSocket* socket;
}

#pragma mark initialization
-(id)init
{
    if(self = [super init]){
        if(socket == nil){
            socket = [[IOSocket alloc]init];
        }
    }
    return self;
}

+(SocketManager*)getInstance
{
    static SocketManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

- (id) copyWithZone:(NSZone*)zone
{
    return self;
}

#pragma mark Set properties

/**
 * Set server address
 */
-(void)setHost:(NSString*)host
{
    [socket setHost:host];
}

/**
 * Set the server port
 */
-(void)setPort:(NSInteger)port
{
    [socket setPort:port];
}


#pragma mark send protocols

/**
 *  send protocol
 *
 *  @param prot protocol instance
 *  @param waitCMD wait tag
 */
-(void)sendProt:(Prot*)prot waitCMD:(NSInteger)waitCMD
{
    [socket sendProt:prot waitCMD:waitCMD];
}

#pragma mark Resolution Protocol

/**
 * Do protocol analysis
 */
-(BOOL)doProtocol:(NSData*)protData protId:(NSInteger)protId
{
    BOOL result = NO;
    Class class = NSClassFromString([NSString stringWithFormat:@"Prot%ld",(long)protId]);
    if(class){
        Prot* prot = [[class alloc] init];
        result = [prot doProtocol:protData];
        
        if(result){
            [prot doProtocolWait];
        }
    }
    return result;
}

/**
 * Do protocol wait
 */
-(void)doProtocolWait:(NSInteger)waitCMD
{
    switch (waitCMD) {
        case 1:
            break;
            
        default:
            break;
    }
}

@end
