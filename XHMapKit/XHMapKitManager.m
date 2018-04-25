
//
//  XHMapKitManager.m
//  JHCommunityClient_V3
//
//  Created by xixixi on 2017/7/10.
//  Copyright © 2017年 xixixi. All rights reserved.
//

#import "XHMapKitManager.h"
#import "XHPlaceTool.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@implementation XHMapKitManager
static XHMapKitManager *_instance = nil;
+ (instancetype)shareManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[XHMapKitManager alloc] init];
        //监听window的变化
        [[NSNotificationCenter defaultCenter] addObserver:_instance selector:@selector(windowChange) name:UIWindowDidBecomeVisibleNotification object:nil];
    });
    return _instance;
}

- (void)setGaodeKey:(NSString *)gaodeKey{
    [AMapLocationServices sharedServices].apiKey = gaodeKey;
    [AMapServices sharedServices].apiKey = gaodeKey;
    [XHMapKitManager shareManager].is_International = NO;
}

- (void)setGmsMapKey:(NSString *)gmsMapKey{
    [GMSServices provideAPIKey:gmsMapKey];
    [GMSPlacesClient provideAPIKey:gmsMapKey];
    [XHMapKitManager shareManager].is_International = YES;
}

- (NSString *)currentCity{
    return _currentCity?_currentCity:@"北京";
}

- (void)windowChange{
    if ([UIApplication sharedApplication].windows.count > 1) {
        // 从后往前获取UIWindow，windows中应该有排序（猜测）
        for (NSInteger i= [UIApplication sharedApplication].windows.count-1; i>0; i--) {
            
            if ([[UIApplication sharedApplication].windows[i] isMemberOfClass:[UIWindow class]]) {// 可能是键盘的window等
                id vc = [[UIApplication sharedApplication].windows[i] rootViewController];
                if([vc isKindOfClass:[UINavigationController class]]){
                    // 修改谷歌地图控制器的导航栏
                    UINavigationController *nav = (UINavigationController *)vc;
                    [nav.navigationBar setBackgroundImage:[self imageWithColor:self.theme_color] forBarMetrics: UIBarMetricsDefault];
                    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:FONT(18)}];
                    nav.navigationBar.shadowImage = [[UIImage alloc] init];
                    break;
                }
            }
        }
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

