//
//  KCAnnotation.h
//  SS
//
//  Created by apple on 2017/8/3.
//  Copyright © 2017年 chenxin · luo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/**
 系统只提供了<MKAnnotation>这个协议 变没有提供一个遵循这个协议的类，所以我们需要自己创建一个类
 */
// 遵循了协议 也就是相当于继承了协议，所以协议里面实现的方法如果使用到了，一定要重写，否则找不到方法会报 ‘unrecognized selector sent to instance 0x17401d270’

@interface KCAnnotation : NSObject <MKAnnotation>

// 重写协议的属性

@property (nonatomic) CLLocationCoordinate2D coordinate; // 必须实现

// 以下两个属性用于显示大头针的小标题
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@end
