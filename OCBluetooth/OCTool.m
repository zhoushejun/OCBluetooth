//
//  OCTool.m
//  OCBluetooth
//
//  Created by zhoushejun on 14-10-26.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "OCTool.h"
#import <UIKit/UIKit.h>
int bg_tag = 999999990;

@implementation OCTool
//创建一个复层显示在屏幕上
+ (void)addALaryerOnWindow:(NSString *)string{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]};
    CGSize titleBrandSizeForHeight = [string sizeWithAttributes:attributes];
    int h = 2*titleBrandSizeForHeight.height;
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 40 - titleBrandSizeForHeight.width)/2, SCREEN_HEIGHT-h-50,40 + titleBrandSizeForHeight.width, h)];
    [bg setBackgroundColor:[UIColor blackColor]];
    bg.tag = bg_tag;
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0,0,40 + titleBrandSizeForHeight.width,h)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = string;
    lab.font = [UIFont systemFontOfSize:12];
    [lab setTextColor:[UIColor whiteColor]];
    [lab setBackgroundColor:[UIColor clearColor]];
    lab.numberOfLines = 0;
    [bg addSubview:lab];
    
    bg.alpha = 0.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    bg.alpha = 1.0;
    [UIView commitAnimations];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:bg];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeALaryerOnWindow) userInfo:nil repeats:NO];
}

+ (void)removeALaryerOnWindow{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *bg = [window viewWithTag:bg_tag];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hidenBG)];
    bg.alpha = 0.0;
    [UIView commitAnimations];
}

+ (void)hidenBG{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *bg = [window viewWithTag:bg_tag];
    [bg removeFromSuperview];
    bg = nil;
}

+ (NSDate *)dateFromUIntType:(UInt8)val {
    int i = 0;
    switch (val) {
        case 0x10://当天
        case 0x11:
        case 0x12:{
            i = 0;
        }
            break;
            
        case 0x13://前 1 天
        case 0x14:
        case 0x15:{
            i = 1;
        }
            break;
            
        case 0x16://前 2 天
        case 0x17:
        case 0x18:{
            i = 2;
        }
            break;
            
        case 0x19://前 3 天
        case 0x1A:
        case 0x1B:{
            i = 3;
        }
            break;
            
        case 0x1C://前 4 天
        case 0x1D:
        case 0x1E:{
            i = 4;
        }
            break;
            
        case 0x1F://前 5 天
        case 0x20:
        case 0x21:{
            i = 5;
        }
            break;
            
        case 0x22://前 6 天
        case 0x23:
        case 0x24:{
            i = 6;
        }
            break;
        default:{
            i = 0;
        }
            break;
    }
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-i*secondsPerDay];
    date = [date dateByAddingTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    return date;
}

+ (NSString *)historyDateStringFrom:(UInt8)val{
    NSDate *date = [self dateFromUIntType:val];
    NSString *dateString = [NSString stringWithFormat:@"%@",date];
    NSString *timestring = [[dateString componentsSeparatedByString:@" "] objectAtIndex:0];
    NSLog(@"timestring:%@",timestring);
    return timestring;
}

@end
