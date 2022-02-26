//
//  UIButton+Rx.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/26.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: UIButton {
    public var toggle: Binder<ButtonState> {
        return Binder<ButtonState>(base) { _, state in
            if state == ButtonState.play {
                base.setImage(UIImage(named: "ic_pause.fill"), for: .normal)
            } else {
                base.setImage(UIImage(named: "ic_play.fill"), for: .normal)
            }
        }
    }
}
