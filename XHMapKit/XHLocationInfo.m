//
//  XHLocationInfo.m
//  JHCommunityClient_V3
//
//  Created by xixixi on 2017/7/10.
//  Copyright © 2017年 xixixi. All rights reserved.
//

#import "XHLocationInfo.h"
#import "XHMapKitManager.h"
#import "XHCoordinateConvert.h"
@implementation XHLocationInfo

- (CLLocationCoordinate2D)bdCoordinate{
    double bdLat;
    double bdLng;
    [XHCoordinateConvert transform_gaode_to_baiduWithGD_lat:_coordinate.latitude
                                                 WithGD_lon:_coordinate.longitude
                                                 WithBD_lat:&bdLat
                                                 WithBD_lon:&bdLng];
    return CLLocationCoordinate2DMake(bdLat, bdLng);
}

- (NSString *)description{
    return [NSString stringWithFormat:@"当前坐标为{%f,%f,当前地址为:%@}",_coordinate.latitude,_coordinate.longitude,_name];
}

- (NSString *)address{
    if (_address.length == 0) {
        return [self.name stringByAppendingString:self.street];
    }else{
        return _address;
    }
}

@end
