//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 24.8.23..
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
