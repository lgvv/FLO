//
//  lyricTableViewCell.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

class LyricTableViewCell: UITableViewCell {
    static let identifier = "LyricTableView"
    
    /// 가사
    var lyricLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LyricTableViewCell {
    fileprivate func setupViews() {
        [lyricLabel].forEach { addSubview($0) }
        
        let superViewInset: CGFloat = 9.0
        
        lyricLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(superViewInset)
        }
    }
    
    func setUI(_ item: LyricModel) {
        if item.isHighlight == true {
            lyricLabel.textColor = .black
        } else {
            lyricLabel.textColor = .lightGray
        }
        lyricLabel.text = item.lyric
    }
}
