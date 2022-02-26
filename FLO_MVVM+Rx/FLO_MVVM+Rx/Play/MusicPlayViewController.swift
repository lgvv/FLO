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

class MusicPlayViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    var musicPlayView = MusicPlayView()
    var musicPlayViewModel = MusicPlayViewModel()
    
    override func loadView() {
        view = musicPlayView
        musicPlayView.commonInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(musicPlayViewModel, musicPlayView)
    }
}

extension MusicPlayViewController {
    func bind(_ viewModel: MusicPlayViewModel, _ view: MusicPlayView) {
        
        musicPlayViewModel.musicDriver
            .drive {
                view.titleLabel.text = $0.title
                view.signerLabel.text = $0.singer
                view.albumLabel.text = $0.album
                view.albumImage.kf.setImage(with: $0.imageURL)
            }
            .disposed(by: disposeBag)
        
        musicPlayViewModel.musicLyricsDriver
            .asObservable()
            .bind { data in
                view.lyricsLabel.text = "\(data[0].lyric)\n\(data[1].lyric)"
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
            .bind(to: viewModel.buttonStateSubject)
            .disposed(by: disposeBag)
        
        viewModel.buttonStateSubject
            .asObservable()
            .debug("🟠")
            .bind(to: view.playButton.rx.toggle)
            .disposed(by: disposeBag)
        
        // TODO: viewModel로 value정보 보내서 가사 시간 계산해야 함.
        view.seekBar.rx.value
            .bind { print("😃 \($0)") }
            .disposed(by: disposeBag)
    }
}
