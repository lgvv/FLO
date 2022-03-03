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
    let disposebag = DisposeBag()
    var lyricFullScreenView = LyricsFullScreenView()
    let viewModel: LyricsFullScreenViewModel
    
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
        view.backgroundColor = .red
        lyricFullScreenView.commonInit()
        
        bind(lyricFullScreenView, viewModel)
    }
}

extension LyricsFullScreenViewController {
    /// 초기화 시 정보를 세팅해주기 위해 사용할 바인딩
    private func initializeBind() {
        print("initializeBind")
        viewModel.lyricDriver
            .asObservable()
            .bind(to: lyricFullScreenView.lyricsTableView.rx.items(
                cellIdentifier: LyricTableViewCell.identifier,
                cellType: LyricTableViewCell.self)
            ) { index, item, cell in
                print("item \(item)")
                if item.isHighlight == true {
                    cell.lyricLabel.backgroundColor = .blue
                } else {
                    cell.lyricLabel.backgroundColor = .green
                }
                cell.lyricLabel.text = item.lyric
            }
            .disposed(by: disposebag)
    }
    
    
    private func bind(_ view: LyricsFullScreenView, _ viewModel: LyricsFullScreenViewModel) {
        view.closeButton.rx.tap
            .bind {
                self.dismiss(animated: true)
            }
            .disposed(by: disposebag)
    }
}
