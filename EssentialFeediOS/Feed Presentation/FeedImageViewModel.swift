//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Milan Bojic on 12.2.23..
//


import Foundation
import EssentialFeed

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
