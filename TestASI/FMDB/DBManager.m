//
//  DBManager.m
//  BaiKe
//
//  Created by yons on 13-8-6.
//  Copyright (c) 2013年 yons. All rights reserved.
//

#import "DBManager.h"
#import "FMDatabase.h"

@interface DBManager ()

@property (nonatomic, strong) FMDatabase *fmdb;

@end

@implementation DBManager

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
    [self checkTable];
}

-(void)checkTable
{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS tbl_stationV3(stationId integer, \
    stationName varchar , pinYin varchar, shortPinYin varchar, teleCode varchar,cityName varchar);";
    [self.fmdb executeUpdate:sql];
}

//获取列表数据
-(NSMutableArray *)getStationGroup:(NSString *)filter
{
    NSMutableArray *rst = [[NSMutableArray alloc] init];
    //数据查询
    NSMutableArray *pams = [[NSMutableArray alloc] init];
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    [sql appendString:@"SELECT count(*) as cnt, substr(pinYin,1,1) as grp FROM tbl_stationV3 where (teleCode <> '') "];
    
//    //检测筛选
//    [self adjustSQLFilter:sql filter:filter pams:pams fix:@"AND"];
//    
//    [sql appendString:@"group by substr(pinYin,1,1) order by 2"];
//    FMResultSet *rs = [self.dbInfo executeQuery:sql withArgumentsInArray:pams];
//    
//    
//    //加入数据
//    while ([rs next]) {
//        StationInfoEntity *obj = [[StationInfoEntity alloc]init];
//        obj.name = [rs stringForColumn:@"grp"];
//        obj.count = [rs intForColumn:@"cnt"];
//        [rst addObject:obj];
//    }
//    [rs close];
    
    return rst;
}

//车站名查站拼音
- (NSString *)teleCodeWithStationName:(NSString *)name
{
    if (name.length <= 0) return name;
    
//    NSString *sql = @"SELECT teleCode from tbl_stationV3 WHERE stationName = ? ";
//    NSString *rst = [self.fmdb stringForQuery:sql, name];
//    if (rst.length <= 0) rst = name;
    return @"";
}



-(NSArray *)quaryKeywordAndDescription{
    NSMutableArray *array = [NSMutableArray array];
  FMDatabase *db = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"ark_station_20150127" ofType:@"sqlite"]];
    //    db= [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM keyword"];
    rs = [db executeQuery:@"SELECT * FROM keyword"];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    [rs close];
    return array;
}
-(NSArray *)quaryQuestionAndDescription{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"DB" ofType:@"sqlite"]];
    //    db= [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM question"];
    rs = [db executeQuery:@"SELECT * FROM question"];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    [rs close];
    return array;
}
-(NSArray *)quaryCompanyAndDescription{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"DB" ofType:@"sqlite"]];
    //    db= [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM company"];
    rs = [db executeQuery:@"SELECT * FROM company"];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    [rs close];
    return array;
}
-(NSArray *)quaryMessageByKeyWords:(NSString *)keyword{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[[NSBundle mainBundle]pathForResource:@"DB" ofType:@"sqlite"]];
    //    db= [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM company"];
    NSString *str =[NSString stringWithFormat:@"SELECT * FROM keyword WHERE title LIKE  '%@%@%@'",@"%", keyword, @"%"];
    rs = [db executeQuery:str];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    
    str = [NSString stringWithFormat:@"SELECT * FROM company WHERE title LIKE  '%@%@%@'",@"%", keyword, @"%"];
    rs = [db executeQuery:str];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    
    str = [NSString stringWithFormat:@"SELECT * FROM question WHERE title LIKE  '%@%@%@'",@"%", keyword, @"%"];
    rs = [db executeQuery:str];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    
    str = [NSString stringWithFormat:@"SELECT * FROM keyword WHERE content LIKE  '%@%@%@'",@"%", keyword, @"%"];
    rs = [db executeQuery:str];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    
    str=[NSString stringWithFormat:@"SELECT * FROM keyword WHERE content LIKE  '%@%@%@'",@"%", keyword, @"%"];
    rs = [db executeQuery:str];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    
    str = [NSString stringWithFormat:@"SELECT * FROM question WHERE content LIKE  '%@%@%@'",@"%", keyword, @"%"];
    rs = [db executeQuery:str];
    while ([rs next]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[rs stringForColumn:@"ID"] forKey:@"ID"];
        [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
        [dic setValue:[rs stringForColumn:@"content"] forKey:@"content"];
        [array addObject:dic];
        NSLog(@"%@ %@", [dic objectForKey:@"ID"], [rs stringForColumn:@"title"]);
    }
    [rs close];
    return array;
}

@end
