//
//  OCHandBandDataModel.h
//  OCBluetooth
//
//  Created by shejun.zhou on 14/12/17.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

/*!
 @file      OCHandBandDataModel.h
 @brief     解析从手环返回到App的数据
 @author    shejun.zhou
 @version   1.0.0
 */

#import <Foundation/Foundation.h>

@interface OCHandBandDataModel : NSObject

+ (OCHandBandDataModel *)sharedInstance;

/*!
 @brief     解析数据
 @detailed  解析从手环返回来的当天、历史7天等步数、卡路里、距离16进制数据
 @param     data:手环16进制数据
 @result    将解析后的数据保存到数据库，并更新主界面UI显示
 */
- (void)analyzeHBData:(NSData *)data;

/*! @name 判断是否请求数据 */
// @{
/*!
 @brief     判断是否向手环请求输入参数日期的数据
 @param     date:日期字符串
 @result    YES/NO:YES-请求数据   NO-不请求数据
 */
- (BOOL)shouldRequestDataForDate:(NSString *)date;
// @}end of 判断是否请求数据

@end
