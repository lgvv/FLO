//
//  Music.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/25.
//
import Foundation

import RxSwift

// MARK: - Music Model
struct Music: Codable {
    let singer, album, title: String
    let duration: Int
    private let image: String
    let file: String
    let lyrics: String
    
    var imageURL: URL? { URL(string: image) }
    
    init(
        singer: String,
        album:String,
        title:String,
        duration: Int,
        imageURL: String,
        file: String,
        lyrics: String
    ) {
        self.singer = singer
        self.album = album
        self.title = title
        self.duration = duration
        self.image = imageURL
        self.file = file
        self.lyrics = lyrics
    }
}

extension Music {
    static let empty = Music(singer: "", album: "", title: "", duration: -1, imageURL: "", file: "", lyrics: "")
}
