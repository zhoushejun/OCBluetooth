//
//  OCTool.h
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-26.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCTool : NSObject

//创建一个复层显示在屏幕上
+ (void)addALaryerOnWindow:(NSString *)string;
+ (void)hidenBG;

/*! @name 根据请求指令返回指令代表的日期字符串 */
// @{
/*!
 @brief     根据指令返回日期
 @param     val:请求指令
 @result    日期格式的日期
 @see       historyDateStringFrom:
 */
+ (NSDate *)dateFromUIntType:(UInt8)val ;
/*!
 @brief     根据指令返回日期字符串
 @param     val:请求指令
 @result    字符串格式的日期
 */
+ (NSString *)historyDateStringFrom:(UInt8)val;
// @}end of 根据请求指令返回指令代表的日期字符串

@end
