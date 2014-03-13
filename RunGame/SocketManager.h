//
//  Game.h
//  SimpleGCDAsyncSocket
//
//  Created by WuGQ on 14-3-13.
//  Copyright (c) 2014年 runGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DelegateClass.h"
#import "Prot.h"

@interface SocketManager : NSObject<DoProtocol>

+(SocketManager*)getInstance;

/**
 *  发送协议
 *
 *  @param prot
 */
-(void)sendProt:(Prot*)prot waitCMD:(NSInteger)waitCMD;

-(void)setHost:(NSString*)host;
-(void)setPort:(NSInteger)port;
@end
