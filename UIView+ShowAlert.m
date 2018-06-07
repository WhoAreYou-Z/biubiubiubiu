//
//  UIView+ShowAlert.m
//  BWStarry
//
//  Created by 尹晓腾 on 2018/4/18.
//  Copyright © 2018年 BW. All rights reserved.
//

#import "UIView+ShowAlert.h"
#import "MBProgressHUD.h"


@implementation UIView (ShowAlert)
// 使用UIAlertController做提示框
-(void)showAlertWithMessage:(NSString *)msg hide:(NSTimeInterval)seconds {
    
    UIAlertController *alertCtl  =[UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    // 定义一个控制器类型的对象，用于接收，view所在的控制器对象的内存
    UIViewController *vc = nil;
    
    // 通过响应者链的方式得到当前view所属于的控制器对象
    for (UIView *v = self ; v  ; v = v.superview) {
        UIResponder *res = v.nextResponder;
        if ([res isKindOfClass:[UIViewController class]]) {
            vc = (UIViewController *)res;
            break;
        }
    }
    
    [vc presentViewController:alertCtl animated:YES completion:nil];
    [self performSelector:@selector(hideAlertController:) withObject:alertCtl afterDelay:seconds];
}


-(void)hideAlertController:(UIAlertController *)sender {
    [sender dismissViewControllerAnimated:YES completion:nil];
}

// 使用MBProgressHUD做提示框
-(void)showMBHudWithMessage:(NSString *)msg hide:(NSTimeInterval)seconds {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = msg;
        [self addSubview:hud];
        [hud show:YES];
        [hud hide:YES afterDelay:seconds];
    });
}

// 显示MBProgressHUD样式的菊花等待指示器
-(void)showMBProgressHUD {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 做一个等待指示器
        MBProgressHUD *hud = [[MBProgressHUD  alloc] initWithView:self];
        [self addSubview:hud];
        hud.tag = 888;
        hud.removeFromSuperViewOnHide = YES;
        [hud show:YES];
    });
}

// 隐藏MBProgressHUD样式的菊花等待指示器
-(void)hideMBProgressHUD{
    
    // 回到UI主线程，
    dispatch_async(dispatch_get_main_queue(), ^{
        // 得到hud的内存
        MBProgressHUD *hud = (MBProgressHUD *)[self viewWithTag:888];
        [hud hide:YES];
        hud = nil;
    });
}
@end




