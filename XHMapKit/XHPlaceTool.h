//  地点工具-当前地理位置,周边搜索,关键字搜索
//  XHLocaitonTool.h
//  JHCommunityClient_V3
//
//  Created by xixixi on 2017/7/10.
//  Copyright © 2017年 xixixi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHLocationInfo.h"
#import <MapKit/MapKit.h>
@interface XHPlaceTool : NSObject

+ (instancetype)sharePlaceTool;

/**
 获取当前的位置
 
 @param success 成功的回调
 @param failure 失败的回调
 */
- (void)getCurrentPlaceWithSuccess:(void (^)(XHLocationInfo *model))success
                           failure:(void (^)(NSString *error))failure;

/**
 周边搜索(高德和 google)

 @param success 成功的回调
 @param failure 失败的回调
 */
- (void)aroundSearchWithSuccess:(void(^)(NSArray <XHLocationInfo *>*pois))success
                        failure:(void (^)(NSString *error))failure;

/**
 高德关键字搜索

 @param key 搜索的内容
 @param success 成功的回调
 @param failure 失败的回调
 */
- (void)keywordsSearchWithKeyString:(NSString *)key
                            success:(void(^)(NSArray <XHLocationInfo *>*pois))success
                            failure:(void (^)(NSString *error))failure;

/**
 发起google地图关键字搜索

 @param GmsPlaceSelectedSuccess 搜索成功后,点击某个地点的回调
 */
- (void)startGmsKeySearch:(void(^)(XHLocationInfo *model))GmsPlaceSelectedSuccess;

- (void)getLocationInfoWithInfo:(XHLocationInfo *)info withBlock:(void(^)(NSArray <XHLocationInfo *>*pois))success;

@end
