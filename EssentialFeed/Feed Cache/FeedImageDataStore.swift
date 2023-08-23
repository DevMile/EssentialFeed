//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 23.8.23..
//

import Foundation

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
