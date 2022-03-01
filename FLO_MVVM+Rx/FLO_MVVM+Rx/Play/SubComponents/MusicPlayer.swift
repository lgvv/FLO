//
//  MusicPlayer.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/26.
//

// https://developer.apple.com/documentation/avfoundation/avplayer

import AVFoundation

// TODO: MusicPlayer Protocol 만들어서 proxy로 바꾼다음 전부 rx로 사용해볼까?

class MusicPlayer {
    static let shared = MusicPlayer()
    
    let player = AVPlayer()
    
    /// 현재 아이템의 시간
    var currentTime: Double {
        return player.currentItem?.currentTime().seconds ?? 0.0
    }
    /// 현재 아이템의 총 시간 (초)
    var duration: Double {
        return player.currentItem?.duration.seconds ?? 0
    }
    
    func initPlayer(url: String) {
        print("🤐\(url)")
        guard let url = URL(string: url) else {
            print("🟠 url error")
            return
        }
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }
    
    /// play/pause 상태를 확인하는 메소드입니다.
    func controlPlayer(_ state: ButtonState) {
        print("💡\(state)")
        if state == .play {
            player.play()
        } else {
            player.pause()
        }
    }
    
    /// 시간을 찾는 메소드
    func addPeriodicTimeObserver(forInterval: CMTime, queue: DispatchQueue?, using: @escaping (CMTime) -> Void) {
        player.addPeriodicTimeObserver(forInterval: forInterval, queue: queue, using: using)
    }
    
}
