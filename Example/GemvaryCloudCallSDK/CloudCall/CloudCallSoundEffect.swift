//
//  CloudCallSoundEffect.swift
//  Gem_Home
//
//  Created by SongMenglong on 2021/12/13.
//

import UIKit
import AudioToolbox

/// 铃声
class CloudCallSoundEffect: NSObject {
    /// 创建单例
    @objc static let instance = CloudCallSoundEffect()
    /// 铃声ID
    private var soundID: SystemSoundID = SystemSoundID()
    /// 创建定时器
    private lazy var timer: DispatchSourceTimer = {
        // 创建定时器
        //let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
                
        return timer
    }()
    
    
    /// 移除铃声
    @objc func remove() -> Void {
        // 定时器移除
        self.timer.cancel()
        //self.timer.suspend()
        swiftDebug("取消循环铃声")
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesDisposeSystemSoundID(self.soundID)
        //self.timer = nil
    }
    
    /// 播放铃声
    @objc func play() -> Void {
        // 获取铃声路径
        if let path = Bundle.main.path(forResource: "ring", ofType: "caf") {
            let url: CFURL = URL(fileURLWithPath: path) as CFURL
            // 创建一个音频文件的播放系统声音服务器
            let error = AudioServicesCreateSystemSoundID(url, &self.soundID)
            if error != kAudioServicesNoError {
                swiftDebug("不能正常播放")
            }
        }
        
        // 创建定时器
        // 当次数为小于等于0 返回
        //let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        var count = 0//repeatCount
        
        self.timer.schedule(wallDeadline: DispatchWallTime.now(), repeating: 1) // timeInterval
        self.timer.setEventHandler(handler: {
            count -= 1
            DispatchQueue.main.async {
                //handler(timer, count)
                // 处理内容
                AudioServicesPlaySystemSound(self.soundID)
                swiftDebug("循环播放铃声")
            }
            if count == 0 {
                //self.timer.cancel()
            }
        })
        //if self.timer.isCancelled {
        swiftDebug("", self.timer.isCancelled)
            // 开始定时器
            //self.timer.resume()
        //}
        
        swiftDebug("开始播放铃声")
    }
            
    /// 循环铃声
    @objc func loopPlaySoundEffect() -> Void {
        AudioServicesPlaySystemSound(self.soundID)
    }
    
}
