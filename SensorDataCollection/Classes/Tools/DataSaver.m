//
//  DataSaver.m
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/9/4.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#import "DataSaver.h"
#import "SensorData.h"
#import "PrefixHeader.h"
#import <FMDB.h>

#define SQLITE_NAME @"model.sqlite"
static DataSaver *_instance;

@interface DataSaver()
/** 数据库 */
@property (strong, nonatomic) FMDatabase *db;

/** 数据库路径 */
@property (strong, nonatomic) NSString *filePath;

/** 队列 */
@property (strong, nonatomic) FMDatabaseQueue *queue;

@end

@implementation DataSaver

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        // 初始化属性
        [_instance filePath];
        [_instance queue];
        [_instance db];
        DDLogDebug(@"DataSaver初始化完成");
    });
    return _instance;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

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
            DDLogError(@"打不开数据库！");
            return nil;
        }
        
        // 初始化数据表
        NSString *sql = @"CREATE TABLE 'SenserData' \
        ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,\
        'timestamp'         DATETIME,\
        'device_id'         TEXT,\
        'longitude'         REAL,\
        'latitude'          REAL,\
        'relative_altitude' REAL,\
        'acc_x'             REAL,\
        'acc_y'             REAL,\
        'acc_z'             REAL,\
        'step'              INETGER,\
        'distance'          REAL,\
        'floor_asce'        INETGER,\
        'floor_desc'        INETGER,\
        'meter_per_sec'     REAL,\
        'step_per_sec'      REAL) ";
        
        [_db executeUpdate:sql];
        
    }
    return _db;
}

+ (void)refreshDatabaseFile {
    DataSaver *instance = [self sharedInstance];
    [instance doRefresh];
}

- (void)doRefresh {
    self.queue = [FMDatabaseQueue databaseQueueWithPath:self.filePath];
}

- (void)inDatabase:(void(^)(FMDatabase*))block {
    [self.queue inDatabase:^(FMDatabase *db){
        block(db);
    }];
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        block(db, rollback);
    }];
}

- (void)saveSensorData:(SensorData *)sensorData {
    [self inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO SenserData (timestamp,device_id,longitude,latitude,relative_altitude,acc_x,acc_y,acc_z,step,distance,floor_asce,floor_desc,meter_per_sec,step_per_sec) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)", [NSDate date], [[[UIDevice currentDevice] identifierForVendor] UUIDString], @(sensorData.longitude), @(sensorData.latitude), @(sensorData.relativeAltitude), @(sensorData.accX), @(sensorData.accY), @(sensorData.accZ), @(sensorData.step), @(sensorData.distance), @(sensorData.floorsAscended), @(sensorData.floorsDescended), @(sensorData.meterPerSec), @(sensorData.stepPerSec)];
    }];
}

- (void)closeDatabase {
    [self.db close];
    DDLogDebug(@"数据库关闭");
}

- (void)dealloc {
    [self closeDatabase];
}

@end
