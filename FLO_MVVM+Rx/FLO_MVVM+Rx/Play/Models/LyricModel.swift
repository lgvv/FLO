//
//  LyricModel.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/26.
//

import Foundation

struct LyricModel {
    private var timeString: String
    var lyric: String
    var isHighlight: Bool
    
    // ex: 01:14:300
    var timeDouble: Double {
        let timeArray = timeString.components(separatedBy: ":")
        var min: Double = Double(timeArray[0]) ?? 0.0
        let sec: Double = Double(timeArray[1]) ?? 0.0
        var msec: Double = Double(timeArray[2]) ?? 0.0
        min = min * 60.0
        msec = msec / 1000.0
        print("😷 timeArray \(timeArray)")
        print("😷\(min) \(sec) \(msec)")
        return (min + sec + msec)
    }
    
    init(
        timeString: String,
        lyric: String,
        isHighlight: Bool = false
        
    ) {
        self.timeString = timeString
        self.lyric = lyric
        self.isHighlight = isHighlight
    }
}
