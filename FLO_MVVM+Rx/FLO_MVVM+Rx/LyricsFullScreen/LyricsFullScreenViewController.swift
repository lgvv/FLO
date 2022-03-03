//
//  LyricsFullScreen.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/03/01.
//

import Foundation
import UIKit
import RxSwift

class LyricsFullScreenViewController: UIViewController {
    let disposeBag = DisposeBag()
    var lyricFullScreenView = LyricsFullScreenView()
    let viewModel: LyricsFullScreenViewModel
    var musicPlayer = MusicPlayer.shared
    
    init(viewModel: LyricsFullScreenViewModel = LyricsFullScreenViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.initializeBind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = lyricFullScreenView
        view.backgroundColor = .white
        lyricFullScreenView.commonInit()
        bind(lyricFullScreenView, viewModel)
    }
}

extension LyricsFullScreenViewController {
    /// 초기화 시 정보를 세팅해주기 위해 사용할 바인딩
    private func initializeBind() {
        viewModel.lyricDriver
            .drive( lyricFullScreenView.lyricsTableView.rx.items(
                cellIdentifier: LyricTableViewCell.identifier,
                cellType: LyricTableViewCell.self)
            ) { index, item, cell in
                cell.setUI(item)
            }
            .disposed(by: disposeBag)
    }
    
    
    private func bind(_ view: LyricsFullScreenView, _ viewModel: LyricsFullScreenViewModel) {
        view.closeButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        view.seekModeButton.rx.tap
            .scan(ButtonState.seekOff) { lastValue, _ in
                switch lastValue {
                case .seekOff: return .seekOn
                case .seekOn: return .seekOff
                default: return .seekOff
                }
            }
            .bind(to: viewModel.buttonStateSubject)
            .disposed(by: disposeBag)
        
        viewModel.seekButtonDriver
            .drive(view.seekModeButton.rx.toggle)
            .disposed(by: disposeBag)
        
        view.lyricsTableView.rx.modelSelected(LyricModel.self)
            .filter { _ in
                let title = view.seekModeButton.titleLabel!.text
                if title == "SEEK MODE ON" {
                    return true
                } else {
                    self.dismiss(animated: true)
                    return false
                }
            }
            .bind(to: viewModel.selectLyricModel)
            .disposed(by: disposeBag)
        
        viewModel.musicSyncDriver
            .drive { [weak self] in
                self?.musicPlayer.player.seek(to: $0)
            }
            .disposed(by: disposeBag)
    }
}

extension LyricsFullScreenViewController {
    func setVM(_ data: Music) {
        viewModel.musicInfoSubject.onNext(data)
        viewModel.currentTimeSubject.onNext(0)
    }
}

