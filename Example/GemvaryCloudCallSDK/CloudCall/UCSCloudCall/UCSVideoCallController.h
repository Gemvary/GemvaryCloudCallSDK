//
//  UCSVideoCallController.h
//  UCS_Demo_OC
//
//  Created by gemvary on 2017/12/25.
//  Copyright © 2017年 gemvary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCSVideoCallController : UIViewController
/// 被叫的名称
@property (nonatomic, strong) NSString *toName;
/// 来电信息
@property (nonatomic, strong) NSDictionary* callinfo;
/// 呼叫的号码
@property (nonatomic, strong) NSString *calledNumber;
/// 设备的类型
@property (nonatomic, strong) NSString *type;

@end
