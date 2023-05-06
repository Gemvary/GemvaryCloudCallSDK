//
//  CloudCallVibrationer.swift
//  Gem_Home
//
//  Created by SongMenglong on 2021/12/13.
//

import UIKit
import AudioToolbox

/// 云对讲震动
class CloudCallVibrationer: NSObject {
    /// 创建单例
    @objc static let instance = CloudCallVibrationer()

    /// 添加震动
    @objc func add() -> Void {
        // 参考网站
        // https://tech.playground.style/swift/audiotoolbox-systemsoundid/
        
        //AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, nil, nil, vibrateCallback, nil)
        
        //let systemSoundID = SystemSoundID(kSystemSoundID_Vibrate)

        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, nil, nil, { (systemSoundID, clientData) -> Void in
            swiftDebug("指针方法:: ", systemSoundID, clientData as Any)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }, nil)
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// 移除震动
    @objc func remove() -> Void {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
    }
}
