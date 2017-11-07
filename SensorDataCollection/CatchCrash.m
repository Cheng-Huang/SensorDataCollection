//
//  CatchCrash.m
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/11/7.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#import "CatchCrash.h"
#import "PrefixHeader.h"

@implementation CatchCrash
//在AppDelegate中注册后，程序崩溃时会执行的方法
void uncaughtExceptionHandler(NSException *exception)
{
    //获取系统当前时间，（注：用[NSDate date]直接获取的是格林尼治时间，有时差）
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *crashTime = [formatter stringFromDate:[NSDate date]];
    //异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    //出现异常的原因
    NSString *reason = [exception reason];
    //异常名称
    NSString *name = [exception name];
    
    //拼接错误信息
    NSString *exceptionInfo = [NSString stringWithFormat:@"crashTime: %@ Exception reason: %@\nException name: %@\nException stack:%@", crashTime, name, reason, stackArray];
    
    //获取到AppDelegate中注册的fileLogger
    //程序崩溃时，把系统捕获到的错误信息写入本地文件
    DDLogError(@"%@", exceptionInfo);
    
    //把错误信息保存到本地文件，设置errorLogPath路径下
    NSString *errorLogPath = [NSString stringWithFormat:@"%@/Documents/crash_%@.log", NSHomeDirectory(),crashTime];
    NSError *error = nil;
    [exceptionInfo writeToFile:errorLogPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        DDLogError(@"将crash信息保存到本地失败: %@", error.userInfo);
        error = nil;
    }
}
@end
