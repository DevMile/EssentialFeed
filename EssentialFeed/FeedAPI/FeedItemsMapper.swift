//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 11.8.22..
//

import Foundation

class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            items.map {$0.feedItem}
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static var OK_200 = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return (.failure(RemoteFeedLoader.Error.invalidData))
        }
        
        return .success(root.feed)
    }
}
