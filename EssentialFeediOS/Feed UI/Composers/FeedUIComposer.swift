//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Milan Bojic on 11.2.23..
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return feedController
    }
    
    // Adapter pattern - mapping [FeedImage] into FeedImageController - we can write also like this:
    // refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
    
//    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
//        return { [weak controller] feed in
//            controller?.tableModel = feed.map { model in
//                FeedImageCellController(model: model, imageLoader: loader)
//            }
//        }
//    }
}
