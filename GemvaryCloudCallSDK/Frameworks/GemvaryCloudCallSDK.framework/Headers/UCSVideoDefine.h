//
//  UCSErrorCodeDefine.h
//  ucsvideosdk
//
//  Created by FredZhang on 15/5/5.
//  Copyright (c) 2015年 ucpaas. All rights reserved.
//


typedef enum
{
    UCSCallType_VOIP       = 0, // 语音电话
    UCSCallType_VideoPhone = 2, // 视频电话
    
}UCSCallTypeEnum;


//摄像头位置
typedef enum
{
    
    CAMERA_REAR =0,          //后置摄像头
    CAMERA_FRONT = 1         //前置摄像头
    
}UCSSwitchCameraType;

//渲染模式
typedef enum
{
    
    RENDER_HALFFULLSCREEN = 0,          //半全屏(主叫设备和被叫设备处于同一方向时)
    RENDER_BLACKBORDER = 1,         //不全屏
    RENDER_ALLFULLSCREEN = 2         //全屏
    
    
}UCSRenderMode;



//视频模式
typedef enum
{
    
    CAMERA_SEND,             //本地视频
    CAMERA_RECEIVE,          //远程视频
    CAMERA_NORMAL            //正常
    
}UCSCameraType;


//通话网络状态
typedef enum
{
    
    UCSNetwork_General  = 0, // 网络状况一般
    UCSNetwork_Nice,         // 网络状况良好
    UCSNetwork_Bad,          // 网络状况很差
    UCSNetwork_Well,         // 网络状态优秀
    
}UCSNetworkState;


//呼叫失败错误码
typedef enum
{
    /**   余额不足 */
    CallFailedErrorCode_NoBalance = 402001,
    
    /**   被叫不在线 */
    CallFailedErrorCode_NotFind = 402002,
    
    /**   呼叫超时(网络连接问题) */
    CallFailedErrorCode_NoResponse = 402003,
    
    /**   服务不受理（媒体协商失败）*/
    CallFailedErrorCode_NotAccept = 402004,
    
    /**   主叫账号已冻结(频繁呼叫/黑名单) */
    CallFailedErrorCode_Freeze = 402005,
    
    /**   账号已过期(长期未使用) */
    CallFailedErrorCode_Expired = 402006,
    
    /**   呼叫错误(未知错误) */
    CallFailedErrorCode_UnkownError = 402007,
    
    /**   呼叫号码非法 */
    CallFailedErrorCode_TooShort = 402008,
    
    /**   呼叫失败(超时) */
    CallFailedErrorCode_ConnectFaild = 402009,
    
    /**    无网络 */
    CallFailedErrorCode_DisConnected = 402011,
    
    /**    对方拒绝接听 */
    CallFailedErrorCode_Reject = 402012,
    
    /**    对方忙(正在通话中) */
    CallFailedErrorCode_Busy = 402013,
    
    /**    呼叫绑定号码(不能拨打自己号码) */
    CallFailedErrorCode_Forbidden = 402022,
    
    /**    被叫不存在 */
    CallFailedErrorCode_UserIdNotExist = 402023,
    
    /**    服务器鉴权失败 */
    CallFailedErrorCode_ProxyAuth = 402041,
    
    /**    呼叫失败(当前网络不支持) */
    CallFailedErrorCode_BadNetwork = 402049,
    
    /**    被叫无应答 */
    CallFailedErrorCode_NoAnswer = 402050,
    
    /**    呼叫失败(线路频繁呼叫已被列入黑名单) */
    CallFailedErrorCode_BlackList = 402052,
    
    /**    消息不可及 */
    CallFailedErrorCode_UnReachable = 402053,
    
    /**    同振呼叫，被叫的个数超过五个 */
    CallFailedErrorCode_BEYOND_FIVE = 402054,
    
    /**    下载预览图片失败*/
    CallFailedErrorCode_DownloadPreviewImageFailed = 402055,
    
    /**    VoIP离线推送会话已失效*/
    CallFailedErrorCode_pushCallInvalid = 402056,
    
    
    
}UCSCallFailedErrorCode;


//会话挂断错误码
typedef enum
{
    /**   会话已不存在 */
    CallEndedErrorCode_Missing = 402010,
    
    /**   已挂机 */
    CallEndedErrorCode_HungupCall = 402015,
    
    /**   对方已挂机 */
    CallEndedErrorCode_HungupPeer = 402016,
    
    /**   媒体数据接收超时 */
    CallEndedErrorCode_RtppTimeOut = 402017,
    
    /**   信令超时 */
    CallEndedErrorCode_MsgTimeOut = 402019,
    
    /**   未知错误 */
    CallEndedErrorCode_UnkownError = 402021,
    
    /**   链接断开(自己断开或者对方断开) */
    CallEndedErrorCode_HungupRTPTimeout = 402051,
    
}UCSCallEndedErrorCode;

