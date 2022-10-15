//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 15.10.22..
//

import Foundation

// Representation of the FeedItem to decouple it from the FeedFeature module. This is called DTO object
struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
