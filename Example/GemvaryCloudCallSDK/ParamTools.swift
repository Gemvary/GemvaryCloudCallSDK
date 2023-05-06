//
//  ParamTools.swift
//  GemvaryCloudCallSDK_Example
//
//  Created by SongMengLong on 2023/4/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

/// 助手
class ParamTools: NSObject {

    /// 云对讲参数
    static let ucsToken = "eyJBbGciOiJIUzI1NiIsIkFjY2lkIjoiM2ViMzUxMmRkZDE3MjA0OGNiOGIxMjMzMGJiNzkyNTAiLCJBcHBpZCI6IjRjMzQzZGFjNDU1MjQ1ZTU2NTQ3MWVkODdkNDhiMTYzIiwiVXNlcmlkIjoiMTc4ODE0MjY1MTAifQ==.+7oXH5WRB+8P4ymQNJfKP3Ea+HNuUiFTULixmmEJ57s="
    
    
}



/// 打印log
func swiftDebug(_ items: Any..., fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
//    #if DEBUG

    guard items.first != nil else {
        return
    }
    
    guard let file = fileName.components(separatedBy: "/").last else {
        return
    }
    
    // 获取当前时间
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale.current
    let convertedDate0 = dateFormatter.string(from: Date())
    
    print("Project: \(convertedDate0) \(file) \(methodName) line:\(lineNumber) \(items)")
//    #endif
}


class GlobalTools: NSObject {

    /// 获取keyWindows
    static func getKeyWindow() -> UIWindow? {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            swiftDebug("获取KeyWindow失败")
            return nil
        }
        return keyWindow
    }
    
    /// 获取根控制器
    static func getRootViewController() -> UIViewController? {
        
        guard let keyWindow = self.getKeyWindow() else {
            return nil
        }
        
        guard let rootViewController = keyWindow.rootViewController else {
            return nil
        }
        
        return rootViewController
    }
    
    
    
    // MARK: 检查麦克风授权
    /// 检查麦克风授权
    @objc class func checkPermissionsForMic() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch authStatus {
        case .notDetermined:
            // 未选择
            return true
        case .authorized:
            // 已授权
            return true
        case .restricted:
            // 不能修改权限
            GlobalTools.showAlertView(message: NSLocalizedString("不能完成麦克风授权,可能开启了访问限制,暂时无法使用云对讲.", comment: ""))
            return false
        case .denied:
            // 显示拒绝
            GlobalTools.showAlertView(message: NSLocalizedString("您已拒绝我们访问麦克风,暂时无法使用云对讲.", comment: ""))
            return false
        default:
            return false
        }
    }
    
    // MARK: 检查相机授权
    @objc class func checkPermissionsForCamera() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .notDetermined:
            // 未选择
            return true
        case .authorized:
            // 已授权
            return true
        case .restricted:
            // 不能修改权限
            GlobalTools.showAlertView(message: NSLocalizedString("不能完成相机授权,可能开启了访问限制,暂时无法使用云对讲.", comment: ""))
            return false
        case .denied:
            // 显示拒绝
            GlobalTools.showAlertView(message: NSLocalizedString("您已拒绝我们访问相机,暂时无法使用云对讲.", comment: ""))
            return false
        }
    }
    
    // MARK: (检查麦克风授权/检查相机授权)弹出提示框
    class func showAlertView(message: String) {
        //
        let alertController = UIAlertController(title: NSLocalizedString("提示", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}
