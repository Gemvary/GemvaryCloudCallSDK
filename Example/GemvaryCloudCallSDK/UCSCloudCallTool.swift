//
//  UCSCloudCallTool.swift
//  Gem_Home
//
//  Created by SongMenglong on 2021/12/18.
//

import UIKit
import GemvaryCloudCallSDK
//import GemvaryZGCloudCallSDK
import GemvaryToolSDK
import GemvaryCommonSDK

/// 云之讯云对讲工具信息
class UCSCloudCallTool: NSObject {
    /// 创建单例
    static let share: UCSCloudCallTool = UCSCloudCallTool()
    /// 推送信息
    private var pushInfo: [String: Any] = [String: Any]()
    
    /// 初始化方法
    override init() {
        super.init()
        swiftDebug("初始化方法， 设置代理")
        // 设置代理
        UCSFuncEngine.shared().uiDelegate = self
        UCSTcpClient.sharedTcpClientManager().setTcpDelegate(self)
    }
        
    /// 云对讲引擎初始化成功
    func ucsEngineSucess() -> Void {
        swiftDebug("云对讲登录成功")
        self.ucsLogin()
        
        self.ucsLoopLogin()
        
        UCSFuncEngine.shared().uiDelegate = self
        UCSTcpClient.sharedTcpClientManager().setTcpDelegate(self)
    }
    
    /// 登录云对讲
    private func ucsLogin() -> Void {
                
        if UCSTcpClient.sharedTcpClientManager().login_isConnected() == true {
            swiftDebug("云对讲功能已经登录")
            return
        }     
        
        DispatchQueue.main.async {
            // 开始登录云对讲
            self.loginUCSClientWithImtoken(ucsToken: ParamTools.ucsToken)
        }
    }
    
    /// 循环云对讲登录
    private func ucsLoopLogin() -> Void {
        
        // 没有登录 开始定时登录
        if UCSTcpClient.sharedTcpClientManager().login_isConnected() ==  false {
            // 定时器
            let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            var count = 0
            timer.schedule(wallDeadline: DispatchWallTime.now(), repeating: 8.0)
            timer.setEventHandler(handler: {
                count -= 1
                DispatchQueue.main.async {
                    // 开始云对讲
                    self.ucsLogin()
                }
                if count == 0 {
                    timer.cancel()
                }
            })
            timer.resume()
        }
    }
    
    /// 登录云之讯云对讲功能
    private func loginUCSClientWithImtoken(ucsToken: String) -> Void {
        // 连接云平台
        UCSTcpClient.sharedTcpClientManager().login_connect(ucsToken) { userId in
            swiftDebug("云对讲登录成功: ", userId as Any)
        } failure: { error in
            swiftDebug("云对讲登录失败: ", error as Any)
        }
    }
}

/// 实现云对讲代理方法
extension UCSCloudCallTool: UCSEngineUIDelegate {
    
    /// 云对讲呼叫信息上报
    func incomingCallId(_ callid: String!, callUserdata: String!, callerNumber: String!, calltype callType: UCSCallTypeEnum) {
        swiftDebug("旧云对讲呼叫信息::", callid as Any, callUserdata as Any, callerNumber as Any, callType as Any)
        
        if let callerNumber = callerNumber {
            let inOutdoorDev = InOutdoorDev(devCode: "P300dd6ac4ba9c99f657", devType: 2, note: "围墙机（1号别墅）", sipAddr: "jhrt2898", unitno: "", zoneCode: "6666")

            swiftDebug("当前数据信息: ", inOutdoorDev)
            // 创建通知
            self.postCall(inOutdoorDev: inOutdoorDev, callerNumber: callerNumber, callid: callid, callType: callType)
        } else {
            // 刷新请求
            //SipDataHandler.requestAllInOutdoorDev()
            // 延时2s
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                swiftDebug("延时2s获取数据", callerNumber as Any)
//                if let inOutdoorDev = InOutdoorDev.qunery(sipAddr: callerNumber) {
//                    // 创建通知
//                    self.postCall(inOutdoorDev: inOutdoorDev, callerNumber: callerNumber, callid: callid, callType: callType)
//                }
            }
        }
    }
    
    
    func responseVoipManagerStatus(_ event: UCSCallStatus, callID callid: String!, data: UCSReason!) {
        swiftDebug("代理方法走了么？？？", event, callid as Any, data as Any)
    }
    
    
}

extension UCSCloudCallTool: UCSTCPDelegateBase {
    
    func didConnectionStatusChanged(_ connectionStatus: UCSConnectionStatus, error: UCSError!) {
        switch connectionStatus {
        case UCSConnectionStatus_BeClicked:
            swiftDebug("UCS 账号在别处登录，被强行下线")
            NotificationCenter.default.post(name: NSNotification.Name.TCPKickOff, object: nil)
            
            if UCSTcpClient.sharedTcpClientManager().getCurrentNetWorkStatus() == UCSReachableViaUnknown || UCSTcpClient.sharedTcpClientManager().getCurrentNetWorkStatus() == UCSNotReachable {
                // 没有网络
                ProgressHUD.showText("暂时无法呼通，请稍后再试")
            } else {
//                UserTokenLogin.repeatLogin(title: "此账号已在别处登录，请重新登录~")
            }
            break
        case UCSConnectionStatus_ReConnectFail:
            swiftDebug("UCS 重连失败")
            NotificationCenter.default.post(name: NSNotification.Name.TCPConnectState, object: NSNotification.Name.UCTCPDisConnect)
            break
        case UCSConnectionStatus_StartReConnect:
            swiftDebug("UCS 开始重连")
            NotificationCenter.default.post(name: NSNotification.Name.TCPConnectState, object: NSNotification.Name.UCTCPConnecting)
            break
        case UCSConnectionStatus_ReConnectSuccess:
            swiftDebug("UCS 重连成功")
            NotificationCenter.default.post(name: NSNotification.Name.TCPConnectState, object: NSNotification.Name.UCTCPDidConnect)
            // 重新拉起页面
            self.launchCall(info: self.pushInfo)
            break
        case UCSConnectionStatus_loginSuccess:
            swiftDebug("UCS连接成功 非重连")
            NotificationCenter.default.post(name: NSNotification.Name.TCPConnectState, object: NSNotification.Name.UCTCPDidConnect)
            // 重新拉起页面
            self.launchCall(info: self.pushInfo)
            break
        case UCSConnectionStatus_ConnectFail:
            swiftDebug("UCS连接失败 非重连")
            NotificationCenter.default.post(name: NSNotification.Name.TCPConnectState, object: NSNotification.Name.UCTCPDisConnect)
            break
        case UCSConnectionStatus_SignOut:
            swiftDebug("UCS 主动断开")
            NotificationCenter.default.post(name: NSNotification.Name.TCPConnectState, object: NSNotification.Name.UCTCPDisConnect)
            break
        case UCSConnectionStatus_AbnormalDisconnection:
            swiftDebug("UCS 网络未连接")
            NotificationCenter.default.post(name: NSNotification.Name.TCPConnectState, object: NSNotification.Name.UCTCPDisConnect)
            break
        default:
            swiftDebug("UCS 其他状态")
            break
        }
        
    }
    
    
    func didReceiveTransParentData(_ objcts: UCSTCPTransParent!) {
        swiftDebug("收到透传数据 ", objcts.senderUserId as Any, objcts.cmdString as Any)
        if let cmdString = objcts.cmdString, cmdString == "outdoorisunlock" {
            ProgressHUD.showText("开锁成功")
        }
    }
}


extension UCSCloudCallTool {
    
    /// 收到远程通知后，来起来电
    private func launchCall(info: [String: Any]) -> Void {
        let reason = UCSReason()
        
        // 续活通知
        UCSFuncEngine.shared().callIncomingPushRsp("", withVps: 0, with: reason)
        // 弹出通知
        
    }
}

extension UCSCloudCallTool {
    
    /// 创建通知信息
    private func postCall(inOutdoorDev: InOutdoorDev, callerNumber: String, callid: String, callType: UCSCallTypeEnum) -> Void {
        swiftDebug("旧云对讲 创建消息通知")
        var inOutdoorDev = inOutdoorDev
        // 创建通知
        if inOutdoorDev.note == nil || inOutdoorDev.note == "" {
            inOutdoorDev.note = callerNumber
        }
            
        
        // 检查麦克风权限 检查相机权限
        if GlobalTools.checkPermissionsForMic() == false || GlobalTools.checkPermissionsForCamera() == false {
            swiftDebug("检查麦克风权限 检查相机权限 没有打开")
            // 拒绝呼叫(挂断)
            UCSFuncEngine.shared().reject(callid)
            return
        }
        // 是否免打扰 正在通话中
        if UCSFuncEngine.shared().callViewController != nil {
            swiftDebug("是否免打扰 正在通话中")
            // 拒绝呼叫(挂断)
            UCSFuncEngine.shared().reject(callid)
            return
        }
        
        // 设置麦克风
        UCSFuncEngine.shared().setSpeakerphone(true)

        if UIApplication.shared.applicationState == UIApplication.State.background {
            // 创建本地通知
            self.createLocalNotification(callid: callid, inOutdoorDev: inOutdoorDev)
        }
        // 呼叫ID赋值
        UCSFuncEngine.shared().callid = callid
        
        switch callType {
        case UCSCallType_VOIP: // 语音来电
            swiftDebug("语音来电")
            if UCSFuncEngine.shared().callViewController != nil {
                swiftDebug("正在通话中")
                UCSFuncEngine.shared().reject(callid)
                return
            }
            UCSFuncEngine.shared().callType = UCSCallType.incomingVoipCall
            if let voipVC: UCSVoipCallController = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UCSVoipCallController") as? UCSVoipCallController {
                voipVC.callinfo = ModelEncoder.encoder(toDictionary: inOutdoorDev)
                voipVC.callinfo["callerNumber"] = callerNumber

                UCSFuncEngine.shared().callViewController = voipVC
                self.showCallView(viewController: voipVC)
            }
            break
        case UCSCallType_VideoPhone: // 视频来电
            swiftDebug("视频来电")
            UCSFuncEngine.shared().callType = UCSCallType.incomingVideoCall
            if let videoVC: UCSVideoCallController = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UCSVideoCallController") as? UCSVideoCallController {
                videoVC.callinfo = ModelEncoder.encoder(toDictionary: inOutdoorDev)
                videoVC.callinfo["callerNumber"] = callerNumber
                UCSFuncEngine.shared().callViewController = videoVC
                self.showCallView(viewController: videoVC)
            }
            break
        default:
            break
        }
    }
    
    /// 创建本地通知
    private func createLocalNotification(callid: String, inOutdoorDev: InOutdoorDev) -> Void {
        
        if #available(iOS 10.0, *) {
            let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
            let sound: UNNotificationSound = UNNotificationSound(named: UNNotificationSoundName(string: "ring.caf") as String)
            notificationContent.sound = sound
            if let note = inOutdoorDev.note {
                notificationContent.body = "\(note) 来电"
            }
            notificationContent.userInfo = ["callId": callid, "timer": NSNumber(1)]
            notificationContent.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            let trigger: UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                        
            let request: UNNotificationRequest = UNNotificationRequest(identifier: "callNoti", content: notificationContent, trigger: trigger)

            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().add(request) { error in
                swiftDebug("发送来电通知")
            }
        } else {
            let notification: UILocalNotification = UILocalNotification()
            notification.soundName = ""
            notification.repeatInterval = NSCalendar.Unit.init(rawValue: 0)
            if let note = inOutdoorDev.note {
                notification.alertBody = "\(note) 来电"
            }
            notification.userInfo = ["callId": callid, "timer": NSNumber(1)]
            notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            notification.repeatCalendar = Calendar.current
            
            UIApplication.shared.presentLocalNotificationNow(notification)
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
        
    /// 拨打电话
    func dial(callType: UCSCallTypeEnum, calledNumber: String, callerData: String, type: String) -> Void {
        swiftDebug("", callType)
        guard let funcEngine = UCSFuncEngine.shared() else {
            swiftDebug("UCS 初始化为空")
            return
        }
        if funcEngine.callViewController != nil {
            swiftDebug("UCS 正在通话中")
            return
        }
        
        switch callType {
        case UCSCallType_VOIP: // voip呼叫 语音电话
            swiftDebug("VOIP呼叫 ", calledNumber)
            funcEngine.callType = UCSCallType.voipCall
            funcEngine.calledNumberList = [calledNumber]
            
            if let callViewController: UCSVoipCallController = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UCSVoipCallController") as? UCSVoipCallController {
                callViewController.toName = callerData
                callViewController.calledNumber = calledNumber
                callViewController.type = type
                funcEngine.callViewController = callViewController
                // 弹出呼叫页面
                self.showCallView(viewController: callViewController)

                funcEngine.dial(0, andCalled: calledNumber, andUserdata: callerData)
            }
            break
//        case UCSCallType.PSTN: // pstn呼叫
//        case UCSCallType_PSTN: // pstn呼叫

//        case UCSCallType_VideoPhone: //
//            swiftDebug("PSTN呼叫 ", calledNumber)
//            funcEngine.callType = UCSCallType.PSTN
//            funcEngine.calledNumberList = [calledNumber]
//            if let callViewController: UCSVoipCallController = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UCSVoipCallController") as? UCSVoipCallController {
//                callViewController.toName = callerData
//                callViewController.calledNumber = calledNumber
//                callViewController.type = type
//                funcEngine.callViewController = callViewController
//                // 弹出呼叫页面
//                self.showCallView(viewController: callViewController)
//
//                funcEngine.dial(1, andCalled: calledNumber, andUserdata: callerData)
//            }
//            break
//        case UCSCallType.videoCall: // video呼叫
        case UCSCallType_VideoPhone: // video呼叫
          swiftDebug("VIDEO呼叫 ", calledNumber)
            funcEngine.callType = UCSCallType.videoCall
            funcEngine.calledNumberList = [calledNumber]
            if let callViewController: UCSVideoCallController = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UCSVideoCallController") as? UCSVideoCallController {
                callViewController.toName = callerData
                callViewController.calledNumber = calledNumber
                callViewController.type = type
                funcEngine.callViewController = callViewController
                // 弹出呼叫页面
                self.showCallView(viewController: callViewController)

                funcEngine.dial(2, andCalled: calledNumber, andUserdata: callerData)
            }
            break
        default:
            break
        }
        
    }
    
    private func showCallView(viewController: UIViewController) -> Void {
        // 隐藏提示弹窗
        self.dismissAlertViews()
        viewController.modalPresentationStyle = UIModalPresentationStyle.popover
        guard let rootVC = GlobalTools.getRootViewController() else {
            swiftDebug("获取主控制器为空")
            return
        }
        if viewController is UCSVideoCallController {
            // 视频
            rootVC.present(viewController, animated: true, completion: nil)
        } else if viewController is UCSVoipCallController {
            // 语音
            rootVC.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    /// 消失AlertView
    private func dismissAlertViews() -> Void {
        // 隐藏弹窗提示
//        if let currentVC = UtilitiesTools.getCurrentVC(), currentVC is UIAlertController {
//            currentVC.dismiss(animated: true, completion: nil)
//        }
    }
        
}

/// 实现通知的代理方法
extension UCSCloudCallTool: UNUserNotificationCenterDelegate {
            
    /// 通知已经接收
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        swiftDebug("本地通知响应 已经接收")
    }
    
    /// 通知即将弹出
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        swiftDebug("本地通知响应 即将推出")
    }
    
}
