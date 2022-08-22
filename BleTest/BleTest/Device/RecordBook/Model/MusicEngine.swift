//
//  MusicEngine.swift
//  IOSApp
//
//  Created by gbt on 2022/7/15.
//

import UIKit
import AVFoundation

class MusicEngine: NSObject {

    //音频引擎单例
    static let shareInstance = MusicEngine()
    var player: AVAudioPlayer?
    
    private override init(){
        //获取音频文件，forResource 参数为工程中的音频文件名，需要为mp3格式
        let path = Bundle.main.path(forResource: "Taylor Swift-《Love Story》", ofType: "mp3")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        player = try! AVAudioPlayer(data: data)
        player?.prepareToPlay()             //进行音频的预加载
        player?.numberOfLoops = -1          //设置音频循环播放次数,设置为0，只播放一次
    }
    
    // MARK: 开始播放
    func playBackgroundMusic(){
        if !player!.isPlaying{
            player?.play()
        }
    }
    
    // MARK: 停止播放
    func stopBackgroundMusic(){
        if player!.isPlaying{
            player?.stop()
        }
    }
    
}
