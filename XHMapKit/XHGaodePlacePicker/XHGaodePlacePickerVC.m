//
//  HZQMapSearch.m
//  JHCommunityBiz
//
//  Created by ijianghu on 16/6/23.
//  Copyright © 2016年 com.jianghu. All rights reserved.
//

#import "XHGaodePlacePickerVC.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "XHLocationInfo.h"
#import "XHMapKitManager.h"
@interface XHGaodePlacePickerVC ()<MAMapViewDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITextField * searchTextField;//搜索框
    UIButton * rightItem;//右边的取消按钮
    MAMapView * _mapView;//地图
    AMapSearchAPI * _search;//周边搜索需要的
    BOOL isRoundSearch;//是否是周边搜索
    BOOL isFirst; //是否是第一次加载地图
    NSMutableArray * aroundInfoArray;//周边搜索存放model的数组
    NSMutableArray * keyInfoArray;//关键字搜索存放model的数组
    UITableView * aroundTableView;//周边搜索的结果表
    UITableView * keyTableView;//关键字搜索的结果表
    void(^selecteSuccess)(XHLocationInfo *place);
}
@end

@implementation XHGaodePlacePickerVC

- (instancetype)initWithSelectePlace:(void (^)(XHLocationInfo *))success{
    self = [super init];
    if (self) {
        selecteSuccess = success;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化一些数据的方法
    [self initData];
    //创建地图
    [self creatMapView];
    //创建地图下方的表
    [self creatAroundTableView];
    SHOW_HUD
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
#pragma mark - 初始化一些数据的方法
-(void)initData{
    [self creatUISearch];
    aroundInfoArray = @[].mutableCopy;
    keyInfoArray = @[].mutableCopy;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //在导航上添加子视图(搜索框和取消的按钮)
    rightItem = [[UIButton alloc]init];
    rightItem.frame = FRAME(0, 0, 32, 30);
    rightItem.titleLabel.font = FONT(15);
    [rightItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightItem addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:rightItem];
    self.navigationItem.rightBarButtonItem = item;
    //检测文本框发生文本发生改变的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:searchTextField];
    
}
#pragma mark - 创建搜索框
-(void)creatUISearch{
    if (searchTextField == nil) {
        searchTextField = [[UITextField alloc]init];
        searchTextField.frame = FRAME(47, 28, WIDTH - 100, 27);
        searchTextField.layer.cornerRadius = 3;
        searchTextField.clipsToBounds = YES;
        searchTextField.delegate = self;
        UILabel *lab = [[UILabel alloc]init];
        lab.frame = FRAME(0,0,15, 27);
        searchTextField.leftViewMode = UITextFieldViewModeAlways;
        searchTextField.leftView = lab;
        searchTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        searchTextField.placeholder = NSLocalizedString(@"请输入搜索地点", nil);
        [searchTextField setValue:[UIColor colorWithWhite:1.0 alpha:0.9] forKeyPath:@"_placeholderLabel.textColor"];
        [searchTextField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        searchTextField.font = [UIFont systemFontOfSize:15];
        self.navigationItem.titleView = searchTextField;
    }
}
#pragma mark - 这是返回的方法
-(void)clickToBack{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 这是取消搜索的方法
-(void)clickCancel{
    if ([rightItem.titleLabel.text isEqualToString:NSLocalizedString(@"取消", nil)]) {
        searchTextField.text = nil;
        [self.navigationController.view endEditing:YES];
        [keyInfoArray removeAllObjects];
        [keyTableView removeFromSuperview];
        keyTableView = nil;
        [rightItem setTitle:@"" forState:UIControlStateNormal];
    }
}
#pragma mark - 创建周边搜索的表
-(void)creatAroundTableView{
    aroundTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, (HEIGHT - NAVI_HEIGHT)/2+NAVI_HEIGHT-1, WIDTH, (HEIGHT - NAVI_HEIGHT)/2+1) style:UITableViewStylePlain];
    aroundTableView.delegate = self;
    aroundTableView.dataSource = self;
    aroundTableView.tag = 10;
    [self.view addSubview:aroundTableView];
    aroundTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    aroundTableView.tableFooterView = [UIView new];
    
}
#pragma mark - 创建关键字搜索的表
-(void)creatKeyTableView{
    if (keyTableView == nil) {
        keyTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVI_HEIGHT, WIDTH, HEIGHT-NAVI_HEIGHT) style:UITableViewStylePlain];
        keyTableView.delegate = self;
        keyTableView.dataSource = self;
        keyTableView.tag = 20;
        keyTableView.tableFooterView = [UIView new];
        keyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:keyTableView];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
#pragma mark - 这是表的数据源方法和代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 10) {
        return aroundInfoArray.count;
    }else{
        return keyInfoArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XHLocationInfo *model;
    if (tableView.tag == 10) {
        static NSString * identifier = @"cell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            UIView *line = [[UIView alloc]init];
            line.backgroundColor = LINE_COLOR;
            [cell addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.offset = 0;
                make.height.offset = 0.5;
            }];
        }
        model = aroundInfoArray[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"XHAddress"];
        cell.textLabel.text = model.name;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.text = model.street;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString * iden = @"cell1";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:iden];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
            UIView *line = [[UIView alloc]init];
            line.backgroundColor = LINE_COLOR;
            [cell addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.offset = 0;
                make.height.offset = 0.5;
            }];
        }
        model = keyInfoArray[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"XHAddress"];
        cell.textLabel.text = model.name;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.text = model.street;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XHLocationInfo * model;
    if (tableView.tag == 10) {
        model = aroundInfoArray[indexPath.row];
    }else{
        model = keyInfoArray[indexPath.row];
    }
    if (selecteSuccess) {
        selecteSuccess(model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 创建地图
-(void)creatMapView{
    _mapView = [[MAMapView alloc]initWithFrame:FRAME(0, NAVI_HEIGHT, WIDTH, (HEIGHT - NAVI_HEIGHT)/2)];
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    _mapView.delegate = self;
    [_mapView setZoomEnabled:YES];
    [_mapView setZoomLevel:16.1 animated:YES];
    _mapView.showsUserLocation = YES;
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    [self.view addSubview:_mapView];
    UIImageView * imageView = [[UIImageView alloc]init];
    imageView.bounds = FRAME(0, 0, 25, 30);
    imageView.center = CGPointMake(_mapView.center.x, _mapView.center.y - 15);
    imageView.image = [UIImage imageNamed:@"XHDatouzhen"];
    [self.view addSubview:imageView];
}
#pragma mark - 这是当前的位置改变的时候会调用的方法
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (userLocation) {
//        NSLog(@"当前位置的坐标%f===%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        if (!isFirst&&_center.latitude == 0) {
            [self creatSearchWithlatiude:mapView.centerCoordinate.latitude withLongitude:mapView.centerCoordinate.longitude];
            
            isFirst = YES;
        }else if (!isFirst&&_center.latitude != 0){
            [mapView setCenterCoordinate:_center animated:YES];
            [self creatSearchWithlatiude:_center.latitude
                           withLongitude:_center.longitude];
            isFirst = YES;
        }
    }
}
#pragma mark - 拖动时一直打印中间的位置
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self creatSearchWithlatiude:mapView.centerCoordinate.latitude withLongitude:mapView.centerCoordinate.longitude];
}
#pragma mark - 添加周边搜索的服务
-(void)creatSearchWithlatiude:(float)lat withLongitude:(float)log{
    isRoundSearch = YES;
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    AMapPOIAroundSearchRequest * request = [[AMapPOIAroundSearchRequest alloc]init];
    request.location = [AMapGeoPoint locationWithLatitude:lat longitude:log];
    request.types = @"餐饮服务|购物服务|生活服务|住宿服务|商务住宅|公司企业";
    request.sortrule = 0;
    request.requireExtension = YES;
    request.radius = 50000;
    //发起周边搜索
    [_search AMapPOIAroundSearch: request];
}
#pragma mark - 添加关键字搜索
-(void)creatKeyWordSearch{
    isRoundSearch = NO;
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    AMapPOIKeywordsSearchRequest * request = [[AMapPOIKeywordsSearchRequest alloc]init];
    request.keywords = searchTextField.text;
    request.city = [XHMapKitManager shareManager].currentCity;
    request.sortrule = 0;
    request.requireExtension = YES;
    //发起关键字搜索
    [_search AMapPOIKeywordsSearch: request];
}
//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
//        NSLog(@"没有搜到结果哦亲");
        //return;
    }
    if (isRoundSearch) {
        [aroundInfoArray removeAllObjects];
    }else{
        [keyInfoArray removeAllObjects];
    }
    for (AMapPOI * poi in response.pois) {
        XHLocationInfo *model = [XHLocationInfo new];
        model.address = @"";
        model.name = poi.name;
        model.street = poi.address;
        model.city = poi.city;
        model.district = poi.district;
        model.province = poi.province;
        model.postalCode = poi.pcode;
        model.cityCode = poi.citycode;
        model.country = @"";
        model.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        
        if (isRoundSearch) {
            [aroundInfoArray addObject:model];
        }else{
            [keyInfoArray addObject:model];
        }
        
    }
    if (isRoundSearch) {
        HIDE_HUD
        [aroundTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [keyTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma mark - 这是文本框的代理fangfa
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    searchTextField.text = nil;
    [self.navigationController.view endEditing:YES];
    [keyInfoArray removeAllObjects];
    [keyTableView removeFromSuperview];
    keyTableView = nil;
    [rightItem setTitle:@"" forState:UIControlStateNormal];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [rightItem setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [self creatKeyTableView];
}
//滚动视图的代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.tag == 20){
        CGFloat offset_y = scrollView.contentOffset.y;
        if (offset_y > 0) {
            //搜索文本框放弃第一响应
            [searchTextField resignFirstResponder];
        }
    }
}
-(void)textFieldTextDidChangeOneCI:(NSNotification *)not{
    [self creatKeyWordSearch];
}
@end
