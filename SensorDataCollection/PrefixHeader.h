//
//  PrefixHeader.h
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/11/6.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#ifndef PrefixHeader_h
#define PrefixHeader_h

#import <CocoaLumberjack/CocoaLumberjack.h>
// 屏幕长宽
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#define HCLog(format, ...) DDLogDebug((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#define HCLog(...);
#endif

#endif /* PrefixHeader_h */
