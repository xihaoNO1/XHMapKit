//  地图-根据配置自动添加
//  XHMapView.h
//  JHWaiMaiUpdate
//
//  Created by xixixi on 2017/6/6.
//  Copyright © 2017年 jianghu2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <GoogleMaps/GoogleMaps.h>
@protocol XHMapViewDelegate<NSObject>
@optional
/**
 地图位置更新的时候走的方法
 
 @param mapView 地图的对象
 @param userLocation 位置的对象
 */
- (void)xhMapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation;
/** *@brief 地图移动结束后调用此接口
 * @param mapView 地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)xhMapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction;
/** *
 @brief 地图缩放结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)xhMapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction;
@end

@interface MAPointAnnotation(XHtool)
@property(nonatomic,strong)NSString *imgStr;

@end


@interface XHMapView : UIView<MAMapViewDelegate>

//初始化地图的中心点位置
@property (nonatomic,assign)CLLocationDegrees lat;
@property (nonatomic,assign)CLLocationDegrees lng;
@property(nonatomic,assign) id<XHMapViewDelegate>XHDelegate;

/**
 逆地理编码获取当前的位置和道路
 
 @param location 位置
 */
-(void)getCurrentLocationName:(CLLocationCoordinate2D)location block:(void(^)(NSString *house,NSString*road))resultBlock;
//地图移动后回调中心点位置和地址
@property (nonatomic,copy)void(^CenterPostion)(CLLocationCoordinate2D centerPoint, NSString *addr);

//添加一个大头针
- (void)addAnnotation:(CLLocationCoordinate2D)point
                title:(NSString *)title
               imgStr:(NSString *)imgStr
             selected:(BOOL)selected;

/**
 设置地图的中心位置为当前位置
 */
- (void)setCenterWithCurrentLocation;

/**
 设置地图的中心位置为指定的位置
 */
- (void)setCenterWithPoint:(CLLocationCoordinate2D)point;

#pragma mark - 改变配送员和商家之间的距离的
-(void)changeDistanceWithShopCoordinate:(CLLocationCoordinate2D)shopCoordinate
                          peiCoordinate:(CLLocationCoordinate2D)peiCoordinate;

#pragma mark - 改变配送员和客户之间的距离的
-(void)changeDistanceWithCustomCoordinate:(CLLocationCoordinate2D)customCoordinate
                            peiCoordinate:(CLLocationCoordinate2D)peiCoordinate;

/**
 两点路径规划,以当前位置为起点
 @param destination_lat  终点 lats
 @param destination_lng  终点 lng
 */
- (void)createRouteSearchWithDestination_lat:(double)destination_lat
                             destination_lng:(double)destination_lng;

/**
 两点路径规划,以特定位置为起点

 @param origin_lat 起点 lat
 @param origin_lng 起点 lng
 @param destination_lat 终点 lat
 @param destination_lng 终点 lng
 */
- (void)createRouteSearchWithOrigin_lat:(double)origin_lat
                             origin_lng:(double)origin_lng
                        destination_lat:(double)destination_lat
                        destination_lng:(double)destination_lng;

/**
 三点路径规划,以当前位置为起点
 @param passingPoint_lat 途经点 lat
 @param passingPoint_lng 途经点 lng
 @param destination_lat  终点 lat
 @param destination_lng  终点 lng
 */
- (void)createRouteSearchWithPassingPoint_lat:(double)passingPoint_lat
                             passingPoint_lng:(double)passingPoint_lng
                              destination_lat:(double)destination_lat
                              destination_lng:(double)destination_lng;

@end





