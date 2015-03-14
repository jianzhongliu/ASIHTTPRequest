//
//  TicketObject.h
//  TestASI
//
//  Created by liujianzhong on 15/3/14.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketObject : NSObject
@property (nonatomic, copy) NSString *train_no ;
@property (nonatomic, copy) NSString *station_train_code ;
@property (nonatomic, copy) NSString *start_station_telecode ;
@property (nonatomic, copy) NSString *start_station_name ;
@property (nonatomic, copy) NSString *end_station_telecode ;//VNP
@property (nonatomic, copy) NSString *end_station_name ;//北京南
@property (nonatomic, copy) NSString *from_station_telecode ;
@property (nonatomic, copy) NSString *from_station_name ;
@property (nonatomic, copy) NSString *to_station_telecode ;
@property (nonatomic, copy) NSString *to_station_name ;
@property (nonatomic, copy) NSString *start_time ;
@property (nonatomic, copy) NSString *arrive_time ;
@property (nonatomic, copy) NSString *day_difference ;
@property (nonatomic, copy) NSString *train_class_name ;
@property (nonatomic, copy) NSString *lishi ;
@property (nonatomic, copy) NSString *canWebBuy ;
@property (nonatomic, copy) NSString *lishiValue ;
@property (nonatomic, copy) NSString *yp_info ;
@property (nonatomic, copy) NSString *control_train_day ;
@property (nonatomic, copy) NSString *start_train_date ;
@property (nonatomic, copy) NSString *seat_feature ;
@property (nonatomic, copy) NSString *yp_ex ;
@property (nonatomic, copy) NSString *train_seat_feature ;
@property (nonatomic, copy) NSString *seat_types ;
@property (nonatomic, copy) NSString *location_code ;
@property (nonatomic, copy) NSString *from_station_no ;
@property (nonatomic, copy) NSString *to_station_no ;
@property (nonatomic, copy) NSString *control_day ;
@property (nonatomic, copy) NSString *sale_time ;
@property (nonatomic, copy) NSString *is_support_card ;
@property (nonatomic, copy) NSString *note ;
@property (nonatomic, copy) NSString *gg_num ;
@property (nonatomic, copy) NSString *gr_num ;
@property (nonatomic, copy) NSString *qt_num ;
@property (nonatomic, copy) NSString *rw_num ;
@property (nonatomic, copy) NSString *rz_num ;
@property (nonatomic, copy) NSString *tz_num ;
@property (nonatomic, copy) NSString *wz_num ;
@property (nonatomic, copy) NSString *yb_num ;
@property (nonatomic, copy) NSString *yw_num ;
@property (nonatomic, copy) NSString *yz_num ;
@property (nonatomic, copy) NSString *ze_num ;
@property (nonatomic, copy) NSString *zy_num ;
@property (nonatomic, copy) NSString *swz_num ;

@end
