//
//  MusicAPIManager.swift
//  FLO_MVVM+Rx
//
//  Created by Hamlit Jason on 2022/02/25.
//

import Foundation

import Alamofire
import RxSwift

class MusicAPIManager {
    fileprivate let url: String = "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json"
    
    func request(completionHandler: @escaping (Music) -> Void) {
        guard let url = URL(string: self.url) else { return }
        
        AF
            .request(url, method: .get, parameters: nil, headers: nil)
            .responseDecodable(of: Music.self) { response in
                switch response.result {
                case .success(let result):
                    completionHandler(result)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .resume()
    }
    
}
