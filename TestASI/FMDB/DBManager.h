//
//  DBManager.h
//  BaiKe
//
//  Created by yons on 13-8-6.
//  Copyright (c) 2013年 yons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

-(NSArray *)quaryKeywordAndDescription;
-(NSArray *)quaryQuestionAndDescription;
-(NSArray *)quaryCompanyAndDescription;
-(NSArray *)quaryMessageByKeyWords:(NSString *)keyword;

@end
