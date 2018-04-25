//
//  HZQMapSearch.h
//  JHCommunityBiz
//
//  Created by ijianghu on 16/6/23.
//  Copyright © 2016年 com.jianghu. All rights reserved.
//

#import "JHBaseVC.h"
#import <CoreLocation/CoreLocation.h>
#import "XHLocationInfo.h"

@interface XHGaodePlacePickerVC : JHBaseVC

/**
 初始化高德选择器

 @param success 成功选择后的回调
 @return 返回的实例
 */
- (instancetype)initWithSelectePlace:(void(^)(XHLocationInfo *place))success;

/**
 首次进图地图时,展示的中心点
 为nil时,则展示当前设备的位置
 */
@property (nonatomic,assign)CLLocationCoordinate2D center;

@end
