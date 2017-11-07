//
//  CatchCrash.h
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/11/7.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatchCrash : NSObject
void uncaughtExceptionHandler(NSException *exception);
@end
