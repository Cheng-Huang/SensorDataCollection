//
//  DataSaver.m
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/9/4.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#import "DataSaver.h"
#import "SensorData.h"
#import <FMDB.h>

#define SQLITE_NAME @"model.sqlite"

@interface DataSaver()
/** 数据库 */
@property (strong, nonatomic) FMDatabase *db;

/** 数据库路径 */
@property (strong, nonatomic) NSString *filePath;

/** 队列 */
@property (strong, nonatomic) FMDatabaseQueue *queue;

@end

@implementation DataSaver


- (NSString *)filePath {
    if (!_filePath) {
        // 获得Documents目录路径
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _filePath = [documentsPath stringByAppendingPathComponent:SQLITE_NAME];
    }
    return _filePath;
}

- (FMDatabaseQueue *)queue {
    if (!_queue) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:self.filePath];
    }
    return _queue;
}

- (FMDatabase *)db {
    if (!_db) {

        // 创建数据库示例
        _db = [FMDatabase databaseWithPath:self.filePath];
        if (![_db open]) {
            NSLog(@"打不开数据库！");
            return nil;
        }
        
        // 初始化数据表
        NSString *sql = @"CREATE TABLE 'SenserData' \
        ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,\
        'timestamp'     DATETIME,\
        'device_id'     TEXT,\
        'longitude'     REAL,\
        'latitude'      REAL,\
        'acc_x'         REAL,\
        'acc_y'         REAL,\
        'acc_z'         REAL,\
        'step'          INETGER,\
        'distance'      REAL,\
        'floor_asce'    INETGER,\
        'floor_desc'    INETGER,\
        'meter_per_sec' REAL,\
        'step_per_sec'  REAL) ";
        
        [_db executeUpdate:sql];
        
        [_db close];
    }
    return _db;
}


- (void)saveSensorData:(SensorData *)sensorData{
    [self.db open];

    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO SenserData (timestamp,device_id,longitude,latitude,acc_x,acc_y,acc_z,step,distance,floor_asce,floor_desc,meter_per_sec,step_per_sec) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", [NSDate date], [[[UIDevice currentDevice] identifierForVendor] UUIDString], @(sensorData.longitude), @(sensorData.latitude), @(sensorData.accX), @(sensorData.accY), @(sensorData.accZ), @(sensorData.step), @(sensorData.distance), @(sensorData.floorsAscended), @(sensorData.floorsDescended), @(sensorData.meterPerSec), @(sensorData.stepPerSec)];
    }];
    
    [self.db close];
}

@end
