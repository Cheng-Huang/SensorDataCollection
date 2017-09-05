//
//  ViewController.m
//  SensorDataCollection
//
//  Created by 成 黄 on 2017/9/4.
//  Copyright © 2017年 成 黄. All rights reserved.
//

#import "ViewController.h"
#import "SensorData.h"
#import "DataSaver.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <MapKit/MapKit.h>

#define AutoSaveInterval 1.0
#define AccUpdateInterval 1.0

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *davLabel;
@property (weak, nonatomic) IBOutlet UILabel *LongitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *relativeAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *XLabel;
@property (weak, nonatomic) IBOutlet UILabel *YLabel;
@property (weak, nonatomic) IBOutlet UILabel *ZLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorsAscendedLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorsDescendedLabel;
@property (weak, nonatomic) IBOutlet UILabel *meterPerSecLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepPerSecLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CMMotionManager *motionManger;
@property (nonatomic, strong) CMPedometer *pedometer;
@property (nonatomic, strong) CMAltimeter *altimeter;

/** 数据模型 */
@property (strong, nonatomic) SensorData *sensorData;

/** 数据库存储工具 */
@property (strong, nonatomic) DataSaver *dataSaver;

/** 自动保存 */
@property (strong, nonatomic) NSTimer *autoSaver;

@end

@implementation ViewController

#pragma mark - MKMapView Delegate
/**
 *  更新到用户的位置时就会调用(显示的位置、显示范围改变)
 *  userLocation : 大头针模型数据， 对大头针位置的一个封装（这里的userLocation描述的是用来显示用户位置的蓝色大头针）
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
    userLocation.title = @"当前位置";
    userLocation.subtitle = [NSString stringWithFormat:@"经度: %f  纬度: %f", center.longitude, center.latitude];
}


#pragma mark - CoreLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    //locations数组里边存放的是CLLocation对象，一个CLLocation对象就代表着一个位置
    CLLocation *loc = [locations firstObject];

    NSLog(@"纬度=%f，经度=%f", loc.coordinate.latitude, loc.coordinate.longitude);
    self.sensorData.longitude = loc.coordinate.longitude;
    self.sensorData.latitude = loc.coordinate.latitude;
    
    self.LongitudeLabel.text = [NSString stringWithFormat:@"%f", loc.coordinate.longitude];
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", loc.coordinate.latitude];
}

#pragma mark - Actions

- (IBAction)startButtonClicked:(id)sender {
    [self.locationManager startUpdatingLocation];
    [self startUpdateACC];
    [self startUpdatePedo];
    [self startUpdateAltitude];
    [self.autoSaver fire];
}

- (IBAction)stopButtonClicked:(id)sender {
    [self.locationManager stopUpdatingLocation];
    if (self.motionManger.isAccelerometerActive) {
        [self.motionManger stopAccelerometerUpdates];
    }
    [self.pedometer stopPedometerUpdates];
    [self.altimeter stopRelativeAltitudeUpdates];
    [self.autoSaver invalidate];
}

#pragma mark - Private Methods

- (void)startUpdateACC {
    if (self.motionManger.isAccelerometerAvailable) {
        if (self.motionManger.isAccelerometerActive) {
            [self.motionManger stopAccelerometerUpdates];
        }
        self.motionManger.accelerometerUpdateInterval = AccUpdateInterval;
        [self.motionManger startAccelerometerUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (error) {
                NSLog(@"出错 %@",error);
            }else{
                CGFloat X=accelerometerData.acceleration.x;
                CGFloat Y=accelerometerData.acceleration.y;
                CGFloat Z=accelerometerData.acceleration.z;
                
                self.sensorData.accX = X;
                self.sensorData.accY = Y;
                self.sensorData.accZ = Z;
                
                NSLog(@"x轴:%f y轴:%f z轴:%f",X,Y,Z);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.XLabel.text = [NSString stringWithFormat:@"%f", X];
                    self.YLabel.text = [NSString stringWithFormat:@"%f", Y];
                    self.ZLabel.text = [NSString stringWithFormat:@"%f", Z];
                });
            }
        }];
    }
}

- (void)startUpdatePedo {
    if ([CMPedometer isStepCountingAvailable] && [CMPedometer isDistanceAvailable]) {
        [self.pedometer stopPedometerUpdates];
        //开始计步
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            if (error) {
                NSLog(@"error: %@",error);
            }else {
                NSLog(@"步数：%@ 距离：%@", pedometerData.numberOfSteps, pedometerData.distance);
                NSLog(@"上楼：%@ 下楼：%@", pedometerData.floorsAscended, pedometerData.floorsDescended);
                NSLog(@"速度：%@ m/s 速度：%@ step/s", pedometerData.currentPace, pedometerData.currentCadence);
                
                self.sensorData.step = pedometerData.numberOfSteps.integerValue;
                self.sensorData.distance = pedometerData.distance.doubleValue;
                self.sensorData.floorsAscended = pedometerData.floorsAscended.integerValue;
                self.sensorData.floorsDescended = pedometerData.floorsDescended.integerValue;
                self.sensorData.meterPerSec = pedometerData.currentPace.doubleValue;
                self.sensorData.stepPerSec = pedometerData.currentCadence.doubleValue;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.stepLabel.text = [NSString stringWithFormat:@"%@",pedometerData.numberOfSteps];
                    self.distanceLabel.text = [NSString stringWithFormat:@"%@",pedometerData.distance];
                    self.floorsAscendedLabel.text = [NSString stringWithFormat:@"%@",pedometerData.floorsAscended];
                    self.floorsDescendedLabel.text = [NSString stringWithFormat:@"%@",pedometerData.floorsDescended];
                    self.meterPerSecLabel.text = [NSString stringWithFormat:@"%@ m/s",pedometerData.currentPace ? pedometerData.currentPace : @(0)];
                    self.stepPerSecLabel.text = [NSString stringWithFormat:@"%@ step/s",pedometerData.currentCadence ? pedometerData.currentCadence : @(0)];
                });
            }
        }];
    }
}

- (void)startUpdateAltitude {
    if ([CMAltimeter isRelativeAltitudeAvailable]) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.altimeter startRelativeAltitudeUpdatesToQueue:queue withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
            if (error) {
                NSLog(@"出错 %@",error);
            }
            self.sensorData.relativeAltitude = altitudeData.relativeAltitude.doubleValue;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.relativeAltitudeLabel.text = altitudeData.relativeAltitude.stringValue;
            });
        }];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.设置地图类型
    self.mapView.mapType = MKMapTypeStandard;
    
    // 2.设置跟踪模式(MKUserTrackingModeFollow == 跟踪)
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    // 3.设置代理（监控地图的相关行为：比如显示的区域发生了改变）
    self.mapView.delegate = self;
    
    self.davLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverURL"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy init

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        // 判断定位操作是否被允许
        if([CLLocationManager locationServicesEnabled]) {
            //定位初始化
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.allowsBackgroundLocationUpdates = YES; //允许后台刷新
            _locationManager.pausesLocationUpdatesAutomatically = NO; //不允许自动暂停刷新
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            _locationManager.distanceFilter = kCLDistanceFilterNone;
            [_locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
        } else {
            //提示用户无法进行定位操作
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定位不成功 ,请确认开启定位" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }
    return _locationManager;
}

- (CMMotionManager *)motionManger {
    if (!_motionManger) {
        _motionManger = [[CMMotionManager alloc] init];
    }
    return _motionManger;
}

- (CMPedometer *)pedometer {
    if (!_pedometer) {
        _pedometer = [[CMPedometer alloc] init];
    }
    return _pedometer;
}

- (CMAltimeter *)altimeter {
    if (!_altimeter) {
        _altimeter = [[CMAltimeter alloc] init];
    }
    return _altimeter;
}

- (SensorData *)sensorData {
    if (!_sensorData) {
        _sensorData = [[SensorData alloc] init];
    }
    return _sensorData;
}

- (DataSaver *)dataSaver {
    if (!_dataSaver) {
        _dataSaver = [[DataSaver alloc] init];
    }
    return _dataSaver;
}

- (NSTimer *)autoSaver {
    if (!_autoSaver) {
        _autoSaver = [NSTimer scheduledTimerWithTimeInterval:AutoSaveInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self.dataSaver saveSensorData:self.sensorData];
        }];
    }
    return _autoSaver;
}


@end
