//
//  UCSVoipCallController.h
//  UCS_Demo_OC
//
//  Created by gemvary on 2017/12/25.
//  Copyright © 2017年 gemvary. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 呼叫设备类型
typedef NS_ENUM(NSInteger, SipCallDeviceType) {
    /// 未知设备
    SipCallDeviceTypeUnknow = -1,
    /// 管理机
    SipCallDeviceTypeManager = 1,
    /// 围墙机
    SipCallDeviceTypeWall = 2,
    /// 单元机
    SipCallDeviceTypeUnit = 3,
    /// 门口机
    SipCallDeviceTypeOutdoor = 4,
    /// 模拟门口机
    SipCallDeviceTypeOutdoorSimu = 5,
    /// 普通固定机
    SipCallDeviceTypeOnlyfixed = 10,
    /// 双网口固定机
    SipCallDeviceTypeRouterfixed = 11,
    /// 模拟室内机
    SipCallDeviceTypeIndoorSimu = 12,
    /// 兴天下室内机
    SipCallDeviceTypeIndoorXTXLinux = 13,
    /// 数字室内机
    DEV_INDOOR_DIGIT = 14,
    /// 君和移动机
    SipCallDeviceTypeGemvaryMobile = 20,
    /// 华为移动机
    SipCallDeviceTypeHuaWeiMobile = 21,
    /// 苹果移动机
    SipCallDeviceTypeAppleMobile = 22,
    /// 数字小门口机
    SipCallDeviceTypeDigit = 30,
    /// 手机
    SipCallDeviceTypeMobile = 40
};

@interface UCSVoipCallController : UIViewController
/// 被叫的名称
@property (nonatomic, strong) NSString *toName;
/// 来电信息
@property (nonatomic, strong) NSDictionary* callinfo;
/// 呼叫的号码信息
@property (nonatomic, strong) NSString *calledNumber;
/// 设备的类型
@property (nonatomic, strong) NSString *type;
@end
