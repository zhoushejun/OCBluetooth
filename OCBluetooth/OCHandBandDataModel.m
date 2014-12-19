//
//  OCHandBandDataModel.m
//  OCBluetooth
//
//  Created by shejun.zhou on 14/12/17.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "OCHandBandDataModel.h"

@implementation OCHandBandDataModel

+ (OCHandBandDataModel *)sharedInstance{
    static OCHandBandDataModel *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)analyzeHBData:(NSData *)data{
    NSLog(@"当前指令内容:%@", data);
    UInt8 xval[1] = {0};
    [data getBytes:&xval range:NSMakeRange(0, 1)];
    /** 7天历史(步数、卡路里、距离)记录:0x24~0x10 */
    switch (xval[0]) {
        case 0x10:{
            
        }
            break;
            
        case 0x11:{
            
        }
            break;
            
        case 0x12:{
            
        }
            break;
            
        case 0x13:{
            
        }
            break;
            
        case 0x14:{
            
        }
            break;
            
        case 0x15:{
            
        }
            break;
            
        case 0x16:{
            
        }
            break;
            
        case 0x17:{
            
        }
            break;
            
        case 0x18:{
            
        }
            break;
            
        case 0x19:{
            
        }
            break;
            
        case 0x1a:{
            
        }
            break;
            
        case 0x1b:{
            
        }
            break;
            
        case 0x1c:{
            
        }
            break;
            
        case 0x1d:{
            
        }
            break;
            
        case 0x1f:{
            
        }
            break;
            
        case 0x20:{
            
        }
            break;
            
        case 0x21:{
            
        }
            break;
            
        case 0x22:{
            
        }
            break;
            
        case 0x23:{
            
        }
            break;
            
        case 0x24:{
            
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)shouldRequestDataForDate:(NSString *)date{
    NSLogCurrentFunction;
    return YES;
}

@end
