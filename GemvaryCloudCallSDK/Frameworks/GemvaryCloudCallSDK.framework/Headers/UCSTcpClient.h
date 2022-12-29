//
//  UCSTcpClient.h
//  ucstcplib
//
//  Created by FredZhang on 15-4-11.
//  Copyright (c) 2015年 ucpaas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCSTCPDelegateBase.h"

@class UCSTCPTransParentRequest;


/*!
 *  @brief UCSTcpClient是云之讯Tcp Sdk核心能力类，为IM、Voip等能力提供支持。
 */
@interface UCSTcpClient : NSObject

/**
 *  sdk版本号
 */
@property(nonatomic, copy, readonly)NSString * version;


/*!
 *  @brief  实例化UCSTcpClient的一个单例对象
 
 *  @discussion 这个方法是生成UCSTcpClient的唯一方法，请不要使用init()等其他初始化方法，否知会出现未知的错误
 
 *  @return UCSTcpClient类型的单例对象
 */
+ (instancetype)sharedTcpClientManager;


/*!
 *  @brief  设置代理.
 *
 *  @discussion  如果需要通过回调监控tcp连接状态之类的,就必须设置这个代理
 *
 *  @param delegate tcp事件回调代理
 */
- (void)setTcpDelegate:(id <UCSTCPDelegateBase>) delegate;


/**
 *  设置离线推送的环境和设备号deviceToke。如果需要使用推送离线推送，则必须调用此方法。
 *
 *  @param environment 离线推送的环境.具体见UCSPushEnvironment，不设置的话,默认是开发环境。
 *  @param deviceToken 从系统获取到的设备号deviceToken。
 */
- (void)setPushEnvironment:(UCSPushEnvironment)environment
               deviceToken:(NSData *)deviceToken;

/**
 *  设置VoipService推送需要的token
 *
 *  @param token VoipService推送需要的token
 */
- (void)setVoipServiceToken:(NSData *)token;



/*!
 *  @brief  连接云平台.
 
 *  @discussion (注意: 除非是为了兼容旧的IMSDK,否则请使用这个登陆方式)。
 
 *  @param token        加密的token
 *  @param success      成功回调
 *  @param failure      登陆失败回调，注意：登陆账号被踢线（在其他地方登录）也会回调这个block
 */
- (void)login_connect:(NSString *)token
              success:(void (^)(NSString *userId))success
              failure:(void (^)(UCSError *error))failure;


/*!
 *  @brief 连接云平台.
 
 *  @discussion  (注意：这个登陆方式是为了兼容旧的IMSDK,后面可能会废弃)。 使用这个接口的唯一场景是: 用户已经在现有的app中集成了我们旧的IMSDK,并且不希望更改成新的登陆方式(云之讯建议你更改成新的登陆方式)。其他场景下，请使用新的登陆方式。
 
 *  @param accountSid   账号sid
 *  @param accountToken 账号token
 *  @param clientNumber clientNumber
 *  @param clientPwd    clientPwd
 *  @param success      成功回调
 *  @param failure      失败回调
 */
- (void)login_connect_old:(NSString *)accountSid
         withAccountToken:(NSString *)accountToken
         withClientNumber:(NSString *)clientNumber
            withClientPwd:(NSString *)clientPwd
                  success:(void (^)(NSString *userId))success
                  failure:(void (^)(UCSError *error))failure;


/*!
 *  @brief  查询客户端与云平台的连接状态,
 
 *  @discussion
 *
 *  @return yes，已连接；no，断开连接
 */
- (BOOL)login_isConnected;



/*!
 *  @brief  查询当前网络状态
 
 *  @discussion
 *
 *  @return 当前网络状态
 */
- (UCSNetworkStatus)getCurrentNetWorkStatus;


/*!
 *  @brief  断开客户端和云平台的连接,并且根据flag标识的bool值选择是否关闭离线推送。
 *
 *  @param flag 是否关闭推送的bool值。YES，关闭。NO，不关闭。
 *
 *  @discussion 断开连接。
 */
- (void)login_uninitWithFlag:(BOOL)flag;

#pragma mark 透传

/**
 *  @brief 发送透传数据
 *
 *  @param request    透传请求类
 *  @param success 发送成功时回调
 *  @param failure 发送失败时回调
 */
- (UCSTCPTransParentRequest *)sendTransParentData:(UCSTCPTransParentRequest *)request
                                          success:(void (^)(UCSTCPTransParentRequest *request))success
                                          failure:(void (^)(UCSTCPTransParentRequest *request, UCSError *error))failure;

/**
 *  @brief 透传响应中携带给对方的数据
 *
 *  @param ackString 响应的内容，长度不能大于500。
 *
 *  @return 设置ackString结果  YES：成功 NO：失败
 */
- (BOOL)setTransAckData:(NSString *)ackString;


/*!
 *  @brief  发送心跳包给服务器
 
 *  @discussion
 *
 */
- (void)only_Sendheartbeat;


/*!
 *   
 *
 *  @brief  保存日志到log消息到沙盒中
 *
 *  @param log <#log description#>
 */
- (void)log:(NSString *) method  detail:(NSString *)detail;

@end
