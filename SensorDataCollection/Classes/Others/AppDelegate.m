//
//  AppDelegate.m
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/9/4.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#import "AppDelegate.h"
#import "PrefixHeader.h"
#import "CatchCrash.h"
#import <GCDWebDAVServer.h>

@interface AppDelegate ()
{
    GCDWebDAVServer* _davServer;
    DDFileLogger * _fileLogger;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _davServer = [[GCDWebDAVServer alloc] initWithUploadDirectory:documentsPath];
    [_davServer start];
    DDLogDebug(@"服务启动成功，使用你的WebDAV客户端访问：%@", _davServer.serverURL);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_davServer.serverURL absoluteString] forKey:@"serverURL"];
    
    // 日志
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    id<DDLogFileManager> logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:documentsPath];
    _fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
//    _fileLogger = [[DDFileLogger alloc] init];
    _fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    _fileLogger.logFileManager.maximumNumberOfLogFiles = 7; //保持一周的日志文件
    [DDLog addLogger:_fileLogger];
    
    //注册消息处理函数的处理方法
    //如此一来，程序崩溃时会自动进入CatchCrash.m的uncaughtExceptionHandler()方法
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
