//
//  MusicViewModel.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/25.
//

import Foundation

import RxCocoa
import RxSwift

class MusicPlayViewModel {
    private let disposeBag = DisposeBag()
    
    // input: View -> ViewModel
    let buttonStateSubject = PublishSubject<ButtonState>()
    
    // output: ViewModel -> View
    let musicDriver: Driver<Music>
    let musicLyricsDriver: Driver<[LyricModel]>
    let musicPlayDriver: Driver<ButtonState>
    
    init(api: MusicAPIManager = MusicAPIManager()) {
        
        let dataResultSubject = PublishSubject<Music>()
        
        api.request { music in
            dataResultSubject.onNext(music)
        }
        
        musicDriver = dataResultSubject
            .asObservable()
            .asDriver(onErrorJustReturn: Music.empty)
        
        // String -> [String] -> [LyricModel]
        musicLyricsDriver = dataResultSubject
            .asObservable()
            .map { $0.lyrics.components(separatedBy: "\n") }
            .map { lyrics -> [LyricModel] in
                var result = [LyricModel]()
                _ = lyrics.map {
                    var data = $0.components(separatedBy: "]")
                    data[0].removeFirst() // "[" 문자 제거
                    let model = LyricModel(time: data[0], lyric: data[1])
                    result.append(model)
                }
                return result
            }
            .asDriver(onErrorJustReturn: [])
        
        
        // TODO: 버튼 상태에 따라서 이미지 바꿔주기.
        musicPlayDriver = buttonStateSubject
            .asDriver(onErrorJustReturn: .pause)
            
        
    }
}
