//
//  MusicPlayView.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

class MusicPlayView: UIView {
    /// 앨범 커버 이미지
    lazy var albumImage = UIImageView().then {
        $0.backgroundColor = .blue
    }
    /// 아티스트명
    var signerLabel = UILabel().then {
        $0.backgroundColor = .red
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.text = "아티스트명"
        
    }
    /// 앨범명
    var albumLabel = UILabel().then {
        $0.backgroundColor = .green
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 13, weight: .semibold)
        $0.textColor = .darkGray
        $0.text = "앨범명"
        
    }
    /// 곡명
    var titleLabel = UILabel().then {
        $0.backgroundColor = .cyan
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.text = "곡명"
    }
    
    /// 가사가 나타날 레이블
    var lyricsLabel = UILabel().then {
        $0.backgroundColor = .yellow
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.text = "ad\nasdasdasdsdfsdfsf"
    }
    
    /// UISlider를 사용한 SeekBar
    var seekBar = UISlider().then {
        $0.backgroundColor = .red
    }
    
    /// play/stop 버튼
    var playButton = UIButton().then {
//        $0.backgroundColor = .gray
        $0.setImage(UIImage(named: "ic_play.fill"), for: .normal)
    }
}

extension MusicPlayView {
    func commonInit() {
        setupViews()
    }
    
    fileprivate func setupViews() {
        [albumImage, signerLabel, albumLabel, titleLabel, lyricsLabel, seekBar, playButton]
            .forEach { addSubview($0) }
        
        let verticalSpacing = 10 // 세로 간격
        
        albumImage.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.height.equalTo(albumImage.snp.width)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-UIScreen.main.bounds.height / 12)
        }
        
        signerLabel.snp.makeConstraints {
            $0.width.equalTo(albumImage.snp.width)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(albumImage.snp.top).offset(-verticalSpacing)
        }
        
        albumLabel.snp.makeConstraints {
            $0.width.equalTo(albumImage.snp.width)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(signerLabel.snp.top)
        }
        
        titleLabel.snp.makeConstraints {
            $0.width.equalTo(albumImage.snp.width)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(albumLabel.snp.top)
        }
        
        lyricsLabel.snp.makeConstraints {
            $0.top.equalTo(albumImage.snp.bottom).offset(verticalSpacing)
            $0.width.equalTo(albumImage.snp.width)
            $0.centerX.equalToSuperview()
        }
        
        seekBar.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.centerX.equalToSuperview()
//            $0.top.greaterThanOrEqualTo(1).priority(.low)
            $0.bottom.equalToSuperview().offset(-UIScreen.main.bounds.height / 6)
        }
        
        playButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(seekBar.snp.bottom).offset(verticalSpacing * 2)
            $0.width.height.equalTo(30)
        }
        
        
    }
}

public enum ButtonState {
    case play
    case pause
}
