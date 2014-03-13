//
//  IOSocket.h
//  SimpleGCDAsyncSocket
//
//  Created by WuGQ on 14-3-13.
//  Copyright (c) 2014年 runGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "Prot.h"
#import "DelegateClass.h"

@interface IOSocket : NSObject<GCDAsyncSocketDelegate>
@property(nonatomic,assign) id<DoProtocol> delegate;

//协议发送
-(void)sendProt:(Prot*)prot waitCMD:(NSInteger)waitCMD;

//协议的连接状态
-(BOOL)isConnected;
-(void)setHost:(NSString*)host;
-(void)setPort:(NSInteger)port;
@end
