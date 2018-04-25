//
//  GaoDe_To_BaiDu.h
//  JHCommunityClient
//
//  Created by xixixi on 16/3/24.
//  Copyright © 2016年 JiangHu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHCoordinateConvert : NSObject

/**
 *  高德坐标转换为百度坐标
 *
 *  @param gd_lat 高德坐标 lat
 *  @param gd_lon 高德坐标 lon
 *  @param bd_lat 百度坐标 lat
 *  @param bd_lon 百度坐标 lon
 */
+(void)transform_gaode_to_baiduWithGD_lat:(double)gd_lat
                               WithGD_lon:(double)gd_lon
                               WithBD_lat:(double *)bd_lat
                               WithBD_lon:(double *)bd_lon;
/**
 *  百度坐标转换为高德坐标
 *
 *  @param bd_lat 百度坐标 lat
 *  @param bd_lon 百度坐标 lon
 *  @param gd_lat 高德坐标 lat
 *  @param gd_lon 高德坐标 lon
 */
+(void)transform_baidu_to_gaodeWithBD_lat:(double)bd_lat
                               WithBD_lon:(double)bd_lon
                               WithGD_lat:(double *)gd_lat
                               WithGD_lon:(double *)gd_lon;
@end
