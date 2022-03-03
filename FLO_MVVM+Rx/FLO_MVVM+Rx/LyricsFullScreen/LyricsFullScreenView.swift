//
//  LyricsFullScreenView.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/03/01.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

class LyricsFullScreenView: UIView {
    var closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close"), for: .normal)
    }
    var lyricsTableView = UITableView().then {
        $0.register(LyricTableViewCell.self, forCellReuseIdentifier: LyricTableViewCell.identifier)
        $0.backgroundColor = .red
        $0.separatorStyle = .none
    }
    
    var seekModeButton = UIButton().then {
        $0.setTitle("SEEK MODE OFF", for: .normal)
        $0.backgroundColor = .darkGray
    }
}

extension LyricsFullScreenView {
    
    func commonInit() {
        setupViews()
    }
    
    private func setupViews() {
        [closeButton, lyricsTableView, seekModeButton].forEach { addSubview($0) }
        
        let verticalSpacing = 10 // 세로 간격
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(21)
            $0.height.equalTo(21)
        }
        
        seekModeButton.snp.makeConstraints {
            $0.centerY.equalTo(closeButton.snp.centerY)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-30)
        }
        
        lyricsTableView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(verticalSpacing)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
