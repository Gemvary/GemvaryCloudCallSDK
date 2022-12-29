
#import <UIKit/UIKit.h>
#import "UCSTcpClient.h"
#import "UCConst.h"
#import "UCSCommonClass.h"
#import "UCSVideoDefine.h"

@protocol UCSEngineUIDelegate <NSObject>

@optional
///来电信息
- (void)incomingCallId:(NSString*)callid callUserdata:(NSString*)callUserdata callerNumber:(NSString*)callerNumber calltype:(UCSCallTypeEnum)callType;

///通话状态回调
- (void)responseVoipManagerStatus:(UCSCallStatus)event callID:(NSString*)callid data:(UCSReason *)data;

///语音质量展示回调
- (void)showNetWorkState:(NSString *)networkStateStr;

///对端视频模式回调
- (void)onRemoCameraMode:(UCSCameraType)type;

//视频通话前被叫显示主叫预览图片时回调
- (void)onReceivedPreviewImg:(UIImage *)image  callid:(NSString *)callid error:(NSError *)error;

//视频截图回调
- (void)onCameraCapture:(NSString*)cameraCapFilePath;

//DTMF回调
- (void)onDTMF:(NSString*)value;

//对端视频模式回调
- (void)onRemoteCameraMode:(UCSCameraType)type;

@end


//这个类是属于上面业务层与SDK之间的调度层，负责调用SDK接口和接收分发SDK的回调
@interface UCSFuncEngine : NSObject

@property (nonatomic, weak) UIViewController *callViewController;
@property (nonatomic, strong) NSString *callid;
@property (nonatomic, strong) NSArray<NSString *>* calledNumberList;//呼叫的号码列表
@property (nonatomic, weak) id<UCSEngineUIDelegate> UIDelegate;//UI业务代理
@property (nonatomic) UCSCallType callType;
@property (nonatomic) BOOL isSuccessfulForCallService;//初始化成功

+ (UCSFuncEngine *)shared;

+ (void)relessUCSFunEngind;

///设置视频参数
- (void)setVideoPresetWith:(UCSVideoProfilePreset)preset;

///设置是否使用硬编硬解
- (void)setVideoIsUseHwEnc:(BOOL)on;

#pragma mark - -------------------呼叫控制函数-------------------

/**
 * 挂断电话
 * param callid 电话id
 * param reason 预留参数
 */
- (void) hangUp: (NSString*)called;

/**
 * 接听电话
 * param callid 电话id
 * V2.0
 */
- (void) answer: (NSString*)callId;

/**
 * 拒绝呼叫(挂断一样,当被呼叫的时候被呼叫方的挂断状态)
 * param callid 电话id
 * param reason 拒绝呼叫的原因, 可以传入ReasonDeclined:用户拒绝 ReasonBusy:用户忙
 */
- (void)reject: (NSString*)called;

/**
 语音或视频同振
 
 @param callType 呼叫类型 0 语音同振  2 视频同振
 @param numbers 呼叫的号码数组，号码不要超过5个
 */
- (void)groupDialWithType:(NSInteger)callType numbers:(NSArray<NSString *> *)numbers;

/**
 * 发起呼叫
 * @param callType 电话类型 0 语音电话  2 视频电话
 * @param called userid号码
 */
- (void)dial:(NSInteger)callType andCalled:(NSString *)calledNumber andUserdata:(NSString *)callerData;


#pragma mark - -------------------DTMF函数-------------------
/**
 * 发送DTMF
 * param callid 电话id
 * param dtmf 键值
 */
- (BOOL)sendDTMF: (char)dtmf;

#pragma mark - -------------------本地功能函数-------------------

/**
 * 免提设置
 * param enable false:关闭 true:打开
 */
- (void) setSpeakerphone:(BOOL)enable;


/**
 * 获取当前免提状态
 * return false:关闭 true:打开
 */
- (BOOL) isSpeakerphoneOn;


/**
 * 静音设置
 * param on false:正常 true:静音
 */
- (void)setMicMute:(BOOL)on;

/**
 * 获取当前静音状态
 * return false:正常 true:静音
 */
- (BOOL)isMicMute;


/**
 * 获取SDK版本信息
 *
 */
- (NSString*) getUCSSDKVersion;



/**
 * 是否支持IPv6
 *
 * @param isIpv6 YES/NO
 */
- (void)setIpv6:(BOOL)isIpv6;

/**
 * 视频来电时是否支持预览
 * isPreView: YES 支持预览 NO 不支持预览。
 * return YES 成功 NO 失败
 */
- (BOOL)setCameraPreViewStatu:(BOOL)isPreView;

#pragma mark - -------------------视频能力------------------------

/**
*  初始化视频显示控件（本地视频显示控件和对方视频显示控件）
*
*参数 frame 窗口大小
*
*return UIView 视频显示控件:
*/
- (UIView *)allocCameraViewWithFrame:(CGRect)frame;

/**
 * 设置视频显示参数
 *
 *参数 localVideoView 设置本地视频显示控件
 *参数 remoteView     设置对方视频显示控件
 *
 *return NO:  YES:
 */
-(BOOL)initCameraConfig:(UIView*)localVideoView withRemoteVideoView:(UIView*)remoteView withRender:(UCSRenderMode)renderMode;



/**
 *  自定义视频编码和解码参数
 */
- (void)setVideoAttr:(UCSVideoEncAttr*)ucsVideoEncAttr ;


/**
 * 用户自定义分级编码参数
 * param ucsHierEncAttr 编码参数
 */
- (void)setHierEncAttr:(UCSHierEncAttr*)ucsHierEncAttr;


/**
 * 旋转显示图像角度
 * Desc: 当呼叫成功、或 接听成功时重新需要重新设置此方法
 * param landscape       竖屏：0 横屏：1
 * param localRotation  本地端显示图像角度  数值为0 90 180 270
 */
- (BOOL)setRotationVideo:(unsigned int)landscape andRecivied:(unsigned int)localRotation;

/**
 *
 * 获取摄像头个数
 */
- (int)getCameraNum;


/**
 * 摄像头切换 后置摄像头：0 前置摄像头：1
 *return YES 成功 NO 失败
 */
- (BOOL)switchCameraDevice:(UCSSwitchCameraType)CameraIndex;


/**
 *  切换视频模式：发送、接收、正常模式
 *
 *  param type         CAMERA_RECEIVE : 只接收视频数据（只能接收到对方的视频）
                        CAMERA_SEND : 只发送视频数据（只让对方看到我的视频）
                        CAMERA_NORMAL : send receive preview
 *
 *  return YES 成功 NO 失败
 */
- (BOOL)switchVideoMode:(UCSCameraType)type;


/**
 * 视频截图
 * param islocal: 0 是远端截图 1 是本地截图。
 * param filename: 截图名称。
 * param savePath: 存放路径。
 *
 */
- (void)cameraCapture:(int)islocal withFileName:(NSString*)filename withSavePath:(NSString*)savePath;


/**
 * 2g网络检测开关
 * param on  YES:发起呼叫时不检测2g网络  NO:发起呼叫时检测2g网络
 */

-(void)set2GNetWorkOn:(BOOL)enable;


/**
 Push续活通知
 
 @param callid 当前来电会话 id (目前版本可以为空)
 @param vpsid 云平台会话控制服务器标识 id
 @param reason 原因
 */
- (void) callIncomingPushRsp:(NSString*)callid  withVps:(NSInteger)vpsid withReason:(UCSReason*)reason;


@end
