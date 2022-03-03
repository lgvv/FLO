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
import RxGesture
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
    /// 가사의 클릭시 이동할 뷰 컨트롤러
    let vc = LyricsFullScreenViewController()
    
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
                view.setUI($0)
                self?.musicPlayer.initPlayer(url: $0.file)
                self?.musicPlayer.duration = Double($0.duration)
                self?.vc.setVM($0)
            }
            .disposed(by: disposeBag)
    
        view.playButton.rx.tap
            .scan(ButtonState.pause) { lastValue, _ in
                switch lastValue {
                case .pause: return .play
                case .play: return .pause
                default: return .pause
                }
            }
            .bind { [weak self] in
                viewModel.buttonStateSubject.onNext($0)
                self?.musicPlayer.controlPlayer($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.musicPlayDriver
            .asObservable()
            .bind(to: view.playButton.rx.toggle)
            .disposed(by: disposeBag)
        
        view.seekBar.rx.value
            .bind { [weak self] in
                let time = CMTime(seconds: Double($0), preferredTimescale: 1000000)
                self?.musicPlayer.player.seek(to: time)
                viewModel.playerCurrentTimeSubject.onNext(Double($0))
            }
            .disposed(by: disposeBag)
        
        // touchUpInside는 터치가 끝나고 나갈 때 발생한다.
        // touchDown이 터치가 들어갈 때 발생한다.
        view.seekBar.rx.controlEvent([.touchDown, .touchUpInside])
            .map { [weak self] in
                self!.isSeeking
            }
            .bind(to: viewModel.seekStateSubject)
            .disposed(by: disposeBag)
        
        viewModel.seekStateDriver
            .drive { [weak self] in
                self?.isSeeking = $0
            }
            .disposed(by: disposeBag)
        
        viewModel.lyricLabelDriver
            .drive { [weak self] data in
                self?.vc.viewModel.currentTimeSubject.onNext(data[0].timeDouble)
                view.lyricsLabel.text = "\(data[0].lyric)"
            }
            .disposed(by: disposeBag)
        
        view.lyricsLabel.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                self?.present(self!.vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        
    }
    
    func setObserver() {
        timeObserver = self.musicPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 10),
            queue: DispatchQueue.main) { time in // 코드의 가독성을 위해 time 명시
                self.updateTime(time: time)
                self.endPlayer(time: time)
            }
    }
    
    func updateTime(time: CMTime) {
        if isSeeking == false {
            let currentTime = time.seconds
            musicPlayView.seekBar.value = Float(currentTime)
            
            // viewModel로 현재 플레이 되는 시간 전송하는 로직
            self.musicPlayViewModel.playerCurrentTimeSubject.onNext(currentTime)
            
            // 전체 가사쪽으로 현재 플레이되는 시간 넘겨주고 거기서 하이라이트 처리하자.
            vc.viewModel.currentTimeSubject.onNext(currentTime)
        }
    }
    
    func endPlayer(time: CMTime) {
        if time.seconds >= musicPlayer.duration {
            self.musicPlayViewModel.buttonStateSubject.onNext(ButtonState.pause)
        }
    }
}

