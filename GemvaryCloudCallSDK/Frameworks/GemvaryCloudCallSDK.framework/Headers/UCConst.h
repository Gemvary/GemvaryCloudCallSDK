//
//  UCConst.h
//  UC_Demo_1.0.0
//
//  Created by Barry on 15/5/25.
//  Copyright (c) 2015年 Barry. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark 登陆结果通知
extern NSString * const UCLoginStateChangedNotication;
extern NSString * const UCLoginStateConnectingNotification ; //连接中....
extern NSString * const UCLoginStateLoginSuccessNotification  ; //登录成功
extern NSString * const UCLoginStateLoginFailureNotification ; //登录失败
extern NSString * const UCLoginStateNetErrorNotification   ; //网络不给力
extern NSString * const UCLoginStateLoginOutNotification  ;  //退出
extern NSString * const UCTCPConnectingNotification ;  // tcp正在连接
extern NSString * const UCTCPDisConnectNotification ;  // tcp断开连接
extern NSString * const UCTCPDidConnectNotification ;  // tcp已经连接
extern NSString * const UCTCPNoNetWorkNotification ;   // 没网
extern NSString * const UCTCPHaveNetWorkNotification ; // 有网
//消息未读数变化通知
extern NSString * const UnReadMessageCountChangedNotification;

//会话列表变化通知，来了新消息，自己发了消息等
extern NSString * const ConversationListDidChangedNotification ;

//收到新的聊天信息
extern NSString * const DidReciveNewMessageNotifacation;

// 收到语音消息下载成功或者失败的回调
extern NSString * const DidRecuveVoiceDownloadStateNotification;

//清空了聊天消息
extern NSString * const ChatMessageDidCleanNotification;

// 聊天背景改变了
extern NSString * const ChatViewBackImageDidChangedNotification  ;

//讨论组好友成员增加了
extern NSString * const DiscussionMembersDidAddNotification;

//主动退出了讨论组
extern NSString * const DidQuitDiscussionNotification;

//创建讨论组成功,rootViewController跳转到chatviewCotroller
extern NSString * const DidCreateDiscussionNotification;

//本地通知体中的key
extern NSString * const LocationNotificationChatterKey;

// 收到删除空的会话的通知
extern NSString * const RemoveEmptyConversationNotification;

// 讨论组名称被修改了
extern NSString * const DiscussionNameChanged;

// 自己被踢出讨论组
extern NSString * const RemovedADiscussionNotification;

// tcp连接状态
extern NSString * const TCPConnectStateNotification;

// 自己被踢线
extern NSString * const TCPKickOffNotification;

// 收到透传数据
extern NSString* const UCS_DidReceiveTransParentData;


typedef NS_ENUM(NSInteger, UCSCallType) {
    UCSCallTypeNone = 0,
    UCSCallTypeVoipCall ,
    UCSCallTypeIncomingVoipCall ,
    UCSCallTypeVideoCall ,
    UCSCallTypeIncomingVideoCall ,
    UCSCallTypePSTN
};

typedef NS_ENUM(NSInteger, UCSCallStatus) {
    UCSCallStatus_NO=0,               //没有呼叫
    UCSCallStatus_Calling,            //呼叫中
    UCSCallStatus_Proceeding,         //服务器有回应
    UCSCallStatus_Alerting,           //对方振铃
    UCSCallStatus_Answered,           //对方应答
    UCSCallStatus_Pasused,            //保持成功
    UCSCallStatus_Released,           //通话释放
    UCSCallStatus_Failed,             //呼叫失败
    UCSCallStatus_Incoming,           //来电
    UCSCallStatus_Transfered,         //
    UCSCallStatus_CallBack,           //
    UCSCallStatus_CallBackFailed,      //
    UCSCallStatus_RecDTMFvalue,      //接收到DTMF
    
    UCSCallStatus_Conference_StateNotify,  //电话会议
    UCSCallStatus_Conference_PassiveModeConvert,
    UCSCallStatus_Conference_ActiveModeConvert
};


extern NSString * const UCSNotiHeadPhone;
extern NSString * const UCSNotiCallBalance;
extern NSString * const UCSNotiRefreshCallList;
extern NSString * const UCSNotiIncomingCall;
extern NSString * const UCSNotiEngineSucess;
extern NSString * const UCSNotiTCPTransParent;

extern NSString * const UCSNotiCallViewController;
