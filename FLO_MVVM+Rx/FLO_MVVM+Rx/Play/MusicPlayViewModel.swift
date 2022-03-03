//
//  MusicViewModel.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/25.
//

import Foundation

import RxCocoa
import RxSwift
import CoreMedia

class MusicPlayViewModel {
    private let disposeBag = DisposeBag()
    
    // input: View -> ViewModel
    let buttonStateSubject = PublishSubject<ButtonState>()
    let seekStateSubject = PublishSubject<Bool>()
    let playerCurrentTimeSubject = PublishSubject<Double>()
    
    // output: ViewModel -> View
    let initMusicInfoDriver: Driver<Music>
    let musicPlayDriver: Driver<ButtonState>
    let seekStateDriver: Driver<Bool>
    let lyricTimeDriver: Driver<Double>
    let lyricLabelDriver: Driver<[LyricModel]>
    
    init(api: MusicAPIManager = MusicAPIManager()) {
        
        let dataResultSubject = PublishSubject<Music>()
        
        api.request { music in
            dataResultSubject.onNext(music)
        }
        
        initMusicInfoDriver = dataResultSubject
            .asObservable()
            .asDriver(onErrorJustReturn: Music.empty)
        
        // 현재 player가 play하는 시간(Double type)
        let currentPlayTime = playerCurrentTimeSubject
            .asObservable()
        
        musicPlayDriver = buttonStateSubject
            .asDriver(onErrorJustReturn: .pause)
            
        seekStateDriver = seekStateSubject
            .asObservable()
            .map { !$0 } // 상태값 반대로 변경
            .asDriver(onErrorJustReturn: false)
        
        lyricTimeDriver = currentPlayTime
            .asDriver(onErrorJustReturn: 0.0)
        
        /// [00:00:000] -> 00:00:000 으로 변환합니다.
        let lyricModels = dataResultSubject
            .asObservable()
            .map { $0.lyrics.components(separatedBy: "\n") }
            .map { lyrics -> [LyricModel] in
                // 코드의 축약 vs 가독성 -> 가독성 챙기기로.
                var result = [LyricModel]()
                _ = lyrics.map {
                    var data = $0.components(separatedBy: "]")
                    data[0].removeFirst() // "[" 문자 제거
                    let model = LyricModel(timeString: data[0], lyric: data[1])
                    result.append(model)
                }
                return result
            }
        
        let updateLyricsLabel = Observable.combineLatest(lyricModels, currentPlayTime) { lyrics, time -> [LyricModel] in
            /// LyricLabelLines의 값 변수
            let numberOfLyricLabelLines: Int = 1
            
            // 추후에 여러줄을 보여줄 수도 있어서 이렇게 방출
            var answer = [LyricModel]()
            for index in 1...lyrics.count {
                var index = index
                if answer.count >= numberOfLyricLabelLines { break }
                
                if index >= lyrics.count { index -= 1 }
                
                if lyrics[index].timeDouble >= time {
                    answer.append(lyrics[index-1])
                }
            }
            
            // 마지막에 한번 실행되어야 한다.
            if answer.count == 0 {
                answer.append(lyrics[lyrics.count-1])
            }
            
            return answer
        }
        
        lyricLabelDriver = Observable.of(lyricModels, updateLyricsLabel)
            .merge()
            .asDriver(onErrorJustReturn: [])
    }
}

