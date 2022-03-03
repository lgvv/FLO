//
//  LyricsFullScreenViewModel.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/03/02.
//

import Foundation

import RxCocoa
import RxSwift

class LyricsFullScreenViewModel {
    
    let musicInfoSubject = PublishSubject<Music>()
    let currentTimeSubject = PublishSubject<Double>()
    
    let lyricDriver: Driver<[LyricModel]>
    
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
        //
        let currentPlayTime = currentTimeSubject.asObservable()
        
        
        // 업데이트 레이블 만들어서 하나씩 방출하게 하자.
        /*
         내 뒤에가 false이고 나는 true야
         내 뒤에 시간에 다다르면 나를 false로 내 뒤를 true로
         
         */
        let updateLyrics = Observable.combineLatest(lyricModels, currentPlayTime) { lyrics, time -> [LyricModel] in
            
            var result = [LyricModel]()
            
            // 이분탐색으로 변경 가능.
            for i in 0...lyrics.count-1 {
                var current = lyrics[i] // current
                var nextIndex: Int = i+1
                if i == lyrics.count-1 { // 끝에 도달하면
                    nextIndex = lyrics.count-1
                }
                var next = lyrics[nextIndex] // next
                var last = lyrics[lyrics.count-1]
                
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
        //            .debug("🤌this is/")
            .asDriver(onErrorJustReturn: [])
        
    }
    
}
