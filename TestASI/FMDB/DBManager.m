//
//  DBManager.m
//  BaiKe
//
//  Created by yons on 13-8-6.
//  Copyright (c) 2013年 yons. All rights reserved.
//

#import "DBManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "StationInfoEntity.h"

@interface DBManager ()

@property (nonatomic, strong) FMDatabase *fmdb;

@end

@implementation DBManager

+(void)load {

    NSLog(@"====%@",[[DBManager share] getStationGroupList] );
}

+ (DBManager *)share {
    static DBManager *dbmanger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (dbmanger == nil) {
            dbmanger = [[DBManager alloc] init];
        }
    });
    return dbmanger;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initDB];
    }
    return self;
}

- (void)initDB {
    self.fmdb = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"ark_station_20150127" ofType:@"sqlite"]];
    [self.fmdb open];
    [self checkTable];
}

-(void)checkTable
{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS tbl_stationV3(stationId integer, \
    stationName varchar , pinYin varchar, shortPinYin varchar, teleCode varchar,cityName varchar);";
    [self.fmdb executeUpdate:sql];
}

//热门站点
- (NSString *)getHotStation {
    return @"'北京','上海','广州','深圳','杭州','苏州','南京','天津','成都','重庆','西安','郑州','长沙','武汉','南昌','青岛','济南','大连','沈阳','长春','哈尔滨','洛阳','兰州','合肥','太原','海口','南宁','福州','昆明','乌鲁木齐' ";
}

//车站名查站拼音
- (NSString *)getStationCodeWithStationName:(NSString *)name
{
    if (name.length <= 0) return name;
    NSString *sql = @"SELECT teleCode from tbl_stationV3 WHERE stationName = ? ";
    NSString *stationCode = [self.fmdb stringForQuery:sql, name];
    if (stationCode.length <= 0) stationCode = name;
    return stationCode;
}

//获取站点拼音
-(NSString *)getPingYinWithStationName:(NSString *)name
{
    if (name.length <= 0) return name;
    NSString *sql = @"SELECT pinYin from tbl_stationV3 WHERE stationName = ? ";
    NSString *rst = [self.fmdb stringForQuery:sql, name];
    if (rst.length <= 0) rst = name;
    return rst;
}

//获取列表首字母列表
-(NSMutableArray *)getStationGroupList
{
    NSMutableArray *arrayStation = [[NSMutableArray alloc] init];
    //数据查询
    NSMutableArray *pams = [[NSMutableArray alloc] init];
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    [sql appendString:@"SELECT count(*) as cnt, substr(pinYin,1,1) as grp FROM tbl_stationV3 where (teleCode <> '') group by substr(pinYin,1,1) order by 2"];
    
    FMResultSet *rs = [self.fmdb executeQuery:sql withArgumentsInArray:pams];
    
    //加入数据
    while ([rs next]) {
        StationInfoEntity *obj = [[StationInfoEntity alloc]init];
        obj.name = [rs stringForColumn:@"grp"];
        NSLog(@"%@",obj.name);
        obj.count = [rs intForColumn:@"cnt"];
        [self setStationInfo:obj];
        [arrayStation addObject:obj];
    }
    [rs close];
    
    return arrayStation;
}

//得到热门城市
-(NSMutableArray *)getHotStationList
{
    NSString *stn = [self getHotStation];
    NSMutableArray *lst = [[NSMutableArray alloc] init];
    if ([stn length] > 0){
        NSMutableArray *pams = [[NSMutableArray alloc] init];
        NSMutableString *sql = [[NSMutableString alloc] init];
        
        [sql appendFormat:@"SELECT * from tbl_stationV3 where stationName in (%@) and teleCode <> '' ", stn];
        
        FMResultSet *rs = [self.fmdb executeQuery:sql withArgumentsInArray:pams];
        
        //加入数据
        while ([rs next]) {
            StationItemInfoEntity *obj = [[StationItemInfoEntity alloc]init];
            obj.stationName = [rs stringForColumn:@"stationName"];
            obj.shortPinYin = [rs stringForColumn:@"shortPinYin"];
            obj.pinYin = [rs stringForColumn:@"pinYin"];
            obj.teleCode = [rs stringForColumn:@"teleCode"];
            obj.cityName = [rs stringForColumn:@"cityName"];
            [lst addObject:obj];
        }
        [rs close];
    }
    return lst;
}

//加载明细数据
-(void)setStationInfo:(StationInfoEntity *)group
{
    if (!group.stationInfo) group.stationInfo = [NSMutableArray array];
    
    //有数据，直接返回
    if ([group.stationInfo count] > 0) return;
    
    
    NSMutableArray *pams = [[NSMutableArray alloc] init];
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    [sql appendString:@"SELECT * from tbl_stationV3 WHERE shortPinYin like ? and teleCode <> '' "];
    [pams addObject:[NSString stringWithFormat:@"%@%%", group.name]];
    
    
    [sql appendString:@"order by shortPinYin desc"];
    FMResultSet *rs = [self.fmdb executeQuery:sql withArgumentsInArray:pams];
    
    //加入数据
    while ([rs next]) {
        StationItemInfoEntity *obj = [[StationItemInfoEntity alloc]init];
        obj.stationName = [rs stringForColumn:@"stationName"];
        obj.shortPinYin = [rs stringForColumn:@"shortPinYin"];
        obj.pinYin = [rs stringForColumn:@"pinYin"];
        obj.teleCode = [rs stringForColumn:@"teleCode"];
        obj.cityName = [rs stringForColumn:@"cityName"];
        [group.stationInfo addObject:obj];
    }
    [rs close];
}
@end
