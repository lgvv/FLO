//
//  MusicPlayViewController.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/25.
//

import Foundation
import UIKit

import Kingfisher
import RxCocoa
import RxSwift

import AVFoundation

class MusicPlayViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    var musicPlayView = MusicPlayView()
    var musicPlayViewModel = MusicPlayViewModel()
    var musicPlayer = MusicPlayer.shared
    
    /// 진행중인 시간 찾는 프로퍼티 - 슬라이더 업데이트 위함.
    var timeObserver: Any?
    /// UISlider seeking 여부 - updateTime 메소드 처리
    var isSeeking: Bool = false
    
    override func loadView() {
        view = musicPlayView
        musicPlayView.commonInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(musicPlayViewModel, musicPlayView)
        setObserver()
    }
}

extension MusicPlayViewController {
    func bind(_ viewModel: MusicPlayViewModel, _ view: MusicPlayView) {
        
        viewModel.initMusicInfoDriver
            .drive { [weak self] in
                // TODO: view쪽에서 UI를 묶자
                view.titleLabel.text = $0.title
                view.signerLabel.text = $0.singer
                view.albumLabel.text = $0.album
                view.albumImage.kf.setImage(with: $0.imageURL)
                
                // TODO: musicPlayer쪽에서 묶자.
                self?.musicPlayer.initPlayer(url: $0.file)
                view.seekBar.maximumValue = Float(Double($0.duration))
                print("✅  seekBar.maximumValue \(view.seekBar.maximumValue)")
            }
            .disposed(by: disposeBag)
    
        view.playButton.rx.tap
            .scan(ButtonState.pause) { lastValue, _ in
                switch lastValue {
                case .pause: return .play
                case .play: return .pause
                }
            }
            .debug("🍎")
            .bind { [weak self] in
                viewModel.buttonStateSubject.onNext($0)
                self?.musicPlayer.controlPlayer($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.musicPlayDriver
            .asObservable()
            .debug("🟠")
            .bind(to: view.playButton.rx.toggle)
            .disposed(by: disposeBag)
        
        view.seekBar.rx.value
            .bind { [weak self] in
                print("😤 \($0)")
                let time = CMTime(seconds: Double($0), preferredTimescale: 1000000)
                self?.musicPlayer.player.seek(to: time)
            }
            .disposed(by: disposeBag)
        
        // touchUpInside는 터치가 끝나고 나갈 때 발생한다.
        // touchDown이 터치가 들어갈 때 발생한다.
        view.seekBar.rx.controlEvent([.touchDown, .touchUpInside])
            .map { [weak self] in
                print(type(of: $0))
                print("😑 \(self!.isSeeking)")
                return self!.isSeeking
            }
            .debug("😨")
            .bind(to: viewModel.seekStateSubject)
            .disposed(by: disposeBag)
        
        viewModel.seekStateDriver
            .asObservable()
            .debug("😮")
            .bind { [weak self] in
                self?.isSeeking = $0
            }
            .disposed(by: disposeBag)
        
        viewModel.lyricLabelDriver
            .asObservable()
            .bind { data in
                view.lyricsLabel.text = "\(data[0])\n\(data[1])"
            }
            .disposed(by: disposeBag)
    }
    
    func setObserver() {
        timeObserver = self.musicPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 10),
            queue: DispatchQueue.main) { time in // 코드의 가독성을 위해 time 명시
                self.updateTime(time: time)
            }
    }
    
    func updateTime(time: CMTime) {
        if isSeeking == false {
            let currentTime = time.seconds
            musicPlayView.seekBar.value = Float(currentTime)
            print("😵‍💫 \(currentTime)")
            // viewModel로 현재 시간 전송하는 로직
            self.musicPlayViewModel.playerCurrentTimeSubject.onNext(currentTime)
        }
    }
}

