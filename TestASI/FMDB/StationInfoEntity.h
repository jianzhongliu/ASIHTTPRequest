//
//  StationInfoEnitty.h
//  ticket99
//
//  Created by Ctrip-zxl on 14-11-12.
//  Copyright (c) 2014年 xuzhq. All rights reserved.
//

/*
   数据3.0 站点信息
 
 */

@interface StationInfoEntity : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) NSMutableArray *stationInfo;
@end


@interface StationItemInfoEntity : NSObject
@property(nonatomic, assign) NSInteger stationId;
@property(nonatomic, strong) NSString *stationName;
@property(nonatomic, strong) NSString *pinYin;
@property(nonatomic, strong) NSString *shortPinYin;
@property(nonatomic, strong) NSString *teleCode;
@property(nonatomic, strong) NSString *cityName;



@end
