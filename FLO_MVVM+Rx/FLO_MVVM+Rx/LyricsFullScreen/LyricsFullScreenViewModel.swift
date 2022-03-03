//
//  LyricsFullScreenViewModel.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/03/02.
//

import Foundation
import CoreMedia

import RxCocoa
import RxSwift


class LyricsFullScreenViewModel {
    
    let musicInfoSubject = PublishSubject<Music>()
    let currentTimeSubject = PublishSubject<Double>()
    let buttonStateSubject = PublishSubject<ButtonState>()
    let selectLyricModel = PublishSubject<LyricModel>()
    
    let lyricDriver: Driver<[LyricModel]>
    let seekButtonDriver: Driver<ButtonState>
    let musicSyncDriver: Driver<CMTime>
    
    init() {
        let lyricModels = self.musicInfoSubject
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
        
        let currentPlayTime = currentTimeSubject.asObservable()
        
        let updateLyrics = Observable.combineLatest(lyricModels, currentPlayTime) { lyrics, time -> [LyricModel] in
            
            var result = [LyricModel]()
            
            for i in 0...lyrics.count-1 {
                var current = lyrics[i] // current
                var nextIndex: Int = i+1
                if i == lyrics.count-1 { // 끝에 도달하면
                    nextIndex = lyrics.count-1
                }
                let next = lyrics[nextIndex] // next
                
                if current.timeDouble <= time {
                    if next.timeDouble > time {
                        current.isHighlight = true
                    } else if current.timeDouble == next.timeDouble {
                        if time >= current.timeDouble {
                            current.isHighlight = true
                        }
                    }
                } else {
                    current.isHighlight = false
                }
                result.append(current)
            }
            return result
        }
        
        lyricDriver = updateLyrics.asObservable()
            .asDriver(onErrorJustReturn: [])
        
        seekButtonDriver = buttonStateSubject
            .asDriver(onErrorJustReturn: .seekOff)
        
        musicSyncDriver = selectLyricModel.asObservable()
            .map { lyric -> CMTime in
                let lyricTime = lyric.timeDouble
                return CMTime(seconds: Double(lyricTime), preferredTimescale: 1000000)
            }
            .asDriver(onErrorJustReturn: CMTime.zero)
            
    }
    
}
