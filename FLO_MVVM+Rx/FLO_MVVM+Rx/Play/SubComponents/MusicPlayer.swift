//
//  MusicPlayer.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/26.
//

// https://developer.apple.com/documentation/avfoundation/avplayer

import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    
    private let player = AVPlayer()
    
    func initPlayer(url: String) {
        print("🤐\(url)")
        guard let url = URL(string: url) else {
            print("🟠 url error")
            return
        }
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }
    
    func controlPlayer(_ state: ButtonState) {
        print("💡\(state)")
        if state == .play {
            player.play()
        } else {
            player.pause()
        }
    }
}
