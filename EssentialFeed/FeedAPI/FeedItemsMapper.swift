//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 11.8.22..
//

import Foundation

class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200 = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}

// Representation of the FeedItem to decouple it from the FeedFeature module. This is called DTO object
struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
