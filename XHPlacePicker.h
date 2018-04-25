//  地点拾取
//  XHPlacePicker.h
//  JHCommunityClient_V3
//
//  Created by xixixi on 2017/7/10.
//  Copyright © 2017年 xixixi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHMapKitManager.h"
#import "XHGaodePlacePickerVC.h"
@interface XHPlacePicker : NSObject
/**
 进入地点选择时,展示的地点纬度
 */
@property (nonatomic,assign)double showLat;
/**
 进入地点选择时,展示的地点经度
 */
@property (nonatomic,assign)double showLng;

- (instancetype)initWithPlaceCallback:(void (^)(XHLocationInfo *place))block;
- (void)startPlacePicker;
@end
