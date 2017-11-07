//
//  DataSaver.h
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/9/4.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SensorData;

@interface DataSaver : NSObject
+ (instancetype)sharedInstance;
+ (void)refreshDatabaseFile;
- (void)saveSensorData:(SensorData *)sensorData;
@end
