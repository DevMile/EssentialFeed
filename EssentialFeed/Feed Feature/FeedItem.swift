//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Milan Bojic on 1.8.22..
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
