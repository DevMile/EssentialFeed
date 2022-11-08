//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 1.8.22..
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
