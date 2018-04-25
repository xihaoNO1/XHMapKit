//
//  XHMapView.m
//  JHWaiMaiUpdate
//
//  Created by xixixi on 2017/6/6.
//  Copyright © 2017年 jianghu2. All rights reserved.
//

#import "XHMapView.h"
#import "XHMapKitManager.h"
#import "XHCoordinateConvert.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <objc/runtime.h>

//给MAPointAnnotation 添加imgStr属性
static char MAPointAnnotation_imgStr;
@implementation MAPointAnnotation(XHtool)

- (NSString *)imgStr{
    return objc_getAssociatedObject(self, &MAPointAnnotation_imgStr);
}

-(void)setImgStr:(NSString *)imgStr{
    
    objc_setAssociatedObject(self, &MAPointAnnotation_imgStr,imgStr,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


@interface XHMapView()<MAMapViewDelegate,GMSMapViewDelegate,AMapSearchDelegate>
@property (nonatomic,strong)MAMapView *gaodeMap;
@property (nonatomic,strong)GMSMapView *gmsMap;
@property (nonatomic,assign)double user_lat;
@property (nonatomic,assign)double user_lng;
@property(nonatomic,copy)void(^getRoadBlock)(NSString *house,NSString*road);
@end

@implementation XHMapView
{
    //高德路径搜索相关,此参数必须为全局变量
    AMapSearchAPI *_search1;
    AMapSearchAPI *_search2;
    AMapSearchAPI *_search;
    AMapLocationManager *amapLocationManager;
    AMapRidingRouteSearchRequest *request1;
    AMapRidingRouteSearchRequest *request2;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        if ([XHMapKitManager shareManager].is_International) {
            [self addSubview:self.gmsMap];
        }else{
            [self addSubview:self.gaodeMap];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        if ([XHMapKitManager shareManager].is_International) {
            [self addSubview:self.gmsMap];
            self.gmsMap.frame = CGRectMake(0,0,CGRectGetWidth(frame),CGRectGetHeight(frame));
        }else{

            [self addSubview:self.gaodeMap];
            self.gaodeMap.frame = CGRectMake(0,0,CGRectGetWidth(frame),CGRectGetHeight(frame));
            [self.gaodeMap setZoomLevel:13 animated:NO];
        }
    }
    return self;
}

#pragma mark - 创建高德地图
- (MAMapView *)gaodeMap{
    if (_gaodeMap == nil) {
        _gaodeMap = [[MAMapView alloc] init];
        _gaodeMap.showsCompass = NO;
        _gaodeMap.showsScale = NO;
        _gaodeMap.delegate = self;
        _gaodeMap.showsUserLocation = YES;
        _gaodeMap.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    }
    return _gaodeMap;
}

#pragma mark - 创建googe地图
- (GMSMapView *)gmsMap{
    if (_gmsMap == nil) {
        _gmsMap = [[GMSMapView alloc] init];
        _gmsMap.delegate=self;
        [_gmsMap setMinZoom:2 maxZoom:30];
        _gmsMap.myLocationEnabled = YES;
    }
    return _gmsMap;
}


- (void)setLat:(CLLocationDegrees)lat{
    _lat = lat;
    if (_lat != 0 && _lng != 0) {
        //设置gmsMap
        _gmsMap.camera = [GMSCameraPosition cameraWithLatitude:_lat
                                                    longitude:_lng
                                                         zoom:16];
        //设置高德map
        [_gaodeMap setZoomLevel:16.1 animated:YES];
        _gaodeMap.centerCoordinate = CLLocationCoordinate2DMake(_lat, _lng);
    }
    
}

- (void)setLng:(CLLocationDegrees)lng{
    _lng = lng;
    if (_lat != 0 && _lng != 0) {
        //设置gmsMap
        _gmsMap.camera = [GMSCameraPosition cameraWithLatitude:_lat
                                                    longitude:_lng
                                                         zoom:16];
        //设置高德map
        [_gaodeMap setZoomLevel:16.1 animated:YES];
        _gaodeMap.centerCoordinate = CLLocationCoordinate2DMake(_lat, _lng);
    }
}
/**
 逆地理编码获取当前的位置和道路
 
 @param location 位置
 */
-(void)getCurrentLocationName:(CLLocationCoordinate2D)location block:(void(^)(NSString *house,NSString*road))resultBlock{
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.location =[AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    regeoRequest.requireExtension = YES;
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeoRequest];
    [self setGetRoadBlock:^(NSString *house, NSString *road) {
        if (resultBlock) {
            resultBlock(house,road);
        }
    }];
}
//逆编码查询代理
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        NSArray *tempArr = response.regeocode.roads;
//        NSLog(@"%@",[tempArr[0] name]);
        NSArray *tempArr1 = response.regeocode.pois;
//        NSLog(@"%@",[tempArr1[0] name]);
        if (self.getRoadBlock) {
            self.getRoadBlock([tempArr1[0] name], [tempArr[0] name]);
        }
    }
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    self.user_lat = userLocation.coordinate.latitude;
    self.user_lng = userLocation.coordinate.longitude;
}
/**
 * @brief 单击地图底图调用此接口
 * @param mapView    地图View
 * @param coordinate 点击位置经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if (self.XHDelegate) {
        [self.XHDelegate XHmapView:mapView didSingleTappedAtCoordinate:coordinate];
    }
}

//标注大头针会回调的方法
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        MAPointAnnotation *ann = (MAPointAnnotation *)annotation;
        NSString *imgStr = ann.imgStr;
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.image = [UIImage imageNamed:imgStr];
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        return annotationView;
    }
    return nil;
}

#pragma mark - GMSMapViewDelegate
- (void) mapView: (GMSMapView *)mapView didChangeCameraPosition: (GMSCameraPosition *)position{
    double latitude = mapView.camera.target.latitude;
    double longitude = mapView.camera.target.longitude;
    __weak typeof(self)weakself = self;
    CLLocationCoordinate2D addressCoordinates = CLLocationCoordinate2DMake(latitude,longitude);
    GMSGeocoder* coder = [[GMSGeocoder alloc] init];
    [coder reverseGeocodeCoordinate:addressCoordinates completionHandler:^(GMSReverseGeocodeResponse *results, NSError *error) {
        if (error) {
            
        } else {
            GMSAddress* address = [results firstResult];
            NSArray *arr = [address valueForKey:@"lines"];
            __block  NSString *addressStr;
            if ([arr count] == 0) {
                addressStr = @"";
            }else{
                NSString *str = [arr objectAtIndex:0];
                addressStr = str;
            }
            //回调中心点位置
            if (weakself.CenterPostion) {
                weakself.CenterPostion(addressCoordinates, addressStr);
            }
        }
    }];
}
- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView{
    //位置变动时回调
    if ([self.XHDelegate respondsToSelector:@selector(xhMapView:mapDidMoveByUser:)]) {
        [self.XHDelegate xhMapView:nil mapDidMoveByUser:YES];
    }
}

- (void)addAnnotation:(CLLocationCoordinate2D)point
                title:(NSString *)title
               imgStr:(NSString *)imgStr
             selected:(BOOL)selected{
    
    if ([XHMapKitManager shareManager].is_International) {
        //国际化客户
        CLLocationCoordinate2D position = point;
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = title;
        marker.map = _gmsMap;
        marker.icon = [UIImage imageNamed:imgStr];
        if (selected) {
            [_gmsMap setSelectedMarker:marker];
        }
        _gmsMap.camera = [GMSCameraPosition cameraWithLatitude:point.latitude
                                                     longitude:point.longitude
                                                          zoom:16];
    }else{
        //国内客户
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = point;
        annotation.title = title;
        annotation.imgStr = imgStr;
        [_gaodeMap addAnnotation:annotation];
        if (selected) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [_gaodeMap selectAnnotation:annotation animated:NO];
            });
        }
        [_gaodeMap setZoomLevel:16.1 animated:YES];
        _gaodeMap.centerCoordinate = point;
    }
}

- (void)setCenterWithCurrentLocation{
    
    if ([XHMapKitManager shareManager].is_International) {
        //国际化客户
        _gmsMap.camera = [GMSCameraPosition cameraWithLatitude:[XHMapKitManager shareManager].lat
                                                     longitude:[XHMapKitManager shareManager].lng
                                                          zoom:16];
    }else{
        //国内客户
        [_gaodeMap setCenterCoordinate:CLLocationCoordinate2DMake(self.user_lat, self.user_lng)];
    }
}

- (void)setCenterWithPoint:(CLLocationCoordinate2D)point{
    
    if ([XHMapKitManager shareManager].is_International) {
        //国际化客户
        _gmsMap.camera = [GMSCameraPosition cameraWithLatitude:point.latitude
                                                     longitude:point.longitude
                                                          zoom:16];
    }else{
        //国内客户
        [_gaodeMap setCenterCoordinate:point];
    }
}

#pragma mark - 改变配送员和商家之间的距离的
-(void)changeDistanceWithShopCoordinate:(CLLocationCoordinate2D)shopCoordinate
                          peiCoordinate:(CLLocationCoordinate2D)peiCoordinate{
    CLLocationCoordinate2D shop = [self changeBaiDuToGaodeWithBaidu:shopCoordinate];
    CLLocationCoordinate2D pei = [self changeBaiDuToGaodeWithBaidu:peiCoordinate];
    NSString *dis = [self getDistanceWithPoint1:shop point2:pei];
    NSString *sub = [NSString stringWithFormat:NSLocalizedString(@"距取货地还有%@", nil),dis];
    [self changePraviteWithPeiCoordinate:pei subT:sub mainT:NSLocalizedString(@"取货中...", nil)];
}

#pragma mark - 改变配送员和客户之间的距离的
-(void)changeDistanceWithCustomCoordinate:(CLLocationCoordinate2D)customCoordinate
                            peiCoordinate:(CLLocationCoordinate2D)peiCoordinate{
    CLLocationCoordinate2D custom = [self changeBaiDuToGaodeWithBaidu:customCoordinate];
    CLLocationCoordinate2D pei = [self changeBaiDuToGaodeWithBaidu:peiCoordinate];
    NSString *dis = [self getDistanceWithPoint1:custom point2:pei];
    NSString *sub = [NSString stringWithFormat:NSLocalizedString(@"距您还有%@", nil),dis];
    [self changePraviteWithPeiCoordinate:pei subT:sub mainT:NSLocalizedString(@"送货中...", nil)];
    
}
#pragma mark - 计算两点之间的距离的方法
-(NSString *)getDistanceWithPoint1:(CLLocationCoordinate2D)point1
                            point2:(CLLocationCoordinate2D)point2{
    NSString *str;
    CLLocation *current1 = [[CLLocation alloc]initWithLatitude:point1.latitude longitude:point1.longitude];
    CLLocation *current2 = [[CLLocation alloc]initWithLatitude:point2.latitude longitude:point2.longitude];
    CLLocationDistance meters = [current1 distanceFromLocation:current2];
    if (meters<1000) {
        str = [NSString stringWithFormat:@"%.1fm",meters];
    }else{
        float a = meters/1000.0;
        str = [NSString stringWithFormat:@"%.2fkm",a];
    }
    return str;
}

/**
 修改一些属性的方法
 
 @param peiCoordinate 大头针显示的经纬度
 @param subT 大头针子标题
 @param mainT 大头针主标题
 */
-(void)changePraviteWithPeiCoordinate:(CLLocationCoordinate2D)peiCoordinate
                                 subT:(NSString *)subT
                                mainT:(NSString *)mainT{
    if ([XHMapKitManager shareManager].is_International) {
        //国际客户
        [_gmsMap clear];
    }else{
        //国内客户
        [_gaodeMap removeAnnotations:_gaodeMap.annotations];
    }
    [self addAnnotation:peiCoordinate
                  title:subT imgStr:@"icon_qishou"
               selected:YES];
}

#pragma mark - 两点路径规划(以当前位置为起点)
- (void)createRouteSearchWithDestination_lat:(double)destination_lat
                             destination_lng:(double)destination_lng{
    if ([XHMapKitManager shareManager].is_International) {
        
        [self getGMSMapNaviPointsWithOrigin_lat:[XHMapKitManager shareManager].lat
                                     origin_lng:[XHMapKitManager shareManager].lng
                                destination_lat:destination_lat
                                destination_lng:destination_lng];
        
    }else{
        [self getGaodeMapNavPointsWithOrigin_lat:[XHMapKitManager shareManager].lat
                                      origin_lng:[XHMapKitManager shareManager].lng
                                 destination_lat:destination_lat
                                 destination_lng:destination_lng];
    }
}


#pragma mark - 两点路径规划(以特定位置为起点)
- (void)createRouteSearchWithOrigin_lat:(double)origin_lat
                             origin_lng:(double)origin_lng
                        destination_lat:(double)destination_lat
                        destination_lng:(double)destination_lng{
    
    if ([XHMapKitManager shareManager].is_International) {
        
        [self getGMSMapNaviPointsWithOrigin_lat:origin_lat
                                     origin_lng:origin_lng
                                destination_lat:destination_lat
                                destination_lng:destination_lng];
        
    }else{
        [self getGaodeMapNavPointsWithOrigin_lat:origin_lat
                                      origin_lng:origin_lng
                                 destination_lat:destination_lat
                                 destination_lng:destination_lng];
    }
}
//获取两点间路径规划的点
- (void)getNavPointWithOrigin_lat:(double)origin_lat
                       origin_lng:(double)origin_lng
                  destination_lat:(double)destination_lat
                  destination_lng:(double)destination_lng{
    
    if ([XHMapKitManager shareManager].is_International) {
        
        [self getGMSMapNaviPointsWithOrigin_lat:origin_lat
                                     origin_lng:origin_lng
                                destination_lat:destination_lat
                                destination_lng:destination_lng];
        
        
    }else{
        [self getGaodeMapNavPointsWithOrigin_lat:origin_lat
                                      origin_lng:origin_lng
                                 destination_lat:destination_lat
                                 destination_lng:destination_lng];
    }
}
#pragma mark - 三点路径规划
- (void)createRouteSearchWithPassingPoint_lat:(double)passingPoint_lat
                             passingPoint_lng:(double)passingPoint_lng
                              destination_lat:(double)destination_lat
                              destination_lng:(double)destination_lng{
    if ([XHMapKitManager shareManager].is_International) {
        [self getGMSMapNaviPointsWithOrigin_lat:[XHMapKitManager shareManager].lat
                                     origin_lng:[XHMapKitManager shareManager].lng
                                destination_lat:passingPoint_lat
                                destination_lng:passingPoint_lng];
        
        [self getGMSMapNaviPointsWithOrigin_lat:passingPoint_lat
                                     origin_lng:passingPoint_lng
                                destination_lat:destination_lat
                                destination_lng:destination_lng];
        
    }else{
        /******高德定位sdk,一次性定位******/
        amapLocationManager = [[AMapLocationManager alloc] init];
        [amapLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [amapLocationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            if (error) return ;
            if (regeocode){
                [self getGaodeMapNavPointsWithOrigin_lat:location.coordinate.latitude
                                              origin_lng:location.coordinate.longitude
                                         destination_lat:passingPoint_lat
                                         destination_lng:passingPoint_lng];
                
                
                [self getGaodeMapNavPointsWithOrigin_lat:passingPoint_lat
                                              origin_lng:passingPoint_lng
                                         destination_lat:destination_lat
                                         destination_lng:destination_lng];
                
            }else{
                
                
            }
        }];
    }
}
- (void)getGaodeMapNavPointsWithOrigin_lat:(double)origin_lat
                                origin_lng:(double)origin_lng
                           destination_lat:(double)destination_lat
                           destination_lng:(double)destination_lng{

    if (_search1 == nil) {
        _search1 = [[AMapSearchAPI alloc] init];
        _search1.delegate = self;
        request1 = [[AMapRidingRouteSearchRequest alloc] init];
        request1.origin = [AMapGeoPoint locationWithLatitude:origin_lat
                                                  longitude:origin_lng];
        request1.destination = [AMapGeoPoint locationWithLatitude:destination_lat
                                                       longitude:destination_lng];
        [_search1 AMapRidingRouteSearch:request1];
    }else{
        _search2 = [[AMapSearchAPI alloc] init];
        _search2.delegate = self;
        request2 = [[AMapRidingRouteSearchRequest alloc] init];
        request2.origin = [AMapGeoPoint locationWithLatitude:origin_lat
                                                   longitude:origin_lng];
        request2.destination = [AMapGeoPoint locationWithLatitude:destination_lat
                                                        longitude:destination_lng];
        [_search2 AMapRidingRouteSearch:request2];
    }
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
//    NSLog(@"%@",error.localizedDescription);
}
#pragma mark=====路径规划代理方法============
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    if(response.route == nil) return;
    NSMutableArray *latArr = @[].mutableCopy;
    NSMutableArray *lngArr = @[].mutableCopy;
    AMapPath *mapath = [response.route.paths firstObject];
    for(AMapStep *step in mapath.steps){
        for(NSString *polyline in [step.polyline componentsSeparatedByString:@";"]){
            NSString *lat = [[polyline componentsSeparatedByString:@","] lastObject];
            NSString *lng = [[polyline componentsSeparatedByString:@","] firstObject];
            [latArr addObject:lat];
            [lngArr addObject:lng];
        }
    }
    NSInteger count = latArr.count;
    CLLocationCoordinate2D commonPolylineCoords[count];
    for(int i = 0; i < latArr.count ; i ++){
        commonPolylineCoords[i].latitude = [latArr[i] floatValue];
        commonPolylineCoords[i].longitude = [lngArr[i] floatValue];
    }
    MAPolyline *_gaodePolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:latArr.count];
    [_gaodeMap addOverlay:_gaodePolyline];
}
#pragma mark======规划线路代理方法=======
    //- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay{
    //
    //    MAOverlayPathView *polylineView = [[MAOverlayPathView alloc] initWithOverlay:overlay];
    //    polylineView.lineWidth = 5.f;
    //    polylineView.strokeColor = HEX(@"ff6600", 1.0f);
    //    polylineView.lineJoin =   kCGLineJoinRound;//连接类型
    //    polylineView.lineCap = kCGLineCapButt;//端点类型
    //    return polylineView;
    //}
    /**
     * @brief 根据overlay生成对应的Renderer
     * @param mapView 地图View
     * @param overlay 指定的overlay
     * @return 生成的覆盖物Renderer
     */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithOverlay:overlay];
    polylineView.lineWidth = 5.f;
    polylineView.strokeColor = HEX(@"ff6600", 1.0f);
    polylineView.lineJoinType =   kCGLineJoinRound;//连接类型
    polylineView.lineCapType = kCGLineCapButt;//端点类型
    return polylineView;
    
}

#pragma mark - google路线规划
- (void)getGMSMapNaviPointsWithOrigin_lat:(double)origin_lat
                               origin_lng:(double)origin_lng
                          destination_lat:(double)destination_lat
                          destination_lng:(double)destination_lng{
    GMSMutablePath *path = [GMSMutablePath path];
    //添加起点
    [path addLatitude:[XHMapKitManager shareManager].lat
            longitude:[XHMapKitManager shareManager].lng];
    //设置起点为中心点
    _gmsMap.camera = [GMSCameraPosition cameraWithLatitude:[XHMapKitManager shareManager].lat
                                                 longitude:[XHMapKitManager shareManager].lng
                                                      zoom:14];
    NSString *url=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=%@",origin_lat,origin_lng,destination_lat,destination_lng,@"driving"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSOperationQueue *queue=[NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *subArr=dict[@"routes"];
        if (subArr.count==0) {
            return ;
        }
        NSDictionary *subDic=subArr[0];
        NSArray *pathArr=subDic[@"legs"];
        NSDictionary *pathDic=pathArr[0];
        NSArray *arr=pathDic[@"steps"];
        for (NSDictionary *locationDic in arr) {
            //添加中间点
            [path addLatitude:[locationDic[@"end_location"][@"lat"] doubleValue]
                    longitude:[locationDic[@"end_location"][@"lng"] doubleValue]];
        }
        //添加终点
        [path addLatitude:destination_lat longitude:destination_lng];
        //绘制路线
        GMSPolyline *gmsPolyline = [GMSPolyline polylineWithPath:path];
        gmsPolyline.strokeWidth =5;
        gmsPolyline.strokeColor = HEX(@"ff6600", 1.0f);
        gmsPolyline.map = _gmsMap;
    }];
}

#pragma mark - 将百度坐标转换为高德坐标
-(CLLocationCoordinate2D)changeBaiDuToGaodeWithBaidu:(CLLocationCoordinate2D)baidu{
    double gaode_lat;
    double gaode_lng;
    [XHCoordinateConvert transform_baidu_to_gaodeWithBD_lat:baidu.latitude WithBD_lon:baidu.longitude WithGD_lat:&gaode_lat WithGD_lon:&gaode_lng];
    return CLLocationCoordinate2DMake(gaode_lat, gaode_lng);
}
@end


