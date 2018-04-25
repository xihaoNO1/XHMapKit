//  地点信息模型
//  XHLocationInfo.h
//  JHCommunityClient_V3
//
//  Created by xixixi on 2017/7/10.
//  Copyright © 2017年 xixixi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface XHLocationInfo : NSObject

@property (nonatomic,copy) NSDictionary *addressDictionary;// address dictionary properties
@property (nonatomic,copy) NSString *address; //详细地址
@property (nonatomic,copy) NSString *name; //当前地址的名称
@property (nonatomic,copy) NSString *province; //当前省
@property (nonatomic,copy) NSString *city; //城市
@property (nonatomic,copy) NSString *cityCode; //城市的区号
@property (nonatomic,copy) NSString *district; //区
@property (nonatomic,copy) NSString *street; //当前街道
@property (nonatomic,copy) NSString *country; //当前国家
@property (nonatomic,copy) NSString *postalCode; //邮政编码
@property (nonatomic,copy) NSString *adcode; //当前地点的区域编码
/**
 高德或者google地图原始坐标
 */
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

/**
 当为国内地图时,某些情况使用的百度坐标
 */
@property (nonatomic,assign,readonly) CLLocationCoordinate2D bdCoordinate;

@end

