//
//  DBManager.h
//  BaiKe
//
//  Created by yons on 13-8-6.
//  Copyright (c) 2013年 yons. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StationInfoEntity;

@interface DBManager : NSObject

+ (DBManager *)share;

//得到热门城市
-(NSMutableArray *)getHotStationList;

//获取列表按照首字母排序列表
-(NSMutableArray *)getStationGroupList;

//车站名查站拼音
- (NSString *)getStationCodeWithStationName:(NSString *)name;

//获取站点拼音
-(NSString *)getPingYinWithStationName:(NSString *)name;

@end
