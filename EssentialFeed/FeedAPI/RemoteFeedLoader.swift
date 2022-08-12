//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 7.8.22..
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    public typealias Result = LoadFeedResult
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let data, let response):
                completion(FeedItemsMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
