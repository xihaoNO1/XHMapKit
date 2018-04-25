//
//  XHPlacePicker.m
//  JHCommunityClient_V3
//
//  Created by xixixi on 2017/7/10.
//  Copyright © 2017年 xixixi. All rights reserved.
//

#import "XHPlacePicker.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
@implementation XHPlacePicker
{
    void (^placeCallback)(XHLocationInfo *model);
    GMSPlacesClient *_placesClient;
    GMSPlacePicker *_placePicker;
    __weak typeof(XHPlacePicker *)weakself;
}
- (instancetype)initWithPlaceCallback:(void (^)(XHLocationInfo *place))block{
    self = [super init];
    if (self) {
        weakself = self;
        placeCallback = block;
    }
    return self;
}

- (void)startPlacePicker{
    //跳转到谷歌地点拾取
    if ([XHMapKitManager shareManager].is_International) {
        if (self.showLat == 0.0) {
            [self gmsPlacePickerWithCenter:CLLocationCoordinate2DMake([XHMapKitManager shareManager].lat, [XHMapKitManager shareManager].lng)];
            
        }else{
             [self gmsPlacePickerWithCenter:CLLocationCoordinate2DMake(self.showLat,self.showLng)]; 
        }
    }else{
        //高德地点拾取
        XHGaodePlacePickerVC *gaodeVC = [[XHGaodePlacePickerVC alloc] initWithSelectePlace:^(XHLocationInfo *place) {
            if (place) {
                [weakself selectePlace:place];
            }
        }];
        gaodeVC.center = CLLocationCoordinate2DMake(self.showLat, self.showLng);
        [(UINavigationController *)[[self getCurrentVC] navigationController] pushViewController:gaodeVC  animated:YES];
    }
}

#pragma mark - gmsPlacePicker
- (void)gmsPlacePickerWithCenter:(CLLocationCoordinate2D)gmsCoordinate{
    
    CLLocationCoordinate2D center = gmsCoordinate;
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        GMSPlace *poi = place;
        XHLocationInfo *model = [XHLocationInfo new];
        model.address = poi.formattedAddress;
        model.name = poi.name;
        model.street = @"";
        model.city = @"";
        model.district = @"";
        model.province = @"";
        model.postalCode = @"";
        model.cityCode = @"";
        model.country = @"";
        model.coordinate = poi.coordinate;
        [weakself selectePlace:model];
    }];
}
- (void)selectePlace:(XHLocationInfo *)model{

    if (placeCallback) {
        placeCallback(model);
    }
}

#pragma mark - 获取当前显示的控制器
//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

@end
