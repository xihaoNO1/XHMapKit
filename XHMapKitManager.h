//  地图配置
//  XHMapKitManager.h
//  JHCommunityClient_V3
//
//  Created by xixixi on 2017/7/10.
//  Copyright © 2017年 xixixi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHMapKitManager : NSObject

+ (instancetype)shareManager;

//当yes时,表示需要国际化,使用google地图;当no时,使用高德地图
@property(nonatomic,assign)BOOL is_International;
//高德地图相应的key
@property (nonatomic,copy)NSString *gaodeKey;
//定位当前或者选择城市后的城市名称
@property(nonatomic,copy)NSString *currentCity;

//googleMapKey
@property(nonatomic,copy)NSString *gmsMapKey;


/**
 当前位置坐标 纬度
 */
@property(nonatomic,assign)double lat;

/**
 当前位置坐标 经度
 */
@property(nonatomic,assign)double lng;

/**
 进入google选择器时,主题色(hex)
 */
@property (nonatomic,strong)UIColor *theme_color;

@end
