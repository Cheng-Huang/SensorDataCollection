//
//  SensorData.h
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/9/4.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SensorData : NSObject
/** 经度 */
@property (assign, nonatomic) CGFloat longitude;
/** 纬度 */
@property (assign, nonatomic) CGFloat latitude;
/** 相对海拔 */
@property (assign, nonatomic) CGFloat relativeAltitude;
/** 加速度X */
@property (assign, nonatomic) CGFloat accX;
/** 加速度Y */
@property (assign, nonatomic) CGFloat accY;
/** 加速度Z */
@property (assign, nonatomic) CGFloat accZ;
/** 步数 */
@property (assign, nonatomic) NSUInteger step;
/** 距离 */
@property (assign, nonatomic) CGFloat distance;
/** 上楼 */
@property (assign, nonatomic) NSUInteger floorsAscended;
/** 下楼 */
@property (assign, nonatomic) NSUInteger floorsDescended;
/** 速度m/s */
@property (assign, nonatomic) CGFloat meterPerSec;
/** 速度step/s*/
@property (assign, nonatomic) CGFloat stepPerSec;
/** 时间 */
@property (assign, nonatomic) NSDate *timestamp;
@end
