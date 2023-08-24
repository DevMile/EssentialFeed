//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 24.8.23..
//

import Foundation


public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
