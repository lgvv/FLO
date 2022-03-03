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
            } else if state == ButtonState.pause {
                base.setImage(UIImage(named: "ic_play.fill"), for: .normal)
            } else if state == ButtonState.seekOff {
                base.setTitle("SEEK MODE OFF", for: .normal)
                base.setTitleColor(.gray, for: .normal)
            } else if state == ButtonState.seekOn {
                base.setTitle("SEEK MODE ON", for: .normal)
                base.setTitleColor(.red, for: .normal)
            }
        }
    }
}

public enum ButtonState {
    case play
    case pause
    case seekOn
    case seekOff
}
