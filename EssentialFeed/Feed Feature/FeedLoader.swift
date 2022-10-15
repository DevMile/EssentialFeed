//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 1.8.22..
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
