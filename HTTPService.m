//
//  HTTPService.m
//  BWStarry
//
//  Created by 尹晓腾 on 2018/4/24.
//  Copyright © 2018年 BW. All rights reserved.
//

#import "HTTPService.h"
#import "AppDelegate.h"
#import "UIView+ShowAlert.h"
#import "Reachability.h"

// 整个应用程序代理的宏
#define APP_Delegate (AppDelegate *)[UIApplication sharedApplication].delegate

@implementation HTTPService

#pragma mark ----- 私有方法 --------
// 判断有没有网络连接
-(BOOL)isConnectNetWork {
    // 判断网络状态，如果没有网络，给客户提示，退出方法调用
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable && [Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable) {
        [[APP_Delegate window] showMBHudWithMessage:@"网络连接失败，请检查您的网络设置" hide:3.0];
        return NO;
    }
    return YES;
}




#pragma mark ----- 对外的接口 --------

// 使用GET方式请求网络数据
-(void)GET:(NSString *)urlStr params:(NSDictionary *)paramDic completion:(HTTPServicePass)pass {
    
    // 网络连接判断
    if (![self isConnectNetWork]) {
        return;
    }
    
    // 指示器开始转动
    [[APP_Delegate window] showMBProgressHUD];
    
    // (1) 做一个字符串，将网址字符串作为初始值
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:urlStr];
    
    // （2）如果参数字典不为空，将所有参数拼接到网址字符串上
    if ( paramDic != nil &&  paramDic.count != 0) {
        [urlString appendString:@"?"];
        
        // 遍历参数字典，将参数拼接到网址字符串上
        for (NSString *key in paramDic) {
            [urlString appendFormat:@"%@=%@&",key,paramDic[key]];
        }
        // 把最后一个&去掉
        [urlString deleteCharactersInRange:NSMakeRange(urlString.length -1, 1)];
    }
    
    // （3）对带汉字的网址字符串做处理，这个方法只对带汉字的字符串做编码，如果字符串本身都是英文字符，此方法不会做任何处理
    urlString = [[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]] mutableCopy];
    
    // （4）封装为NSURL对象
    NSURL *url = [NSURL URLWithString:urlString];
    
    // （5）封装为请求对象
    NSURLRequest *req  = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    // （6)请求服务器数据
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 停止菊花转动
        dispatch_async(dispatch_get_main_queue(), ^{
            [[APP_Delegate window] hideMBProgressHUD];
        });
        
        // 如果服务器连接失败，给客户提示
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APP_Delegate window] showMBHudWithMessage:@"服务器错误！" hide:2.0];
            });
            return ;
        }
        
        // json解析数据
        NSError *jsonError = nil;
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if (jsonError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APP_Delegate window] showMBHudWithMessage:@"网络数据错误" hide:2.0];
            });
            return;
        }
        // 调用block类型的参数，实际上做了一个block函数的调用，将数据回传给URLService对象
        pass(obj,YES);
    }] resume];
}

// 使用POST方式请求网络数据
-(void)POST:(NSString *)urlStr params:(NSDictionary *)paramDic completion:(HTTPServicePass)pass {
    
    // 网络连接判断
    if (![self isConnectNetWork]) {
        return;
    }
    
    
    // 等待指示器开始转动
    [[APP_Delegate window] showMBProgressHUD];
    
    
    // （1） 将网址字符串做成URL对象
    NSURL *url = [NSURL URLWithString:urlStr];
    // (2) 实例化请求对象
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url  cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    // （3）设置请求方式为POST请求
    [req setHTTPMethod:@"POST"];
    // （4）将请求参数做成一个字符串
    if (paramDic != nil && paramDic.count != 0) {
        
        NSMutableString *paramStr = [[NSMutableString alloc] init];
        
        for (NSString *key in paramDic) {  //
            [paramStr appendFormat:@"%@=%@&",key,paramDic[key]];
        }
        
        [paramStr deleteCharactersInRange:NSMakeRange(paramStr.length-1, 1)];
        
        // （5）将参数字符串转换为二进制数据
        NSData *paramData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
        // (6)将请求参数添加到请求对象的请求体中
        [req setHTTPBody:paramData];
    }


    // （7）实例化会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    // （8）请求网络会话，得到一个网络数据获取任务对象
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 隐藏转动的菊花
        dispatch_async(dispatch_get_main_queue(), ^{
            [[APP_Delegate window] hideMBProgressHUD];
        });
        
        
        // 判断服务器错误
        if (error != nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APP_Delegate window] showMBHudWithMessage:@"服务器错误！" hide:2.0];
            });
            
            return ;
        }
        
        
        
        NSError *jsonError = nil;
        // 服务器返回数据所做的回调代码
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if (jsonError != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APP_Delegate window] showMBHudWithMessage:@"JSON解析错误" hide:2.0];
            });
            
            return ;
        }
        // 调用block类型的参数，实际上做了一个block函数的调用，将数据回传给URLService对象
        pass(obj,YES);
        
    }];
    
    // (9)开启线程
    [dataTask resume];
}



@end
