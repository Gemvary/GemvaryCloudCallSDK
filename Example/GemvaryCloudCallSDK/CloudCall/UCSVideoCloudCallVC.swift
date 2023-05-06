//
//  UCSVideoCloudCallVC.swift
//  Gem_Home
//
//  Created by SongMenglong on 2021/12/14.
//

import UIKit
import GemvaryCloudCallSDK // 旧云对讲
import GemvaryCommonSDK

class UCSVideoCloudCallVC: UIViewController {

    /// 顶部
    private var headerImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.backgroundColor = UIColor.brown
        imageView.image = UIImage(named: "icon")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    /// 预览画面(视频对讲时出现)
    private var previewImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.backgroundColor = UIColor.yellow
        imageView.image = UIImage(named: "icon")
        //imageView.contentMode = .scaleToFill
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    /// 状态label
    private var stateLabel: UILabel = {
        let label = UILabel()
        label.text = "通话中";
        label.textColor = UIColor.white
        return label
    }()
    /// 显示名字滚动图
    private var marqueeView: MarqueeView = {
        let view = MarqueeView()
        //view.backgroundColor = UIColor.orange
        //view.isHidden = true
        view.fontOfMarqueeLabel = 17.0
        view.textColor = UIColor.white
        return view
    }()
    /// 底部按钮页面 栈view
    private var buttonListView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.equalSpacing
        //stackView.distribution = UIStackView.Distribution.fillEqually
        if #available(iOS 11.0, *) {
            stackView.spacing = UIStackView.spacingUseDefault
        } else {
            // Fallback on earlier versions
        }
        stackView.alignment = UIStackView.Alignment.center
        //stackView.alignment = UIStackView.Alignment.fill
        //stackView.spacing = 0
        stackView.contentMode = UIView.ContentMode.scaleToFill
        stackView.semanticContentAttribute = .unspecified
        return stackView
    }()
    /// 麦克风静音按钮
    private var microButton: CloudCallButton = {
        let button = CloudCallButton()
        //button.imageView?.contentMode = .scaleAspectFit
        button.setBackgroundImage(UIImage(named: "button_mute_off"), for: UIControl.State.selected)
        button.setBackgroundImage(UIImage(named: "button_mute_on"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(microButtonAction(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    /// 接通按钮
    private var answerButton: CloudCallButton = {
        let button = CloudCallButton()
        //button.imageView?.contentMode = .scaleAspectFit
        button.setBackgroundImage(UIImage(named: "answer_keys"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(answerButtonAction(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    /// 开锁按钮
    private var unlockButton: CloudCallButton = {
        let button = CloudCallButton()
        //button.imageView?.contentMode = .scaleAspectFit
        button.setBackgroundImage(UIImage(named: "unlocking"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(unlockButtonAction(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    /// 挂断按钮
    private var hangupButton: CloudCallButton = {
        let button = CloudCallButton()
        //button.imageView?.contentMode = .scaleAspectFit
        button.setBackgroundImage(UIImage(named: "hang_up_key"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(hangupButtonAction(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    /// 扬声器按钮
    private var speakerButton: CloudCallButton = {
        let button = CloudCallButton()
        //button.imageView?.contentMode = .scaleAspectFit
        button.setBackgroundImage(UIImage(named: "button_HF_off"), for: UIControl.State.normal)
        button.setBackgroundImage(UIImage(named: "button_HF_on"), for: UIControl.State.selected)
        button.addTarget(self, action: #selector(speakerButtonAction(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    /// 宽度的约束
    private var buttonsWidthCon: NSLayoutConstraint = NSLayoutConstraint()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 感应距离息屏
        UIDevice.current.isProximityMonitoringEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true
        // 设置子控件
        self.setupSubViews()
        
        // 设置云对讲
        UCSFuncEngine.shared().uiDelegate = self
        UCSFuncEngine.shared().setVideoPresetWith(UCS_VIE_PROFILE_PRESET_640x480)
        UCSFuncEngine.shared().setVideoIsUseHwEnc(false)
        // 初始化相机
        //UCSFuncEngine.shared().initCameraConfig(<#T##localVideoView: UIView!##UIView!#>, withRemoteVideoView: <#T##UIView!#>, withRender: <#T##UCSRenderMode#>)
        UCSFuncEngine.shared().switchVideoMode(CAMERA_NORMAL)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                        
        // 移除震动
        // 移除铃声
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 挂断电话
    }
        
    
    
}

extension UCSVideoCloudCallVC {
    
    private func makeVideoCallView() -> Void {
        // 远程窗口
        UCSFuncEngine.shared().allocCameraView(withFrame: self.view.bounds)
        
        // 本地窗口
        //UCSFuncEngine.shared().allocCameraView(withFrame: self.)
    }
    
    /// 更新UI
    private func updateUI() -> Void {
        switch UCSFuncEngine.shared().callType {
        case UCSCallType.voipCall,
            UCSCallType.videoCall,
            UCSCallType.PSTN:
            // 呼叫信息
            break
        case UCSCallType.incomingVoipCall, UCSCallType.incomingVideoCall:
            // 来电信息
            break
        default:
            break
        }
    }
    
    /// 页面消失
    @objc private func dismissVC() -> Void {
        
        self.dismiss(animated: true) {
            // 判断云对讲是否正在链接
            if UCSTcpClient.sharedTcpClientManager().login_isConnected() == false {
                // 判断网络状态
                if UCSTcpClient.sharedTcpClientManager().getCurrentNetWorkStatus() == UCSReachableViaUnknown ||
                    UCSTcpClient.sharedTcpClientManager().getCurrentNetWorkStatus() == UCSNotReachable {
                    ProgressHUD.showText("没有网络，请检查网络")
                } else {
                    // 跳转到登录页面
                    //UserTokenLogin.repeatLogin(title: "此账号已在别处登录，请重新登录~")
                }
            }
            
        }
    }
    
}

extension UCSVideoCloudCallVC {
    
    /// 设置参数
    private func setHierEncArrt() -> Void {
        let hierEncAttr: UCSHierEncAttr = UCSHierEncAttr()
        hierEncAttr.low_complexity_w240 = 2
        hierEncAttr.low_complexity_w360 = 1
        hierEncAttr.low_complexity_w480 = 1
        hierEncAttr.low_complexity_w720 = 0
        hierEncAttr.low_bitrate_w240 =  200
        hierEncAttr.low_bitrate_w360 =  -1
        hierEncAttr.low_bitrate_w480 =  -1
        hierEncAttr.low_bitrate_w720 =  -1
        hierEncAttr.low_framerate_w240 = 12
        hierEncAttr.low_framerate_w360 = 14
        hierEncAttr.low_framerate_w480 = -1
        hierEncAttr.low_framerate_w720 = 14
        
        hierEncAttr.medium_complexity_w240 = 3
        hierEncAttr.medium_complexity_w360 = 2
        hierEncAttr.medium_complexity_w480 = 1
        hierEncAttr.medium_complexity_w720 = 0
        hierEncAttr.medium_bitrate_w240 = 200
        hierEncAttr.medium_bitrate_w360 = 400
        hierEncAttr.medium_bitrate_w480 = -1
        hierEncAttr.medium_bitrate_w720  = -1
        hierEncAttr.medium_framerate_w240 = 14
        hierEncAttr.medium_framerate_w360 = 14
        hierEncAttr.medium_framerate_w480 = 13
        hierEncAttr.medium_framerate_w720 = 14
        
        hierEncAttr.high_complexity_w240 = 3
        hierEncAttr.high_complexity_w360 = 2
        hierEncAttr.high_complexity_w480 = 2
        hierEncAttr.high_complexity_w720 = 1
        hierEncAttr.high_bitrate_w240 = 200
        hierEncAttr.high_bitrate_w360 = 400
        hierEncAttr.high_bitrate_w480 = -1
        hierEncAttr.high_bitrate_w720 = -1
        hierEncAttr.high_framerate_w240 = 14
        hierEncAttr.high_framerate_w360 = 15
        hierEncAttr.high_framerate_w480 = 15
        hierEncAttr.high_framerate_w720 = 14
        
        UCSFuncEngine.shared().setHierEncAttr(hierEncAttr)
    }
    
    
    private func setVideoEnc() -> Void {
        let vEncAttr = UCSVideoEncAttr()
        vEncAttr.uStartBitrate = 300
        vEncAttr.uMaxBitrate = 900
        vEncAttr.uMinBitrate = 150
        
        UCSFuncEngine.shared().setVideoAttr(vEncAttr)
    }
    
}

extension UCSVideoCloudCallVC {
    
    /// 麦克风
    @objc func microButtonAction(button: UIButton) -> Void {
        swiftDebug("麦克风")
        if UCSFuncEngine.shared().isMicMute() == true {
            UCSFuncEngine.shared().setMicMute(false)
            self.microButton.isSelected = false
            swiftDebug("非静音")
        } else {
            UCSFuncEngine.shared().setMicMute(true)
            self.microButton.isSelected = true
            swiftDebug("静音")
        }
    }
    
    /// 接通电话
    @objc func answerButtonAction(button: UIButton) -> Void {
        swiftDebug("接通电话")
        
        if let callid = UCSFuncEngine.shared().callid {
            UCSFuncEngine.shared().answer(callid)
        } else {
            // 挂断 无法接听
            UCSFuncEngine.shared().reject(nil)
        }
        
    }
    
    /// 开锁
    @objc func unlockButtonAction(button: UIButton) -> Void {
        swiftDebug("发送开锁")
    }
    
    /// 挂断电话
    @objc func hangupButtonAction(button: UIButton) -> Void {
        swiftDebug("挂断电话")
        // 移除震动
        
        // 移除铃声
        
        // 挂断
        UCSFuncEngine.shared().hangUp(nil)
                
        self.perform(#selector(dismissVC), with: nil, afterDelay: 5.0)
    }
    
    /// 扬声器
    @objc func speakerButtonAction(button: UIButton) -> Void {
        swiftDebug("扬声器")
        if UCSFuncEngine.shared().isSpeakerphoneOn() == true {
            UCSFuncEngine.shared().setSpeakerphone(false)
            self.speakerButton.isSelected = false
            swiftDebug("关闭免提")
        } else {
            UCSFuncEngine.shared().setSpeakerphone(true)
            self.speakerButton.isSelected = true
            swiftDebug("打开免提")
        }
    }
    
}

extension UCSVideoCloudCallVC: UCSEngineUIDelegate {
    
}


extension UCSVideoCloudCallVC {
    /// 设置子控件
    private func setupSubViews() -> Void {
        self.view.addSubview(self.headerImageView)
        self.view.addSubview(self.stateLabel)
        self.view.addSubview(self.marqueeView)
        self.view.addSubview(self.previewImageView)
        self.view.addSubview(self.buttonListView)
        
        self.headerImageView.translatesAutoresizingMaskIntoConstraints = false
        self.stateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.marqueeView.translatesAutoresizingMaskIntoConstraints = false
        self.previewImageView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonListView.translatesAutoresizingMaskIntoConstraints = false
                        
                
        self.buttonListView.addArrangedSubview(self.microButton)
        self.buttonListView.addArrangedSubview(self.answerButton)
        self.buttonListView.addArrangedSubview(self.unlockButton)
        self.buttonListView.addArrangedSubview(self.hangupButton)
        self.buttonListView.addArrangedSubview(self.speakerButton)
        
        // 顶部
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.headerImageView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0), // 水平居中
            NSLayoutConstraint(item: self.headerImageView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 100.0), // 宽度
            NSLayoutConstraint(item: self.headerImageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: 100.0), // 高度
            NSLayoutConstraint(item: self.headerImageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 80.0), // 顶部
        ])
        // 状态
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.stateLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0), // 水平居中
            NSLayoutConstraint(item: self.stateLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 188.0), // 顶部
            NSLayoutConstraint(item: self.stateLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: 30.0), // 高度
        ])
        // 字符串滚动
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.marqueeView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0), // 水平居中
            NSLayoutConstraint(item: self.marqueeView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: 40.0), // 高度
            NSLayoutConstraint(item: self.marqueeView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 120.0), // 宽度
            NSLayoutConstraint(item: self.marqueeView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.stateLabel, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0), // 顶部
        ])
        // 预览
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.previewImageView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1.0, constant: 0), // 左边
            NSLayoutConstraint(item: self.previewImageView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: 0), // 右边
            NSLayoutConstraint(item: self.previewImageView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.buttonListView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: -8.0), // 底部
            NSLayoutConstraint(item: self.previewImageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.marqueeView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 8.0), // 顶部
        ])
        self.buttonsWidthCon = NSLayoutConstraint(item: self.buttonListView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 250.0) // 宽度
        // 设置标签
        self.buttonsWidthCon.identifier = "buttonsWidthCon"
        // 按钮列表
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.buttonListView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: -60.0), // 底部
            NSLayoutConstraint(item: self.buttonListView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0), // 水平居中
            NSLayoutConstraint(item: self.buttonListView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: 50.0),// 高度
            self.buttonsWidthCon, // 宽度
        ])
    }
    
    /// 更新stackview的约束
    private func updateSubViews(width: CGFloat) -> Void {
//        NSLayoutConstraint.deactivate(
//            [NSLayoutConstraint(item: self.buttonListView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: old)
//        ])
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: self.buttonListView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: new)
//        ])
        // 更新约束
        //self.buttonListView.updateConstraints()
        //self.buttonListView.needsUpdateConstraints()
        
//        let associatedConstraints = self.buttonListView.constraints.filter {
//            $0.identifier == "buttonsWidthCon"
//        }
//        NSLayoutConstraint.deactivate(associatedConstraints)
//        self.buttonListView.removeConstraint(associatedConstraints.first!)
//
//        self.buttonsWidthCon = NSLayoutConstraint(item: self.buttonListView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: width)// 高度
//        // 设置标签
//        self.buttonsWidthCon.identifier = "buttonsWidthCon"
//        self.buttonsWidthCon.isActive = true
////        NSLayoutConstraint.activate([
////            self.buttonsWidthCon
////        ])
//
//        self.buttonListView.addConstraint(self.buttonsWidthCon)
//
//        self.buttonListView.layoutIfNeeded()
     
        
        self.buttonsWidthCon.constant = width
    }
}


/// 云对讲按钮
class CloudCallButton: UIButton {
 
//    override public var intrinsicContentSize: CGSize {
//        get {
//            //...
//            return CGSize(width: 50.0, height: 50.0)
//        }
//    }
    
    /// 防止变形设置按钮
    override public var intrinsicContentSize: CGSize {
        //...
        return CGSize(width: 50.0, height: 50.0)
    }
    
}
