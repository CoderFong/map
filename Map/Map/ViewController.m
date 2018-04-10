//
//  ViewController.m
//  Map
//
//  Created by Playboy on 2018/4/4.
//  Copyright © 2018年 tmkj. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "KCAnnotation.h"
#import "JZLocationConverter.h"

/**
 需要在info.plist中添加白名单
 */
@interface ViewController ()<MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configure];
}
- (void)configure {
    self.mapView.delegate = self;
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[@"29.654631" doubleValue] longitude:[@"106.595922" doubleValue]];
    // 转国内火星坐标
    CLLocationCoordinate2D coor = [JZLocationConverter wgs84ToGcj02:loc.coordinate];
    // 比例尺 值越小越直观
    MKCoordinateSpan span = {0.01,0.01};
    // 该参数为两个结构体 一个为经纬度，一个为显示比例尺
    MKCoordinateRegion region = {coor,span};
    // 添加标注
    [self addAnnotation:coor name:@"当前位置" subTitle:@"描述信息"];
    // 在地图上显示当前比例尺的位置
    [self.mapView setRegion:region animated:YES];
}

// 添加大头针
- (void)addAnnotation:(CLLocationCoordinate2D)coordinate name:(NSString *)name subTitle:(NSString *)subTitle;
{
    // 要添加大头针，只能遵循<MKAnnotation>创建一个类出来，系统没有提供
    KCAnnotation *annotation = [[KCAnnotation alloc]init];
    annotation.title      = name;
    annotation.coordinate = coordinate;
    annotation.subtitle = subTitle;
    // 添加大头针，会调用代理方法 mapView:viewForAnnotation:
    [_mapView addAnnotation:annotation];
    // 设置默认点击大头针
    self.mapView.selectedAnnotations = @[annotation];
    
}

#pragma mark - MKMapViewDelegate
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[KCAnnotation class]])
    {
        // 跟tableViewCell的创建一样的原理
        static NSString *identifier = @"kkk";
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        annotationView.canShowCallout = YES; // 显示大头针小标题
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        rightBtn.frame = CGRectMake(0, 0, 50, 50);
        rightBtn.backgroundColor = [UIColor redColor];
        [rightBtn setTitle:@"导航" forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"map_daohang"] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 15, 25, 0)];
        [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(25, -15, 5, 0)];
        [rightBtn addTarget:self action:@selector(mapButtonClick) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = rightBtn;
        // 自定义图片(如果使用系统大头针可以使用<MKPinAnnotationView>类)
        annotationView.image = [UIImage imageNamed:@"annotation"];
        return annotationView;
    }
    return nil; // 设为nil  自动创建系统大头针(唯一区别就是图片的设置)
}

// 导航
- (void)mapButtonClick {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地图进行导航" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *systemAction = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self enterIOSSystemMap];
    }];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        UIAlertAction *baiduAction = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self enterBaiduMap];
        }];
        [alert addAction:baiduAction];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        UIAlertAction *gaodeAction = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self enterGaoDeMap];
        }];
        [alert addAction:gaodeAction];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        UIAlertAction *googleAction = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self enterGoogleMap];
        }];
        [alert addAction:googleAction];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        UIAlertAction *qqAction = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self enterQQMap];
        }];
        [alert addAction:qqAction];
    }
    
    [alert addAction:cancelAction];
    [alert addAction:systemAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark ------------------------------ 导航 - iosMap
-(void) enterIOSSystemMap {
    //起点
    CLLocation * location = [[CLLocation alloc]initWithLatitude:[@"29.654631" doubleValue] longitude:[@"106.595922" doubleValue]];
    CLLocationCoordinate2D coor =location.coordinate;
    MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coor  addressDictionary:nil]];
    currentLocation.name =@"我的位置";
    
    //目的地的位置
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:[@"29.654631" doubleValue] longitude:[@"107.595922" doubleValue]];
    CLLocationCoordinate2D coor2 =location2.coordinate;
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coor2 addressDictionary:nil]];
    toLocation.name = @"目的地";
    NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil, nil];
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber                                 numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    //打开苹果自身地图应用，并呈现特定的item
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark ------------------------------ 导航 - 百度地图
- (void)enterBaiduMap {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSString *url = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%lf,%lf|name:我的位置&destination=latlng:%@,%@|name:%@&mode=driving",[@"29.654631" floatValue], [@"107.595922" floatValue],@"29.654631",@"106.595922",@"当前位置"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

#pragma mark ------------------------------ 导航 - 高德地图
- (void)enterGaoDeMap {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSString *url = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",@"导航功能",@"nav123456",[@"29.654631" floatValue], [@"107.595922" floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

#pragma mark ------------------------------ 导航 - 腾讯地图
- (void)enterQQMap {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        NSString *url = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=终点&coord_type=1&policy=0",[@"29.654631" floatValue], [@"107.595922" floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

#pragma mark ------------------------------ 导航 - 谷歌地图
- (void)enterGoogleMap {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSString *url = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"导航测试",@"nav123456",[@"29.654631" floatValue], [@"107.595922" floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
