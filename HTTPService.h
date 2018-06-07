//
//  HTTPService.h
//  BWStarry
//
//  Created by 尹晓腾 on 2018/4/24.
//  Copyright © 2018年 BW. All rights reserved.
//

#import <Foundation/Foundation.h>

// 定义一个用于网络回传的Block类型
typedef void(^HTTPServicePass)(id,BOOL);

@interface HTTPService : NSObject

// 使用GET方式请求网络数据
-(void)GET:(NSString *)urlStr params:(NSDictionary *)paramDic completion:(HTTPServicePass)pass;
// 使用POST方式请求网络数据
-(void)POST:(NSString *)urlStr params:(NSDictionary *)paramDic completion:(HTTPServicePass)pass;




@end
