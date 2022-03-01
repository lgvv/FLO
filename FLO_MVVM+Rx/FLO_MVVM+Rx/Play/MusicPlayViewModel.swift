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
    let lyricLabelDriver: Driver<[String]>
    
    init(api: MusicAPIManager = MusicAPIManager()) {
        
        let dataResultSubject = PublishSubject<Music>()
        
        api.request { music in
            dataResultSubject.onNext(music)
            print(music)
        }
        
        initMusicInfoDriver = dataResultSubject
            .asObservable()
            .asDriver(onErrorJustReturn: Music.empty)
        
        musicPlayDriver = buttonStateSubject
            .asDriver(onErrorJustReturn: .pause)
            
        seekStateDriver = seekStateSubject
            .asObservable()
            .debug("😦 change seeking state")
            .map { !$0 } // 상태값 반대로 변경
            .asDriver(onErrorJustReturn: false)
        
        lyricTimeDriver = playerCurrentTimeSubject
            .asObservable()
            .debug("😰")
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
        
        /// 초기 상태의 가사
        let initLyricsLabel = lyricModels
            .map { lyrics -> [String] in
                lyrics.map { $0.lyric }
            }
        
        // 현재 player가 play하는 시간(Double type)
        let lyricTime = playerCurrentTimeSubject
            .asObservable()
        
        let updateLyricsLabel = Observable.combineLatest(lyricModels, lyricTime) { lyrics, time -> [String] in
            /// LyricLabelLines의 값 변수
            let numberOfLyricLabelLines: Int = 2
            
            var answer = [String]() // index
            for index in 1...lyrics.count {
                var index = index
                if answer.count >= numberOfLyricLabelLines { break }
                
                if index >= lyrics.count { index -= 1 }
                
                if lyrics[index].timeDouble >= time {
                    answer.append(lyrics[index-1].lyric)
                }
            }
            
            // 마지막에 한번 실행되어야 한다.
            if answer.count == 0 {
                answer.append(lyrics[lyrics.count-2].lyric)
                answer.append(lyrics[lyrics.count-1].lyric)
            }
            
            return answer
        }
        
        lyricLabelDriver = Observable.of(initLyricsLabel, updateLyricsLabel)
            .merge()
            .asDriver(onErrorJustReturn: [])

        
    }
}

