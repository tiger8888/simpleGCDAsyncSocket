//
//  Prot.h
//  SimpleGCDAsyncSocket
//
//  Created by WuGQ on 14-3-13.
//  Copyright (c) 2014年 runGame. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Prot : NSObject
@property (nonatomic) NSInteger protId;
@property (nonatomic,strong) NSData* protData;
-(BOOL) doProtocol:(NSData*)data;
-(void) doProtocolWait;


@end
