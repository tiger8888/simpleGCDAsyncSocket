//
//  DelegateClass.h
//  SimpleGCDAsyncSocket
//
//  Created by WuGQ on 14-3-13.
//  Copyright (c) 2014年 runGame. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DoProtocol <NSObject>

-(BOOL)doProtocol:(NSData*)protData protId:(NSInteger)protId;
-(void)doProtocolWait:(NSInteger)waitCMD;

@end
